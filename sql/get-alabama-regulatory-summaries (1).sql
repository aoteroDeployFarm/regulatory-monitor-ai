SELECT 
  source_id, 
  scraped_at, 
  ml_generate_text_llm_result AS ai_summary
FROM 
  ML.GENERATE_TEXT(
    MODEL `regulatory_monitor.gemini_2_pro`,
    (
      -- We rename 'content' to 'prompt' here so the model can find it
      SELECT 
        source_id, 
        scraped_at, 
        content AS prompt 
      FROM `regulatory_monitor.raw_scrapes` 
      WHERE source_id LIKE 'alabama%'
    ),
    STRUCT(TRUE AS flatten_json_output)
  )
ORDER BY scraped_at DESC;