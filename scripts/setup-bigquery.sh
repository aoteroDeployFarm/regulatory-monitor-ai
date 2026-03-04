#!/bin/bash

# Project Configuration
PROJECT_ID="regulatory-monitor-ai-agentic"
REGION="us-central1" 

echo "--------------------------------------------------------"
echo "🏗️  REGULATORY MONITOR AI: INFRASTRUCTURE SETUP (2026 Edition)"
echo "--------------------------------------------------------"

# 1. Dataset & Table (us-central1)
echo "📁 Ensuring Dataset & Table in $REGION..."
bq --project_id=$PROJECT_ID mk --if_exists --dataset --location=$REGION regulatory_monitor
bq --project_id=$PROJECT_ID mk --if_exists --table regulatory_monitor.raw_scrapes \
source_id:STRING,jurisdiction:STRING,url:STRING,content:STRING,content_hash:STRING,scraped_at:TIMESTAMP

# 2. Connection
echo "🔗 Verifying Cloud Resource Connection..."
if bq show --connection --location=$REGION --project_id=$PROJECT_ID gemini_connection > /dev/null 2>&1; then
  echo "✅ Connection already exists."
else
  bq mk --connection --location=$REGION --project_id=$PROJECT_ID \
    --connection_type=CLOUD_RESOURCE gemini_connection
fi

# 3. Extract Service Account & IAM Pause
SA_ID=$(bq show --connection --project_id=$PROJECT_ID --location=$REGION gemini_connection | grep -oE "bqcx-[0-9]+-[a-z0-9]+@gcp-sa-bigquery-condel\.iam\.gserviceaccount\.com")

echo "--------------------------------------------------------"
echo "🛑 FINAL IAM CHECK FOR 2026 MODELS"
echo "--------------------------------------------------------"
echo "SA ID: $SA_ID"
echo "Ensure this SA has these TWO roles in IAM:"
echo " 1. Vertex AI User"
echo " 2. Service Usage Consumer"
echo "--------------------------------------------------------"
read -p "Press [Enter] AFTER permissions are saved to initialize the Gemini 2.0 Brain..."

# 4. Initialize Gemini Model (Using 2.0 Flash for 2026 compatibility)
echo "🧠 Initializing Gemini 2.0 Flash Model..."
bq --project_id=$PROJECT_ID query --use_legacy_sql=false "
  CREATE OR REPLACE MODEL \`regulatory_monitor.gemini_flash\`
    REMOTE WITH CONNECTION \`$PROJECT_ID.$REGION.gemini_connection\`
    OPTIONS (ENDPOINT = 'gemini-2.0-flash');
"

if [ $? -eq 0 ]; then
    echo "--------------------------------------------------------"
    echo "✅ SUCCESS: Your AI Data Warehouse is live with Gemini 2.0!"
    echo "--------------------------------------------------------"
else
    echo "❌ STILL 404? Final manual check required:"
    echo "Go to https://console.cloud.google.com/vertex-ai/model-garden"
    echo "Search for 'Gemini 2.0 Flash' and click 'Enable' or 'Open' to accept terms."
fi