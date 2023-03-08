--------- TRIGGER ----------
CREATE OR REPLACE TRIGGER increase_arrearage
AFTER INSERT
ON Order_TB
FOR EACH ROW
BEGIN
    UPDATE  Customer
    SET     Arrearage = Arrearage + :NEW.Total_Price
    WHERE   Code = :NEW.Cus_Code;
END;
/

CREATE OR REPLACE TRIGGER check_arrearage
BEFORE INSERT
ON Partial_Payments
FOR EACH ROW
DECLARE
    ar INTEGER;
    INVALID_AMOUNT EXCEPTION;
BEGIN
    SELECT  Arrearage
    INTO    ar
    FROM    Customer
    WHERE   Code = :NEW.Cus_Code;
    
    IF :NEW.Amount > ar THEN
        RAISE INVALID_AMOUNT;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER decrease_arrearage
AFTER INSERT
ON Partial_Payments
FOR EACH ROW
BEGIN
    UPDATE  Customer
    SET     Arrearage = Arrearage - :NEW.Amount
    WHERE   Code = :NEW.Cus_Code;
END;
/

CREATE OR REPLACE TRIGGER update_status
FOR INSERT
ON Payment_History
COMPOUND TRIGGER
    sum_amount NUMBER(19);
    total_price NUMBER(19);
    O_Code_new VARCHAR(6);

    AFTER EACH ROW IS
    BEGIN
        O_Code_new := :NEW.O_code;
    END AFTER EACH ROW;
         
    AFTER STATEMENT IS
    BEGIN
        SELECT SUM(Amount) 
        INTO sum_amount 
        FROM Payment_History 
        WHERE O_Code = O_Code_new;
        
        SELECT Total_Price
        INTO total_price
        FROM Order_TB 
        WHERE O_Code = O_Code_new;
        
        IF sum_amount < total_price THEN
            UPDATE  Order_TB
            SET Order_Status = 'partial paid'
            WHERE O_code = O_Code_new;
        ELSE
            UPDATE  Order_TB
            SET Order_Status = 'full paid'
            WHERE O_code = O_Code_new;
        END IF;
    END AFTER STATEMENT;
END update_status;
/

CREATE OR REPLACE TRIGGER decrease_quantity
AFTER INSERT
ON Contains
FOR EACH ROW
BEGIN
    UPDATE  Category
    SET     Quantity = Quantity - 1
    WHERE   C_Code = :NEW.C_Code;
END;
/

CREATE OR REPLACE TRIGGER update_status_cancelled
AFTER INSERT
ON Cancel_Order
FOR EACH ROW
BEGIN
        UPDATE  Order_TB
        SET Order_Status = 'cancelled'
        WHERE O_code = :NEW.O_Code;

        UPDATE  Customer
        SET     Arrearage = Arrearage - (SELECT Total_Price FROM Order_TB Where Cus_Code=:NEW.Cus_Code)
        WHERE   Code = :NEW.Cus_Code;
END;
/


CREATE SEQUENCE sup_seq START WITH 1;

CREATE OR REPLACE TRIGGER auto_sup
BEFORE INSERT ON Supplier
FOR EACH ROW
DECLARE
BEGIN
    SELECT ('SU' || TO_CHAR(sup_seq.NEXTVAL, 'fm0000'))
    INTO :new.S_Code
    FROM dual;
END;

/

CREATE SEQUENCE cat_seq START WITH 1;

CREATE OR REPLACE TRIGGER auto_cat
BEFORE INSERT ON Category
FOR EACH ROW
DECLARE
BEGIN
    SELECT ('CA' || TO_CHAR(cat_seq.NEXTVAL, 'fm0000'))
    INTO :new.C_Code
    FROM dual;
END;

/