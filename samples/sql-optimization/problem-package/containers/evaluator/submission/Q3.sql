-- Template Q3 query  
-- This will be replaced by the actual submission during evaluation

-- Example query: Aggregate events by device type
SELECT d.device_type, 
       COUNT(*) as total_events,
       COUNT(DISTINCT e.user_id) as unique_users
FROM events e
JOIN devices d ON e.device_id = d.device_id
GROUP BY d.device_type
ORDER BY total_events DESC;