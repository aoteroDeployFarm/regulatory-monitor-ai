SELECT 
  COALESCE(sm.industry_category, 'Unmapped/Pending') as industry,
  COUNT(DISTINCT rs.source_id) as unique_sites,
  -- Using COUNT(*) instead of rs.id to avoid the "Name not found" error
  COUNT(*) as total_scrapes_captured,
  -- Calculate what % of your total unique sites are in each sector
  ROUND(COUNT(DISTINCT rs.source_id) * 100 / SUM(COUNT(DISTINCT rs.source_id)) OVER(), 1) as portfolio_percent
FROM `regulatory_monitor.raw_scrapes` AS rs
LEFT JOIN `regulatory_monitor.source_metadata` AS sm
  ON rs.source_id = sm.source_id
GROUP BY industry
ORDER BY unique_sites DESC;