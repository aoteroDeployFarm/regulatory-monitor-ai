-- Categorizing Massachusetts Regulatory Sites
ALTER TABLE `regulatory_monitor.raw_scrapes` 
ADD COLUMN IF NOT EXISTS industry_category STRING;
UPDATE `regulatory_monitor.raw_scrapes`
SET industry_category = 
  CASE 
    WHEN source_id IN ('massachusetts-0', 'massachusetts-1', 'massachusetts-9') 
      THEN 'Oil, Gas & Energy'
    WHEN source_id IN ('massachusetts-2', 'massachusetts-3', 'massachusetts-4', 'massachusetts-5', 'massachusetts-6', 'massachusetts-7', 'massachusetts-8') 
      THEN 'Environmental & Agriculture'
    ELSE 'General Regulatory'
  END
WHERE source_id LIKE 'massachusetts%';