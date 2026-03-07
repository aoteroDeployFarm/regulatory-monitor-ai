#!/bin/bash

echo "------------------------------------------------"
echo "🧹 Maintenance: Freeing up Disk Space"
echo "------------------------------------------------"

# 1. Show current usage
echo "📊 Current Disk Usage:"
df -h /home

echo -e "\n🐳 Cleaning up local Docker environment..."

# 2. Remove stopped containers
docker container prune -f

# 3. Remove dangling images (untagged layers)
docker image prune -f

# 4. Remove unused build cache (This is usually the biggest culprit)
docker builder prune -a -f

# 5. Optional: Full wipe (Uncomment if you still have no space)
# echo "⚠️ Performing deep prune..."
# docker system prune -a -f --volumes

echo -e "\n♻️ Checking Cloud Artifact Registry..."
# List top 5 largest images to see what's taking space remotely
gcloud artifacts docker images list us-central1-docker.pkg.dev/regulatory-monitor-ai-agentic/bulk-scraper/bulk-scraper \
    --sort-by=~CREATE_TIME --limit=5

echo -e "\n------------------------------------------------"
echo "✅ Cleanup complete. Current Space:"
df -h /home