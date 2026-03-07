WITH ScrapeHistory AS (
  SELECT
    source_id,
    jurisdiction,
    scraped_at,
    content_hash,
    raw_content,
    -- Get the hash and content from the previous scrape of the same site
    LAG(content_hash) OVER (PARTITION BY source_id ORDER BY scraped_at ASC) as prev_hash,
    LAG(raw_content) OVER (PARTITION BY source_id ORDER BY scraped_at ASC) as prev_content
  FROM
    `regulatory-monitor-ai-agentic.regulatory_monitor.property_management_scrapes`
)
SELECT
  source_id,
  jurisdiction,
  scraped_at,
  CASE 
    WHEN prev_hash IS NULL THEN 'Initial Scrape'
    WHEN content_hash != prev_hash THEN 'CHANGE DETECTED'
    ELSE 'No Change'
  END as status,
  -- This provides a snippet of the new content for quick review
  SUBSTR(raw_content, 1, 500) as current_snippet
FROM
  ScrapeHistory
WHERE
  -- Only show the most recent scrape results
  scraped_at > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
ORDER BY
  status DESC, jurisdiction ASC;