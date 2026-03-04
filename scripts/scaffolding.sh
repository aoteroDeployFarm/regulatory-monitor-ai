#!/bin/bash

# Define the root project name
PROJECT_NAME="regulatory-monitor-ai"

echo "🏗️ Building organized scaffolding for $PROJECT_NAME..."

# 1. Create Directory Structure (Added /scripts)
mkdir -p $PROJECT_NAME/apps/web/src/components
mkdir -p $PROJECT_NAME/apps/scraper/src/scrapers
mkdir -p $PROJECT_NAME/apps/scraper/src/utils
mkdir -p $PROJECT_NAME/packages/shared-types
mkdir -p $PROJECT_NAME/packages/configs
mkdir -p $PROJECT_NAME/functions
mkdir -p $PROJECT_NAME/infrastructure
mkdir -p $PROJECT_NAME/scripts

# Move into project root
cd $PROJECT_NAME

# 2. Initialize Monorepo package.json (npm workspaces)
cat <<EOF > package.json
{
  "name": "$PROJECT_NAME",
  "private": true,
  "workspaces": [
    "apps/*",
    "packages/*",
    "functions"
  ],
  "scripts": {
    "dev": "npm run dev --workspaces --if-present",
    "build": "npm run build --workspaces --if-present",
    "deploy:scraper": "gcloud builds submit apps/scraper --tag gcr.io/\$GOOGLE_CLOUD_PROJECT/scraper",
    "deploy:firebase": "firebase deploy",
    "setup:db": "bash scripts/setup-bigquery.sh"
  }
}
EOF

# 3. Create Scraper App Boilerplate
cat <<EOF > apps/scraper/Dockerfile
FROM node:20-slim
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
EXPOSE 8080
# Playwright/Puppeteer requirement: Install browser dependencies if using headless
# RUN npx playwright install-deps
CMD [ "node", "dist/index.js" ]
EOF

# 4. Create Placeholder Files
touch apps/scraper/src/index.ts
touch apps/scraper/src/utils/runScraper.ts
touch packages/shared-types/index.ts
touch packages/configs/sites.json
touch functions/index.ts
touch functions/bigquery-queries.sql

# 5. Move Infrastructure scripts to the new /scripts directory
# We'll keep the .sh files in /scripts for execution ease
cat <<EOF > scripts/setup-bigquery.sh
#!/bin/bash
# Script to initialize BigQuery datasets and tables
echo "Initializing BigQuery..."
# gcloud storage buckets create ...
# bq mk --dataset ...
EOF
chmod +x scripts/setup-bigquery.sh

# 6. Create .gitignore
cat <<EOF > .gitignore
# Dependencies
node_modules/
.pnp
.pnp.js

# Firebase
.firebase/
firebase-debug.log
*.runtimeconfig.json

# Environment / Secret
.env
.env.local
.env.development.local
.env.production.local

# Build outputs
dist/
build/
.next/
out/

# OS Files
.DS_Store
EOF

# 7. Create README
cat <<EOF > README.md
# RegulatoryMonitor.ai

## Directory Map
- **/apps**: Deployable applications (Web & Scraper).
- **/packages**: Shared types and site configurations.
- **/functions**: Firebase Cloud Functions.
- **/scripts**: Automation and setup utilities.
- **/infrastructure**: Cloud resource definitions.
EOF

echo "✅ Project $PROJECT_NAME is ready."
echo "💡 Your setup scripts are located in the /scripts directory."
