SELECT 
  jurisdiction,
  agency_name,
  industry_category,
  scraped_at,
  -- This creates a "Snippet" to see the keyword in context
  SUBSTR(content, STRPOS(LOWER(content), 'permit') - 50, 200) as context_snippet,
  site_url
FROM `regulatory_monitor.enriched_scrapes`
WHERE REGEXP_CONTAINS(LOWER(content), r'permit|fire|pipeline|building|construction')
ORDER BY scraped_at DESC;