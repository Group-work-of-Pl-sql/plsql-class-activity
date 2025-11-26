CREATE OR REPLACE PACKAGE hospital_mgmt_pkg IS

    -- Collection type for bulk patient loading
    TYPE patient_rec IS RECORD (
        patient_id      NUMBER,
        name            VARCHAR2(100),
        age             NUMBER,
        gender          VARCHAR2(10)
    );

    TYPE patient_tab IS TABLE OF patient_rec;

    -- Bulk insert procedure
    PROCEDURE bulk_load_patients(p_patients IN patient_tab);

    -- Return all patients
    FUNCTION show_all_patients RETURN SYS_REFCURSOR;

    -- Count admitted patients
    FUNCTION count_admitted RETURN NUMBER;

    -- Admit a patient
    PROCEDURE admit_patient(p_id NUMBER);

END hospital_mgmt_pkg;
/
