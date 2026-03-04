import { chromium } from 'playwright';
import { BigQuery } from '@google-cloud/bigquery';
import crypto from 'crypto';

// Initialize BigQuery with your specific project ID
const bq = new BigQuery({ projectId: 'regulatory-monitor-ai-agentic' });

export async function runScraper(site: { id: string; name: string; url: string; jurisdiction: string; selector?: string }) {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  
  console.log(`📡 Scraping ${site.name} (${site.url})...`);
  
  try {
    // Navigate with a 30s timeout
    await page.goto(site.url, { waitUntil: 'networkidle', timeout: 30000 });

    // Extract text from the page
    const content = await page.innerText(site.selector || 'body');
    
    // Create a unique hash of the content to detect changes in the future
    const contentHash = crypto.createHash('md5').update(content).digest('hex');

    const row = {
      source_id: site.id,
      jurisdiction: site.jurisdiction,
      url: site.url,
      content: content,
      content_hash: contentHash,
      scraped_at: bq.timestamp(new Date()),
    };

    // Stream the data into BigQuery
    await bq.dataset('regulatory_monitor').table('raw_scrapes').insert([row]);
    console.log(`✅ ${site.id} successfully streamed to BigQuery.`);
    
    return true;
  } catch (error) {
    console.error(`❌ Error scraping ${site.id}:`, error);
    throw error;
  } finally {
    await browser.close();
  }
}