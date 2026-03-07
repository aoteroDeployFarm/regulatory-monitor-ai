SELECT 
  SUBSTR(source_id, 0, STRPOS(source_id, '-') - 1) as state,
  COUNT(*) as untagged_count
FROM `regulatory_monitor.raw_scrapes`
WHERE industry_category IS NULL
GROUP BY state
ORDER BY untagged_count DESC;