WITH capture_stats AS (
  SELECT 
    REGEXP_EXTRACT(source_id, r'^([a-zA-Z]+)-') AS state,
    source_id,
    -- Content is from your raw table
    CASE WHEN prompt IS NOT NULL THEN 1 ELSE 0 END AS scrape_success,
    -- This column only exists in the ML function output
    CASE WHEN ml_generate_text_llm_result IS NOT NULL THEN 1 ELSE 0 END AS ai_success,
    scraped_at
  FROM ML.GENERATE_TEXT(
    MODEL `regulatory_monitor.gemini_2_pro`,
    (
      SELECT 
        source_id, 
        scraped_at, 
        content AS prompt 
      FROM `regulatory_monitor.raw_scrapes`
    ),
    STRUCT(TRUE AS flatten_json_output)
  )
  QUALIFY ROW_NUMBER() OVER(PARTITION BY source_id ORDER BY scraped_at DESC) = 1
)
SELECT 
  state,
  COUNT(source_id) AS total_sites,
  SUM(scrape_success) AS successful_scrapes,
  SUM(ai_success) AS successful_analyses,
  ROUND(SAFE_DIVIDE(SUM(scrape_success), COUNT(source_id)) * 100, 1) AS success_rate_percentage
FROM capture_stats
GROUP BY state
ORDER BY success_rate_percentage ASC;