CREATE OR REPLACE PROCEDURE renew_lease(
  p_lease_no IN LEASE_AGREEMENT.LEASE_NO%TYPE,
  p_new_end_date IN LEASE_AGREEMENT.LEASE_ENDDATE%TYPE
) AS
  v_lease_status LEASE_AGREEMENT.LEASE_STATUS%TYPE;
  v_lease_end_date LEASE_AGREEMENT.LEASE_ENDDATE%TYPE;
  LEASE_COUNT NUMBER;
BEGIN
  -- Check if lease exists
  SELECT COUNT(*) INTO LEASE_COUNT FROM LEASE_AGREEMENT WHERE LEASE_NO = p_lease_no;
  IF LEASE_COUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Lease does not exist.');
  END IF;
  
  -- Check if lease is active
  SELECT LEASE_STATUS, LEASE_ENDDATE INTO v_lease_status, v_lease_end_date FROM LEASE_AGREEMENT WHERE LEASE_NO = p_lease_no;
  IF v_lease_status <> 'Active' THEN
    RAISE_APPLICATION_ERROR(-20002, 'Lease is not active.');
  END IF;
  
  -- Check if new end date is greater than old end date
  IF p_new_end_date <= v_lease_end_date THEN
    RAISE_APPLICATION_ERROR(-20003, 'New end date must be greater than old end date.');
  END IF;
  
  -- Renew lease
  UPDATE LEASE_AGREEMENT SET LEASE_ENDDATE = p_new_end_date WHERE LEASE_NO = p_lease_no;
  
  -- Commit transaction
  COMMIT;
EXCEPTION
  -- Rollback transaction on error
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END;

--------------------------------------------------------------------

--test to check if lease exist
BEGIN
  renew_lease(1, TO_DATE('2023-02-01', 'YYYY-MM-DD'));
END;

