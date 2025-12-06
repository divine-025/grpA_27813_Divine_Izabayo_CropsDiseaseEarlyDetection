DECLARE
    v_success BOOLEAN;
    v_message VARCHAR2(4000);
    v_count NUMBER;
    v_location VARCHAR2(100);
    v_total_reports NUMBER;
    v_high_risk NUMBER;
    v_most_affected VARCHAR2(100);
    v_risk_score NUMBER;
    v_ref_cursor SYS_REFCURSOR;
    v_disease_name VARCHAR2(100);
    v_crop_name VARCHAR2(50);
    v_occurrence NUMBER;
    v_contagion VARCHAR2(20);
BEGIN
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('PHASE VI TESTING - PROCEDURES & FUNCTIONS');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test 1: Update Report Status
    DBMS_OUTPUT.PUT_LINE('TEST 1: Update Report Status');
    update_report_status(201, 'RESPONDED', 'Test update', v_success, v_message);
    DBMS_OUTPUT.PUT_LINE('  Result: ' || CASE WHEN v_success THEN 'SUCCESS' ELSE 'FAILED' END);
    DBMS_OUTPUT.PUT_LINE('  Message: ' || v_message);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test 2: Generate Monthly Summary
    DBMS_OUTPUT.PUT_LINE('TEST 2: Generate Monthly Summary');
    generate_monthly_summary(2025, 12, v_total_reports, v_high_risk, v_most_affected, v_success);
    DBMS_OUTPUT.PUT_LINE('  Total Reports: ' || v_total_reports);
    DBMS_OUTPUT.PUT_LINE('  High Risk: ' || v_high_risk);
    DBMS_OUTPUT.PUT_LINE('  Most Affected Crop: ' || v_most_affected);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test 3: Calculate Risk Score Function
    DBMS_OUTPUT.PUT_LINE('TEST 3: Calculate Risk Score');
    v_risk_score := calculate_risk_score(8, 75, 'HIGH');
    DBMS_OUTPUT.PUT_LINE('  Risk Score (severity=8, confidence=75, contagion=HIGH): ' || v_risk_score);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test 4: Validate Phone Function
    DBMS_OUTPUT.PUT_LINE('TEST 4: Validate Phone');
    DBMS_OUTPUT.PUT_LINE('  0788123456: ' || CASE WHEN validate_phone('0788123456') THEN 'VALID' ELSE 'INVALID' END);
    DBMS_OUTPUT.PUT_LINE('  1234567890: ' || CASE WHEN validate_phone('1234567890') THEN 'VALID' ELSE 'INVALID' END);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test 5: Get User Report Count
    DBMS_OUTPUT.PUT_LINE('TEST 5: Get User Report Count');
    v_count := get_user_report_count(1);
    DBMS_OUTPUT.PUT_LINE('  User 1 total reports: ' || v_count);
    v_count := get_user_report_count(1, 'PENDING');
    DBMS_OUTPUT.PUT_LINE('  User 1 pending reports: ' || v_count);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test 6: Get Disease Name
    DBMS_OUTPUT.PUT_LINE('TEST 6: Get Disease Name');
    DBMS_OUTPUT.PUT_LINE('  Disease ID 1: ' || get_disease_name(1));
    DBMS_OUTPUT.PUT_LINE('  Disease ID 2: ' || get_disease_name(2));
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test 7: Average Severity by Location
    DBMS_OUTPUT.PUT_LINE('TEST 7: Average Severity by Location');
    DBMS_OUTPUT.PUT_LINE('  Kigali: ' || get_avg_severity_by_location('Kigali'));
    DBMS_OUTPUT.PUT_LINE('  Rwamagana: ' || get_avg_severity_by_location('Rwamagana'));
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test 8: Location Report with Cursor
    DBMS_OUTPUT.PUT_LINE('TEST 8: Location Report (First 5 from Kigali)');
    report_analytics_pkg.generate_location_report('Kigali');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test 9: Top Diseases
    DBMS_OUTPUT.PUT_LINE('TEST 9: Top 5 Diseases');
    v_ref_cursor := report_analytics_pkg.get_top_diseases(5);
    LOOP
        FETCH v_ref_cursor INTO v_disease_name, v_crop_name, v_occurrence, v_contagion;
        EXIT WHEN v_ref_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('  ' || v_disease_name || ' (' || v_crop_name || '): ' || 
                           v_occurrence || ' cases, ' || v_contagion || ' contagion');
    END LOOP;
    CLOSE v_ref_cursor;
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test 10: Window Functions
    DBMS_OUTPUT.PUT_LINE('TEST 10: Window Function Examples');
    show_window_function_examples;
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test 11: Process Reports with Cursor
    DBMS_OUTPUT.PUT_LINE('TEST 11: Process Reports with Bulk Collect');
    report_analytics_pkg.process_reports_with_cursor;
    DBMS_OUTPUT.PUT_LINE('');
    
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('ALL TESTS COMPLETED SUCCESSFULLY');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/