set serveroutput on
declare
    v_table_exists varchar(1) := 'Y';
    v_sql varchar(2000);
begin
   dbms_output.put_line('Start schema cleanup');
   for i in (
             select 'LEASE_AGREEMENT' table_name from dual union all
             select 'TENANT' table_name from dual union all
             select 'OWNER' table_name from dual union all
             select 'HOUSE' table_name from dual union all
             select 'LEASE_PAYMENTS' table_name from dual union all
             select 'SECURITY_DEPOSIT_AMOUNT' table_name from dual union all
             select 'RESIDENT_MANAGEMENT' from dual union all
             select 'SECURITY_DEPOSIT_RETURN' from dual union all
             select 'ROLES' from dual union all
             select 'REQUESTS' table_name from dual union all
             select 'EMPLOYEES' table_name from dual union all
             select 'INSPECTION_CHECK' table_name from dual union all
             select 'ACCOUNT_TYPE' table_name from dual    
   )
   loop
   dbms_output.put_line('....Drop foreign keys for table '||i.table_name);
   begin
       for j in (
               select constraint_name, table_name
               from user_constraints
               where constraint_type = 'R' and r_constraint_name in (
                   select constraint_name
                   from user_constraints
                   where table_name = i.table_name and constraint_type in ('P', 'U')
               )
           )
       loop
           v_sql := 'alter table '||j.table_name||' drop constraint '||j.constraint_name;
           execute immediate v_sql;
           dbms_output.put_line('........Foreign key '||j.constraint_name||' dropped successfully');
       end loop;
       end;
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
  select  6056, 'employee', 'Steven', 'Wilson', 45, 'stevenwilson@example.com', '345-67-8901', 'password7' from dual union all
  select  6066, 'owner', 'Steff', 'Wild', 35, 'steff@example.com', '345-67-8601', 'password8' from dual union all
  select  6070, 'owner', 'Derek', 'Roy', 65, 'derekRoy@example.com', '345-67-8801', 'password9' from dual union all
  select  6047, 'tenant', 'Karen', 'Miller', 32, 'karenmiller@example.com', '678-90-1234', 'password11' from dual union all
  SELECT  6080, 'tenant', 'Michael', 'Jones', 42, 'michaeljones@example.com', '123-45-1234', 'password12' FROM dual UNION ALL
  SELECT 6090, 'owner', 'Jane', 'Smith', 55, 'janesmith@example.com', '567-89-0123', 'password13' FROM dual UNION ALL
  SELECT 6100, 'employee', 'Thomas', 'Brown', 23, 'thomasbrown@example.com', '901-23-3456', 'password14' FROM dual UNION ALL 
  SELECT 6110, 'tenant', 'Amanda', 'Davis', 27, 'amandadavis@example.com', '345-67-1234', 'password15' FROM dual UNION ALL 
  SELECT 6120, 'owner', 'Mark', 'Johnson', 60, 'markjohnson@example.com', '789-12-3450', 'password16' FROM dual UNION ALL 
  SELECT 6130, 'employee', 'Jennifer', 'Wilson', 31, 'jenniferwilson@example.com', '234-56-7891', 'password17' FROM dual UNION ALL
  SELECT 6140, 'employee', 'Brian', 'Lee', 48, 'brianlee@example.com', '901-24-5678', 'password18' FROM dual UNION ALL 



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
  SELECT 1071, 6080, 8983303773 from dual union all
  SELECT 1261, 6110, 7276118846 from dual union all
  SELECT 1289, 6160, 9422539140 from dual union all
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
SELECT 73,  6090 from dual union all
SELECT 69,  6120 from dual union all
SELECT 84,  6150 from dual union all
SELECT 76,  6170 from dual union all
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
  monthly_Rent NUMBER(10,2) NOT NULL
);


