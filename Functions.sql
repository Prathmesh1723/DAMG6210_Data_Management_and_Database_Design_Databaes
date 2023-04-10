-------Get Account Details by Email
CREATE OR REPLACE FUNCTION get_account_by_email(email IN VARCHAR2)
  RETURN ACCOUNT_TYPE%ROWTYPE
IS
  account_record ACCOUNT_TYPE%ROWTYPE;
BEGIN
  SELECT *
  INTO account_record
  FROM ACCOUNT_TYPE
  WHERE EMAIL = email;
  
  RETURN account_record;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No account found with email ' || email);
    RETURN NULL;
END;


--------Get Lease Payment History for Tenant
CREATE OR REPLACE FUNCTION get_lease_payments_for_tenant(tenant_id IN NUMBER)
  RETURN SYS_REFCURSOR
IS
  payment_history SYS_REFCURSOR;
BEGIN
  OPEN payment_history FOR
    SELECT lp.*
    FROM LEASE_PAYMENTS lp
    INNER JOIN LEASE_AGREEMENT la
      ON lp.LEASE_NO = la.LEASE_NO
    WHERE la.TENANT_ID = tenant_id
    ORDER BY lp.PAYMENT_DATE DESC;
      
  RETURN payment_history;
END;


------Get Units with Pets Allowed
CREATE OR REPLACE FUNCTION get_units_with_pets_allowed
  RETURN SYS_REFCURSOR
IS
  units_with_pets SYS_REFCURSOR;
BEGIN
  OPEN units_with_pets FOR
    SELECT *
    FROM HOUSE
    WHERE PETS_ALLOWED = 'Y';
  
  RETURN units_with_pets;
END;
---------Get Total Security Deposit Amount for a Lease
CREATE OR REPLACE FUNCTION get_security_deposit_total(lease_no IN NUMBER)
  RETURN NUMBER
IS
  deposit_total NUMBER;
BEGIN
  SELECT SUM(SECURITY_DEPOSIT)
  INTO deposit_total
  FROM LEASE_AGREEMENT
  WHERE LEASE_NO = lease_no;
  
  RETURN deposit_total;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No lease found with lease number ' || lease_no);
    RETURN NULL;
END;

-------------Get Open Maintenance Requests
CREATE OR REPLACE FUNCTION get_open_maintenance_requests
  RETURN SYS_REFCURSOR
IS
  open_requests SYS_REFCURSOR;
BEGIN
  OPEN open_requests FOR
    SELECT *
    FROM REQUESTS
    WHERE STATUS = 'OPEN';
  
  RETURN open_requests;
END;
