DECLARE
V_PREVIOUS_YEAR_BALANCE NUMBER(3,0);
V_REMARKS VARCHAR2(200 BYTE);
BEGIN


-- LOOPT ALL LEAVE LIST FOR CARRY FORWARD
FOR LEAVE_LIST IN (SELECT * FROM HRIS_LEAVE_MASTER_SETUP WHERE 
                                        STATUS='E'
                                        AND IS_SUBSTITUTE='N'
                                        AND IS_MONTHLY='N'
                                                )
LOOP

-- LOOP ALL EMPLOYEE LEAVE_ASSIGN LIST
FOR EMPLOYEE_LEAVE_ASSIGN_LIST IN (SELECT * FROM HRIS_EMPLOYEE_LEAVE_ASSIGN WHERE  LEAVE_ID=LEAVE_LIST.LEAVE_ID)
LOOP

DBMS_OUTPUT.PUT_LINE(EMPLOYEE_LEAVE_ASSIGN_LIST.EMPLOYEE_ID);
DBMS_OUTPUT.PUT_LINE(EMPLOYEE_LEAVE_ASSIGN_LIST.BALANCE);
V_PREVIOUS_YEAR_BALANCE:=0;
V_REMARKS:='';



IF(LEAVE_LIST.CARRY_FORWARD='Y')THEN
V_PREVIOUS_YEAR_BALANCE:=EMPLOYEE_LEAVE_ASSIGN_LIST.BALANCE;
-- TO CHECK IF NEGATIVE BALANCE
IF(EMPLOYEE_LEAVE_ASSIGN_LIST.BALANCE<0)
THEN
V_PREVIOUS_YEAR_BALANCE:=0;
V_REMARKS:='PREVIOUS YEAR BALANCE IS '|| EMPLOYEE_LEAVE_ASSIGN_LIST.BALANCE;
END IF;
IF(V_PREVIOUS_YEAR_BALANCE>LEAVE_LIST.MAX_ACCUMULATE_DAYS AND LEAVE_LIST.MAX_ACCUMULATE_DAYS IS NOT NULL)
THEN
V_PREVIOUS_YEAR_BALANCE:=LEAVE_LIST.MAX_ACCUMULATE_DAYS;
END IF;
END IF;

BEGIN
UPDATE HRIS_EMPLOYEE_LEAVE_ASSIGN SET 
PREVIOUS_YEAR_BAL = V_PREVIOUS_YEAR_BALANCE,
TOTAL_DAYS= LEAVE_LIST.DEFAULT_DAYS,
BALANCE= V_PREVIOUS_YEAR_BALANCE+LEAVE_LIST.DEFAULT_DAYS      
WHERE EMPLOYEE_ID = EMPLOYEE_LEAVE_ASSIGN_LIST.EMPLOYEE_ID 
AND LEAVE_ID = EMPLOYEE_LEAVE_ASSIGN_LIST.LEAVE_ID;
DBMS_OUTPUT.PUT_LINE('PREVIOUS '||V_PREVIOUS_YEAR_BALANCE||' DEFAULT DAYS '||LEAVE_LIST.DEFAULT_DAYS);
   DBMS_OUTPUT.PUT_LINE('Update SUCESSFULL '||EMPLOYEE_LEAVE_ASSIGN_LIST.EMPLOYEE_ID||'  '||EMPLOYEE_LEAVE_ASSIGN_LIST.LEAVE_ID);
 
 EXCEPTION
       WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('Update Process Failed.'||EMPLOYEE_LEAVE_ASSIGN_LIST.EMPLOYEE_ID||'  '||EMPLOYEE_LEAVE_ASSIGN_LIST.LEAVE_ID);
        ROLLBACK;
  END;
  
END LOOP;
--END EMPLOYEE LEAVE ASSIGN
END LOOP;
--END EMPLOYEE LEAVE LIST




-- DELTE ALL SUBSTITUTE LEAVE
DELETE  FROM HRIS_EMPLOYEE_LEAVE_ASSIGN 
WHERE LEAVE_ID IN ( SELECT LEAVE_ID FROM HRIS_LEAVE_MASTER_SETUP
             WHERE STATUS='E' AND IS_SUBSTITUTE='Y');
             

-- FOR MONTHLY LEAVE
FOR LEAVE_LIST IN (SELECT * FROM HRIS_LEAVE_MASTER_SETUP WHERE 
                                        STATUS='E'
                                        AND IS_MONTHLY='Y'
                                                )
LOOP

-- LOOP ALL EMPLOYEE LEAVE_ASSIGN LIST
FOR EMPLOYEE_LEAVE_ASSIGN_LIST IN (SELECT DISTINCT EMPLOYEE_ID,LEAVE_ID FROM HRIS_EMPLOYEE_LEAVE_ASSIGN 
                                   WHERE   LEAVE_ID=LEAVE_LIST.LEAVE_ID
                                   GROUP BY EMPLOYEE_ID,LEAVE_ID)
LOOP

DELETE  FROM HRIS_EMPLOYEE_LEAVE_ASSIGN WHERE 
LEAVE_ID=EMPLOYEE_LEAVE_ASSIGN_LIST.LEAVE_ID
AND EMPLOYEE_ID=EMPLOYEE_LEAVE_ASSIGN_LIST.EMPLOYEE_ID;


  FOR i IN 1..12
            LOOP
              
                INSERT
                INTO HRIS_EMPLOYEE_LEAVE_ASSIGN
                  (
                    EMPLOYEE_ID,
                    LEAVE_ID,
                    PREVIOUS_YEAR_BAL,
                    TOTAL_DAYS,
                    BALANCE,
                    FISCAL_YEAR_MONTH_NO,
                    CREATED_DT
                  )
                  VALUES
                  (
                    EMPLOYEE_LEAVE_ASSIGN_LIST.EMPLOYEE_ID,
                    EMPLOYEE_LEAVE_ASSIGN_LIST.LEAVE_ID,
                    0,
                    LEAVE_LIST.DEFAULT_DAYS,
                    LEAVE_LIST.DEFAULT_DAYS,
                    i,
                    TRUNC(SYSDATE)
                  );
              
              
            END LOOP;


    
    
   
    


END LOOP; -- FOR EMPLOYEE MONTHLY ASSIGN LEAVE LIST
END LOOP; -- FOR MONTHLY LEAVE LIST END

END;