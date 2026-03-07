#!/bin/bash

# --- CONFIGURATION ---
PROJECT_ID="regulatory-monitor-ai-agentic"
REGION="us-central1"
JOB_NAME="bulk-scraper"
SCHEDULER_NAME="nightly-regulatory-sweep"
SCHEDULE="0 2 * * *"  # 2:00 AM daily
# Using the specific service account from your screenshot
SERVICE_ACCOUNT="regulatory-monitor-ai-agentic@appspot.gserviceaccount.com"

echo "--------------------------------------------------------"
echo "🛠️  AUTOMATING REGULATORY SCRAPER"
echo "--------------------------------------------------------"

# 1. Construct the REST API URL for Cloud Run Jobs
# This is the exact endpoint needed for a POST request to trigger the job
echo "🔍 Building Job Trigger URL..."
JOB_URL="https://${REGION}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${PROJECT_ID}/jobs/${JOB_NAME}:run"

echo "📍 Target URL: $JOB_URL"

# 2. Refresh the Scheduler Job
if gcloud scheduler jobs describe "$SCHEDULER_NAME" --location="$REGION" &>/dev/null; then
    echo "♻️  Updating existing scheduler job..."
    gcloud scheduler jobs delete "$SCHEDULER_NAME" --location="$REGION" --quiet
fi

# 3. Create the Scheduler Job with OAuth
# Since we are hitting a Google API (*.googleapis.com), we must use an OAuth token
echo "📅 Creating Nightly Schedule ($SCHEDULE)..."
gcloud scheduler jobs create http "$SCHEDULER_NAME" \
    --location="$REGION" \
    --schedule="$SCHEDULE" \
    --uri="$JOB_URL" \
    --http-method="POST" \
    --oauth-service-account-email="$SERVICE_ACCOUNT" \
    --oauth-token-scope="https://www.googleapis.com/auth/cloud-platform" \
    --description="Nightly trigger for the bulk-scraper Cloud Run job." \
    --time-zone="America/Denver"

# 4. Ensure the Service Account has 'Invoker' permissions
# This prevents 403 Forbidden errors when the scheduler tries to start the job
echo "🔐 Granting Invoker permissions to $SERVICE_ACCOUNT..."
gcloud run jobs add-iam-policy-binding "$JOB_NAME" \
    --region="$REGION" \
    --member="serviceAccount:$SERVICE_ACCOUNT" \
    --role="roles/run.invoker"

echo "--------------------------------------------------------"
echo "✅ SUCCESS: $SCHEDULER_NAME is configured."
echo "👉 Test it now: gcloud scheduler jobs run $SCHEDULER_NAME --location=$REGION"
echo "--------------------------------------------------------"