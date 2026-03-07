CREATE OR REPLACE VIEW `regulatory_monitor.enriched_scrapes` AS
SELECT 
  rs.source_id,
  rs.scraped_at,
  rs.content,
  rs.content_hash,
  sm.industry_category,
  sm.jurisdiction,
  sm.agency_name,
  sm.site_url -- Adding this so the search query can find it
FROM `regulatory_monitor.raw_scrapes` AS rs
LEFT JOIN `regulatory_monitor.sites_master` AS sm
  ON rs.source_id = sm.source_id;