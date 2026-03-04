CREATE TABLE IF NOT EXISTS `regulatory_monitor.sites_master` (
  source_id STRING,             -- maps to "id": "wyoming-2"
  jurisdiction STRING,          -- maps to "jurisdiction": "Wyoming"
  agency_name STRING,           -- maps to "name": "Wyoming Source 2"
  site_url STRING,              -- maps to "url": "https://deq.wyoming.gov/..."
  css_selector STRING,          -- maps to "selector": "body"
  industry_category STRING,     -- The tag for your Agents
  is_active BOOLEAN DEFAULT TRUE,
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);