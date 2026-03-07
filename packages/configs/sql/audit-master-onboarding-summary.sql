SELECT 
  jurisdiction, 
  COUNT(*) as total_sites_onboarded
FROM `regulatory_monitor.sites_master`
GROUP BY jurisdiction
ORDER BY total_sites_onboarded DESC;