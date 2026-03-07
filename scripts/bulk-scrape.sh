#!/bin/bash

# Configuration
PROJECT_ID="regulatory-monitor-ai-agentic"
SCRAPER_URL="http://localhost:8080/scrape"

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_SITES_FILE="/app/packages/configs/sites.json"

# --- Cloud Parallelism Logic ---
TASK_INDEX=${CLOUD_RUN_TASK_INDEX:-0}
TASK_COUNT=${CLOUD_RUN_TASK_COUNT:-1}

ARG_INPUT=$1

# 1. Determine Logic: Is it a filename or a filter?
if [[ "$ARG_INPUT" == *.json ]]; then
    SITES_FILE="/app/packages/configs/$ARG_INPUT"
    FILTER_TERM=""
    echo "📂 Mode: Direct File Load ($ARG_INPUT)"
else
    SITES_FILE="$DEFAULT_SITES_FILE"
    FILTER_TERM="$ARG_INPUT"
    echo "🔍 Mode: Filtered Search (Term: ${FILTER_TERM:-NONE})"
fi

echo "--------------------------------------------------------"
echo "🚀 TASK $TASK_INDEX of $TASK_COUNT | File: $(basename $SITES_FILE)"
echo "--------------------------------------------------------"

if [ ! -f "$SITES_FILE" ]; then
    echo "❌ Error: Config file not found at $SITES_FILE"
    exit 1
fi

# 2. Extract IDs from the chosen file
if [ -n "$FILTER_TERM" ]; then
    ALL_IDS=$(jq -r ".[].id | select(contains(\"$FILTER_TERM\"))" "$SITES_FILE")
else
    ALL_IDS=$(jq -r ".[].id" "$SITES_FILE")
fi

# 3. Parallel Slicing
MY_IDS=$(echo "$ALL_IDS" | awk -v t_idx="$TASK_INDEX" -v t_count="$TASK_COUNT" \
    '{ if ((NR-1) % t_count == t_idx) print $1 }')

MY_COUNT=$(echo "$MY_IDS" | wc -w)
TOTAL_MATCHED=$(echo "$ALL_IDS" | wc -w)

echo "🔍 Assigned $MY_COUNT out of $TOTAL_MATCHED sites to this task."

if [ "$MY_COUNT" -eq 0 ]; then
    echo "⚠️ No sites found to process. Exiting."
    exit 0
fi

# 4. Execution Loop
for ID in $MY_IDS; do
    echo "📡 [Task $TASK_INDEX] Scraping $ID..."
    RESPONSE=$(curl -s "$SCRAPER_URL/$ID")
    
    SUCCESS=$(echo "$RESPONSE" | jq -r '.success // false')
    NEW_HASH=$(echo "$RESPONSE" | jq -r '.hash // "null"')
    CONTENT=$(echo "$RESPONSE" | jq -r '.contentSnippet // ""')

    if [ "$SUCCESS" == "true" ] && [ "$NEW_HASH" != "null" ]; then
        echo "✅ $ID: Scraped successfully."
        bash "$SCRIPT_DIR/check-for-changes.sh" "$ID" "$NEW_HASH" "$CONTENT"
    else
        ERROR_MSG=$(echo "$RESPONSE" | jq -r '.error // "Unknown error"')
        echo "❌ $ID: Failed. Reason: $ERROR_MSG"
    fi
    sleep 1
done

echo "🏁 Task $TASK_INDEX Complete."