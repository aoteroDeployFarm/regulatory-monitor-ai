CREATE TABLE IF NOT EXISTS `regulatory_monitor.source_metadata` (
  source_id STRING,
  industry_category STRING,
  state STRING,
  agency_name STRING,
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);