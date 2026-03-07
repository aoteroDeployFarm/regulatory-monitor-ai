#!/bin/bash

PROJECT_ID="regulatory-monitor-ai-agentic"
REGION="us-central1"

echo "------------------------------------------------"
echo "🗓️ Deploying Cloud Scheduler Triggers"
echo "------------------------------------------------"

# 1. Nightly Regulatory Sweep (Original Table)
gcloud scheduler jobs create http nightly-regulatory-sweep \
  --location=$REGION \
  --schedule="0 2 * * *" \
  --uri="https://$REGION-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/$PROJECT_ID/jobs/bulk-scraper-job:run" \
  --http-method=POST \
  --oauth-service-account-email=$PROJECT_ID@appspot.gserviceaccount.com \
  --message-body='{"overrides": {"containerOverrides": [{"args": ["hawaii"]}]}}' \
  --time-zone="America/Denver"

# 2. Nightly Property Management Sweep (New Table)
gcloud scheduler jobs create http nightly-property-sweep \
  --location=$REGION \
  --schedule="0 4 * * *" \
  --uri="https://$REGION-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/$PROJECT_ID/jobs/bulk-scraper-job:run" \
  --http-method=POST \
  --oauth-service-account-email=$PROJECT_ID@appspot.gserviceaccount.com \
  --message-body='{"overrides": {"containerOverrides": [{"args": ["property_sites.json"], "env": [{"name": "BQ_TABLE", "value": "regulatory_monitor.property_management_scrapes"}]}]}}' \
  --time-zone="America/Denver"

echo "------------------------------------------------"
echo "✅ Schedules Deployed. View them at: https://console.cloud.google.com/cloudscheduler"