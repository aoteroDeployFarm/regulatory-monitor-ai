CREATE TABLE IF NOT EXISTS `regulatory_monitor.task_status` (
  task_id STRING DEFAULT GENERATE_UUID(),
  event_id STRING,       -- Links back to the original regulatory change
  client_id STRING,      -- e.g., 'xyz_construction_corp'
  agent_name STRING,     -- e.g., 'BOM_AGENT', 'EMAIL_AGENT'
  status STRING,         -- e.g., 'PENDING', 'IN_PROGRESS', 'COMPLETED', 'FAILED'
  output_data_uri STRING, -- Path to the generated BOM or Email draft in Cloud Storage
  started_at TIMESTAMP,
  completed_at TIMESTAMP,
  retry_count INT64 DEFAULT 0
);