SELECT 
  jurisdiction,
  industry_category,
  COUNT(*) as updates_found
FROM `regulatory_monitor.enriched_scrapes`
-- Only look at the last 24 hours
WHERE scraped_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
GROUP BY 1, 2
ORDER BY updates_found DESC;