INSERT INTO Lease_agreement (lease_no, unit_no, owner_id, tenant_id, lease_Date, lease_Startdate, lease_Enddate, lease_Term, security_Deposit, lease_Status, monthly_Rent)
select 1200, 101, 11, 1063, TO_DATE('2022-01-01', 'YYYY-MM-DD'), TO_DATE('2022-01-01', 'YYYY-MM-DD'), TO_DATE('2023-01-31', 'YYYY-MM-DD'), 12, 2000, 1, 1000 from dual union all
select 1000, 102, 11, 1066,  TO_DATE('2022-01-31', 'YYYY-MM-DD'), TO_DATE('2022-02-11', 'YYYY-MM-DD'), TO_DATE('2023-01-31', 'YYYY-MM-DD'), 24, 1500, 1, 800 from dual union all
select 1080, 108, 21, 1008, TO_DATE('2022-01-31', 'YYYY-MM-DD'), TO_DATE('2022-02-11', 'YYYY-MM-DD'), TO_DATE('2023-01-31', 'YYYY-MM-DD'), 12, 1000, 1, 1600 from dual;


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
  CHECK (unit_type IN ('flat', 'condo', 'apartment', 'house')),
  CHECK (parking_spot IN ('Y', 'N')),
  CHECK (inUnit_Laundry IN ('Y', 'N')),
  CHECK (pets_Allowed IN ('Y', 'N'))
);


INSERT INTO House (unit_no, owner_id, building_no, unit_type, parking_spot, inUnit_Laundry, pets_Allowed, no_of_bedrooms, no_of_bathrooms, residency_no)
select 101, 11, 'B101', 'flat', 'Y', 'Y', 'Y', 2, 1, 1001  from dual union all
select 102, 11, 'B101', 'flat', 'N', 'N', 'N', 1, 1, 1002 from dual union all
select 103, 18, 'B201', 'condo', 'Y', 'N', 'Y', 3, 2, 2002 from dual union all
select 108, 14, 'B201', 'condo', 'N', 'Y', 'N', 2, 1, 2002 from dual union all
select 104, 21, 'B301', 'apartment', 'Y', 'Y', 'N', 1, 1, 1001 from dual union all



-- Create the Resident Management Table
CREATE TABLE Resident_Management (
  residency_no NUMBER(10) PRIMARY KEY,
  residency_first_name VARCHAR2(50) NOT NULL,
  residency_last_name VARCHAR2(50) NOT NULL,
  request_id NUMBER(10) NOT NULL,
  address_line1 VARCHAR2(100) NOT NULL,
  address_line2 VARCHAR2(100) NOT NULL
);

INSERT INTO Resident_Management (residency_no, residency_first_name, residency_last_name, request_id, address_line1, address_line2)
select 1001, 'John', 'Doe', 199, '123 Main St', 'Apt 4B' from dual union all
select 1002, 'Jane', 'Smith', 202, '456 Elm St', 'Unit 2' from dual union all
select 2002, 'Bob', 'Johnson', 224, '789 Oak St', 'Suite 10' from dual;

CREATE TABLE Requests (
    request_id NUMBER PRIMARY KEY,
    logged_by VARCHAR2(50) NOT NULL,
    reported_to_Employee_id NUMBER NOT NULL,
    request_type VARCHAR2(50) NOT NULL,
    priority VARCHAR2(10) NOT NULL,
    date_logged DATE NOT NULL,
    status VARCHAR2(20) NOT NULL,
    due_date DATE NOT NULL,
    CONSTRAINT chk_status CHECK (status IN ('Open', 'In Progress', 'Completed')),
    CONSTRAINT chk_priority CHECK (priority IN ('High', 'Medium', 'Low')),
    CONSTRAINT chk_request_type CHECK (request_type IN ('Maintenance', 'Plumbing', 'Pest Control')),
    CONSTRAINT chk_due_date CHECK (due_date >= date_logged)
);

INSERT INTO Requests (request_id, logged_by, reported_to_Employee_id, request_type, priority, date_logged, status, due_date)
select 199, 'John Doe', 22101, 'Maintenance', 'High', '01-JAN-2023', 'Open', '31-JAN-2023' from dual union all
select 202, 'Jane Smith', 22122, 'Plumbing', 'Medium', '15-JAN-2023', 'In Progress', '15-FEB-2023' from dual union all
select 224, 'Bob Williams', 22100, 'Pest Control', 'Low', '25-JAN-2023', 'Completed', '28-JAN-2023' from dual;



--Create Employees Table
CREATE TABLE Employees (
  employee_id NUMBER(10) PRIMARY KEY,
  account_id NUMBER(10) NOT NULL,
  role_id NUMBER(1) NOT NULL,
  residency_no NUMBER(10) NOT NULL,
  CONSTRAINT chk_role_id
    CHECK (role_id IN (1,2))
);

