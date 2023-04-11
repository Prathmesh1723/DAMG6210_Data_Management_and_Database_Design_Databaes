CREATE OR REPLACE PACKAGE insertion_procedures AS
    PROCEDURE resident_operations(ObjName varchar2, ObjType varchar2);
END insertion_procedures;
/

CREATE OR REPLACE PACKAGE BODY insertion_procedures AS
PROCEDURE resident_operations(ObjName varchar2, ObjType varchar2)
IS
    T_counter number := 0;
BEGIN
    dbms_output.put_line('Start schema cleanup');
    if ObjType = 'TABLE' then
        select count(*) into T_counter from user_tables where table_name = upper(ObjName);
        if T_counter > 0 then 
            execute immediate 'drop table ' || ObjName || ' cascade constraints';
            dbms_output.put_line('....Drop table '|| ObjName);
        end if;
    end if;

    if ObjType = 'SEQUENCE' then
        select count (*) into T_counter from user_sequences where sequence_name = upper(ObjName) ;
        if T_counter > 0 then
            execute immediate 'DROP SEQUENCE ' || ObjName;
            dbms_output.put_line('....Drop Sequence '|| ObjName);
        
        end if;
    end if;

    if objType = 'USER' then
        select count(*) into T_counter from all_users where username = upper (ObjName) ;
        if T_counter > 0 then 
            execute immediate 'DROP USER' || ObjName;
        end if;
    end if;
    
    if objType = 'PROCEDURE' then
        select count(*) into T_counter From user_objects WHERE object_type = 'PROCEDURE' AND object_name = upper(ObjName);
        IF T_counter > 0 THEN
            EXECUTE IMMEDIATE 'DROP PROCEDURE' || ObjName;
        end if;
    end if;
END resident_operations;
END insertion_procedures;
/




call resident_operations('ACCOUNT_TYPE', 'TABLE');
CREATE TABLE ACCOUNT_TYPE
(
  account_id NUMBER PRIMARY KEY NOT NULL,
  account_type VARCHAR2(20),
  first_name VARCHAR2(20),
  last_name VARCHAR2(20),
  age NUMBER,
  email VARCHAR2(50) UNIQUE,
  ssn VARCHAR2(20) UNIQUE,
  contact_number NUMBER(20) UNIQUE,
  account_password VARCHAR2(20),
  CHECK (account_type IN ('owner', 'tenant', 'employee'))
);

call resident_operations('Tenant', 'TABLE');
CREATE TABLE Tenant (
  tenant_id NUMBER(20) PRIMARY KEY NOT NULL, 
  account_id NUMBER(20),
  FOREIGN KEY (account_id) REFERENCES Account_type(account_id)
);

call resident_operations('Owner', 'TABLE');
CREATE TABLE Owner (
  owner_id NUMBER(10) PRIMARY KEY NOT NULL,
  account_id NUMBER(10) NOT NULL,
  FOREIGN KEY (account_id) REFERENCES Account_type(account_id)
);

call resident_operations('Lease_agreement', 'TABLE');
CREATE TABLE Lease_agreement (
  lease_no NUMBER(10) PRIMARY KEY NOT NULL,
  unit_no NUMBER(10) NOT NULL,
  owner_id NUMBER(10) NOT NULL,
  tenant_id NUMBER(10) NOT NULL,
  lease_Date DATE NOT NULL,
  lease_Startdate DATE NOT NULL,
  lease_Term NUMBER(10) NOT NULL,
  security_Deposit NUMBER(10,2) NOT NULL,
  lease_Status NUMBER(1),
  monthly_Rent NUMBER(10,2) NOT NULL,
  CONSTRAINT unit_no FOREIGN KEY (unit_no) REFERENCES House(unit_no),
  CONSTRAINT owner_id FOREIGN KEY (owner_id) REFERENCES owner(owner_id),
  CONSTRAINT tenant_id FOREIGN KEY (tenant_id) REFERENCES Tenant(tenant_id)
);

call resident_operations('House', 'TABLE');
CREATE TABLE House (
  unit_no NUMBER(10) PRIMARY KEY NOT NULL,
  owner_id NUMBER(10) NOT NULL,
  status VARCHAR2(20),
  unit_type VARCHAR2(20) NOT NULL,
  parking_spot VARCHAR2(1) NOT NULL,
  inUnit_Laundry VARCHAR2(1) NOT NULL,
  pets_Allowed VARCHAR2(1) NOT NULL,
  no_of_bedrooms NUMBER(2) NOT NULL,
  no_of_bathrooms NUMBER(2) NOT NULL,
  residency_no NUMBER(10) NOT NULL,
  CHECK (unit_type IN ('flat', 'condo', 'apartment', 'house')),
  CHECK (parking_spot IN ('Y', 'N')),
  CHECK (inUnit_Laundry IN ('Y', 'N')),
  CHECK (pets_Allowed IN ('Y', 'N')),
  CONSTRAINT chk_status CHECK (status IN ('Available', 'Rented')),
  CONSTRAINT fk_owner_id FOREIGN KEY (owner_id) REFERENCES owner(owner_id),
  CONSTRAINT fk_residency_no FOREIGN KEY (residency_no) REFERENCES Resident_Management(residency_no)
);

call resident_operations('Resident_Management', 'TABLE');
CREATE TABLE Resident_Management (
  residency_no NUMBER(10) PRIMARY KEY,
  residency_name VARCHAR2(50) NOT NULL,
  address_line1 VARCHAR2(100) NOT NULL,
  address_line2 VARCHAR2(100) NOT NULL
);

