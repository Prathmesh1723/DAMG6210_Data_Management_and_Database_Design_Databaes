set serveroutput on
declare
    v_table_exists varchar(1) := 'Y';
    v_sql varchar(2000);
begin
   dbms_output.put_line('Start schema cleanup');
   for i in (select 'TENANT' table_name from dual union all
   select 'HOUSE' table_name from dual union all
             select 'OWNER' table_name from dual union all
             select 'RESIDENT_MANAGEMENT' from dual union all
             select 'ACCOUNT_TYPE' table_name from dual
             
   )
   loop
   dbms_output.put_line('....Drop table '||i.table_name);
   begin
       select 'Y' into v_table_exists
       from USER_TABLES
       where TABLE_NAME=i.table_name;

       v_sql := 'drop table '||i.table_name;
       execute immediate v_sql;
       dbms_output.put_line('........Table '||i.table_name||' dropped successfully');
       
   exception
       when no_data_found then
           dbms_output.put_line('........Table already dropped');
   end;
   end loop;
   dbms_output.put_line('Schema cleanup successfully completed');
exception
   when others then
      dbms_output.put_line('Failed to execute code:'||sqlerrm);
end;

-- Create the Account_type table
CREATE TABLE Account_type (
  account_id NUMBER PRIMARY KEY NOT NULL,
  account_type VARCHAR2(20),
  first_name VARCHAR2(20),
  last_name VARCHAR2(20),
  age NUMBER,
  email VARCHAR2(50),
  ssn_passport VARCHAR2(20),
  account_password VARCHAR2(20),
  CHECK (account_type IN ('owner', 'tenant', 'employee'))
);

INSERT INTO Account_type (account_id, account_type, first_name, last_name, age, email, ssn_passport, account_password)
  select  6041, 'owner', 'John', 'Doe', 30, 'johndoe@example.com', '123-45-6789', 'password1' from dual union all
  select  6042, 'tenant', 'Bob', 'Smith', 40, 'bobsmith@example.com', '789-12-3456', 'password3' from dual union all
  select  6043, 'tenant', 'Alice', 'Johnson', 35, 'alicejohnson@example.com', '234-56-7890', 'password4' from dual union all
  select  6044, 'tenant', 'David', 'Brown', 50, 'davidbrown@example.com', '567-89-1234', 'password5' from dual union all
  select  6045, 'employee', 'Emily', 'Davis', 28, 'emilydavis@example.com', '901-23-4567', 'password6' from dual union all
  select  6055, 'employee', 'Rose', 'Davinci', 29, 'rosedavis@example.com', '901-24-5567', 'password65' from dual union all
  select  6046, 'employee', 'Steven', 'Wilson', 45, 'stevenwilson@example.com', '345-67-8901', 'password7' from dual union all
  select  6066, 'owner', 'Steff', 'Wild', 35, 'steff@example.com', '345-67-8601', 'password8' from dual union all
  select  6070, 'owner', 'Derek', 'Roy', 65, 'derekRoy@example.com', '345-67-8801', 'password9' from dual union all
  select  6047, 'tenant', 'Karen', 'Miller', 32, 'karenmiller@example.com', '678-90-1234', 'password11' from dual;


-- Create the Tenant table
CREATE TABLE Tenant (
  tenant_id NUMBER(20) PRIMARY KEY NOT NULL, 
  account_id NUMBER(20),
  contact_number NUMBER(20),
  FOREIGN KEY (account_id) REFERENCES Account_type(account_id)
);

INSERT INTO Tenant (tenant_id, account_id, contact_number)
  select 1063, 6042,2345678901 from dual union all
  select 1066, 6043,3456789012 from dual union all
  select 1206, 6044,4567890123 from dual union all
  select 1008, 6047,4567889504 from dual;
  
-- Create the Owner table
CREATE TABLE Owner (
  owner_id NUMBER(10) PRIMARY KEY NOT NULL,
  account_id NUMBER(10) NOT NULL,
  FOREIGN KEY (account_id) REFERENCES Account_type(account_id)
);

INSERT INTO Owner (owner_id, account_id)
select 11,  6041 from dual union all
select 18,  6043 from dual union all
select 21,  6066 from dual union all
select 14,  6070 from dual;

