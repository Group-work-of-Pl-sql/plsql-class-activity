  Question one readme 
  # AUCA Security Database (AUCA_SECDB)

## Overview

**AUCA_SECDB** is a pluggable Oracle database designed to monitor and track suspicious login behavior. The system automatically detects when users attempt multiple failed logins and generates security alerts for investigation.

**Course**: INSY 8311 - Database Development with PL/SQL  
**Academic Year**: 2025-2026, SEM II  
**Instructor**: Eric Maniraguha

---

## Features

✅ **Login Audit Tracking** - Records all login attempts (successful and failed)  
✅ **Automatic Alert Generation** - Triggers security alerts after 3+ failed attempts in a day  
✅ **Email Notifications** - Notifies security team of suspicious activity  
✅ **Isolated Environment** - Completely separate pluggable database for security testing

---

## System Requirements

- **Oracle Database**: 21c Express Edition (XE) or later
- **SQL Developer**: Latest version
- **Storage Path**: `D:\PL-SQL\ORADATA\XE\`
- **Administrator Access**: SYSDBA privileges required for initial setup

---

## Installation

### 1. Create Pluggable Database

Connect as **SYSDBA** in SQL Developer with connection `CDB_SysAdmin`, then run:

```sql
-- Create tablespaces
CREATE TABLESPACE AUCA_DATA
  DATAFILE 'D:\PL-SQL\ORADATA\XE\AUCA_DATA_01.dbf' SIZE 200M
  AUTOEXTEND ON NEXT 50M
  MAXSIZE UNLIMITED;

CREATE TEMPORARY TABLESPACE AUCA_TEMP
  TEMPFILE 'D:\PL-SQL\ORADATA\XE\AUCA_TEMP_01.tmp' SIZE 100M
  AUTOEXTEND ON NEXT 10M
  MAXSIZE UNLIMITED;

-- Create pluggable database
CREATE PLUGGABLE DATABASE AUCA_SECDB
  ADMIN USER pdb_admin IDENTIFIED BY Admin@123
  FILE_DEST 'D:\PL-SQL\ORADATA\XE';

-- Open the PDB
ALTER PLUGGABLE DATABASE AUCA_SECDB OPEN;

-- Switch to new PDB
ALTER SESSION SET CONTAINER=AUCA_SECDB;

-- Grant privileges
GRANT DBA TO pdb_admin;
```

### 2. Create Database Connection in SQL Developer

- **Connection Name**: `AUCA_SECDB_Admin`
- **Username**: `pdb_admin`
- **Password**: `Admin@123`
- **Hostname**: `localhost`
- **Port**: `1521`
- **SID**: `AUCA_SECDB`

### 3. Create Tables and Trigger

Connect as `pdb_admin` and run:

```sql
-- Create LOGIN_AUDIT table
CREATE TABLE login_audit (
    login_id NUMBER PRIMARY KEY,
    username VARCHAR2(50) NOT NULL,
    attempt_time TIMESTAMP DEFAULT SYSTIMESTAMP,
    status VARCHAR2(10) NOT NULL CHECK (status IN ('SUCCESS', 'FAILED')),
    ip_address VARCHAR2(45),
    device_info VARCHAR2(100)
);

CREATE SEQUENCE seq_login_id START WITH 1 INCREMENT BY 1;

-- Create SECURITY_ALERTS table
CREATE TABLE security_alerts (
    alert_id NUMBER PRIMARY KEY,
    username VARCHAR2(50) NOT NULL,
    failed_attempt_count NUMBER NOT NULL,
    alert_time TIMESTAMP DEFAULT SYSTIMESTAMP,
    alert_message VARCHAR2(200),
    email_contact VARCHAR2(100),
    status VARCHAR2(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'NOTIFIED', 'RESOLVED'))
);

CREATE SEQUENCE seq_alert_id START WITH 1 INCREMENT BY 1;

-- Create trigger
CREATE OR REPLACE TRIGGER tr_check_failed_login_attempts
AFTER INSERT ON login_audit
FOR EACH ROW
DECLARE
    v_failed_count NUMBER;
    v_alert_message VARCHAR2(200);
BEGIN
    IF :NEW.status = 'FAILED' THEN
        SELECT COUNT(*)
        INTO v_failed_count
        FROM login_audit
        WHERE username = :NEW.username
        AND TRUNC(attempt_time) = TRUNC(SYSDATE)
        AND status = 'FAILED';
        
        IF v_failed_count > 2 THEN
            v_alert_message := 'User ' || :NEW.username || 
                             ' has FAILED login ' || v_failed_count || 
                             ' times TODAY. SUSPICIOUS ACTIVITY!';
            
            INSERT INTO security_alerts (
                alert_id, username, failed_attempt_count,
                alert_time, alert_message, email_contact, status
            ) VALUES (
                seq_alert_id.NEXTVAL, :NEW.username, v_failed_count,
                SYSTIMESTAMP, v_alert_message, 'security-team@auca.ac.rw', 'PENDING'
            );
        END IF;
    END IF;
