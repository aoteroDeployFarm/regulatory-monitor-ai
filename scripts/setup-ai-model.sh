#!/bin/bash

PROJECT_ID="regulatory-monitor-ai-agentic"

echo "--------------------------------------------------------"
echo "🤖 CREATING GEMINI MODEL IN BIGQUERY"
echo "--------------------------------------------------------"

# Using gemini-2.5-pro for stable reasoning and long-context support
bq query --project_id=$PROJECT_ID --use_legacy_sql=false "
  CREATE OR REPLACE MODEL \`regulatory_monitor.gemini_2_pro\`
  REMOTE WITH CONNECTION \`us-central1.gemini_connection\`
  OPTIONS(ENDPOINT = 'gemini-2.5-pro');
"

echo "--------------------------------------------------------"
echo "✅ Model Created Successfully."