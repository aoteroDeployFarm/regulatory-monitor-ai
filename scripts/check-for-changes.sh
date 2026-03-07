#!/bin/bash

PROJECT_ID="regulatory-monitor-ai-agentic"
SOURCE_ID="${1:-alabama-0}"
NEW_HASH="${2:-dummy_hash}" 
CONTENT_BODY="${3:-No content captured}" 

# 🎯 DYNAMIC TABLE SELECTION
# If BQ_TABLE is set as an env var, use it. Otherwise, default to the original table.
# Format: dataset.table_name
TARGET_TABLE="${BQ_TABLE:-regulatory_monitor.raw_scrapes}"

echo "--------------------------------------------------------"
echo "🔍 CHANGE DETECTION: $SOURCE_ID"
echo "📊 TARGET TABLE: $TARGET_TABLE"
echo "--------------------------------------------------------"

# 1. Query the last hash from the TARGET table
RESULT=$(bq query --project_id=$PROJECT_ID --use_legacy_sql=false --format=csv --quiet "
  SELECT content_hash 
  FROM \`$PROJECT_ID.$TARGET_TABLE\`
  WHERE source_id = '$SOURCE_ID'
  ORDER BY scraped_at DESC
  LIMIT 1
" | sed -n '2p' | tr -d '\r')

# 2. Determine Status
if [ -z "$RESULT" ]; then
    STATUS="FIRST_RUN"
elif [ "$RESULT" == "$NEW_HASH" ]; then
    STATUS="NO_CHANGE"
else
    STATUS="CHANGE_DETECTED"
fi

# 3. IF CHANGED: Save to BigQuery
if [ "$STATUS" != "NO_CHANGE" ]; then
    echo "🚀 $STATUS: Committing to BigQuery..."
    
    TEMP_JSON=$(mktemp)
    
    # Updated JQ to include category and jurisdiction if you want to pass them
    # For now, keeping the core fields to match your table schema
    jq -n -c \
      --arg sid "$SOURCE_ID" \
      --arg hash "$NEW_HASH" \
      --arg body "$CONTENT_BODY" \
      --arg time "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
      '{source_id: $sid, content_hash: $hash, raw_content: $body, scraped_at: $time}' > "$TEMP_JSON"

    # Execute insert using the dynamic TARGET_TABLE variable
    BQ_ERROR=$(bq insert "$PROJECT_ID:$TARGET_TABLE" "$TEMP_JSON" 2>&1)
    
    if [ $? -eq 0 ]; then
        echo "✅ BigQuery Insert Successful into $TARGET_TABLE."
        export SOURCE_ID="$SOURCE_ID"
        bash "$(dirname "$0")/analyze-baseline.sh"
    else
        echo "❌ BigQuery Insert FAILED!"
        echo "📝 Error Detail: $BQ_ERROR"
        echo "📄 JSON Preview: $(head -c 150 "$TEMP_JSON")..."
    fi
    
    rm "$TEMP_JSON"
else
    echo "💤 NO_CHANGE: Skipping BigQuery and AI."
fi
echo "--------------------------------------------------------"