CREATE OR REPLACE TRIGGER add_entry_automatically
AFTER INSERT ON account_type
FOR EACH ROW
DECLARE
   v_owner_id NUMBER;
   v_tenant_id NUMBER;
   v_employee_id NUMBER;
BEGIN
   IF :NEW.account_type = 'owner' THEN
      SELECT OWNER_ID_SEQ.NEXTVAL INTO v_owner_id FROM dual;
      INSERT INTO owner (owner_id, account_id)
      VALUES (v_owner_id, :NEW.account_id);
   
   ELSIF :NEW.account_type = 'tenant' THEN
      SELECT TENANT_ID_SEQ.NEXTVAL INTO v_tenant_id FROM dual;
      INSERT INTO tenant (tenant_id, account_id)
      VALUES (v_tenant_id, :NEW.account_id);

   ELSIF :NEW.account_type = 'employee' THEN
      SELECT EMPLOYEE_ID_SEQ.NEXTVAL INTO v_employee_id FROM dual;
      INSERT INTO employees (employee_id, account_id)
      VALUES ( v_employee_id, :NEW.account_id);

   END IF;
END;
/
