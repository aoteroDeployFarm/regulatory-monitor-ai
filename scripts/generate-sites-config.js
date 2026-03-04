const fs = require('fs');
const path = require('path');

// 1. Path to your raw 560-URL list
const rawDataPath = path.join(__dirname, '../packages/configs/raw-sites.json');
const rawData = JSON.parse(fs.readFileSync(rawDataPath, 'utf8'));

const flattenedSites = [];

// 2. Loop through every State and every URL
Object.entries(rawData).forEach(([state, urls]) => {
  urls.forEach((url, index) => {
    flattenedSites.push({
      id: `${state.toLowerCase().replace(/\s+/g, '-')}-${index}`,
      jurisdiction: state,
      name: `${state} Source ${index}`,
      url: url,
      selector: "body" // We use body as default; you can refine this later
    });
  });
});

// 3. Save the "Scraper-Ready" version
const outputPath = path.join(__dirname, '../packages/configs/sites.json');
fs.writeFileSync(outputPath, JSON.stringify(flattenedSites, null, 2));

console.log(`🚀 Success! Processed all 560 sites into ${outputPath}`);