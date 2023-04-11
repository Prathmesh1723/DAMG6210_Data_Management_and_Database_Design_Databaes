CREATE OR REPLACE PACKAGE functions AS
   FUNCTION calculate_amount_returned(v_request_count IN NUMBER, p_security_deposit_amount NUMBER)
    RETURN NUMBER;
    
    FUNCTION assign_request_to_emp(v_residency_no NUMBER)
    RETURN NUMBER;
END functions;
/

