SELECT 
  client_id,
  industry_category,
  notification_level,
  preferred_agent,
  FORMAT_TIMESTAMP('%Y-%m-%d', created_at) AS joined_date
FROM 
  `regulatory_monitor.client_subscriptions`
ORDER BY 
  industry_category ASC, client_id ASC;