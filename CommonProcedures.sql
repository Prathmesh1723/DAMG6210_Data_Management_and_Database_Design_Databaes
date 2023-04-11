CREATE OR REPLACE PACKAGE common_procedures AS
    PROCEDURE insert_lease_agreement (
        p_lease_no IN NUMBER,
        p_unit_no IN NUMBER,
        p_owner_id IN NUMBER,
        p_tenant_id IN NUMBER,
        p_lease_Date IN DATE,
        p_lease_Startdate IN DATE,
        p_lease_Term IN NUMBER,
        p_security_Deposit IN NUMBER,
        p_monthly_Rent IN NUMBER
    );
    PROCEDURE assign_employee_to_residency (
      p_emp_id IN NUMBER,
      p_residency_no IN NUMBER
    );
    PROCEDURE pay_rent(
    p_lease_payment_id IN NUMBER,
    p_payment_amount IN NUMBER,
    p_payment_date IN DATE
    );
    PROCEDURE charge_rent (
        due_date IN DATE,
        lease_payment_id IN NUMBER,
        p_lease_no IN NUMBER
    );
    PROCEDURE enter_deposit_return(
      p_payment_id IN security_Deposit_Return.payment_id%TYPE,
      p_lease_no IN security_Deposit_Return.lease_no%TYPE
    );
    PROCEDURE insert_request (
        p_request_id IN NUMBER,
        p_request_type IN VARCHAR2,
        p_request_priority IN VARCHAR2,
        p_request_date IN DATE,
        p_unit_no IN NUMBER
    );
    PROCEDURE update_request (
      p_request_id IN NUMBER,
      p_resolved_date IN DATE
    );
END common_procedures;
/

CREATE OR REPLACE PACKAGE BODY common_procedures AS
    PROCEDURE insert_lease_agreement (
        p_lease_no IN NUMBER,
        p_unit_no IN NUMBER,
        p_owner_id IN NUMBER,
        p_tenant_id IN NUMBER,
        p_lease_Date IN DATE,
        p_lease_Startdate IN DATE,
        p_lease_Term IN NUMBER,
        p_security_Deposit IN NUMBER,
        p_monthly_Rent IN NUMBER
    ) AS
        l_house_status VARCHAR2(20);
        l_months_diff NUMBER(10);
        
    BEGIN
        IF (p_lease_Date > p_lease_Startdate) THEN
            RAISE_APPLICATION_ERROR(-20001, 'Lease start date cannot be less than lease date.');
        END IF;
        
        SELECT status INTO l_house_status FROM House WHERE unit_no = p_unit_no;

        IF (l_house_status = 'Rented') THEN
            RAISE_APPLICATION_ERROR(-20002, 'This unit is already rented.');
        ELSIF (l_house_status = 'Available') THEN
            INSERT INTO Lease_agreement (
                lease_no,
                unit_no,
                owner_id,
                tenant_id,
                lease_Date,
                lease_Startdate,
                lease_Term,
                security_Deposit,
                lease_Status,
                monthly_Rent
            )
            VALUES (
                p_lease_no,
                p_unit_no,
                p_owner_id,
                p_tenant_id,
                p_lease_Date,
                p_lease_Startdate,
                p_lease_Term,
                p_security_Deposit,
                0,
                p_monthly_Rent
            );
            
            l_months_diff := MONTHS_BETWEEN(SYSDATE, p_lease_Startdate);
            
            IF (l_months_diff > p_lease_Term) THEN
                UPDATE House SET status = 'Available' WHERE unit_no = p_unit_no;
            ELSE
                UPDATE Lease_agreement SET lease_status = 1 WHERE lease_no = p_lease_no;
                UPDATE House SET status = 'Rented' WHERE unit_no = p_unit_no;
            END IF;
        ELSE
            RAISE_APPLICATION_ERROR(-20003, 'Invalid house status.');
        END IF;
    END insert_lease_agreement;
    
    PROCEDURE assign_employee_to_residency (
      p_emp_id IN NUMBER,
      p_residency_no IN NUMBER
    )
    IS
    BEGIN
      UPDATE Employees
      SET residency_no = p_residency_no
      WHERE employee_id = p_emp_id;
      
      COMMIT;
      dbms_output.put_line('Employee with ID ' || p_emp_id || ' has been assigned to residency number ' || p_residency_no);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('Invalid employee ID or residency number');
      WHEN OTHERS THEN
        dbms_output.put_line('An error occurred: ' || SQLERRM);
    END assign_employee_to_residency;

    
    PROCEDURE pay_rent(
    p_lease_payment_id IN NUMBER,
    p_payment_amount IN NUMBER,
    p_payment_date IN DATE
)
AS
    v_monthly_rent_amount NUMBER;
    v_total_due NUMBER;
    v_last_payment_date DATE;
    v_late_fee NUMBER := 0;
    v_lease_no NUMBER;
    v_lease_status NUMBER;
    temp NUMBER;
