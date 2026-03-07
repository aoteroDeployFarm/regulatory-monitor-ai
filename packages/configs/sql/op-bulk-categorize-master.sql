UPDATE `regulatory_monitor.sites_master`
SET industry_category = CASE 
    WHEN REGEXP_CONTAINS(LOWER(agency_name), r'oil|gas|energy|utility|pipeline|psc|puc') THEN 'Oil, Gas & Energy'
    WHEN REGEXP_CONTAINS(LOWER(agency_name), r'water|air|environment|adem|dec|dep|epa') THEN 'Environmental & Agriculture'
    WHEN REGEXP_CONTAINS(LOWER(agency_name), r'fire|building|code|housing|labor|safety') THEN 'Property Management'
    ELSE 'General Regulatory'
  END
WHERE industry_category IS NULL;