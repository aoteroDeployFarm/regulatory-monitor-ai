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