call resident_operations('Requests', 'TABLE');
CREATE TABLE Requests (
    request_id NUMBER PRIMARY KEY,
    logged_by NUMBER NOT NULL,
    reported_to_Employee_id NUMBER NOT NULL,
    request_type VARCHAR2(50) NOT NULL,
    request_priority VARCHAR2(10) NOT NULL,
    date_logged DATE NOT NULL,
    req_status VARCHAR2(20) NOT NULL,
    due_date DATE NOT NULL,
    resolved_date DATE,
    CONSTRAINT chk_req_status CHECK (req_status IN ('Open', 'Completed')),
    CONSTRAINT chk_request_priority CHECK (request_priority IN ('High', 'Medium', 'Low')),
    CONSTRAINT chk_request_type CHECK (request_type IN ('Maintenance', 'Plumbing', 'Pest Control')),
    CONSTRAINT chk_due_date CHECK (due_date >= date_logged),
    CONSTRAINT reported_to_Employee_id FOREIGN KEY (reported_to_Employee_id) REFERENCES Employees(Employee_id),
    CONSTRAINT logged_by FOREIGN KEY (logged_by) REFERENCES House(unit_no)
);

call resident_operations('Employees', 'TABLE');
CREATE TABLE Employees (
  employee_id NUMBER(10) PRIMARY KEY,
  account_id NUMBER(10) NOT NULL,
  residency_no NUMBER(10),
  CONSTRAINT account_id FOREIGN KEY (account_id) REFERENCES Account_type(account_id),
  CONSTRAINT residency_no FOREIGN KEY (residency_no) REFERENCES Resident_Management(residency_no)
);


call resident_operations('Lease_Payments', 'TABLE');
CREATE TABLE Lease_Payments (
    lease_payment_id NUMBER PRIMARY KEY,
    payment_dueDate DATE,
    payment_status VARCHAR2(20) NOT NULL,
    payment_date DATE,
    payment_amount NUMBER,
    lease_no NUMBER REFERENCES Lease_Agreement(lease_no),
    late_fees NUMBER,
    CONSTRAINT chk_payment_status CHECK (payment_status IN ('Payment Done', 'Payment Not Done'))
);

call resident_operations('security_Deposit_Return', 'TABLE');
CREATE TABLE security_Deposit_Return (
  payment_id NUMBER PRIMARY KEY,
  return_status VARCHAR2(20) NOT NULL,
  return_date DATE,
  security_deposit_amount NUMBER,
  amount_returned DECIMAL,
  lease_no NUMBER,
  CONSTRAINT chk_return_status CHECK (return_status IN ('Returned', 'Not Returned')),
  CONSTRAINT lease_no FOREIGN KEY (lease_no) REFERENCES Lease_Agreement(lease_no)
);


----------------- ID Generation operations -----------------------------------------------------
call resident_operations ('ACCOUNT_ID_SEQ', 'SEQUENCE');
CREATE SEQUENCE ACCOUNT_ID_SEQ
START WITH 1
INCREMENT BY 1
NOCACHE NOCYCLE;

call resident_operations ('TENANT_ID_SEQ', 'SEQUENCE');
CREATE SEQUENCE TENANT_ID_SEQ
START WITH 500
INCREMENT BY 1
NOCACHE NOCYCLE;

call resident_operations ('OWNER_ID_SEQ', 'SEQUENCE');
CREATE SEQUENCE OWNER_ID_SEQ
START WITH 1000
INCREMENT BY 1
NOCACHE NOCYCLE;

call resident_operations ('LEASE_NO_SEQ', 'SEQUENCE');
CREATE SEQUENCE LEASE_NO_SEQ
START WITH 10000
INCREMENT BY 1
NOCACHE NOCYCLE;

call resident_operations ('UNIT_NO_SEQ', 'SEQUENCE');
CREATE SEQUENCE UNIT_NO_SEQ
START WITH 5000
INCREMENT BY 1
NOCACHE NOCYCLE;


call resident_operations ('RESIDENCY_NO_SEQ', 'SEQUENCE');
CREATE SEQUENCE RESIDENCY_NO_SEQ
START WITH 15000
INCREMENT BY 1
NOCACHE NOCYCLE;

call resident_operations ('REQUEST_ID_SEQ', 'SEQUENCE');
CREATE SEQUENCE REQUEST_ID_SEQ
START WITH 25000
INCREMENT BY 1
NOCACHE NOCYCLE;

call resident_operations ('EMPLOYEE_ID_SEQ', 'SEQUENCE');
CREATE SEQUENCE EMPLOYEE_ID_SEQ
START WITH 35000
INCREMENT BY 1
NOCACHE NOCYCLE;


call resident_operations ('LEASE_PAYMENT_ID_SEQ', 'SEQUENCE');
CREATE SEQUENCE LEASE_PAYMENT_ID_SEQ
START WITH 45000
INCREMENT BY 1
NOCACHE NOCYCLE;

call resident_operations ('PAYMENT_ID_SEQ', 'SEQUENCE');
CREATE SEQUENCE PAYMENT_ID_SEQ
START WITH 55000
INCREMENT BY 1
NOCACHE 
NOCYCLE;


--------------------------------------- DATA insertion operations -------------------------------------------
@triggers.sql
SET SERVEROUTPUT ON;

INSERT INTO Resident_Management VALUES ( RESIDENCY_NO_SEQ.NEXTVAL, 'Sunset Apartments', '123 Main St', 'Boston');
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'owner', 'John', 'Doe', 30, 'johndoe@gmail.com', '123-45-6789', 8573132603, 'password1');
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'condo', 'N', 'N', 'N', 1, 1, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'employee', 'James', 'Ray', 21, 'jamesray@hotmail.com', '154-35-2446', 8574393600, 'password3');
EXEC common_procedures.assign_employee_to_residency(EMPLOYEE_ID_SEQ.CURRVAL, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'employee', 'Ashley', 'Wang', 26, 'ashleywang@hotmail.com', '678-12-3457', 8574393602, 'password9');
EXEC common_procedures.assign_employee_to_residency(EMPLOYEE_ID_SEQ.CURRVAL, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'tenant', 'Scott', 'Smith', 32, 'scottsmith@gmail.com', '145-34-2356', 8574542603, 'password2');
EXEC common_procedures.insert_lease_agreement(LEASE_NO_SEQ.NEXTVAL, UNIT_NO_SEQ.CURRVAL, OWNER_ID_SEQ.CURRVAL, TENANT_ID_SEQ.CURRVAL, SYSDATE , TO_DATE('20-MAY-2023 14:30:00', 'dd-Mon-yyyy hh24:mi:ss'), 12, 1000, 800);
EXEC common_procedures.charge_rent(TO_DATE('01-JUN-2023', 'dd-Mon-yyyy'),LEASE_PAYMENT_ID_SEQ.NEXTVAL,LEASE_NO_SEQ.CURRVAL);
EXEC common_procedures.pay_rent(LEASE_PAYMENT_ID_SEQ.CURRVAL,800,TO_DATE('01-JUN-2023', 'dd-Mon-yyyy'));
EXEC common_procedures.insert_request(REQUEST_ID_SEQ.NEXTVAL,'Maintenance', 'High', TO_DATE('20-MAY-2023 14:30:00', 'dd-Mon-yyyy hh24:mi:ss'), UNIT_NO_SEQ.CURRVAL);
EXEC common_procedures.enter_deposit_return( PAYMENT_ID_SEQ.NEXTVAL, LEASE_NO_SEQ.CURRVAL);

