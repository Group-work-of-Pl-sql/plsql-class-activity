sqlplus / as sysdba

SHOW con_name;

ALTER SESSION SET CONTAINER = CDB$ROOT;

CREATE PLUGGABLE DATABASE hospital_pdb
  2  ADMIN USER hosp_admin IDENTIFIED BY Admin123
  3  FILE_NAME_CONVERT = (
  4      'D:\ORACLE21C\ORADATA\ORCL\PDBSEED\',
  5      'D:\ORACLE21C\ORADATA\ORCL\HOSPITAL_PDB\'
  6  );

ALTER PLUGGABLE DATABASE hospital_pdb OPEN;

ALTER PLUGGABLE DATABASE hospital_pdb SAVE STATE;

ALTER SESSION SET CONTAINER = hospital_pdb;

GRANT CREATE SESSION TO hosp_admin;

GRANT CREATE TABLE TO hosp_admin;

GRANT UNLIMITED TABLESPACE TO hosp_admin;

GRANT CREATE PROCEDURE TO hosp_admin;

GRANT CREATE SEQUENCE TO hosp_admin;

GRANT CREATE VIEW TO hosp_admin;

CONNECT hosp_admin/Admin123@localhost:1521/hospital_pdb;

SQL> SHOW user;

CREATE TABLE patients (
  2      patient_id      NUMBER PRIMARY KEY,
  3      name            VARCHAR2(100),
  4      age             NUMBER,
  5      gender          VARCHAR2(10),
  6      admitted_status VARCHAR2(10) DEFAULT 'NO'
  7  );


SQL> CREATE TABLE doctors (
  2      doctor_id   NUMBER PRIMARY KEY,
  3      name        VARCHAR2(100),
  4      specialty   VARCHAR2(50)
  5  );