BEGIN
    -- Get the lease number for the given lease payment
    SELECT lease_no
    INTO v_lease_no
    FROM Lease_Payments
    WHERE lease_payment_id = p_lease_payment_id;

    -- Get the monthly rent amount for the given lease agreement
    SELECT monthly_rent
    INTO v_monthly_rent_amount
    FROM Lease_Agreement
    WHERE lease_no = v_lease_no;

    -- Check if the lease agreement is still active
    SELECT lease_status
    INTO v_lease_status
    FROM Lease_Agreement
    WHERE lease_no = v_lease_no;

    IF v_lease_status <> 1 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Cannot insert payment for an expired or terminated lease agreement');
    END IF;

    -- Calculate the total amount due for this payment
    SELECT payment_amount + NVL(late_fees, 0)
    INTO v_total_due
    FROM Lease_Payments
    WHERE lease_payment_id = p_lease_payment_id;

    -- Validate the payment amount
    IF p_payment_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Invalid payment amount');
    END IF;
    

    -- Check if the payment is late
    SELECT payment_dueDate
    INTO v_last_payment_date
    FROM Lease_Payments
    WHERE lease_payment_id = p_lease_payment_id;

    IF v_last_payment_date < TRUNC(p_payment_date) THEN -- compare payment_dueDate with payment_date provided
        -- Calculate late fees
        v_late_fee := (TRUNC(p_payment_date) - TRUNC(v_last_payment_date)) * 10; -- Assuming late fees are 10$ per day
        DBMS_OUTPUT.PUT_LINE('Late Fees: $' || v_late_fee); -- display late fees to console
    END IF;
    
    temp := v_monthly_rent_amount + v_late_fee;
    
    
     IF p_payment_amount != temp THEN
        RAISE_APPLICATION_ERROR(-20002, 'Rent amount due is ' || temp);
    END IF;
    
    -- Update the Lease_Payments table
    IF p_payment_amount = temp THEN
    UPDATE Lease_Payments
    SET payment_status = 'Payment Done',
        payment_amount = p_payment_amount,
        payment_date = p_payment_date,
        late_fees = v_late_fee
    WHERE lease_payment_id = p_lease_payment_id;
    END IF;
    
END pay_rent;

PROCEDURE charge_rent (
        due_date IN DATE,
        lease_payment_id IN NUMBER,
        p_lease_no IN NUMBER
    ) AS
        rent_amount NUMBER;
    BEGIN
        -- Get the monthly rent for the lease agreement
        SELECT monthly_Rent INTO rent_amount FROM Lease_agreement WHERE lease_no = p_lease_no;
    
        -- Insert a new entry in the Lease_Payments table
        INSERT INTO Lease_Payments (
            lease_payment_id,
            payment_dueDate,
            payment_status,
            payment_amount,
            lease_no,
            late_fees
        ) VALUES (
            lease_payment_id,
            due_date,
            'Payment Not Done',
            rent_amount,
            p_lease_no,
            NULL
        );
    END charge_rent;
    