-- Create the Lease_agreement table
CREATE TABLE Lease_agreement (
  lease_no NUMBER(10) PRIMARY KEY NOT NULL,
  unit_no NUMBER(10) NOT NULL,
  owner_id NUMBER(10) NOT NULL,
  tenant_id NUMBER(10) NOT NULL,
  lease_Date DATE NOT NULL,
  lease_Startdate DATE NOT NULL,
  lease_EndDate DATE NOT NULL,
  lease_Term NUMBER(10) NOT NULL,
  security_Deposit NUMBER(10,2) NOT NULL,
  lease_Status NUMBER(1) NOT NULL,
  monthly_Rent NUMBER(10,2) NOT NULL,
  FOREIGN KEY (unit_no) REFERENCES House(unit_no),
  FOREIGN KEY (owner_id) REFERENCES Owner(owner_id),
  FOREIGN KEY (tenant_id) REFERENCES Tenant(tenant_id)
);


INSERT INTO Lease_agreement (lease_no, unit_no, owner_id, tenant_id, lease_Date, lease_Startdate, lease_Enddate, lease_Term, security_Deposit, lease_Status, monthly_Rent)
select 1001, 101, 552, 1063, '2022-01-01', '2022-02-01', '2023-01-31', 12, 2000, 1, 1000 from dual union all
select 1002, 102, 522, 1066, '2021-01-02', '2021-01-02', '2023-01-31', 24, 1500, 1, 800 from dual union all
select 1003, 103, 522, 1206, '2022-01-03', '2022-02-01', '2023-01-31', 12, 1000, 1, 600 from dual union all
select 1004, 104, 480, 1045, '2022-01-04', '2022-02-01', '2023-01-31', 12, 2500, 1, 1200 from dual union all
select 1008, 108, 488, 1008, '2022-01-08', '2022-02-01', '2023-01-31', 12, 1000, 1, 1600 from dual;


-- Create the house table
CREATE TABLE House (
  unit_no NUMBER(10) PRIMARY KEY NOT NULL,
  owner_id NUMBER(10) NOT NULL,
  building_no VARCHAR2(20) NOT NULL,
  unit_type VARCHAR2(20) NOT NULL,
  parking_spot VARCHAR2(1) NOT NULL,
  inUnit_Laundry VARCHAR2(1) NOT NULL,
  pets_Allowed VARCHAR2(1) NOT NULL,
  no_of_bedrooms NUMBER(2) NOT NULL,
  no_of_bathrooms NUMBER(2) NOT NULL,
  residency_no NUMBER(10) NOT NULL,
  FOREIGN KEY (owner_id) REFERENCES Owner(owner_id),
  FOREIGN KEY (residency_no) REFERENCES Resident_Management(residency_no),
  CHECK (unit_type IN ('flat', 'condo', 'apartment', 'house')),
  CHECK (parking_spot IN ('Y', 'N')),
  CHECK (inUnit_Laundry IN ('Y', 'N')),
  CHECK (pets_Allowed IN ('Y', 'N'))
);


INSERT INTO House (unit_no, owner_id, building_no, unit_type, parking_spot, inUnit_Laundry, pets_Allowed, no_of_bedrooms, no_of_bathrooms, residency_no)
select 101, 11, 'B101', 'flat', 'Y', 'Y', 'Y', 2, 1, 1001  from dual union all
select 102, 18, 'B101', 'flat', 'N', 'N', 'N', 1, 1, 1002 from dual union all
select 201, 21, 'B201', 'condo', 'Y', 'N', 'Y', 3, 2, 2001 from dual union all
select 202, 11, 'B201', 'condo', 'N', 'Y', 'N', 2, 1, 2002 from dual union all
select 301, 14, 'B301', 'apartment', 'Y', 'Y', 'N', 1, 1, 3001 from dual union all
select 401, 21, 'B401', 'house', 'Y', 'N', 'Y', 4, 3, 4001 from dual union all
select 402, 21, 'B401', 'house', 'Y', 'Y', 'N', 3, 1, 3004 from dual;

-- Create the Resident Management Table
CREATE TABLE Resident_Management (
  residency_no NUMBER(10) PRIMARY KEY,
  residency_first_name VARCHAR2(50) NOT NULL,
  residency_last_name VARCHAR2(50) NOT NULL,
  request_id NUMBER(10) NOT NULL,
  address_line1 VARCHAR2(100) NOT NULL,
  address_line2 VARCHAR2(100) NOT NULL,
  CONSTRAINT fk_request_id FOREIGN KEY (request_id) REFERENCES Requests(request_id)
);

