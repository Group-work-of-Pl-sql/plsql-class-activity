DECLARE
    rc SYS_REFCURSOR;
    v_id NUMBER;
    v_name VARCHAR2(100);
    v_age NUMBER;
    v_gender VARCHAR2(10);
    v_status VARCHAR2(10);
BEGIN
    rc := hospital_mgmt_pkg.show_all_patients;

    LOOP
        FETCH rc INTO v_id, v_name, v_age, v_gender, v_status;
        EXIT WHEN rc%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_id || ' | ' || v_name || ' | ' || v_status);
    END LOOP;

    CLOSE rc;
END;
/
