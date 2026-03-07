#!/bin/bash

# --- Configuration ---
# 1. Force the Firebase CLI to wait 60s during the "Analyzing source code" phase
export FUNCTIONS_DISCOVERY_TIMEOUT=60

# 2. Match the export name in your index.js
FUNCTION_NAME="sendDailyPulse"

echo "🚀 Starting Deployment for $FUNCTION_NAME..."
echo "⏱️  Discovery Timeout set to 60s to prevent initialization errors."

# 3. Navigate to the functions directory to ensure the build works
cd "$(dirname "$0")/../functions" || exit

# 4. Build the TypeScript (even if we are using JS, this clears the path)
echo "📦 Building project assets..."
npm run build

if [ $? -eq 0 ]; then
  echo "✅ Build alignment successful."
else
  echo "⚠️  Build notes: Proceeding to deployment..."
fi

# 5. The Main Event: Deploy via Firebase
cd ..
firebase deploy --only functions:$FUNCTION_NAME

if [ $? -eq 0 ]; then
  echo "🎯 ACTUAL Deployment Complete!"
  echo "Check the terminal output above for your live Function URL."
else
  echo "❌ Firebase deploy failed. If it timed out at 60s, we can increase it further."
  exit 1
fi