-- Manual Test: Simulate the BOM Agent finishing a task for a Kansas client
INSERT INTO `regulatory_monitor.task_status` 
(event_id, client_id, agent_name, status, started_at, completed_at)
VALUES 
('test-event-ks-01', 'Otero_Energy_Group', 'BOM_RETROFITTER', 'COMPLETED', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP());