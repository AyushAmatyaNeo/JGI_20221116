create or replace PROCEDURE HRIS_SYSTEM_NOTIFICATION(
    P_TO_EMPLOYEE_ID HRIS_NOTIFICATION.MESSAGE_TO%TYPE,
    P_MESSAGE_DATETIME HRIS_NOTIFICATION.MESSAGE_DATETIME%TYPE,
    P_MESSAGE_TITLE HRIS_NOTIFICATION.MESSAGE_TITLE%TYPE,
    P_MESSAGE_DESC HRIS_NOTIFICATION.MESSAGE_DESC%TYPE,
    P_ROUTE HRIS_NOTIFICATION.ROUTE%TYPE)
AS
  V_MESSAGE_ID HRIS_NOTIFICATION.MESSAGE_ID%TYPE;
  V_MESSAGE_FROM HRIS_NOTIFICATION.MESSAGE_FROM%TYPE;
  V_EXPIRY_TIME HRIS_NOTIFICATION.EXPIRY_TIME%TYPE;
BEGIN
  SELECT NVL(MAX(MESSAGE_ID),0)+1 INTO V_MESSAGE_ID FROM HRIS_NOTIFICATION;
  --
  SELECT EMPLOYEE_ID
  INTO V_MESSAGE_FROM
  FROM HRIS_EMPLOYEES
  WHERE IS_ADMIN='Y'
  AND ROWNUM    =1;
  --
  V_EXPIRY_TIME:=P_MESSAGE_DATETIME+14;
  --
  INSERT
  INTO HRIS_NOTIFICATION
    (
      MESSAGE_ID,
      MESSAGE_DATETIME,
      MESSAGE_TITLE,
      MESSAGE_DESC,
      MESSAGE_FROM,
      MESSAGE_TO,
      STATUS,
      EXPIRY_TIME,
      ROUTE
    )
    VALUES
    (
      V_MESSAGE_ID,
      P_MESSAGE_DATETIME,
      P_MESSAGE_TITLE,
      P_MESSAGE_DESC,
      V_MESSAGE_FROM,
      P_TO_EMPLOYEE_ID,
      'U',
      V_EXPIRY_TIME,
      P_ROUTE
    );
EXCEPTION
WHEN NO_DATA_FOUND THEN
  DBMS_OUTPUT.PUT_LINE ('No Admin is defined!!!' );
END;