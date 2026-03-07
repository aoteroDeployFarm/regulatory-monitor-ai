#!/bin/bash

# --- Configuration ---
JOB_NAME="daily-regulatory-pulse"
SCHEDULE="0 8 * * *" # 8:00 AM Daily
REGION="us-central1"
TARGET_URI="https://us-central1-regulatory-monitor-ai-agentic.cloudfunctions.net/sendDailyPulse"
DESCRIPTION="Triggers the Fabing Productions National Regulatory Pulse email alert."

echo "⏳ Setting up Cloud Scheduler for $JOB_NAME..."

# 1. Check if the job already exists
if gcloud scheduler jobs describe $JOB_NAME --location=$REGION > /dev/null 2>&1; then
    echo "🔄 Job exists. Updating existing schedule..."
    gcloud scheduler jobs update http $JOB_NAME \
      --schedule="$SCHEDULE" \
      --uri="$TARGET_URI" \
      --http-method=GET \
      --location=$REGION \
      --description="$DESCRIPTION"
else
    echo "✨ Creating new scheduler job..."
    gcloud scheduler jobs create http $JOB_NAME \
      --schedule="$SCHEDULE" \
      --uri="$TARGET_URI" \
      --http-method=GET \
      --location=$REGION \
      --description="$DESCRIPTION"
fi

echo "✅ Scheduler is live! Your agent will now wake up at 8:00 AM daily."