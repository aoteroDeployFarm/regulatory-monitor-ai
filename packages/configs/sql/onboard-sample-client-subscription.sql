INSERT INTO `regulatory_monitor.client_subscriptions` 
(client_id, industry_category, notification_level, preferred_agent)
VALUES 
  -- A manufacturing client that needs technical retrofits
  ('Otero_Energy_Group', 'Oil, Gas & Energy', 'ALL_CHANGES', 'BOM_RETROFITTER'),
  
  -- A property management firm that just needs to stay informed
  ('Summit_Property_Mgmt', 'Property Management', 'CRITICAL_ONLY', 'EMAIL_ONLY');