EXEC common_procedures.update_request(REQUEST_ID_SEQ.CURRVAL, TO_DATE('20-MAY-2023 14:30:00', 'dd-Mon-yyyy hh24:mi:ss'));


INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'house', 'Y', 'Y', 'N', 3, 2, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'tenant', 'Emily', 'Jones', 28, 'emilyjones@gmail.com', '678-12-3456', 8574542604, 'password5');
EXEC common_procedures.assign_employee_to_residency(EMPLOYEE_ID_SEQ.CURRVAL, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'employee', 'James', 'Ray', 21, 'jamesrayr@hotmail.com', '154-35-2226', 8574222600, 'password3');
EXEC common_procedures.assign_employee_to_residency(EMPLOYEE_ID_SEQ.CURRVAL, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'employee', 'Massek', 'Rossi', 39, 'marcoriceeeci@gmail.com', '123-45-6908', 8574903603, 'password124');
EXEC common_procedures.assign_employee_to_residency(EMPLOYEE_ID_SEQ.CURRVAL, RESIDENCY_NO_SEQ.CURRVAL);
EXEC common_procedures.insert_lease_agreement(LEASE_NO_SEQ.NEXTVAL, UNIT_NO_SEQ.CURRVAL, OWNER_ID_SEQ.CURRVAL, TENANT_ID_SEQ.CURRVAL, SYSDATE, TO_DATE('09-JUL-2023 14:30:00', 'dd-Mon-yyyy hh24:mi:ss'), 22, 1200, 800);
EXEC common_procedures.charge_rent(TO_DATE('01-AUG-2023', 'dd-Mon-yyyy'),LEASE_PAYMENT_ID_SEQ.NEXTVAL,LEASE_NO_SEQ.CURRVAL);
EXEC common_procedures.pay_rent(LEASE_PAYMENT_ID_SEQ.CURRVAL,800,TO_DATE('04-JUN-2021', 'dd-Mon-yyyy'));
EXEC common_procedures.insert_request(REQUEST_ID_SEQ.NEXTVAL,'Maintenance', 'Medium', TO_DATE('20-MAY-2023 14:30:00', 'dd-Mon-yyyy hh24:mi:ss'), UNIT_NO_SEQ.CURRVAL);
EXEC common_procedures.update_request(REQUEST_ID_SEQ.CURRVAL, TO_DATE('21-MAY-2023 14:30:00', 'dd-Mon-yyyy hh24:mi:ss'));

INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'owner', 'Jane', 'Smith', 35, 'janesmith@gmail.com', '234-56-7890', 8573132604, 'password4');
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'apartment', 'N', 'N', 'Y', 2, 1, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'flat', 'Y', 'N', 'N', 1, 1, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'condo', 'N', 'Y', 'Y', 2, 2, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'tenant', 'Ava', 'Davis', 27, 'avadavis@gmail.com', '876-54-3211', 8574542606, 'password11');
EXEC common_procedures.insert_lease_agreement(LEASE_NO_SEQ.NEXTVAL, UNIT_NO_SEQ.CURRVAL, OWNER_ID_SEQ.CURRVAL, TENANT_ID_SEQ.CURRVAL, TO_DATE('09-JUL-2021 14:30:00' , 'dd-Mon-yyyy hh24:mi:ss'), TO_DATE('01-AUG-2021 14:30:00', 'dd-Mon-yyyy hh24:mi:ss'), 12, 1200, 800);
EXEC common_procedures.charge_rent(TO_DATE('01-SEP-2021', 'dd-Mon-yyyy'),LEASE_PAYMENT_ID_SEQ.NEXTVAL,LEASE_NO_SEQ.CURRVAL);
EXEC common_procedures.insert_request(REQUEST_ID_SEQ.NEXTVAL,'Maintenance', 'High', TO_DATE('20-SEP-2021 14:30:00', 'dd-Mon-yyyy hh24:mi:ss'), UNIT_NO_SEQ.CURRVAL);
EXEC common_procedures.insert_request(REQUEST_ID_SEQ.NEXTVAL,'Maintenance', 'Low', TO_DATE('02-NOV-2021 14:30:00', 'dd-Mon-yyyy hh24:mi:ss'), UNIT_NO_SEQ.CURRVAL);
EXEC common_procedures.insert_request(REQUEST_ID_SEQ.NEXTVAL,'Maintenance', 'Medium', TO_DATE('12-DEC-2021 14:30:00', 'dd-Mon-yyyy hh24:mi:ss'), UNIT_NO_SEQ.CURRVAL);
EXEC common_procedures.insert_request(REQUEST_ID_SEQ.NEXTVAL,'Maintenance', 'Low', TO_DATE('20-FEB-2022 14:30:00', 'dd-Mon-yyyy hh24:mi:ss'), UNIT_NO_SEQ.CURRVAL);
EXEC common_procedures.insert_request(REQUEST_ID_SEQ.NEXTVAL,'Maintenance', 'High', TO_DATE('20-MAY-2022 14:30:00', 'dd-Mon-yyyy hh24:mi:ss'), UNIT_NO_SEQ.CURRVAL);
EXEC common_procedures.insert_request(REQUEST_ID_SEQ.NEXTVAL,'Maintenance', 'High', TO_DATE('30-MAY-2022 14:30:00', 'dd-Mon-yyyy hh24:mi:ss'), UNIT_NO_SEQ.CURRVAL);
EXEC common_procedures.enter_deposit_return( PAYMENT_ID_SEQ.NEXTVAL, LEASE_NO_SEQ.CURRVAL);
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'house', 'Y', 'Y', 'N', 4, 2, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'tenant', 'Neha', 'Patel', 25, 'neha.patel@gmail.com', '543-21-6789', 8765432109, 'Password1!');
EXEC common_procedures.insert_lease_agreement(LEASE_NO_SEQ.NEXTVAL, UNIT_NO_SEQ.CURRVAL, OWNER_ID_SEQ.CURRVAL, TENANT_ID_SEQ.CURRVAL, TO_DATE('10-JUL-2022 14:30:00' , 'dd-Mon-yyyy hh24:mi:ss'), TO_DATE('02-AUG-2022 14:30:00', 'dd-Mon-yyyy hh24:mi:ss'), 24, 2500, 1000);
EXEC common_procedures.charge_rent(TO_DATE('01-SEP-2022', 'dd-Mon-yyyy'),LEASE_PAYMENT_ID_SEQ.NEXTVAL,LEASE_NO_SEQ.CURRVAL);
EXEC common_procedures.pay_rent(LEASE_PAYMENT_ID_SEQ.CURRVAL,1000,TO_DATE('02-AUG-2021', 'dd-Mon-yyyy'));
EXEC common_procedures.insert_request(REQUEST_ID_SEQ.NEXTVAL,'Plumbing', 'Low', TO_DATE('03-SEP-2023 14:30:00', 'dd-Mon-yyyy hh24:mi:ss'), UNIT_NO_SEQ.CURRVAL);
EXEC common_procedures.enter_deposit_return( PAYMENT_ID_SEQ.NEXTVAL, LEASE_NO_SEQ.CURRVAL);

