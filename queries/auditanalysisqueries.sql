-- Query 1: Summary by operation status
SELECT 
    operation,
    is_allowed,
    COUNT(*) as attempt_count
FROM trigger_audit_log
GROUP BY operation, is_allowed
ORDER BY operation, is_allowed;

-- Query 2: All denied operations
SELECT 
    audit_id,
    operation,
    username,
    TO_CHAR(operation_date, 'YYYY-MM-DD HH24:MI:SS') as attempt_time,
    day_of_week,
    denial_reason
FROM trigger_audit_log
WHERE is_allowed = 'DENIED'
ORDER BY audit_id DESC;

-- Query 3: All allowed operations
SELECT 
    audit_id,
    operation,
    username,
    TO_CHAR(operation_date, 'YYYY-MM-DD HH24:MI:SS') as operation_time,
    day_of_week
FROM trigger_audit_log
WHERE is_allowed = 'ALLOWED'
ORDER BY audit_id DESC;

-- Query 4: Operations by day of week
SELECT 
    TRIM(day_of_week) as day,
    is_allowed,
    COUNT(*) as count
FROM trigger_audit_log
GROUP BY day_of_week, is_allowed
ORDER BY 
    CASE TRIM(day_of_week)
        WHEN 'SUNDAY' THEN 1
        WHEN 'MONDAY' THEN 2
        WHEN 'TUESDAY' THEN 3
        WHEN 'WEDNESDAY' THEN 4
        WHEN 'THURSDAY' THEN 5
        WHEN 'FRIDAY' THEN 6
        WHEN 'SATURDAY' THEN 7
    END;

-- Query 5: Check current day status
SELECT 
    TO_CHAR(SYSDATE, 'YYYY-MM-DD') as current_date,
    TO_CHAR(SYSDATE, 'DAY') as day_of_week,
    TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH') as day_abbr,
    CASE 
        WHEN TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH') IN ('MON','TUE','WED','THU','FRI')
        THEN 'WEEKDAY (BLOCKED)'
        ELSE 'WEEKEND (ALLOWED)'
    END as day_status,
    CASE 
        WHEN EXISTS (SELECT 1 FROM holidays WHERE TRUNC(holiday_date) = TRUNC(SYSDATE))
        THEN 'YES (BLOCKED)'
        ELSE 'NO'
    END as is_holiday
FROM dual;

-- Query 6: View all holidays
SELECT 
    holiday_id,
    TO_CHAR(holiday_date, 'YYYY-MM-DD') as holiday_date,
    TO_CHAR(holiday_date, 'DAY') as day_of_week,
    description
FROM holidays
ORDER BY holiday_date;