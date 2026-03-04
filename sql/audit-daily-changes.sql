WITH daily_ranks AS (
  SELECT 
    jurisdiction,
    agency_name,
    content,
    content_hash,
    scraped_at,
    -- Ranks the scrapes so we can compare the latest to the previous one
    LAG(content_hash) OVER (PARTITION BY source_id ORDER BY scraped_at ASC) as previous_hash
  FROM `regulatory_monitor.enriched_scrapes`
)
SELECT 
  jurisdiction,
  agency_name,
  scraped_at,
  'CONTENT UPDATED' as status
FROM daily_ranks
WHERE content_hash != previous_hash 
AND previous_hash IS NOT NULL
ORDER BY scraped_at DESC;