INSERT INTO Employees (employee_id, account_id, role_id, residency_no)
select 22101, 6045, 1, 2002 from dual union all
select 22122, 6055, 2, 2002 from dual union all
select 22100, 6056, 1, 1002 from dual union all


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
select 111, 'Cash', TO_DATE('2022-01-15', 'YYYY-MM-DD'), 1000, 1000, NULL from dual union all
select 112, 'Credit Card', TO_DATE('2022-02-15', 'YYYY-MM-DD'), 1200, 1200, NULL from dual union all
select 114, 'Check', TO_DATE('2022-03-15', 'YYYY-MM-DD'), 1500, 1080, 50 from dual ;

--Create Security Deposit Returns Table
CREATE TABLE security_Deposit_Return (
  payment_id NUMBER PRIMARY KEY,
  return_date DATE,
  security_deposit_amount NUMBER,
  amount_returned DECIMAL,
  lease_no NUMBER
);

INSERT INTO security_Deposit_Return (payment_id, return_date, security_deposit_amount, amount_returned, lease_no)
select 1, TO_DATE('2022-01-01', 'YYYY-MM-DD'), 1000, 800, 1200 from dual union all
select 2, TO_DATE('2022-02-01', 'YYYY-MM-DD'), 1500, 1200, 1000 from dual union all
select 4, TO_DATE('2022-04-01', 'YYYY-MM-DD'), 2500, 2500, 1080 from dual;

--Create Security Inspection Check Table
CREATE TABLE Inspection_check (
  inspection_id NUMBER PRIMARY KEY NOT NULL,
  date_logged DATE NOT NULL,
  inspected_by NUMBER NOT NULL,
  Damages_found VARCHAR2(1) NOT NULL CHECK (Damages_found IN ('Y', 'N')),
  cost_of_repairs NUMBER NOT NULL,
  unit_no NUMBER NOT NULL,
  CONSTRAINT fk_inspected_by FOREIGN KEY (inspected_by) REFERENCES Employees(employee_id),
  CONSTRAINT fk_unit_no FOREIGN KEY (unit_no) REFERENCES House(unit_no)
);


INSERT INTO Inspection_check (inspection_id, date_logged, inspected_by, Damages_found, cost_of_repairs, unit_no)
select 111, TO_DATE('2022-01-01', 'YYYY-MM-DD'), 22101, 'N', 0, 101 from dual union all
select 211, TO_DATE('2022-02-01', 'YYYY-MM-DD'), 22100, 'Y', 500, 103 from dual union all
select 303, TO_DATE('2022-03-01', 'YYYY-MM-DD'), 22100, 'N', 0, 102 from dual union all
select 401, TO_DATE('2022-04-01', 'YYYY-MM-DD'), 22100, 'Y', 1000, 108 from dual;

ALTER TABLE security_Deposit_Return
ADD CONSTRAINT lease_no FOREIGN KEY (lease_no) REFERENCES Lease_Agreement(lease_no);


ALTER TABLE Lease_Agreement
ADD CONSTRAINT unit_no FOREIGN KEY (unit_no) REFERENCES House(unit_no)
ADD CONSTRAINT owner_id FOREIGN KEY (owner_id) REFERENCES owner(owner_id)
ADD CONSTRAINT tenant_id FOREIGN KEY (tenant_id) REFERENCES Tenant(tenant_id);


ALTER TABLE House
ADD CONSTRAINT fk_owner_id FOREIGN KEY (owner_id) REFERENCES owner(owner_id)
ADD CONSTRAINT fk_residency_no FOREIGN KEY (residency_no) REFERENCES Resident_Management(residency_no);

ALTER TABLE Resident_Management
ADD CONSTRAINT request_id FOREIGN KEY (request_id) REFERENCES Requests(request_id);

ALTER TABLE Requests
ADD CONSTRAINT reported_to_Employee_id FOREIGN KEY (reported_to_Employee_id) REFERENCES Employees(Employee_id);

ALTER TABLE Employees
ADD CONSTRAINT account_id FOREIGN KEY (account_id) REFERENCES Account_type(account_id)
ADD CONSTRAINT residency_no FOREIGN KEY (residency_no) REFERENCES Resident_Management(residency_no);


COMMIT;

