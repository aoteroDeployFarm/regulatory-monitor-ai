import { chromium, Browser, Page } from 'playwright';
import express from 'express';
import { execSync } from 'child_process';
import { createHash } from 'crypto';
import * as fs from 'fs';

const app = express();
const PORT = 8080;

// 1. Load Config to validate incoming requests
const CONFIG_PATH = process.env.CONFIG_PATH || '/app/packages/configs/property_sites.json';
let sitesConfig: any[] = [];

try {
    if (fs.existsSync(CONFIG_PATH)) {
        sitesConfig = JSON.parse(fs.readFileSync(CONFIG_PATH, 'utf-8'));
    }
} catch (e) {
    console.error("⚠️ Failed to load sites config for validation.");
}

// 🌐 HEALTH CHECK
app.get('/health', (req, res) => res.status(200).send('OK'));

// 📡 THE SCRAPE ROUTE (Called by bulk-scrape.sh)
app.get('/scrape/:id', async (req, res) => {
    const siteId = req.params.id;
    const site = sitesConfig.find(s => s.id === siteId);

    if (!site) {
        return res.status(404).json({ success: false, error: `Site ID ${siteId} not found in config.` });
    }

    const browser: Browser = await chromium.launch({ 
        headless: true, 
        args: ['--no-sandbox', '--disable-setuid-sandbox'] 
    });

    try {
        const context = await browser.newContext({
            userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
            viewport: { width: 1280, height: 720 }
        });
        
        const page: Page = await context.newPage();
        console.log(`📡 [${site.id}] Remote request to scrape: ${site.url}`);
        
        // 🚀 INCREASED TIMEOUT: 90 seconds for slow gov servers
        // Using 'domcontentloaded' as it's more stable than 'networkidle'
        await page.goto(site.url, { waitUntil: 'domcontentloaded', timeout: 90000 });
        
        // 🛑 CRITICAL: Wait for body to ensure the page actually rendered something
        await page.waitForSelector('body', { timeout: 30000 });

        let content = "";
        
        if (site.selector) {
            try {
                // Try the specific selector first with a 15s grace period
                console.log(`🔍 Waiting for selector: ${site.selector}`);
                content = await page.locator(site.selector).innerText({ timeout: 15000 });
            } catch (selectorError) {
                console.warn(`⚠️ Selector ${site.selector} failed for ${site.id}. Falling back to body text.`);
                content = await page.innerText('body');
            }
        } else {
            content = await page.innerText('body');
        }
            
        const contentHash = createHash('md5').update(content).digest('hex');

        await browser.close();
        
        res.json({
            success: true,
            id: site.id,
            hash: contentHash,
            contentSnippet: content.substring(0, 1500) // Increased snippet for better preview in BQ
        });

    } catch (e: any) {
        await browser.close();
        console.error(`❌ [${siteId}] Scrape failed:`, e.message);
        res.status(500).json({ success: false, error: e.message });
    }
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Scraper Service listening on port ${PORT}`);
    console.log(`📖 Using config: ${CONFIG_PATH}`);
});