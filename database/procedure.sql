CREATE OR REPLACE PROCEDURE update_report_status(
    p_report_id IN NUMBER,
    p_new_status IN VARCHAR2,
    p_notes IN VARCHAR2 DEFAULT NULL,
    p_success OUT BOOLEAN,
    p_message OUT VARCHAR2
) IS
    v_old_status VARCHAR2(20);
    v_user_id NUMBER;
    e_invalid_status EXCEPTION;
    e_report_not_found EXCEPTION;
BEGIN
    -- Validate status
    IF p_new_status NOT IN ('PENDING', 'ANALYZED', 'RESPONDED') THEN
        RAISE e_invalid_status;
    END IF;
    
    -- Get current status and user
    BEGIN
        SELECT status, user_id INTO v_old_status, v_user_id
        FROM reports
        WHERE report_id = p_report_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE e_report_not_found;
    END;
    
    -- Update status
    UPDATE reports
    SET status = p_new_status
    WHERE report_id = p_report_id;
    
    -- Log the change (simplified)
    INSERT INTO audit_log
    VALUES (
        seq_audit.NEXTVAL,
        v_user_id,
        'UPDATE_STATUS',
        'REPORT',
        TO_CHAR(p_report_id),
        'SUCCESS',
        'Status changed from ' || v_old_status || ' to ' || p_new_status,
        SYSDATE
    );
    
    COMMIT;
    p_success := TRUE;
    p_message := 'Report status updated successfully';
    
EXCEPTION
    WHEN e_invalid_status THEN
        ROLLBACK;
        p_success := FALSE;
        p_message := 'Invalid status value';
    WHEN e_report_not_found THEN
        ROLLBACK;
        p_success := FALSE;
        p_message := 'Report not found';
    WHEN OTHERS THEN
        ROLLBACK;
        p_success := FALSE;
        p_message := 'Error: ' || SQLERRM;
END update_report_status;
/
CREATE OR REPLACE PROCEDURE delete_old_reports(
    p_days_old IN NUMBER,
    p_delete_count OUT NUMBER,
    p_success OUT BOOLEAN,
    p_message OUT VARCHAR2
) IS
    v_cutoff_date DATE;
    e_invalid_days EXCEPTION;
BEGIN
    -- Validate input
    IF p_days_old <= 0 THEN
        RAISE e_invalid_days;
    END IF;
    
    v_cutoff_date := SYSDATE - p_days_old;
    
    -- Delete old reports
    DELETE FROM reports
    WHERE report_date < v_cutoff_date
    AND status = 'RESPONDED';
    
    p_delete_count := SQL%ROWCOUNT;
    
    -- Log the operation
    INSERT INTO audit_log
    VALUES (
        seq_audit.NEXTVAL,
        NULL,
        'BULK_DELETE',
        'REPORT',
        'MULTIPLE',
        'SUCCESS',
        'Deleted ' || p_delete_count || ' reports older than ' || p_days_old || ' days',
        SYSDATE
    );
    
    COMMIT;
    p_success := TRUE;
    p_message := p_delete_count || ' old reports deleted successfully';
    
EXCEPTION
    WHEN e_invalid_days THEN
        ROLLBACK;
        p_success := FALSE;
        p_message := 'Days must be greater than 0';
        p_delete_count := 0;
    WHEN OTHERS THEN
        ROLLBACK;
        p_success := FALSE;
        p_message := 'Error: ' || SQLERRM;
        p_delete_count := 0;
END delete_old_reports;
/
CREATE OR REPLACE PROCEDURE generate_monthly_summary(
    p_year IN NUMBER,
    p_month IN NUMBER,
    p_total_reports OUT NUMBER,
    p_high_risk_count OUT NUMBER,
    p_most_affected_crop OUT VARCHAR2,
    p_success OUT BOOLEAN
) IS
    v_start_date DATE;
    v_end_date DATE;
BEGIN
    v_start_date := TO_DATE(p_year || '-' || LPAD(p_month, 2, '0') || '-01', 'YYYY-MM-DD');
    v_end_date := ADD_MONTHS(v_start_date, 1);
    
    -- Get total reports
    SELECT COUNT(*)
    INTO p_total_reports
    FROM reports
    WHERE report_date >= v_start_date AND report_date < v_end_date;
    
    -- Get high risk count
    SELECT COUNT(*)
    INTO p_high_risk_count
    FROM reports r
    JOIN analysis a ON r.report_id = a.report_id
    WHERE r.report_date >= v_start_date AND r.report_date < v_end_date
    AND a.risk_level = 'HIGH';
    
    -- Get most affected crop
    BEGIN
        SELECT c.crop_name
        INTO p_most_affected_crop
        FROM (
            SELECT r.crop_id, COUNT(*) as cnt
            FROM reports r
            WHERE r.report_date >= v_start_date AND r.report_date < v_end_date
            GROUP BY r.crop_id
            ORDER BY cnt DESC
        ) sub
        JOIN crops c ON sub.crop_id = c.crop_id
        WHERE ROWNUM = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_most_affected_crop := 'N/A';
    END;
    
    p_success := TRUE;
    
EXCEPTION
    WHEN OTHERS THEN
        p_success := FALSE;
        p_total_reports := 0;
        p_high_risk_count := 0;
        p_most_affected_crop := 'ERROR';
END generate_monthly_summary;
/
CREATE OR REPLACE PROCEDURE update_user_location(
    p_user_id IN NUMBER,
    p_location IN OUT VARCHAR2,
    p_success OUT BOOLEAN,
    p_message OUT VARCHAR2
) IS
    v_old_location VARCHAR2(100);
    v_new_location VARCHAR2(100);
    e_user_not_found EXCEPTION;
BEGIN
    v_new_location := p_location;
    
    -- Get old location
    BEGIN
        SELECT location INTO v_old_location
        FROM users
        WHERE user_id = p_user_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE e_user_not_found;
    END;
    
    -- Update location
    UPDATE users
    SET location = v_new_location
    WHERE user_id = p_user_id;
    
    -- Return old location through IN OUT parameter
    p_location := 'Old: ' || v_old_location || ', New: ' || v_new_location;
    
    COMMIT;
    p_success := TRUE;
    p_message := 'Location updated successfully';
    
EXCEPTION
    WHEN e_user_not_found THEN
        ROLLBACK;
        p_success := FALSE;
        p_message := 'User not found';
    WHEN OTHERS THEN
        ROLLBACK;
        p_success := FALSE;
        p_message := 'Error: ' || SQLERRM;
END update_user_location;
/
CREATE OR REPLACE PROCEDURE process_pending_reports(
    p_batch_size IN NUMBER DEFAULT 10,
    p_processed_count OUT NUMBER
) IS
    CURSOR c_pending IS
        SELECT report_id
        FROM reports
        WHERE status = 'PENDING'
        AND ROWNUM <= p_batch_size;
    
    v_count NUMBER := 0;
BEGIN
    FOR rec IN c_pending LOOP
        BEGIN
            crop_pkg.generate_analysis(rec.report_id);
            v_count := v_count + 1;
        EXCEPTION
            WHEN OTHERS THEN
                NULL; -- Continue processing
        END;
    END LOOP;
    
    p_processed_count := v_count;
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_processed_count := 0;
        RAISE;
END process_pending_reports;
/
