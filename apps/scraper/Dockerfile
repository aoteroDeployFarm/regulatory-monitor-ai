FROM mcr.microsoft.com/playwright:v1.50.0-noble

# 1. Install System Tools & GCloud SDK
RUN apt-get update && apt-get install -y \
    curl gnupg jq \
    && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | \
    tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
    gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
    apt-get update && apt-get install -y google-cloud-sdk \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 2. Explicitly Copy Folders for Monorepo structure
COPY package*.json ./
# Copying the entire packages directory ensures property_sites.json is included
COPY packages/ ./packages/
COPY scripts/ ./scripts/
COPY apps/scraper/ ./apps/scraper/

# 3. Build the project
RUN npm install
RUN npx playwright install --with-deps chromium

# 4. Orchestration Script with updated Path handling
RUN echo '#!/bin/bash\n\
npm run --prefix apps/scraper cloud-start & \n\
echo "⏳ Waiting for scraper server..." \n\
MAX_RETRIES=30; COUNT=0; \n\
while ! curl -s http://localhost:8080/health > /dev/null; do \n\
    sleep 1; ((COUNT++)); \n\
    if [ $COUNT -ge $MAX_RETRIES ]; then echo "❌ Server timeout"; exit 1; fi \n\
done \n\
echo "🚀 Server ready. Starting bulk scrape..." \n\
bash /app/scripts/bulk-scrape.sh "$@"' > /app/start.sh

RUN chmod +x /app/start.sh
ENTRYPOINT ["/bin/bash", "/app/start.sh"]