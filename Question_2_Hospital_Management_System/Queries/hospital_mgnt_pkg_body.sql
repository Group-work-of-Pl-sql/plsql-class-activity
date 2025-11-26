CREATE OR REPLACE PACKAGE BODY hospital_mgmt_pkg IS

    ---------------------------------------------------
    -- Bulk load patients
    ---------------------------------------------------
    PROCEDURE bulk_load_patients(p_patients IN patient_tab) IS
    BEGIN
        FORALL i IN 1 .. p_patients.COUNT
            INSERT INTO patients(patient_id, name, age, gender, admitted_status)
            VALUES (
                p_patients(i).patient_id,
                p_patients(i).name,
                p_patients(i).age,
                p_patients(i).gender,
                'NO'
            );
        COMMIT;
    END bulk_load_patients;

    ---------------------------------------------------
    -- Show all patients (cursor)
    ---------------------------------------------------
    FUNCTION show_all_patients RETURN SYS_REFCURSOR IS
        rc SYS_REFCURSOR;
    BEGIN
        OPEN rc FOR SELECT * FROM patients ORDER BY patient_id;
        RETURN rc;
    END show_all_patients;

    ---------------------------------------------------
    -- Count admitted patients
    ---------------------------------------------------
    FUNCTION count_admitted RETURN NUMBER IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM patients
        WHERE admitted_status = 'YES';
        
        RETURN v_count;
    END count_admitted;

    ---------------------------------------------------
    -- Admit a patient
    ---------------------------------------------------
    PROCEDURE admit_patient(p_id NUMBER) IS
    BEGIN
        UPDATE patients
        SET admitted_status = 'YES'
        WHERE patient_id = p_id;

        COMMIT;
    END admit_patient;

END hospital_mgmt_pkg;
/
