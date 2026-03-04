#!/bin/bash

# Configuration
PROJECT_ID="regulatory-monitor-ai-agentic"
DATASET="regulatory_monitor"
TABLE="raw_scrapes"

echo "--------------------------------------------------------"
echo "🔍 VERIFYING LATEST SCRAPE DATA"
echo "--------------------------------------------------------"

# The SQL query you provided, wrapped in the bq command
# We use --use_legacy_sql=false to ensure Standard SQL (2026 default)
bq query --project_id=$PROJECT_ID --use_legacy_sql=false "
  SELECT 
    source_id, 
    jurisdiction, 
    scraped_at, 
    LEFT(content, 100) as content_snippet 
  FROM 
    \`$PROJECT_ID.$DATASET.$TABLE\`
  WHERE 
    source_id = 'alaska-0' 
  ORDER BY 
    scraped_at DESC 
  LIMIT 1;
"

echo "--------------------------------------------------------"
echo "✅ Verification Query Complete."