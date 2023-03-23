BEGIN
  -- Drop table if it exists
  BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Tenant';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
        RAISE;
      END IF;
  END;

    -- Create the Tenant table
    EXECUTE IMMEDIATE 'CREATE TABLE Tenant (
      tenant_id NUMBER PRIMARY KEY,
      contact_number NUMBER
    )';



    INSERT ALL
      INTO Tenant (tenant_id, contact_number) VALUES (101, 1234567890)
      INTO Tenant (tenant_id, contact_number) VALUES (102, 2345678901)
      INTO Tenant (tenant_id, contact_number) VALUES (103, 3456789012)
      INTO Tenant (tenant_id, contact_number) VALUES (104, 4567890123)
      INTO Tenant (tenant_id, contact_number) VALUES (105, 5678901234)
    SELECT * FROM dual;
    COMMIT;

END;
SELECT * FROM Tenant;