DECLARE
    p hospital_mgmt_pkg.patient_tab := hospital_mgmt_pkg.patient_tab();
BEGIN
    p.EXTEND(3);

    p(1).patient_id := 1;
    p(1).name := 'John Doe';
    p(1).age := 30;
    p(1).gender := 'Male';

    p(2).patient_id := 2;
    p(2).name := 'Alice Smith';
    p(2).age := 25;
    p(2).gender := 'Female';

    p(3).patient_id := 3;
    p(3).name := 'Michael Brown';
    p(3).age := 40;
    p(3).gender := 'Male';

    hospital_mgmt_pkg.bulk_load_patients(p);
END;
/
