-- Check if the analysis was created
SELECT a.analysis_id, a.report_id, a.disease_id, a.risk_level, a.confidence_score
FROM analysis a
WHERE a.report_id = 201;

-- Check recommendations
SELECT r.rec_id, r.analysis_id, r.recommendation_text
FROM recommendations r
JOIN analysis a ON r.analysis_id = a.analysis_id
WHERE a.report_id = 201;

-- Check if report status was updated
SELECT report_id, status FROM reports WHERE report_id = 201;

-- Check audit log
SELECT log_id, action, object_type, object_id, status, notes
FROM audit_log
WHERE object_id = '201'
ORDER BY action_time DESC;