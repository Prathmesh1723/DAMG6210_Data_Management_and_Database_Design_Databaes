set serveroutput on
declare
    v_table_exists varchar(1) := 'Y';
    v_sql varchar(2000);
begin
   dbms_output.put_line('Start schema cleanup');
   for i in (select 'TENANT' table_name from dual union all
   select 'HOUSE' table_name from dual union all
             select 'OWNER' table_name from dual union all
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
  CHECK (account_type IN ('owner', 'tenant', 'empoyee'))
);

INSERT INTO Account_type (account_id, account_type, first_name, last_name, age, email, ssn_passport, account_password)
  select  6041, 'owner', 'John', 'Doe', 30, 'johndoe@example.com', '123-45-6789', 'password1' from dual union all
  select  6042, 'tenant', 'Bob', 'Smith', 40, 'bobsmith@example.com', '789-12-3456', 'password3' from dual union all
  select  6043, 'owner', 'Alice', 'Johnson', 35, 'alicejohnson@example.com', '234-56-7890', 'password4' from dual union all
  select  6044, 'tenant', 'David', 'Brown', 50, 'davidbrown@example.com', '567-89-1234', 'password5' from dual union all
  select  6045, 'employee', 'Emily', 'Davis', 28, 'emilydavis@example.com', '901-23-4567', 'password6' from dual union all
  select  6046, 'employee', 'Steven', 'Wilson', 45, 'stevenwilson@example.com', '345-67-8901', 'password7' from dual union all
  select  6066, 'owner', 'Steff', 'Wild', 35, 'steff@example.com', '345-67-8601', 'password8' from dual union all
  select  6070, 'owner', 'Derek', 'Roy', 65, 'derekRoy@example.com', '345-67-8801', 'password9' from dual union all
  select  6047, 'tenant', 'Karen', 'Miller', 32, 'karenmiller@example.com', '678-90-1234', 'password11' from dual;


-- Create the Tenant table
CREATE TABLE Tenant (
  tenant_id NUMBER(20) PRIMARY KEY NOT NULL, 
  account_id NUMBER(20) REFERENCES Account_type(account_id),
  contact_number NUMBER(20) 
);

INSERT INTO Tenant (tenant_id, account_id, contact_number)
  select 1060, 6041,1234567890 from dual union all
  select 1063, 6042,2345678901 from dual union all
  select 1066, 6043,3456789012 from dual union all
  select 1206, 6044,4567890123 from dual union all
  select 1008, 6047,4567889504 from dual union all
  select 1045, 6045,5678901234 from dual;
  
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
select 1007, 107, 570, 1060, '2022-01-07', '2022-02-01', '2023-01-31', 12, 1500, 1, 800  from dual union all
select 1008, 108, 488, 1088, '2022-01-08', '2022-02-01', '2023-01-31', 12, 1000, 1, 1600 from dual;


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
--  FOREIGN KEY (residency_no) REFERENCES Resident_Management(residency_no),
  CHECK (unit_type IN ('flat', 'condo', 'apartment', 'house')),
  CHECK (parking_spot IN ('Y', 'N')),
  CHECK (inUnit_Laundry IN ('Y', 'N')),
  CHECK (pets_Allowed IN ('Y', 'N'))
);


INSERT INTO House (unit_no, owner_id, building_no, unit_type, parking_spot, inUnit_Laundry, pets_Allowed, no_of_bedrooms, no_of_bathrooms, residency_no)
select 101, 11, 'B101', 'flat', 'Y', 'Y', 'Y', 2, 1, 1001  from dual union all
select 102, 1, 'B101', 'flat', 'N', 'N', 'N', 1, 1, 1002 from dual union all
select 201, 2, 'B201', 'condo', 'Y', 'N', 'Y', 3, 2, 2001 from dual union all
select 202, 2, 'B201', 'condo', 'N', 'Y', 'N', 2, 1, 2002 from dual union all
select 301, 3, 'B301', 'apartment', 'Y', 'Y', 'N', 1, 1, 3001 from dual union all
select 401, 4, 'B401', 'house', 'Y', 'N', 'Y', 4, 3, 4001 from dual union all
select 402, 4, 'B401', 'house', 'Y', 'Y', 'N', 3, 1, 3004 from dual;


COMMIT;
