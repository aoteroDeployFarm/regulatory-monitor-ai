#!/bin/bash

# Configuration
PROJECT_ID="regulatory-monitor-ai-agentic"
SCRAPER_URL="http://localhost:8080/scrape"

# Dynamic Path Discovery: Finds sites.json in packages/configs/
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SITES_FILE="$SCRIPT_DIR/../packages/configs/sites.json"

# Check if a state filter was provided (e.g., ./bulk-scrape.sh alabama)
STATE_FILTER=$1

echo "--------------------------------------------------------"
echo "🚀 STARTING BULK REGULATORY MONITOR"
echo "--------------------------------------------------------"

if [ ! -f "$SITES_FILE" ]; then
    echo "❌ Error: sites.json not found at $SITES_FILE"
    exit 1
fi

# Extract IDs from sites.json using jq
if [ -n "$STATE_FILTER" ]; then
    echo "🔍 Filtering for: $STATE_FILTER"
    IDS=$(jq -r ".[] | select(.id | startswith(\"$STATE_FILTER\")) | .id" "$SITES_FILE")
else
    echo "🌍 Processing all 560+ sites..."
    IDS=$(jq -r ".[].id" "$SITES_FILE")
fi

for ID in $IDS; do
    echo "--------------------------------------------------------"
    echo "📡 STEP 1: Scraping $ID..."
    
    # Trigger the local Playwright scraper
    RESPONSE=$(curl -s "$SCRAPER_URL/$ID")
    
    if [[ "$RESPONSE" == *"Success"* ]]; then
        echo "✅ Scrape Successful."
        
        # STEP 2: Trigger Change Detection & AI Analysis
        # We pass the ID as the first argument ($1) to the script
        bash "$SCRIPT_DIR/check-for-changes.sh" "$ID"
    else
        echo "❌ Scrape Failed for $ID. Skipping AI analysis."
    fi
    
    # Polite 'jitter' to prevent IP blocking
    sleep 1
done

echo "--------------------------------------------------------"
echo "🏁 BULK PROCESS COMPLETE"
echo "--------------------------------------------------------"