END tr_check_failed_login_attempts;
/
```

---

## How It Works

### Login Behavior Policy

| Scenario | Result |
|----------|--------|
| 1st failed login attempt | ✓ Recorded in `login_audit` table |
| 2nd failed login attempt | ✓ Recorded in `login_audit` table |
| 3rd failed login attempt | 🚨 **ALERT GENERATED** + recorded in `security_alerts` |
| Successful login | ✓ Recorded in `login_audit` table (no alert) |

### Security Alert Process

1. User attempts login with wrong credentials
2. Application inserts record into `login_audit` table
3. Trigger `tr_check_failed_login_attempts` fires automatically
4. Trigger counts failed attempts for that user **today**
5. If count > 2 → alert inserted into `security_alerts` table
6. Email notification sent to security team

---

## Usage Examples

### Insert a Failed Login Attempt

```sql
INSERT INTO login_audit (login_id, username, attempt_time, status, ip_address, device_info)
VALUES (seq_login_id.NEXTVAL, 'john_doe', SYSTIMESTAMP, 'FAILED', '192.168.1.100', 'Windows PC');
COMMIT;
```

### Insert a Successful Login

```sql
INSERT INTO login_audit (login_id, username, attempt_time, status, ip_address, device_info)
VALUES (seq_login_id.NEXTVAL, 'jane_smith', SYSTIMESTAMP, 'SUCCESS', '192.168.1.101', 'Mac OS');
COMMIT;
```

### View All Login Attempts

```sql
SELECT login_id, username, attempt_time, status, ip_address
FROM login_audit
ORDER BY attempt_time DESC;
```

### View Security Alerts

```sql
SELECT alert_id, username, failed_attempt_count, alert_time, alert_message, status
FROM security_alerts
ORDER BY alert_time DESC;
```

### Mark Alert as Resolved

```sql
UPDATE security_alerts
SET status = 'RESOLVED'
WHERE alert_id = 1;
COMMIT;
```

---

## Database Structure

### login_audit Table
Stores all login attempts (successful and failed)

| Column | Type | Description |
|--------|------|-------------|
| login_id | NUMBER | Primary Key (auto-increment) |
| username | VARCHAR2(50) | User attempting login |
| attempt_time | TIMESTAMP | When the attempt occurred |
| status | VARCHAR2(10) | SUCCESS or FAILED |
| ip_address | VARCHAR2(45) | IP address of the login attempt |
| device_info | VARCHAR2(100) | Device information (OS, browser, etc.) |

### security_alerts Table
Stores security alerts for suspicious login behavior

| Column | Type | Description |
|--------|------|-------------|
| alert_id | NUMBER | Primary Key (auto-increment) |
| username | VARCHAR2(50) | User with suspicious activity |
| failed_attempt_count | NUMBER | Number of failed attempts |
| alert_time | TIMESTAMP | When alert was generated |
| alert_message | VARCHAR2(200) | Details of the alert |
| email_contact | VARCHAR2(100) | Email to notify |
| status | VARCHAR2(20) | PENDING, NOTIFIED, or RESOLVED |

---

## Key Components

### Sequences
- **seq_login_id** - Auto-generates login_id values
- **seq_alert_id** - Auto-generates alert_id values

### Trigger
- **tr_check_failed_login_attempts** - Automatically monitors failed login attempts and generates alerts

### Stored Procedures (Optional)
- **send_security_alert_email()** - Sends email notifications to security team

---

## Common Tasks

### Add New User for Login Tracking

```sql
-- User will automatically be tracked when they attempt login
INSERT INTO login_audit (login_id, username, attempt_time, status, ip_address, device_info)
VALUES (seq_login_id.NEXTVAL, 'new_user', SYSTIMESTAMP, 'SUCCESS', '192.168.1.50', 'Linux');
COMMIT;
```

### Reset Failed Attempts for a User

```sql
-- Delete old failed attempts (or wait for new day)
DELETE FROM login_audit
WHERE username = 'john_doe'
AND status = 'FAILED'
AND TRUNC(attempt_time) = TRUNC(SYSDATE);
COMMIT;
```

### Check Alert Status

```sql
SELECT * FROM security_alerts WHERE status = 'PENDING';
```

---

## Troubleshooting

### Problem: PDB won't open
**Solution**: Check if the PDB already exists
```sql
SELECT PDB_NAME FROM DBA_PDBS;
```

### Problem: Can't connect as pdb_admin
**Solution**: Verify the user was created
```sql
SELECT USERNAME FROM DBA_USERS WHERE USERNAME = 'PDB_ADMIN';
```

### Problem: Trigger not firing
**Solution**: Check trigger status
```sql
SELECT TRIGGER_NAME, STATUS FROM USER_TRIGGERS;
```

---

## Security Notes

⚠️ **Important**: This is an educational system. For production use:
- Change the default password `Admin@123`
- Implement proper email notification service
- Add audit logging for all database changes
- Use encryption for sensitive data
- Implement role-based access control (RBAC)

---

## Support & Questions

For assistance with this project:
- Contact: Eric Maniraguha (Instructor)
- Course: INSY 8311 - Database Development with PL/SQL
- Institution: AUCA (African Union Commission University)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Nov 2025 | Initial release - Login audit system with automatic alert generation |

---

**Last Updated**: November 26, 2025  
**Status**: ✅ Production Ready for Educational Use
