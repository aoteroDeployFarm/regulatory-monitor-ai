import express from 'express';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
// We use the .js extension here because of Node ESM requirements
import { runScraper } from './utils/runScraper.js';

// ESM-specific way to get __dirname
const __dirname = path.dirname(fileURLToPath(import.meta.url));

// Load the 560-site configuration using FileSystem to ensure stability
const sitesPath = path.join(__dirname, '../../../packages/configs/sites.json');
const sites = JSON.parse(fs.readFileSync(sitesPath, 'utf8'));

const app = express();
const PORT = process.env.PORT || 8080;

/**
 * Endpoint to trigger a specific scrape by ID
 * Example: http://localhost:8080/scrape/alaska-0
 */
app.get('/scrape/:id', async (req, res) => {
  const { id } = req.params;
  
  // Find the site in our generated 560-site list
  const siteConfig = (sites as any[]).find(s => s.id === id);

  if (!siteConfig) {
    console.warn(`⚠️  Site ID "${id}" requested but not found in sites.json`);
    return res.status(404).send(`❌ Site ID "${id}" not found.`);
  }

  try {
    // Execute the Playwright scraper and stream to BigQuery
    await runScraper(siteConfig);
    res.status(200).send(`✅ Success: ${siteConfig.name} data is now in BigQuery.`);
  } catch (err) {
    console.error(`❌ Scraper Error for ${id}:`, err);
    res.status(500).send(`❌ Scraper Error: ${err}`);
  }
});

app.listen(PORT, () => {
  console.log(`🚀 Scraper Service listening on http://localhost:${PORT}`);
  console.log(`📡 Loaded ${sites.length} site configurations.`);
});