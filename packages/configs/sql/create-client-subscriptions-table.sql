CREATE TABLE IF NOT EXISTS `regulatory_monitor.client_subscriptions` (
  subscription_id STRING DEFAULT GENERATE_UUID(),
  client_id STRING,           -- e.g., 'Otero_Energy_Group'
  industry_category STRING,    -- e.g., 'Oil, Gas & Energy'
  notification_level STRING,   -- e.g., 'CRITICAL_ONLY', 'ALL_CHANGES'
  preferred_agent STRING,     -- e.g., 'BOM_RETROFITTER', 'EMAIL_ONLY'
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);