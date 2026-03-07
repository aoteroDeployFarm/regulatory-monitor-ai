#!/bin/bash

# Configuration
JOB_NAME="bulk-scraper-job"
REGION="us-central1"
PROJECT_ID="regulatory-monitor-ai-agentic"

echo "------------------------------------------------"
echo "🚀 Regulatory Monitor: Scraper Launcher"
echo "------------------------------------------------"
echo "1) Run Property Management Scrape (New Table)"
echo "2) Run Regular Regulatory Scrape (Default Table)"
echo "3) Cancel"
echo "------------------------------------------------"
read -p "Select an option [1-3]: " choice

case $choice in
    1)
        echo "📡 Starting Property Management Scrape..."
        gcloud run jobs execute $JOB_NAME \
          --args="property_sites.json" \
          --update-env-vars BQ_TABLE=regulatory_monitor.property_management_scrapes \
          --region $REGION
        ;;
    2)
        echo "⚖️ Starting Regular Regulatory Scrape..."
        # We don't need update-env-vars here because the script 
        # defaults to raw_scrapes if BQ_TABLE is empty
        gcloud run jobs execute $JOB_NAME \
          --args="hawaii" \
          --region $REGION
        ;;
    3)
        echo "❌ Execution cancelled."
        exit 0
        ;;
    *)
        echo "⚠️ Invalid selection. Please choose 1, 2, or 3."
        exit 1
        ;;
esac

echo "------------------------------------------------"
echo "✅ Job execution request sent."