EXEC common_procedures.update_request(REQUEST_ID_SEQ.CURRVAL, TO_DATE('06-SEP-2023 14:30:00', 'dd-Mon-yyyy hh24:mi:ss'));


INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'owner', 'Robert', 'Johnson', 43, 'robertjohnson@yahoo.com', '876-54-3210', 8573132605, 'password7');
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'tenant', 'Sophie', 'Garcia', 30, 'sophiegarcia@gmail.com', '234-56-7891', 8574542605, 'password8');
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'apartment', 'N', 'N', 'Y', 3, 2, RESIDENCY_NO_SEQ.CURRVAL);
EXEC common_procedures.insert_lease_agreement(LEASE_NO_SEQ.NEXTVAL, UNIT_NO_SEQ.CURRVAL, OWNER_ID_SEQ.CURRVAL, TENANT_ID_SEQ.CURRVAL, TO_DATE('01-SEP-2023', 'dd-Mon-yyyy'), TO_DATE('01-OCT-2022', 'dd-Mon-yyyy'), 6, 1000, 1200);
EXEC common_procedures.charge_rent(TO_DATE('01-NOV-2022', 'dd-Mon-yyyy'),LEASE_PAYMENT_ID_SEQ.NEXTVAL,LEASE_NO_SEQ.CURRVAL);

EXEC common_procedures.insert_request(REQUEST_ID_SEQ.NEXTVAL,'Pest Control', 'Low', TO_DATE('03-DEC-2022 14:30:00', 'dd-Mon-yyyy hh24:mi:ss'), UNIT_NO_SEQ.CURRVAL);
EXEC common_procedures.update_request(REQUEST_ID_SEQ.CURRVAL, TO_DATE('06-DEC-2022 14:30:00', 'dd-Mon-yyyy hh24:mi:ss'));
EXEC common_procedures.insert_request(REQUEST_ID_SEQ.NEXTVAL,'Pest Control', 'Medium', TO_DATE('30-JAN-2023 09:28:00', 'dd-Mon-yyyy hh24:mi:ss'), UNIT_NO_SEQ.CURRVAL);
EXEC common_procedures.update_request(REQUEST_ID_SEQ.CURRVAL, TO_DATE('01-FEB-2023 14:30:00', 'dd-Mon-yyyy hh24:mi:ss'));
EXEC common_procedures.insert_request(REQUEST_ID_SEQ.NEXTVAL,'Plumbing', 'Low', TO_DATE('17-MAR-2023 18:38:00', 'dd-Mon-yyyy hh24:mi:ss'), UNIT_NO_SEQ.CURRVAL);
EXEC common_procedures.update_request(REQUEST_ID_SEQ.CURRVAL, TO_DATE('19-MAR-2023 14:30:00', 'dd-Mon-yyyy hh24:mi:ss'));
EXEC common_procedures.insert_request(REQUEST_ID_SEQ.NEXTVAL,'Maintenance', 'Medium', TO_DATE('03-APR-2023 14:30:00', 'dd-Mon-yyyy hh24:mi:ss'), UNIT_NO_SEQ.CURRVAL);
EXEC common_procedures.update_request(REQUEST_ID_SEQ.CURRVAL, TO_DATE('04-APR-2023 14:30:00', 'dd-Mon-yyyy hh24:mi:ss'));
EXEC common_procedures.enter_deposit_return( PAYMENT_ID_SEQ.NEXTVAL, LEASE_NO_SEQ.CURRVAL);

EXEC common_procedures.update_request(REQUEST_ID_SEQ.CURRVAL, TO_DATE('04-OCT-2023 14:30:00', 'dd-Mon-yyyy hh24:mi:ss'));

INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'tenant', 'Rajesh', 'Singh', 35, 'rajesh.singh@gmail.com', '890-12-3456', 5432109876, 'StrongPassword!');
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'flat', 'Y', 'N', 'N', 2, 1, RESIDENCY_NO_SEQ.CURRVAL);
EXEC common_procedures.insert_lease_agreement(LEASE_NO_SEQ.NEXTVAL, UNIT_NO_SEQ.CURRVAL, OWNER_ID_SEQ.CURRVAL, TENANT_ID_SEQ.CURRVAL, SYSDATE, TO_DATE('01-JUN-2023', 'dd-Mon-yyyy'), 6, 1500, 1500);
EXEC common_procedures.charge_rent(TO_DATE('01-JUL-2023', 'dd-Mon-yyyy'),LEASE_PAYMENT_ID_SEQ.NEXTVAL,LEASE_NO_SEQ.CURRVAL);
EXEC common_procedures.pay_rent(LEASE_PAYMENT_ID_SEQ.CURRVAL,1510,TO_DATE('02-JUL-2023', 'dd-Mon-yyyy'));
EXEC common_procedures.insert_request(REQUEST_ID_SEQ.NEXTVAL,'Pest Control', 'Low', TO_DATE('03-AUG-2021 14:30:00', 'dd-Mon-yyyy hh24:mi:ss'), UNIT_NO_SEQ.CURRVAL);
EXEC common_procedures.enter_deposit_return( PAYMENT_ID_SEQ.NEXTVAL, LEASE_NO_SEQ.CURRVAL);

EXEC common_procedures.update_request(REQUEST_ID_SEQ.CURRVAL, TO_DATE('04-AUG-2021 14:30:00', 'dd-Mon-yyyy hh24:mi:ss'));

INSERT INTO Resident_Management VALUES ( RESIDENCY_NO_SEQ.NEXTVAL, 'Riverbend Apartments', '222 Walnut St', 'Boston');
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'employee', 'Ashley', 'Wang', 26, 'ashleywanggg@hotmail.com', '678-12-3333', 8574333602, 'password9');
EXEC common_procedures.assign_employee_to_residency(EMPLOYEE_ID_SEQ.CURRVAL, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'employee', 'William', 'Kim', 29, 'williamkim@hotmail.com', '234-56-7892', 8574393603, 'password12');
EXEC common_procedures.assign_employee_to_residency(EMPLOYEE_ID_SEQ.CURRVAL, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Rented', 'condo', 'N', 'Y', 'Y', 2, 2, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'condo', 'N', 'N', 'N', 1, 1, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'owner', 'David', 'Brown', 52, 'davidbrown@gmail.com', '546-98-1235', 8573132606, 'password10');
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'tenant', 'Adrien', 'Lefebvre', 50, 'adrien.lefebvre@gmail.com', '789-01-2345', 7890123456, 'Password1!');
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'apartment', 'N', 'Y', 'N', 1, 1, RESIDENCY_NO_SEQ.CURRVAL);
EXEC common_procedures.insert_lease_agreement(LEASE_NO_SEQ.NEXTVAL, UNIT_NO_SEQ.CURRVAL, OWNER_ID_SEQ.CURRVAL, TENANT_ID_SEQ.CURRVAL, TO_DATE('10-SEP-2022', 'dd-Mon-yyyy'), TO_DATE('01-NOV-2022', 'dd-Mon-yyyy'), 12, 2200, 1900);
EXEC common_procedures.charge_rent(TO_DATE('01-DEC-2022', 'dd-Mon-yyyy'),LEASE_PAYMENT_ID_SEQ.NEXTVAL,LEASE_NO_SEQ.CURRVAL);
EXEC common_procedures.enter_deposit_return( PAYMENT_ID_SEQ.NEXTVAL, LEASE_NO_SEQ.CURRVAL);

INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'flat', 'Y', 'N', 'Y', 3, 2, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'tenant', 'Julia', 'Bauer', 30, 'julia.bauer@gmail.com', '678-00-1234', 6789442345, 'Password1!');
EXEC common_procedures.insert_lease_agreement(LEASE_NO_SEQ.NEXTVAL, UNIT_NO_SEQ.CURRVAL, OWNER_ID_SEQ.CURRVAL, TENANT_ID_SEQ.CURRVAL, SYSDATE, TO_DATE('01-DEC-2023', 'dd-Mon-yyyy'), 12, 2500, 2000);
EXEC common_procedures.enter_deposit_return( PAYMENT_ID_SEQ.NEXTVAL, LEASE_NO_SEQ.CURRVAL);


INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'house', 'Y', 'Y', 'Y', 4, 3, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'tenant', 'Anna', 'Kovalenko', 45, 'anna.kovalenko@gmail.com', '345-67-8901', 3456789012, 'Password1!');
EXEC common_procedures.insert_lease_agreement(LEASE_NO_SEQ.NEXTVAL, UNIT_NO_SEQ.CURRVAL, OWNER_ID_SEQ.CURRVAL, TENANT_ID_SEQ.CURRVAL, TO_DATE('08-SEP-2022', 'dd-Mon-yyyy'), TO_DATE('01-OCT-2022', 'dd-Mon-yyyy'), 24, 1000, 1200);
EXEC common_procedures.charge_rent(TO_DATE('01-NOV-2022', 'dd-Mon-yyyy'),LEASE_PAYMENT_ID_SEQ.NEXTVAL,LEASE_NO_SEQ.CURRVAL);
EXEC common_procedures.pay_rent(LEASE_PAYMENT_ID_SEQ.CURRVAL,1200,TO_DATE('01-NOV-2022', 'dd-Mon-yyyy'));

INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'condo', 'N', 'N', 'N', 2, 2, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'tenant', 'Matteo', 'Ricci', 28, 'matteo.ricci@gmail.com', '234-56-1400', 2348598901, 'Password1!');
EXEC common_procedures.insert_lease_agreement(LEASE_NO_SEQ.NEXTVAL, UNIT_NO_SEQ.CURRVAL, OWNER_ID_SEQ.CURRVAL, TENANT_ID_SEQ.CURRVAL, TO_DATE('06-SEP-2021', 'dd-Mon-yyyy'), TO_DATE('01-OCT-2021', 'dd-Mon-yyyy'), 24, 4000, 2800);
EXEC common_procedures.enter_deposit_return( PAYMENT_ID_SEQ.NEXTVAL, LEASE_NO_SEQ.CURRVAL);
EXEC common_procedures.charge_rent(TO_DATE('01-NOV-2021', 'dd-Mon-yyyy'),LEASE_PAYMENT_ID_SEQ.NEXTVAL,LEASE_NO_SEQ.CURRVAL);
EXEC common_procedures.pay_rent(LEASE_PAYMENT_ID_SEQ.CURRVAL,2870,TO_DATE('08-NOV-2021', 'dd-Mon-yyyy'));
EXEC common_procedures.charge_rent(TO_DATE('01-DEC-2021', 'dd-Mon-yyyy'),LEASE_PAYMENT_ID_SEQ.NEXTVAL,LEASE_NO_SEQ.CURRVAL);
EXEC common_procedures.pay_rent(LEASE_PAYMENT_ID_SEQ.CURRVAL,2800,TO_DATE('01-DEC-2021', 'dd-Mon-yyyy'));


INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'apartment', 'N', 'Y', 'N', 2, 1, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO Resident_Management VALUES ( RESIDENCY_NO_SEQ.NEXTVAL, 'Pine View Estates', '456 Elm St', 'New York');
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'employee', 'Ravi', 'Kumar', 32, 'ravik.kumar@yahoo.com', '238-56-7890', 7844321098, 'Secret123');
EXEC common_procedures.assign_employee_to_residency(EMPLOYEE_ID_SEQ.CURRVAL, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'employee', 'Vikram', 'Yadav', 27, 'vikram.yadav@hotmail.com', '987-65-4321', 4321098765, 'Pass123word');
EXEC common_procedures.assign_employee_to_residency(EMPLOYEE_ID_SEQ.CURRVAL, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'employee', 'Gaius', 'Julius', 32, 'gjulius@gmail.com', '899-56-7890', 8574398804, 'password123');
EXEC common_procedures.assign_employee_to_residency(EMPLOYEE_ID_SEQ.CURRVAL, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'apartment', 'Y', 'N', 'N', 1, 1, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'tenant', 'Mohamed', 'Ahmed', 35, 'mohamed.ahmed@gmail.com', '123-45-6666', 1234666890, 'Password1!');
EXEC common_procedures.insert_lease_agreement(LEASE_NO_SEQ.NEXTVAL, UNIT_NO_SEQ.CURRVAL, OWNER_ID_SEQ.CURRVAL, TENANT_ID_SEQ.CURRVAL, TO_DATE('06-MAY-2021', 'dd-Mon-yyyy'), TO_DATE('01-JUN-2021', 'dd-Mon-yyyy'), 12, 4000, 2200);
EXEC common_procedures.enter_deposit_return( PAYMENT_ID_SEQ.NEXTVAL, LEASE_NO_SEQ.CURRVAL);
EXEC common_procedures.charge_rent(TO_DATE('01-AUG-2021', 'dd-Mon-yyyy'),LEASE_PAYMENT_ID_SEQ.NEXTVAL,LEASE_NO_SEQ.CURRVAL);
EXEC common_procedures.insert_request(REQUEST_ID_SEQ.NEXTVAL,'Maintenance', 'High', TO_DATE('20-MAY-2023 14:30:00', 'dd-Mon-yyyy hh24:mi:ss'), UNIT_NO_SEQ.CURRVAL);


INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'owner', 'Adrien', 'Lefebvre', 50, 'adrien.lefebvreiu@gmail.com', '700-00-2345', 7899005450, 'Password1!');
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'house', 'N', 'Y', 'N', 3, 2, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'tenant', 'Julia', 'Bauer', 30, 'julia.bauer34@gmail.com', '678-90-1224', 6789019705, 'Password1!');
EXEC common_procedures.insert_lease_agreement(LEASE_NO_SEQ.NEXTVAL, UNIT_NO_SEQ.CURRVAL, OWNER_ID_SEQ.CURRVAL, TENANT_ID_SEQ.CURRVAL, TO_DATE('21-MAR-2022', 'dd-Mon-yyyy'), TO_DATE('01-JUN-2022', 'dd-Mon-yyyy'), 12, 1000, 1200);
EXEC common_procedures.enter_deposit_return( PAYMENT_ID_SEQ.NEXTVAL, LEASE_NO_SEQ.CURRVAL);
EXEC common_procedures.charge_rent(TO_DATE('01-JUL-2022', 'dd-Mon-yyyy'),LEASE_PAYMENT_ID_SEQ.NEXTVAL,LEASE_NO_SEQ.CURRVAL);
EXEC common_procedures.pay_rent(LEASE_PAYMENT_ID_SEQ.CURRVAL,1240,TO_DATE('05-JUL-2022', 'dd-Mon-yyyy'));

INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'flat', 'N', 'Y', 'N', 2, 1, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'condo', 'Y', 'N', 'Y', 1, 1, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'house', 'Y', 'Y', 'N', 4, 3, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'tenant', 'Giuseppe', 'Rossi', 40, 'giuseppe.rossi@gmail.com', '555-89-0123', 5558901234, 'Password1!');
EXEC common_procedures.insert_lease_agreement(LEASE_NO_SEQ.NEXTVAL, UNIT_NO_SEQ.CURRVAL, OWNER_ID_SEQ.CURRVAL, TENANT_ID_SEQ.CURRVAL,  TO_DATE('01-AUG-2022', 'dd-Mon-yyyy'), TO_DATE('01-OCT-2022', 'dd-Mon-yyyy'), 24, 4000, 2800);
EXEC common_procedures.enter_deposit_return( PAYMENT_ID_SEQ.NEXTVAL, LEASE_NO_SEQ.CURRVAL);
EXEC common_procedures.charge_rent(TO_DATE('01-NOV-2022', 'dd-Mon-yyyy'),LEASE_PAYMENT_ID_SEQ.NEXTVAL,LEASE_NO_SEQ.CURRVAL);
EXEC common_procedures.pay_rent(LEASE_PAYMENT_ID_SEQ.CURRVAL,2840,TO_DATE('05-NOV-2022', 'dd-Mon-yyyy'));

INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'owner', 'Maria', 'Gonzalez', 41, 'mariagonzalez@yahoo.com', '678-12-3458', 8573132607, 'password13');
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'apartment', 'N', 'N', 'N', 1, 1, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'tenant', 'Marco', 'Fernández', 27, 'marco.fernandez@gmail.com', '899-12-3456', 8906354567, 'Password1!');
EXEC common_procedures.insert_lease_agreement(LEASE_NO_SEQ.NEXTVAL, UNIT_NO_SEQ.CURRVAL, OWNER_ID_SEQ.CURRVAL, TENANT_ID_SEQ.CURRVAL, TO_DATE('06-SEP-2022', 'dd-Mon-yyyy'), TO_DATE('01-NOV-2022', 'dd-Mon-yyyy'), 24, 4000, 2800);
EXEC common_procedures.enter_deposit_return( PAYMENT_ID_SEQ.NEXTVAL, LEASE_NO_SEQ.CURRVAL);
EXEC common_procedures.charge_rent(TO_DATE('01-DEC-2022', 'dd-Mon-yyyy'),LEASE_PAYMENT_ID_SEQ.NEXTVAL,LEASE_NO_SEQ.CURRVAL);


INSERT INTO Resident_Management VALUES ( RESIDENCY_NO_SEQ.NEXTVAL, 'Meadow Gardens', '789 Oak St', 'Dallas');
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'employee', 'Lucius', 'Cornelius', 31, 'lcornelius@hotmail.com', '900-89-0123', 8574563604, 'password456');
EXEC common_procedures.assign_employee_to_residency(EMPLOYEE_ID_SEQ.CURRVAL, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'employee', 'Octavia', 'Claudius', 27, 'oclaudius@yahoo.com', '814-12-3456', 8574398704, 'password789');
EXEC common_procedures.assign_employee_to_residency(EMPLOYEE_ID_SEQ.CURRVAL, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'flat', 'N', 'Y', 'N', 1, 1, RESIDENCY_NO_SEQ.CURRVAL);


INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'house', 'Y', 'Y', 'Y', 4, 3, RESIDENCY_NO_SEQ.CURRVAL);

INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'owner', 'Amit', 'Sharma', 28, 'amitsharma@gmail.com', '678-90-1234', 9876543210, 'Passw0rd!');
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'flat', 'N', 'N', 'N', 1, 1, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'condo', 'Y', 'Y', 'N', 2, 1, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'tenant', 'Alok', 'Jain', 29, 'alok.jain@gmail.com', '799-91-2345', 2109504999, 'Password@123');
EXEC common_procedures.insert_lease_agreement(LEASE_NO_SEQ.NEXTVAL, UNIT_NO_SEQ.CURRVAL, OWNER_ID_SEQ.CURRVAL, TENANT_ID_SEQ.CURRVAL, TO_DATE('06-SEP-2022', 'dd-Mon-yyyy'), TO_DATE('01-NOV-2022', 'dd-Mon-yyyy'), 24, 4000, 2800);
EXEC common_procedures.enter_deposit_return( PAYMENT_ID_SEQ.NEXTVAL, LEASE_NO_SEQ.CURRVAL);


INSERT INTO Resident_Management VALUES ( RESIDENCY_NO_SEQ.NEXTVAL, 'Hilltop Condos', '111 Maple Ave', 'NewYork');
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'employee', 'Aurelia', 'Pompeia', 29, 'apompeia@gmail.com', '834-56-7890', 8574398805, 'password012');
EXEC common_procedures.assign_employee_to_residency(EMPLOYEE_ID_SEQ.CURRVAL, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'employee', 'Sanjay', 'Mishra', 31, 'sanjay.mishra@yahoo.com', '456-78-9012', 1098765432, 'StrongPass!');
EXEC common_procedures.assign_employee_to_residency(EMPLOYEE_ID_SEQ.CURRVAL, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'employee', 'Marco', 'Ricci', 29, 'marcoricci@gmail.com', '123-45-6888', 8574443603, 'password124');
EXEC common_procedures.assign_employee_to_residency(EMPLOYEE_ID_SEQ.CURRVAL, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'apartment', 'N', 'N', 'Y', 1, 1, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'owner', 'Chathuranga', 'Jayawardena', 46, 'chathuranga.jayawardena@gmail.com', '923-87-2315', 94778765432, 'MyPassw0rd!');
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'flat', 'Y', 'Y', 'N', 2, 1, RESIDENCY_NO_SEQ.CURRVAL);

INSERT INTO Resident_Management VALUES ( RESIDENCY_NO_SEQ.NEXTVAL, 'Cityscape Towers', '444 Broad St', 'San Francisco');

INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'employee', 'Giulia', 'Rossi', 32, 'giuliarossi@yahoo.com', '234-88-7890', 8570993603, 'password34');
EXEC common_procedures.assign_employee_to_residency(EMPLOYEE_ID_SEQ.CURRVAL, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'employee', 'Giovanni', 'Rizzo', 28, 'giovannirizzo@hotmail.com', '776-67-8912', 8574093603, 'password56');
EXEC common_procedures.assign_employee_to_residency(EMPLOYEE_ID_SEQ.CURRVAL, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'house', 'Y', 'Y', 'Y', 4, 3, RESIDENCY_NO_SEQ.CURRVAL);

INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'owner', 'Kavisha', 'Rajapaksha', 31, 'kavisha.rajapaksha@gmail.com', '908-23-5467', 94775894325, 'MyPassw0rd!');
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'flat', 'N', 'N', 'N', 1, 1, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Rented', 'condo', 'Y', 'Y', 'N', 2, 1, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'house', 'Y', 'N', 'N', 3, 2, RESIDENCY_NO_SEQ.CURRVAL);

INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'owner', 'Priya', 'Verma', 24, 'priya.verma@gmail.com', '345-07-8901', 3210097654, 'MySecret!');
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Rented', 'flat', 'N', 'Y', 'Y', 2, 1, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'apartment', 'N', 'N', 'Y', 2, 1, RESIDENCY_NO_SEQ.CURRVAL);

