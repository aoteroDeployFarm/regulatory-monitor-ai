#!/bin/bash

PROJECT_ID="regulatory-monitor-ai-agentic"

echo "--------------------------------------------------------"
echo "🔌 API READINESS CHECK: $PROJECT_ID"
echo "--------------------------------------------------------"

# 1. Define required services
SERVICES=(
  "aiplatform.googleapis.com"      # Vertex AI (Gemini)
  "bigquery.googleapis.com"        # BigQuery Core
  "bigqueryconnection.googleapis.com" # BigQuery <-> AI Tunnel
  "run.googleapis.com"             # Cloud Run (Scraper)
  "cloudbuild.googleapis.com"      # Deployment
  "documentai.googleapis.com"      # PDF Analysis
  "iam.googleapis.com"             # IAM
  "serviceusage.googleapis.com"    # API gatekeeper
)

# 2. Get list of ALREADY enabled services
echo "🔍 Fetching currently enabled services..."
ENABLED_SERVICES=$(gcloud services list --enabled --project=$PROJECT_ID --format="value(config.name)")

# 3. Loop and verify
for SERVICE in "${SERVICES[@]}"; do
  if echo "$ENABLED_SERVICES" | grep -q "^$SERVICE$"; then
    echo "✅ $SERVICE is already enabled. Skipping..."
  else
    echo "📡 $SERVICE is NOT enabled. Activating now..."
    gcloud services enable $SERVICE --project=$PROJECT_ID
    if [ $? -eq 0 ]; then
        echo "   ✔️ Successfully enabled $SERVICE"
    else
        echo "   ❌ Failed to enable $SERVICE. Please check project billing."
    fi
  fi
done

echo "--------------------------------------------------------"
echo "🏁 API Configuration Complete."
echo "--------------------------------------------------------"