DECLARE
    v NUMBER;
BEGIN
    v := hospital_mgmt_pkg.count_admitted;
    DBMS_OUTPUT.PUT_LINE('Admitted Patients = ' || v);
END;
/