--    PROCEDURE enter_deposit_return(
--      p_payment_id IN security_Deposit_Return.payment_id%TYPE,
--      p_lease_no IN security_Deposit_Return.lease_no%TYPE
--    )
--    IS
--      v_return_status security_Deposit_Return.return_status%TYPE := 'Not Returned';
--      v_return_date security_Deposit_Return.return_date%TYPE;
--      v_security_deposit_amount Lease_agreement.security_Deposit%TYPE;
--      v_lease_term NUMBER;
--      v_date NUMBER;
--      v_amount_returned security_Deposit_Return.amount_returned%TYPE;
--      v_request_count NUMBER;
--      v_lease_duration NUMBER;
--    BEGIN
--      SELECT lease_startdate, lease_term, security_deposit, lease_term
--      INTO v_return_date, v_lease_term, v_security_deposit_amount, v_lease_duration
--      FROM Lease_agreement
--      WHERE lease_no = p_lease_no;
--    
--      v_date := MONTHS_BETWEEN(SYSDATE, v_return_date);
--      v_amount_returned := NULL;
--      
--      -- Subquery to retrieve the count of requests for the unit in the lease agreement
--      SELECT COUNT(request_id)
--      INTO v_request_count
--      FROM Requests
--      WHERE LOGGED_BY = (SELECT unit_no FROM Lease_agreement WHERE lease_no = p_lease_no);
--      
--      DBMS_OUTPUT.PUT_LINE('Requests ' || v_request_count); -- display late fees to console
--
--      IF v_date >=  v_lease_duration THEN
--        v_return_status := 'Returned';
--        v_return_date := v_return_date + v_lease_term;
--        v_amount_returned := functions.calculate_amount_returned(v_request_count, v_security_deposit_amount);
--      END IF;
--      
--      v_return_date := v_return_date + v_lease_term;
--      DBMS_OUTPUT.PUT_LINE('return date ' || v_return_date);
--      DBMS_OUTPUT.PUT_LINE('lease end date ' || v_return_date);
--      
--    
--      INSERT INTO security_Deposit_Return(
--        payment_id, return_status, return_date, security_deposit_amount, amount_returned, lease_no
--      )
--      VALUES(
--        p_payment_id, v_return_status, v_return_date, v_security_deposit_amount, v_amount_returned, p_lease_no
--      );
--      
--      COMMIT;
--    EXCEPTION
--      WHEN NO_DATA_FOUND THEN
--        RAISE_APPLICATION_ERROR(-20001, 'Invalid lease number.');
--    END enter_deposit_return;

    PROCEDURE enter_deposit_return(
      p_payment_id IN security_Deposit_Return.payment_id%TYPE,
      p_lease_no IN security_Deposit_Return.lease_no%TYPE
    )
    IS
      v_return_status security_Deposit_Return.return_status%TYPE := 'Not Returned';
      v_return_date security_Deposit_Return.return_date%TYPE;
      v_security_deposit_amount Lease_agreement.security_Deposit%TYPE;
      v_lease_term NUMBER;
      v_date NUMBER;
      v_amount_returned security_Deposit_Return.amount_returned%TYPE;
      v_request_count NUMBER;
      v_lease_duration NUMBER;
      v_lease_enddate DATE;
    BEGIN
      SELECT lease_startdate, lease_term, security_deposit, lease_term, ADD_MONTHS(lease_startdate, lease_term) AS lease_enddate
      INTO v_return_date, v_lease_term, v_security_deposit_amount, v_lease_duration, v_lease_enddate
      FROM Lease_agreement
      WHERE lease_no = p_lease_no;
    
      v_date := MONTHS_BETWEEN(SYSDATE, v_return_date);
      v_amount_returned := NULL;
    
      -- Subquery to retrieve the count of requests for the unit in the lease agreement
      SELECT COUNT(request_id)
      INTO v_request_count
      FROM Requests
      WHERE LOGGED_BY = (SELECT unit_no FROM Lease_agreement WHERE lease_no = p_lease_no);
    
      DBMS_OUTPUT.PUT_LINE('Requests ' || v_request_count); -- display late fees to console
    
      IF SYSDATE >= v_lease_enddate THEN
        v_return_status := 'Returned';
        v_amount_returned := functions.calculate_amount_returned(v_request_count, v_security_deposit_amount);
      END IF;
    
      DBMS_OUTPUT.PUT_LINE('return date ' || v_return_date);
      DBMS_OUTPUT.PUT_LINE('lease end date ' || v_lease_enddate);
      
      INSERT INTO security_Deposit_Return(
        payment_id, return_status, return_date, security_deposit_amount, amount_returned, lease_no
      )
      VALUES(
        p_payment_id, v_return_status, v_lease_enddate, v_security_deposit_amount, v_amount_returned, p_lease_no
      );

      UPDATE security_Deposit_Return
      SET return_status = v_return_status,
          return_date = v_lease_enddate,
          amount_returned = v_amount_returned
      WHERE payment_id = p_payment_id
        AND lease_no = p_lease_no;
    
    
      COMMIT;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid lease number.');
    END enter_deposit_return;

    
    PROCEDURE insert_request (
        p_request_id IN NUMBER,
        p_request_type IN VARCHAR2,
        p_request_priority IN VARCHAR2,
        p_request_date IN DATE,
        p_unit_no IN NUMBER
    ) IS
        v_employee_id NUMBER(10);
        v_residency_no NUMBER(10);
        v_due_date DATE;
        v_request_count NUMBER(10);
        v_emp_id NUMBER(10);
    BEGIN
        SELECT residency_no INTO v_residency_no
        FROM House
        WHERE unit_no = p_unit_no;
        
        v_emp_id:= functions.assign_request_to_emp(v_residency_no);


        IF p_request_priority = 'High' THEN
            v_due_date := p_request_date;
        ELSIF p_request_priority = 'Medium' THEN
            v_due_date := p_request_date + 2;
        ELSE
            v_due_date := p_request_date + 3;
        END IF;
        
        INSERT INTO Requests (request_id, logged_by, reported_to_Employee_id, request_type, request_priority, date_logged, req_status, due_date, resolved_date)
        VALUES (
            p_request_id ,
            p_unit_no,
            v_emp_id,
            p_request_type,
            p_request_priority,
            p_request_date,
            'Open',
            v_due_date,
            NULL
        );

--        -- update the employee's request_id
--        UPDATE Employees
--        SET request_id = p_request_id
--        WHERE employee_id = v_employee_id;
    END insert_request;

    
    PROCEDURE update_request (
      p_request_id IN NUMBER,
      p_resolved_date IN DATE
    ) IS
    BEGIN
      UPDATE Requests
      SET req_status = 'Completed',
          resolved_date = p_resolved_date
      WHERE request_id = p_request_id;
      
      DBMS_OUTPUT.PUT_LINE('Request updated successfully.');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Request ID ' || p_request_id || ' not found.');
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error updating request: ' || SQLERRM);
    END update_request;
END common_procedures;
/





