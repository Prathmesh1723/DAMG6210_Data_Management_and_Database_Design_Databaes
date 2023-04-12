--Total Monthly Rent Collected by Each Owner:

SELECT o.owner_id, a.first_name, a.last_name, SUM(la.monthly_rent) AS total_rent_collected
FROM Owner o
INNER JOIN ACCOUNT_TYPE a ON a.account_id = o.account_id
INNER JOIN Lease_agreement la ON o.owner_id = la.owner_id
WHERE la.lease_Status = 1
GROUP BY o.owner_id, a.first_name, a.last_name;


--Percentage of Units with In-Unit Laundry by Unit Type:

SELECT h.unit_type, COUNT(h.unit_no) AS total_units, 
    ROUND(COUNT(CASE WHEN h.inUnit_Laundry = 'Y' THEN 1 END) / COUNT(h.unit_no) * 100, 2) AS percent_units_with_laundry
FROM House h
GROUP BY h.unit_type;

--Average Security Deposit Return Time by Unit Type:

SELECT h.unit_type, AVG(MONTHS_BETWEEN(sd.return_date, la.lease_Startdate)) AS avg_return_time
FROM security_Deposit_Return sd
INNER JOIN Lease_agreement la ON sd.lease_no = la.lease_no
INNER JOIN House h ON la.unit_no = h.unit_no
WHERE sd.return_status = 'Returned'
GROUP BY h.unit_type;



----- Occupancy rate by unit type: 

SELECT 
  h.unit_type,
  (COUNT(DISTINCT l.lease_no) / COUNT(DISTINCT h.unit_no))* 100 AS occupancy_rate
FROM 
  House h
  LEFT JOIN Lease_agreement l ON h.unit_no = l.unit_no AND l.lease_Status = 1
WHERE 
  h.status = 'Available' OR h.status = 'Rented'
GROUP BY 
  h.unit_type



------Average age of tenants per residency:-------

SELECT Resident_Management.residency_name, AVG(Account_type.age) as avg_age
FROM Resident_Management
JOIN House ON Resident_Management.residency_no = House.residency_no
JOIN Lease_agreement ON House.unit_no = Lease_agreement.unit_no
JOIN Tenant ON Lease_agreement.tenant_id = Tenant.tenant_id
JOIN Account_type ON Tenant.account_id = Account_type.account_id
GROUP BY Resident_Management.residency_name;

--------------- Total number of tenants per residency: ------------

SELECT Resident_Management.residency_name, COUNT(Tenant.tenant_id) as total_tenants
FROM Resident_Management
JOIN House ON Resident_Management.residency_no = House.residency_no
JOIN Lease_agreement ON House.unit_no = Lease_agreement.unit_no
JOIN Tenant ON Lease_agreement.tenant_id = Tenant.tenant_id
GROUP BY Resident_Management.residency_name;

------------ Report the number of available and rented units for each property --------

SELECT rm.residency_name, 
       COUNT(CASE WHEN h.status = 'Available' THEN 1 ELSE NULL END) AS available_units, 
       COUNT(CASE WHEN h.status = 'Rented' THEN 1 ELSE NULL END) AS rented_units
FROM resident_management rm
INNER JOIN house h ON rm.residency_no = h.residency_no
GROUP BY rm.residency_name;
