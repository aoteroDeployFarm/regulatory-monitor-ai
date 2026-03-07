SELECT 
  rs.source_id,
  -- Extracts state name (everything before the first dash)
  IF(REGEXP_CONTAINS(rs.source_id, '-'), SPLIT(rs.source_id, '-')[OFFSET(0)], rs.source_id) as extracted_state,
  COUNT(*) as total_scrapes
FROM `regulatory_monitor.raw_scrapes` AS rs
LEFT JOIN `regulatory_monitor.source_metadata` AS sm
  ON rs.source_id = sm.source_id
WHERE sm.source_id IS NULL
GROUP BY rs.source_id, extracted_state
ORDER BY extracted_state ASC;