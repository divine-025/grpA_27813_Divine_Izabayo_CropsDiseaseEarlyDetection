BEGIN
    EXECUTE IMMEDIATE 'CREATE TABLE error_log (
        error_id NUMBER PRIMARY KEY,
        error_code VARCHAR2(50),
        error_message VARCHAR2(4000),
        error_procedure VARCHAR2(200),
        error_date DATE DEFAULT SYSDATE,
        additional_info VARCHAR2(2000)
    )';
    DBMS_OUTPUT.PUT_LINE('Error log table created');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -955 THEN
            DBMS_OUTPUT.PUT_LINE('Error log table already exists');
        ELSE
            RAISE;
        END IF;
END;
/
