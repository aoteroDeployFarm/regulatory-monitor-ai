CREATE TABLE IF NOT EXISTS `regulatory_monitor.regulatory_events` (
  event_id STRING DEFAULT GENERATE_UUID(),
  source_id STRING,
  event_type STRING, -- e.g., 'PERMIT_EXPIRATION', 'NEW_RULE', 'HEARING_SCHEDULED'
  severity STRING,   -- e.g., 'CRITICAL', 'WARNING', 'INFO'
  summary_delta STRING, -- The specific change Gemini detected
  raw_change_log JSON, -- Supporting data for the agent
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);