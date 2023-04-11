CREATE OR REPLACE PACKAGE functions AS
   FUNCTION calculate_amount_returned(v_request_count IN NUMBER, p_security_deposit_amount NUMBER)
    RETURN NUMBER;
    
    FUNCTION assign_request_to_emp(v_residency_no NUMBER)
    RETURN NUMBER;
END functions;
/

CREATE OR REPLACE PACKAGE BODY functions AS
   FUNCTION calculate_amount_returned(v_request_count IN NUMBER, p_security_deposit_amount NUMBER)
    RETURN NUMBER
    IS
      v_amount_returned NUMBER;
    BEGIN
     
      v_amount_returned := p_security_deposit_amount; 
      
      IF v_request_count > 5 THEN
        v_amount_returned := p_security_deposit_amount - 50;
      END IF;
    
      IF v_request_count > 10 THEN
        v_amount_returned := p_security_deposit_amount - 50;
      END IF;
    
      RETURN v_amount_returned;
    END calculate_amount_returned;
    
    FUNCTION assign_request_to_emp(v_residency_no NUMBER)
    RETURN NUMBER
    IS
      v_emp NUMBER;
    BEGIN
        SELECT employee_id
    INTO v_emp
    FROM (
        SELECT e.employee_id, COUNT(r.request_id) AS assigned_requests
        FROM Employees e
        LEFT JOIN Requests r ON e.employee_id = r.reported_to_Employee_id
        WHERE e.residency_no = v_residency_no
        GROUP BY e.employee_id
        ORDER BY assigned_requests
    )
    WHERE ROWNUM = 1;
    RETURN v_emp;
END assign_request_to_emp;
END functions;
/