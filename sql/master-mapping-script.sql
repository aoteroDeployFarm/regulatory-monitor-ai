UPDATE `regulatory_monitor.raw_scrapes`
SET industry_category = 
  CASE 
    -- Energy & Oil/Gas (Common keywords in source_ids)
    WHEN source_id LIKE '%energy%' OR source_id LIKE '%utility%' OR source_id LIKE '%pipeline%' OR source_id LIKE '%puc%' 
      THEN 'Oil, Gas & Energy'
    
    -- Environmental & Ag (Common keywords)
    WHEN source_id LIKE '%env%' OR source_id LIKE '%dep%' OR source_id LIKE '%agriculture%' OR source_id LIKE '%dnr%' 
      THEN 'Environmental & Agriculture'
      
    -- Property & Construction
    WHEN source_id LIKE '%fire%' OR source_id LIKE '%building%' OR source_id LIKE '%housing%' OR source_id LIKE '%zoning%' 
      THEN 'Property Management'
      
    ELSE 'General Regulatory'
  END
WHERE industry_category IS NULL;