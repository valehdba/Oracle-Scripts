SELECT
 s.username,
 s.sid,
 s.serial#,
 s.sql_id,
 seg.segment_type,
 seg.bytes / 1024 / 1024 AS used_mb,
 seg.bytes_used / 1024 / 1024 AS used_in_sort_mb
FROM v$session s
INNER JOIN v$sort_segment_usage seg ON s.sid = seg.session_id
WHERE s.status = 'ACTIVE'
AND seg.bytes > 0;
