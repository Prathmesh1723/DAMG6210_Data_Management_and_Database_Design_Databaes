
-- Connect as Prathmesh and create all the tables
Create USER prathmesh IDENTIFIED BY Prathme$H2105;
GRANT ALL PRIVILEGES TO prathmesh;

--ROLES

CREATE USER tenant IDENTIFIED BY Theoffice6969;
CREATE USER owner IDENTIFIED BY Theoffice6969;
CREATE USER employee IDENTIFIED BY Theoffice6969;
CREATE USER resident_admin IDENTIFIED BY Theoffice6969;

GRANT CREATE SESSION TO tenant, owner, employee, resident_admin;

--Tenant permissions
-- Grant SELECT permission on tables
GRANT SELECT ON LEASE_AGREEMENT TO Tenant;
GRANT SELECT ON LEASE_PAYMENTS TO Tenant;
GRANT SELECT ON SECURITY_DEPOSIT_RETURN TO Tenant;
GRANT SELECT ON REQUESTS TO Tenant;

-- Grant UPDATE permission on LEASE_PAYMENTS table to update payment status
GRANT UPDATE (REQUEST_TYPE, PRIORITY ) ON REQUESTS TO Tenant;


--Owner permissions
-- Grant SELECT permission on tables
GRANT SELECT ON LEASE_AGREEMENT TO Owner;
GRANT SELECT ON TENANT TO Owner;
GRANT SELECT ON HOUSE TO Owner;
GRANT SELECT ON LEASE_PAYMENTS TO Owner;
GRANT SELECT ON SECURITY_DEPOSIT_RETURN TO Owner;


-- Grant UPDATE permission on LEASE_AGREEMENT table to update lease terms
GRANT UPDATE (lease_startdate, lease_enddate, monthly_rent) ON LEASE_AGREEMENT TO Owner;


--Employee permissions
-- Grant SELECT permission on tables
GRANT SELECT ON TENANT TO Employee;
GRANT SELECT ON HOUSE TO Employee;
GRANT SELECT ON LEASE_PAYMENTS TO Employee;
GRANT SELECT ON SECURITY_DEPOSIT_RETURN TO Employee;
GRANT SELECT ON REQUESTS TO Employee;
GRANT SELECT ON INSPECTION_CHECK TO Employee;

-- Grant UPDATE permission on REQUESTS table to update request status
GRANT UPDATE (status, due_date) ON REQUESTS TO Employee;

-- Grant UPDATE permission on INSPECTION_CHECK table to update inspection status
GRANT UPDATE ON INSPECTION_CHECK TO Employee;

-- Grant UPDATE permission on SECURITY_DEPOSIT_RETURN table to update refund status
GRANT UPDATE (SECURITY_DEPOSIT_AMOUNT) ON SECURITY_DEPOSIT_RETURN TO Employee;

-- Grant UPDATE permission on LEASE_PAYMENTS table to update payment status
GRANT UPDATE ON LEASE_PAYMENTS TO Owner;


--Resident admin permissions
--Grant SELECT permission on tables
GRANT SELECT ON LEASE_AGREEMENT TO resident_admin;
GRANT SELECT ON TENANT TO resident_admin;
GRANT SELECT ON HOUSE TO resident_admin;
GRANT SELECT ON LEASE_PAYMENTS TO resident_admin;
GRANT SELECT ON SECURITY_DEPOSIT_RETURN TO resident_admin;
GRANT SELECT ON REQUESTS TO resident_admin;
GRANT SELECT ON EMPLOYEES TO resident_admin;
GRANT SELECT ON INSPECTION_CHECK TO resident_admin;
GRANT SELECT ON ACCOUNT_TYPE TO resident_admin;

-- Grant UPDATE permission on REQUESTS table to update request status
GRANT UPDATE (status) ON REQUESTS TO resident_admin;

-- Grant UPDATE permission on INSPECTION_CHECK table to update inspection status
GRANT UPDATE ON INSPECTION_CHECK TO resident_admin;

-- Grant INSERT permission on EMPLOYEES table to add new employees
GRANT INSERT ON EMPLOYEES TO resident_admin;


-- Grant UPDATE permission on SECURITY_DEPOSIT_RETURN table to update refund status
GRANT UPDATE ON SECURITY_DEPOSIT_RETURN TO resident_admin;

-- Grant UPDATE permission on LEASE_PAYMENTS table to update payment status
GRANT UPDATE ON LEASE_PAYMENTS TO resident_admin;

-- Grant UPDATE permission on LEASE_AGREEMENT table to update lease terms
GRANT UPDATE (lease_startdate, lease_enddate, monthly_rent) ON LEASE_AGREEMENT TO resident_admin;

commit;