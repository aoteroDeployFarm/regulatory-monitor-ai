#!/bin/bash

PROJECT_ID="regulatory-monitor-ai-agentic"

# This uses the first argument passed to the script, defaulting to alabama-0
SOURCE_ID="${1:-alabama-0}"

# Ensures the script finds analyze-baseline.sh regardless of execution directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "--------------------------------------------------------"
echo "🔍 CHANGE DETECTION: $SOURCE_ID"
echo "--------------------------------------------------------"

# Query the two most recent hashes for the SPECIFIC source_id
RESULT=$(bq query --project_id=$PROJECT_ID --use_legacy_sql=false --format=csv --quiet "
  WITH last_two AS (
    SELECT content_hash, scraped_at
    FROM \`$PROJECT_ID.regulatory_monitor.raw_scrapes\`
    WHERE source_id = '$SOURCE_ID'
    ORDER BY scraped_at DESC
    LIMIT 2
  )
  SELECT 
    CASE 
      WHEN (SELECT COUNT(*) FROM last_two) < 2 THEN 'FIRST_RUN'
      WHEN (SELECT content_hash FROM last_two LIMIT 1) = (SELECT content_hash FROM last_two LIMIT 1 OFFSET 1) THEN 'NO_CHANGE'
      ELSE 'CHANGE_DETECTED'
    END AS status
" | tail -n 1)

if [ "$RESULT" == "CHANGE_DETECTED" ] || [ "$RESULT" == "FIRST_RUN" ]; then
    echo "🚀 $RESULT: Triggering Gemini Analysis..."
    # We pass the SOURCE_ID into the analysis script as well
    export SOURCE_ID="$SOURCE_ID"
    bash "$SCRIPT_DIR/analyze-baseline.sh"
else
    echo "💤 NO_CHANGE: Content hash matches. Skipping AI analysis."
fi

echo "--------------------------------------------------------"