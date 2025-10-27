-- Template Q1 query
-- This will be replaced by the actual submission during evaluation

-- Example query: Find top 10 users by event count
SELECT user_id, COUNT(*) as event_count
FROM events
GROUP BY user_id
ORDER BY event_count DESC
LIMIT 10;