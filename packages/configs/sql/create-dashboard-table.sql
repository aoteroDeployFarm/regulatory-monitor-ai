SELECT 
  t.client_id,
  e.event_type,
  e.severity,
  t.agent_name,
  t.status,
  -- Calculate how long the agent has been working
  TIMESTAMP_DIFF(
    COALESCE(t.completed_at, CURRENT_TIMESTAMP()), 
    t.started_at, 
    MINUTE
  ) AS duration_minutes,
  t.retry_count,
  e.summary_delta AS regulatory_change
FROM `regulatory_monitor.task_status` AS t
JOIN `regulatory_monitor.regulatory_events` AS e 
  ON t.event_id = e.event_id
ORDER BY e.created_at DESC, t.client_id ASC;