INSERT INTO Resident_Management (residency_no, residency_first_name, residency_last_name, request_id, address_line1, address_line2)
select 1001, 'John', 'Doe', 100, '123 Main St', 'Apt 4B' from dual union all
select 1002, 'Jane', 'Smith', 110, '456 Elm St', 'Unit 2' from dual union all
select 2002, 'Bob', 'Johnson', 1003, '789 Oak St', 'Suite 10' from dual union all
select 3004, 'Sarah', 'Williams', 1004, '234 Pine St', 'Apt 7C' from dual union all
select 2001, 'Michael', 'Brown', 1005, '567 Maple St', 'Unit 3B' from dual union all
select 1001, 'Lisa', 'Davis', 1006, '890 Cedar St', 'Suite 5A' from dual;

CREATE TABLE Requests (
    request_id NUMBER PRIMARY KEY,
    logged_by VARCHAR2(50) NOT NULL,
    reported_to_Employee_id NUMBER NOT NULL,
    request_type VARCHAR2(50) NOT NULL,
    priority VARCHAR2(10) NOT NULL,
    date_logged DATE NOT NULL,
    status VARCHAR2(20) NOT NULL,
    due_date DATE NOT NULL,
    CONSTRAINT fk_reported_to FOREIGN KEY (reported_to_Employee_id)
    REFERENCES Employees (Employee_id),
    CONSTRAINT chk_status CHECK (status IN ('Open', 'In Progress', 'Completed')),
    CONSTRAINT chk_priority CHECK (priority IN ('High', 'Medium', 'Low')),
    CONSTRAINT chk_request_type CHECK (request_type IN ('Maintenance', 'Plumbing', 'Pest Control')),
    CONSTRAINT chk_date_logged CHECK (date_logged <= SYSDATE),
    CONSTRAINT chk_due_date CHECK (due_date >= date_logged)
);

INSERT INTO Requests (request_id, logged_by, reported_to_Employee_id, request_type, priority, date_logged, status, due_date)
select 199, 'John Doe', 22101, 'Maintenance', 'High', '01-JAN-2023', 'Open', '31-JAN-2023' from dual union all
select 202, 'Jane Smith', 22102, 'Plumbing', 'Medium', '15-JAN-2023', 'In Progress', '15-FEB-2023' from dual union all
select 224, 'Bob Williams', 22100, 'Pest Control', 'Low', '25-JAN-2023', 'Completed', '28-JAN-2023' from dual;



--Create Employees Table
CREATE TABLE Employees (
  employee_id NUMBER(10) PRIMARY KEY,
  account_id NUMBER(10) NOT NULL,
  role_id NUMBER(1) NOT NULL,
  residency_no NUMBER(10) NOT NULL,
  CONSTRAINT fk_account_id
    FOREIGN KEY (account_id)
    REFERENCES Account_type(account_id),
  CONSTRAINT fk_residency_no
    FOREIGN KEY (residency_no)
    REFERENCES Resident_Management(residency_no),
  CONSTRAINT chk_role_id
    CHECK (role_id IN (1,2))
);

INSERT INTO Employees (employee_id, account_id, role_id, residency_no)
select 22102, 6045, 1, 2001 from dual union all
select 22102, 6046, 1, 2002 from dual union all
select 22022, 6055, 2, 2001 from dual union all
select 22100, 6056, 1, 3001 from dual;

CREATE TABLE Roles (
    role_id NUMBER PRIMARY KEY,
    role_name VARCHAR2(20) NOT NULL CHECK (role_name IN ('employee', 'resident manager'))
);

INSERT INTO Roles (role_id, role_name)
select 1, 'employee' from dual union all
select 2, 'resident manager' from dual;

--Create Lease Payment Table
CREATE TABLE Lease_Payments (
    lease_payment_id NUMBER PRIMARY KEY,
    payment_type VARCHAR2(50) CHECK (payment_type IN ('Cash', 'Check', 'Credit Card')),
    payment_date DATE,
    payment_amount NUMBER,
    lease_no NUMBER REFERENCES Lease_Agreement(lease_no),
    late_fees NUMBER
);

INSERT INTO Lease_Payments (lease_payment_id, payment_type, payment_date, payment_amount, lease_no, late_fees)
select 111, 'Cash', TO_DATE('2022-01-15', 'YYYY-MM-DD'), 1000, 1002, NULL from dual union all
select 112, 'Credit Card', TO_DATE('2022-02-15', 'YYYY-MM-DD'), 1200, 1003, NULL from dual union all
select 114, 'Check', TO_DATE('2022-03-15', 'YYYY-MM-DD'), 1500, 1008, 50 from dual ;
COMMIT;

