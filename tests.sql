----Tests ---------
--Cannot insert payment for an expired or terminated lease agreement

EXEC common_procedures.pay_rent(LEASE_PAYMENT_ID_SEQ.CURRVAL,1220,TO_DATE('03-NOV-2022', 'dd-Mon-yyyy'));