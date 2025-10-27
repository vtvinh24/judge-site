-- Template Q2 query
-- This will be replaced by the actual submission during evaluation

-- Example query: Find users with recent activity
SELECT DISTINCT u.user_id, u.country, u.plan
FROM users u
JOIN events e ON u.user_id = e.user_id
WHERE e.event_ts >= NOW() - INTERVAL '30 days';