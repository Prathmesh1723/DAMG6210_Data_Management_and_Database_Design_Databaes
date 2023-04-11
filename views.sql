-----------------VIEW 1-----------------------------------
/* Lease_Agreement_View :
- This view displays information about lease agreements, including the lease ID, tenant's first and last name, property address, lease start and end dates, monthly rent, and security deposit.
- This view can be used to easily see all the lease agreements in the system and the details associated with each one.*/

CREATE OR REPLACE VIEW Lease_Agreement_View AS
SELECT l.lease_no, a.first_name AS tenant_first_name, a.last_name AS tenant_last_name,
       r.address_line1 || ' ' || r.address_line2 AS property_address,
       l.lease_startdate, l.lease_startdate + interval '1' month * l.lease_term AS lease_enddate, 
       l.monthly_rent
FROM Lease_agreement l
JOIN Tenant t ON l.tenant_id = t.tenant_id
JOIN Account_type a ON a.account_id = t.account_id
JOIN House h ON l.unit_no = h.unit_no
JOIN Resident_Management r ON h.residency_no = r.residency_no;

SELECT * FROM Lease_Agreement_View;

SET PAGESIZE 100;
COLUMN PROPERTY_ADDRESS FORMAT A20;

---------------- VIEW 2-------------------------------------------
/* Maintenance_Request_View -
resulting view contains data on requests including request type, priority, status, and dates, as well as the unit number, employee ID, and account details of those involved*/

CREATE VIEW request_info AS
SELECT r.request_id, h.unit_no, e.employee_id, e.account_id, a.first_name, a.last_name, a.email, r.request_type, r.request_priority, r.date_logged, r.req_status, r.due_date, r.resolved_date
FROM Requests r
INNER JOIN House h ON r.logged_by = h.unit_no
LEFT JOIN Employees e ON r.reported_to_Employee_id = e.employee_id
LEFT JOIN Account_type a ON e.account_id = a.account_id;

SELECT * FROM request_info;

---------------------- VIEW 3 ------------------------------------------------------
/* Lease_Payment_View:
- This view displays information about lease payments, including the payment ID, tenant's first and last name, property address, payment amount, and payment date.
- This view can be used to track lease payments, see when payments were made, and ensure that tenants are paying their rent on time.*/

CREATE OR REPLACE VIEW Lease_Payment_View AS
SELECT lp.lease_payment_id AS Payment_ID,
       h.unit_no AS Unit,
       a.first_name AS First_Name,
       a.last_name AS Last_Name,
       rm.address_line1 || ', ' || rm.address_line2 AS Property_Address,
       lp.payment_status AS Status,
       lp.payment_amount AS Payment_Amount,
       lp.payment_duedate AS Payment_duedate,
       lp.payment_date AS Payment_Date,
       lp.late_fees
FROM Lease_Payments lp
JOIN Lease_agreement la ON lp.lease_no = la.lease_no
JOIN Tenant t ON la.tenant_id = t.tenant_id
JOIN Account_type a ON t.account_id = a.account_id
JOIN House h ON la.unit_no = h.unit_no
JOIN Resident_Management rm ON h.residency_no = rm.residency_no;

SELECT * FROM Lease_Payment_View;