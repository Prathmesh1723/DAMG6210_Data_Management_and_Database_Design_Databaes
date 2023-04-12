CREATE OR REPLACE PROCEDURE get_monthly_income_report (
    p_month IN VARCHAR2,
    p_year IN NUMBER
) AS
    v_monthly_rent_total NUMBER(10,2);
BEGIN
    -- Validate input parameters
    IF NOT REGEXP_LIKE(p_month, '^[0-9]{2}$') THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid month parameter');
    END IF;
    IF p_year < 1900 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Invalid year parameter');
    END IF;
    
    -- Calculate monthly rent total
    SELECT SUM(PAYMENT_AMOUNT) INTO v_monthly_rent_total
    FROM LEASE_PAYMENTS LP
    JOIN LEASE_AGREEMENT LA ON LP.LEASE_NO = LA.LEASE_NO
    WHERE TO_CHAR(PAYMENT_DATE, 'MM') = p_month AND TO_CHAR(PAYMENT_DATE, 'YYYY') = p_year;

    -- Output monthly rent total
    DBMS_OUTPUT.PUT_LINE('Monthly rent total for ' || p_month || '/' || p_year || ': $' || v_monthly_rent_total);
END;
/

--test
BEGIN
    get_monthly_income_report('04', 2023);
END;

-- create test data
INSERT INTO LEASE_AGREEMENT (LEASE_NO, UNIT_NO, OWNER_ID, TENANT_ID, LEASE_DATE, LEASE_STARTDATE, LEASE_ENDDATE, LEASE_TERM, SECURITY_DEPOSIT, LEASE_STATUS, MONTHLY_RENT) 
VALUES (1, 'A101', 1, 2, '01-JAN-2022', '01-FEB-2022', '31-JAN-2023', 12, 1000, 'ACTIVE', 1200);

INSERT INTO LEASE_PAYMENTS (LEASE_PAYMENT_ID, PAYMENT_TYPE, PAYMENT_DATE, PAYMENT_AMOUNT, LEASE_NO, LATE_FEES) 
VALUES (1, 'CHECK', '01-FEB-2022', 1200, 1, 0);

-- call the procedure with test data
DECLARE
  p_month VARCHAR2(10) := 'FEB-2022';
  p_year VARCHAR2(4) := '2022';
  p_owner_id NUMBER := 1;
BEGIN
  get_monthly_income_report(p_month, p_year, p_owner_id);
END;
/
