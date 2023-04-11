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
  email VARCHAR2(50),
  ssn_passport VARCHAR2(20),
  contact_number NUMBER(20),
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
  lease_Status NUMBER(1) NOT NULL,
  monthly_Rent NUMBER(10,2) NOT NULL,
  CONSTRAINT unit_no FOREIGN KEY (unit_no) REFERENCES House(unit_no),
  CONSTRAINT owner_id FOREIGN KEY (owner_id) REFERENCES owner(owner_id),
  CONSTRAINT tenant_id FOREIGN KEY (tenant_id) REFERENCES Tenant(tenant_id)
);

call resident_operations('House', 'TABLE');
CREATE TABLE House (
  unit_no NUMBER(10) PRIMARY KEY NOT NULL,
  owner_id NUMBER(10) NOT NULL,
  status VARCHAR2(20) NOT NULL,
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
  request_id NUMBER(10) NOT NULL,
  address_line1 VARCHAR2(100) NOT NULL,
  address_line2 VARCHAR2(100) NOT NULL,
  CONSTRAINT request_id FOREIGN KEY (request_id) REFERENCES Requests(request_id)
);

call resident_operations('Requests', 'TABLE');
CREATE TABLE Requests (
    request_id NUMBER PRIMARY KEY,
    logged_by VARCHAR2(50) NOT NULL,
    reported_to_Employee_id NUMBER NOT NULL,
    request_type VARCHAR2(50) NOT NULL,
    request_priority VARCHAR2(10) NOT NULL,
    date_logged DATE NOT NULL,
    req_status VARCHAR2(20) NOT NULL,
    due_date DATE NOT NULL,
    CONSTRAINT chk_req_status CHECK (req_status IN ('Open', 'In Progress', 'Completed')),
    CONSTRAINT chk_request_priority CHECK (request_priority IN ('High', 'Medium', 'Low')),
    CONSTRAINT chk_request_type CHECK (request_type IN ('Maintenance', 'Plumbing', 'Pest Control')),
    CONSTRAINT chk_due_date CHECK (due_date >= date_logged),
    CONSTRAINT reported_to_Employee_id FOREIGN KEY (reported_to_Employee_id) REFERENCES Employees(Employee_id)
);

call resident_operations('Employees', 'TABLE');
CREATE TABLE Employees (
  employee_id NUMBER(10) PRIMARY KEY,
  account_id NUMBER(10) NOT NULL,
  role_id NUMBER(1) NOT NULL,
  residency_no NUMBER(10) NOT NULL,
  CONSTRAINT chk_role_id CHECK (role_id IN (1,2)),
  CONSTRAINT account_id FOREIGN KEY (account_id) REFERENCES Account_type(account_id),
  CONSTRAINT residency_no FOREIGN KEY (residency_no) REFERENCES Resident_Management(residency_no)
);

call resident_operations('Roles', 'TABLE');
CREATE TABLE Roles (
    role_id NUMBER PRIMARY KEY,
    role_name VARCHAR2(20) NOT NULL CHECK (role_name IN ('employee', 'resident manager'))
);

call resident_operations('Lease_Payments', 'TABLE');
CREATE TABLE Lease_Payments (
    lease_payment_id NUMBER PRIMARY KEY,
    payment_type VARCHAR2(50) CHECK (payment_type IN ('Cash', 'Check', 'Credit Card')),
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

call resident_operations('Inspection_check', 'TABLE');
CREATE TABLE Inspection_check (
  inspection_id NUMBER PRIMARY KEY NOT NULL,
  insp_status VARCHAR2(20) NOT NULL,
  date_logged DATE NOT NULL,
  inspected_by NUMBER NOT NULL,
  Damages_found VARCHAR2(1) NOT NULL CHECK (Damages_found IN ('Y', 'N')),
  cost_of_repairs NUMBER NOT NULL,
  unit_no NUMBER NOT NULL,
  CONSTRAINT fk_inspected_by FOREIGN KEY (inspected_by) REFERENCES Employees(employee_id),
  CONSTRAINT fk_unit_no FOREIGN KEY (unit_no) REFERENCES House(unit_no),
  CONSTRAINT chk_insp_status CHECK (insp_status IN ('Done', 'In Progress', 'Pending'))
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


call resident_operations ('INSPECTION_ID_SEQ', 'SEQUENCE');
CREATE SEQUENCE INSPECTION_ID_SEQ
START WITH 65000
INCREMENT BY 1
NOCACHE 
NOCYCLE;

call resident_operations ('INSERT_ACCOUNT', 'PROCEDURE');
CREATE OR REPLACE PROCEDURE INSERT_ACCOUNT(
    p_account_type IN VARCHAR2
) AS
  l_account_id   NUMBER;
BEGIN
  -- Get the next value from the sequence
  SELECT account_id_seq.NEXTVAL
  INTO   l_account_id
  FROM   DUAL;

  -- Insert the account ID into the appropriate table based on the account type
  IF p_account_type = 'owner' THEN
    INSERT INTO owner (owner_id, account_id)
    VALUES (owner_id_seq.NEXTVAL, l_account_id);
  ELSIF p_account_type = 'tenant' THEN
    INSERT INTO tenant (tenant_id, account_id)
    VALUES (tenant_id_seq.NEXTVAL, l_account_id);
  ELSIF p_account_type = 'employee' THEN
    INSERT INTO employees (employee_id, account_id)
    VALUES (employee_id_seq.NEXTVAL, l_account_id);
  END IF;

  -- Return the new account ID
  DBMS_OUTPUT.PUT_LINE('New Account ID: ' || l_account_id);
  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
END;
/


--------------------------------------- DATA insertion operations -------------------------------------------


INSERT INTO ACCOUNT_TYPE VALUES (ACCOUNT_ID_SEQ.NEXTVAL, 'owner', 'John', 'Doe', 30, 'johndoe@example.com', '123-45-6789', 8573132603, 'password1');