INSERT INTO Resident_Management VALUES ( RESIDENCY_NO_SEQ.NEXTVAL, 'Mountain View Apartments', '555 Pine St', 'San Francisco');

INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'employee', 'Lorenzo', 'Bianchi', 27, 'lorenzobianchi@gmail.com', '400-78-9123', 8574367603, 'password78');
EXEC common_procedures.assign_employee_to_residency(EMPLOYEE_ID_SEQ.CURRVAL, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'employee', 'Sofia', 'Conti', 31, 'sofiaconti@hotmail.com', '559-89-0123', 8574557773, 'password90');
EXEC common_procedures.assign_employee_to_residency(EMPLOYEE_ID_SEQ.CURRVAL, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'flat', 'Y', 'N', 'Y', 2, 1, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Rented', 'house', 'Y', 'Y', 'Y', 4, 3, RESIDENCY_NO_SEQ.CURRVAL);


INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'owner', 'Sneha', 'Shah', 26, 'sneha.shah@gmail.com', '901-24-4567', 9876543219, 'MyPassw0rd!'); 
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'house', 'Y', 'N', 'N', 3, 2, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO Resident_Management VALUES ( RESIDENCY_NO_SEQ.NEXTVAL, 'Central Park West', '777 5th Ave', 'New York');

INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'employee', 'Alessandro', 'Greco', 26, 'alessandrogreco@yahoo.com', '678-00-2345', 8574893603, 'password123');
EXEC common_procedures.assign_employee_to_residency(EMPLOYEE_ID_SEQ.CURRVAL, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'employee', 'Francesca', 'Gallo', 30, 'francescagallo@gmail.com', '799-12-3456', 8574398603, 'password456');
EXEC common_procedures.assign_employee_to_residency(EMPLOYEE_ID_SEQ.CURRVAL, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Rented', 'flat', 'N', 'Y', 'Y', 2, 1, RESIDENCY_NO_SEQ.CURRVAL);

INSERT INTO Resident_Management VALUES ( RESIDENCY_NO_SEQ.NEXTVAL, 'Beachside Villas', '123 Ocean Blvd', 'Miami');
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'employee', 'Simone', 'Moretti', 29, 'simonemoretti@hotmail.com', '899-92-3456', 8574398803, 'password789');
EXEC common_procedures.assign_employee_to_residency(EMPLOYEE_ID_SEQ.CURRVAL, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'flat', 'Y', 'Y', 'N', 1, 1, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'apartment', 'N', 'N', 'Y', 2, 1, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'owner', 'Nadeesha', 'Perera', 35, 'nadeesha.perera@gmail.com', '934-34-2234', 94771234567, 'MyPassw0rd!');
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'apartment', 'N', 'N', 'Y', 1, 1, RESIDENCY_NO_SEQ.CURRVAL);

INSERT INTO Resident_Management VALUES ( RESIDENCY_NO_SEQ.NEXTVAL, 'Harbor View Condos', '456 Harbor St', 'Miami');

INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'employee', 'Marta', 'Santoro', 28, 'martasantoro@yahoo.com', '909-23-4567', 8574563603, 'password012');
EXEC common_procedures.assign_employee_to_residency(EMPLOYEE_ID_SEQ.CURRVAL, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'employee', 'Ludovico', 'Ferrari', 26, 'ludovicoferrari@hotmail.com', '814-34-5678', 8574398703, 'password345');
EXEC common_procedures.assign_employee_to_residency(EMPLOYEE_ID_SEQ.CURRVAL, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'apartment', 'Y', 'N', 'N', 2, 1, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'owner', 'Dilshan', 'Fernando', 28, 'dilshan.fernando@gmail.com', '917-45-6789', 94773245678, 'MyPassw0rd!');
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'apartment', 'Y', 'N', 'N', 2, 1, RESIDENCY_NO_SEQ.CURRVAL);
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'house', 'Y', 'N', 'Y', 3, 2, RESIDENCY_NO_SEQ.CURRVAL);

INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'owner', 'Sandun', 'Silva', 42, 'sandun.silva@gmail.com', '921-67-3456', 94779785634, 'MyPassw0rd!');
INSERT INTO HOUSE VALUES (UNIT_NO_SEQ.NEXTVAL, OWNER_ID_SEQ.CURRVAL, 'Available', 'apartment', 'N', 'Y', 'N', 1, 1, RESIDENCY_NO_SEQ.CURRVAL);
EXEC common_procedures.insert_lease_agreement(LEASE_NO_SEQ.NEXTVAL, UNIT_NO_SEQ.CURRVAL, OWNER_ID_SEQ.CURRVAL, TENANT_ID_SEQ.CURRVAL, TO_DATE('10-May-2021 14:30:00' , 'dd-Mon-yyyy hh24:mi:ss'), TO_DATE('01-JUN-2022 14:30:00', 'dd-Mon-yyyy hh24:mi:ss'), 24, 2800, 1200);
EXEC common_procedures.charge_rent(TO_DATE('01-JUL-2022', 'dd-Mon-yyyy'),LEASE_PAYMENT_ID_SEQ.NEXTVAL,LEASE_NO_SEQ.CURRVAL);
EXEC common_procedures.pay_rent(LEASE_PAYMENT_ID_SEQ.CURRVAL,1200,TO_DATE('02-AUG-2021', 'dd-Mon-yyyy'));
EXEC common_procedures.insert_request(REQUEST_ID_SEQ.NEXTVAL,'Pest Control', 'High', TO_DATE('03-SEP-2021 14:30:00', 'dd-Mon-yyyy hh24:mi:ss'), UNIT_NO_SEQ.CURRVAL);
EXEC common_procedures.enter_deposit_return( PAYMENT_ID_SEQ.NEXTVAL, LEASE_NO_SEQ.CURRVAL);

EXEC common_procedures.update_request(REQUEST_ID_SEQ.CURRVAL, TO_DATE('03-SEP-2021 03:30:00', 'dd-Mon-yyyy hh24:mi:ss'));


COMMIT;



