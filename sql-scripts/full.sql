------- TABLE --------
-- Customer
CREATE TABLE Customer (
    Code VARCHAR2(8) NOT NULL PRIMARY KEY,  -- Example: CUXXXXXX
    FName VARCHAR2(30) NOT NULL,
    LName VARCHAR2(30),
    Address VARCHAR2(200),
    Arrearage INTEGER CHECK (Arrearage >= 0) NOT NULL,
    Office_Staff_Code VARCHAR2(8) NOT NULL
);

-- * Set default for Arrearage = 0
ALTER TABLE
    Customer
MODIFY
    Arrearage DEFAULT 0;

-- Customer's Phone Numbers
CREATE TABLE Cus_Phone_Numbers (
    Cus_Code VARCHAR2(8) NOT NULL,
    Phone_Number VARCHAR2(15) NOT NULL,
    CONSTRAINT PK_Cus_Phone_Numbers PRIMARY KEY (Cus_Code, Phone_Number)
);

-- * Cus_Phone_Numbers -> Customer
ALTER TABLE
    Cus_Phone_Numbers
ADD
    FOREIGN KEY (Cus_Code) REFERENCES Customer(Code);

-- Partial Payments
CREATE TABLE Partial_Payments (
    Cus_Code VARCHAR2(8) NOT NULL,
    Amount INTEGER CHECK (Amount > 0) NOT NULL,
    "Date" DATE NOT NULL,
    CONSTRAINT PK_Partial_Payments PRIMARY KEY (Cus_Code, Amount, "Date")
);

-- * Partial_Payments -> Customer
ALTER TABLE
    Partial_Payments
ADD
    FOREIGN KEY (Cus_Code) REFERENCES Customer(Code);

-- Employee
CREATE TABLE Employee (
    E_Code VARCHAR2(8) NOT NULL PRIMARY KEY,    -- Example: EMXXXXXX
    FName VARCHAR2(30) NOT NULL,
    LName VARCHAR2(30),
    Gender CHAR(1) NOT NULL,
    Address VARCHAR2(200) NOT NULL,
    Phone_Number VARCHAR2(15) NOT NULL
);

-- Manager
CREATE TABLE Manager (E_Code VARCHAR2(8) NOT NULL PRIMARY KEY);

-- * Manager -> Employee
ALTER TABLE
    Manager
ADD
    FOREIGN KEY (E_Code) REFERENCES Employee(E_Code);

-- Office Staff
CREATE TABLE Office_Staff (E_Code VARCHAR2(8) NOT NULL PRIMARY KEY);

-- * Office Staff -> Employee
ALTER TABLE
    Office_Staff
ADD
    FOREIGN KEY (E_Code) REFERENCES Employee(E_Code);

-- * Customer -> Office Staff 
ALTER TABLE
    Customer
ADD
    FOREIGN KEY (Office_Staff_Code) REFERENCES Office_Staff(E_Code);

-- Partner Staff
CREATE TABLE Partner_Staff (E_Code VARCHAR2(8) NOT NULL PRIMARY KEY);

-- * Partner Staff -> Employee
ALTER TABLE
    Partner_Staff
ADD
    FOREIGN KEY (E_Code) REFERENCES Employee(E_Code);

-- Operational Staff
CREATE TABLE Operational_Staff (E_Code VARCHAR2(8) NOT NULL PRIMARY KEY);

-- * Operational Staff -> Employee
ALTER TABLE
    Operational_Staff
ADD
    FOREIGN KEY (E_Code) REFERENCES Employee(E_Code);

-- Supplier
CREATE TABLE Supplier (
    S_Code VARCHAR2(6) NOT NULL PRIMARY KEY,    -- Example: SUXXXXXX
    Name VARCHAR2(100) NOT NULL,
    Address VARCHAR2(200) NOT NULL,
    Bank_Account VARCHAR2(17) NOT NULL UNIQUE,
    Tax_Code VARCHAR2(18) NOT NULL UNIQUE,
    Partner_Staff_Code VARCHAR2(8) NOT NULL
);

-- * Supplier -> Partner Staff
ALTER TABLE
    Supplier
ADD
    FOREIGN KEY (Partner_Staff_Code) REFERENCES Partner_Staff(E_Code);

-- Supplier's Phone Numbers
CREATE TABLE Sup_Phone_Numbers (
    S_Code VARCHAR2(8) NOT NULL,
    Phone_Number VARCHAR2(15) NOT NULL,
    CONSTRAINT PK_Sup_Phone_Numbers PRIMARY KEY (S_Code, Phone_Number)
);

-- * Sup Phone Numbers -> Supplier
ALTER TABLE
    Sup_Phone_Numbers
ADD
    FOREIGN KEY (S_Code) REFERENCES Supplier(S_Code);

-- Order
CREATE TABLE Order_TB (
    O_Code VARCHAR2(10) NOT NULL PRIMARY KEY,   -- Example: ORXXXXXXXX
    Total_Price INTEGER CHECK (Total_Price > 0) NOT NULL,
    DateTime TIMESTAMP(0) NOT NULL,
    Opr_Staff_Code VARCHAR2(8) NOT NULL,
    Cus_Code VARCHAR2(8) NOT NULL,
    Order_Status VARCHAR2(12) NOT NULL  -- "new", "order", "partial paid", "full paid", "cancelled"
);

-- * Order -> Operational Staff
ALTER TABLE
    Order_TB
ADD
    FOREIGN KEY (Opr_Staff_Code) REFERENCES Operational_Staff(E_Code);

-- * Order -> Cus_Code
ALTER TABLE
    Order_TB
ADD
    FOREIGN KEY (Cus_Code) REFERENCES Customer(Code);

-- Payment History
CREATE TABLE Payment_History (
    O_Code VARCHAR2(10) NOT NULL,
    Amount INTEGER CHECK (Amount > 0) NOT NULL,
    "Date" DATE NOT NULL,
    CONSTRAINT PK_Payment_History PRIMARY KEY (O_Code, Amount, "Date")
);

-- * Payment History -> Order_TB
ALTER TABLE
    Payment_History
ADD
    FOREIGN KEY (O_Code) REFERENCES Order_TB(O_Code);

-- Cancel Order
CREATE TABLE Cancel_Order (
    Cus_Code VARCHAR2(8) NOT NULL,
    O_Code VARCHAR2(10) NOT NULL PRIMARY KEY,
    Opr_Staff_Code VARCHAR2(8) NOT NULL,
    Reason VARCHAR2(255) NOT NULL
);

-- * Cancel Order -> Customer
ALTER TABLE
    Cancel_Order
ADD
    FOREIGN KEY (Cus_Code) REFERENCES Customer(Code);

-- * Cancel Order -> Order
ALTER TABLE
    Cancel_Order
ADD
    FOREIGN KEY (O_Code) REFERENCES Order_TB(O_Code);

-- * Cancel Order -> Operational Staff
ALTER TABLE
    Cancel_Order
ADD
    FOREIGN KEY (Opr_Staff_Code) REFERENCES Operational_Staff(E_Code);

-- Category
CREATE TABLE Category (
    C_Code VARCHAR2(6) NOT NULL PRIMARY KEY,    -- Example: CAXXXX
    Name VARCHAR2(10) NOT NULL,
    Color VARCHAR2(20) NOT NULL,
    Quantity INTEGER CHECK (Quantity > 0) NOT NULL,
    S_Code VARCHAR2(6) NOT NULL,
    "Date" DATE NOT NULL,
    Provided_Quantity INTEGER CHECK (Provided_Quantity > 0) NOT NULL,
    Purchased_Price INTEGER CHECK (Purchased_Price > 0) NOT NULL
);

-- * Category -> Supplier
ALTER TABLE
    Category
ADD
    FOREIGN KEY (S_Code) REFERENCES Supplier(S_Code);

-- Bolt
CREATE TABLE Bolt (
    C_Code VARCHAR2(6) NOT NULL,
    B_Code VARCHAR2(6) NOT NULL,    -- Example: BOXXXX
    Length NUMBER CHECK (Length > 0) NOT NULL,
    CONSTRAINT PK_Bolt PRIMARY KEY (C_Code, B_Code)
);

-- * Bolt -> Category
ALTER TABLE
    Bolt
ADD
    FOREIGN KEY (C_Code) REFERENCES Category(C_Code);

-- Contains
CREATE TABLE Contains (
    C_Code VARCHAR2(6) NOT NULL,
    B_Code VARCHAR2(6) NOT NULL,
    O_Code VARCHAR2(10) NOT NULL,
    CONSTRAINT PK_Contains PRIMARY KEY (C_Code, B_Code)
);

-- * Contains -> Bolt
ALTER TABLE
    Contains
ADD
    FOREIGN KEY (C_Code, B_Code) REFERENCES Bolt(C_Code, B_Code);

-- * Contains -> Order TB
ALTER TABLE
    Contains
ADD
    FOREIGN KEY (O_Code) REFERENCES Order_TB(O_Code);

-- Current Price
CREATE TABLE Current_Price (
    C_Code VARCHAR2(6) NOT NULL,
    Price INTEGER CHECK (Price > 0) NOT NULL,
    Set_Date Date NOT NULL,
    CONSTRAINT PK_Curr_Price PRIMARY KEY (C_Code, Price, Set_Date)
);

-- * Current Price -> Category
ALTER TABLE
    Current_Price
ADD
    FOREIGN KEY (C_Code) REFERENCES Category(C_Code);

--------- CONSTRAINT --------
ALTER TABLE Category
ADD CHECK (Name IN ('Silk', 'Khaki', 'Crewel', 'Jacquard', 'Faux silk', 'Damask'));

ALTER TABLE Order_TB
ADD CHECK (Order_Status IN ('new', 'ordered', 'partial paid', 'full paid', 'cancelled'));

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


--------- DATA -----------
-- * Employee
-- E_Code, FName, LName, Gender, Address, Phone_Number
-- 01: Manger, 02: Office Staff, 03: Operation Staff, 04: Partner Staff
INSERT INTO Employee VALUES ('EM010001',   'Minh',        NULL,       'M', '345 Ly Thuong Kiet, HCM, VN',             '+84 963 041 118');
INSERT INTO Employee VALUES ('EM010002',   'John' ,       'Smith',    'M', '731 Fondren, Houston, TX, US',            '+1 202 555 0118');
INSERT INTO Employee VALUES ('EM020001',   'Franklin',    'Wong',     'M', '638 Voss, Houston, TX, US',               '+1 281 555 0176');
INSERT INTO Employee VALUES ('EM020002',   'Kai',         'Roberts',  'M', '869 Sit Rd., Bundaberg, NSW, Aus',        '+61 7 5277 5734');
INSERT INTO Employee VALUES ('EM020003',   'Jennifer',    'Wallace',  'F', '291 Berry, Bellaire, TX, US',             '+1 613 555 0165');
INSERT INTO Employee VALUES ('EM030001',   'Ramesh',      'Narayan',  'M', '975 Fire Oak, Humble, TX, US',            '+1 256 555 0114');
INSERT INTO Employee VALUES ('EM030002',   'Joyce',       'English',  'F', '5631 Rice, Houston, TX, US',              '+1 281 555 0179');
INSERT INTO Employee VALUES ('EM030003',   'Ahmad',       'Jabbar',   'M', '980 Dallas, Houston, TX, US',             '+1 281 555 0102');
INSERT INTO Employee VALUES ('EM040001',   'James',       'Borg',     'M', '450 Stone, Houston, TX',                  '+1 281 555 0147');
INSERT INTO Employee VALUES ('EM040002',   'Dale',        'Diener',   'F', '4118 Dictum, Berlin, Hamburg, Germany',   '+49 21 213 7385');

-- * Manager
INSERT INTO Manager
SELECT E_Code
FROM Employee
WHERE E_Code LIKE 'EM01%';

-- * Office Staff
INSERT INTO Office_Staff
SELECT E_Code
FROM Employee
WHERE E_Code LIKE 'EM02%';

-- * Operation Staff
INSERT INTO Operational_Staff
SELECT E_Code
FROM Employee
WHERE E_Code LIKE 'EM03%';

-- * Partner Staff
INSERT INTO Partner_Staff
SELECT E_Code
FROM Employee
WHERE E_Code LIKE 'EM04%';

-- * Supplier
-- S_Code, Name, Address, Bank_Acount, Tax_Code, Partner_Staff_Code
INSERT INTO Supplier VALUES ('auto', 'MSC Industrial Supply',           '168 Odio. Rd., Melville, NY, US',              'VG934578442495',       '74 7873724',       'EM040002');
INSERT INTO Supplier VALUES ('auto', 'Wurth Industry North America',    'Ap #213-3892 Egestas. Rd., Ramsey, NJ, US',    '3697 325764 37210',    '33 0086631',       'EM040002');
INSERT INTO Supplier VALUES ('auto', 'KPF',                             '50 Chungjusandan, Chungju-Si, KR',             '123552529112',         '339 00 86631',     'EM040001');
INSERT INTO Supplier VALUES ('auto', 'Zhejiang Laibao Precision',       '668 Donghai Rd., Xitangquiao, Haiyan, CN',     '91234567890',          '5151657005475175x','EM040002');
INSERT INTO Supplier VALUES ('auto', 'Sanritsu Corp.',                  '1-1 Ebiso-Cho, Yokohama . JAPAN',              '4571 8764',            '840751732718',     'EM040001');

-- * Supplier Phone Numbers
INSERT INTO Sup_Phone_Numbers VALUES ('SU0001', '800 645 7270');
INSERT INTO Sup_Phone_Numbers VALUES ('SU0001', '+1 800 645 7270');
INSERT INTO Sup_Phone_Numbers VALUES ('SU0002', '+1 877 999 8784');
INSERT INTO Sup_Phone_Numbers VALUES ('SU0003', '031 8038 9700');
INSERT INTO Sup_Phone_Numbers VALUES ('SU0004', '+86 866 574 428');
INSERT INTO Sup_Phone_Numbers VALUES ('SU0005', '6208457 6208457');


INSERT INTO Category VALUES ('auto', 'Silk', 'Red', 626, 'SU0001', '30-DEC-2020', 900, 500);
INSERT INTO Category VALUES ('auto', 'Silk', 'Blue', 153, 'SU0002', '15-JAN-2021',750, 1000);
INSERT INTO Category VALUES ('auto', 'Silk', 'Yellow', 495, 'SU0003', '05-MAR-2019', 1200, 700);
INSERT INTO Category VALUES ('auto', 'Crewel', 'Green', 123, 'SU0004', '24-MAY-2020', 500, 400);
INSERT INTO Category VALUES ('auto', 'Damask', 'Purple', 86, 'SU0005', '18-SEP-2020', 300, 600);

INSERT INTO Current_Price VALUES ('CA0001', 550, '03-JAN-2021');
INSERT INTO Current_Price VALUES ('CA0002', 900, '17-JAN-2022');
INSERT INTO Current_Price VALUES ('CA0003', 600, '23-FEB-2020');
INSERT INTO Current_Price VALUES ('CA0003', 650, '08-JUL-2021');
INSERT INTO Current_Price VALUES ('CA0004', 500, '29-DEC-2021');
INSERT INTO Current_Price VALUES ('CA0005', 500, '01-AUG-2022');


INSERT INTO Bolt VALUES ('CA0001', 'BO0001', 10);
INSERT INTO Bolt VALUES ('CA0001', 'BO0002', 15);
INSERT INTO Bolt VALUES ('CA0002', 'BO0001', 10);
INSERT INTO Bolt VALUES ('CA0003', 'BO0001', 10);
INSERT INTO Bolt VALUES ('CA0003', 'BO0002', 15);
INSERT INTO Bolt VALUES ('CA0003', 'BO0003', 20);
INSERT INTO Bolt VALUES ('CA0004', 'BO0001', 15);
INSERT INTO Bolt VALUES ('CA0005', 'BO0001', 10);
INSERT INTO Bolt VALUES ('CA0005', 'BO0002', 20);

INSERT INTO Customer VALUES ('CU0001', 'Josephine', 'Darakjy', '4 B Blue Ridge Blvd', 0, 'EM020001');
INSERT INTO Customer VALUES ('CU0002', 'Art', 'Venere', '8 W Cerritos Ave', 0, 'EM020002');
INSERT INTO Customer VALUES ('CU0003', 'Lenna', 'Paprocki', '25 E 75th St', 0, 'EM020002');
INSERT INTO Customer VALUES ('CU0004', 'Paprocki', 'Foller', '34 Center St', 0, 'EM020003');

-- Customer CU0001 order Bolt<CA0001,BO0001> + Bolt<CA0003, BO0002> = 10*550 + 15*650 = 15250. Full paid one time
INSERT INTO Order_TB VALUES ('OR0001', 15250, '12-JULY-2021 09:13', 'EM030001', 'CU0001', 'new');
INSERT INTO Contains VALUES ('CA0001', 'BO0001', 'OR0001');
INSERT INTO Contains VALUES ('CA0003', 'BO0002', 'OR0001');
INSERT INTO Payment_History VALUES ('OR0001', 15250, '12-JULY-2021');
INSERT INTO Partial_Payments VALUES('CU0001', 15250, '12-JULY-2021');

-- Customer CU0002 order Bolt<CA0004,BO0001> = 15*500 = 7500. partial paid two time: 2000 and 3000. still owes money
INSERT INTO Order_TB VALUES ('OR0002', 7500, '10-DEC-2021 8:45', 'EM030002', 'CU0002', 'new');
INSERT INTO Contains VALUES ('CA0004', 'BO0001', 'OR0002');
INSERT INTO Payment_History VALUES ('OR0002', 2000, '10-DEC-2021');
INSERT INTO Payment_History VALUES ('OR0002', 3000, '25-JAN-2022');
INSERT INTO Partial_Payments VALUES('CU0002', 2000, '10-DEC-2021');
INSERT INTO Partial_Payments VALUES('CU0002', 3000, '25-JAN-2022');

-- Customer CU0003 order Bolt<CA0002,BO0001> + Bolt<CA0003,BO0001> = 10*900 + 10*650 = 15500. cancelled
INSERT INTO Order_TB VALUES ('OR0003', 15500, '20-MAR-2022 9:24', 'EM030003', 'CU0003', 'new');
INSERT INTO Contains VALUES ('CA0002', 'BO0001', 'OR0003');
INSERT INTO Contains VALUES ('CA0003', 'BO0001', 'OR0003');
INSERT INTO Cancel_Order VALUES ('CU0003', 'OR0003', 'EM030003', 'did not want to buy anymore');

-- Customer CU0004 order Bolt<CA0005,BO0001>= 10*500 = 5000. New order
INSERT INTO Order_TB VALUES ('OR0004', 5000, '01-NOV-2022 10:00', 'EM030001', 'CU0004', 'new');
INSERT INTO Contains VALUES ('CA0005', 'BO0001', 'OR0004');



INSERT INTO Customer VALUES ('CU0005', 'Cristiano', 'Ronaldo',  '828 Magnis Ave',   0, 'EM020001');
INSERT INTO Customer VALUES ('CU0006', 'Lionel',    'Messi',    '238 Nulla Av.',    0, 'EM020001');

INSERT INTO Supplier VALUES ('SU0006', 'Silk Agency',   '268 Ly Thuong Kiet, HCM, VN',  '010 1234 123456',  '987 654 321',  'EM040002');

-- * Add more category for exercise d
INSERT INTO Category VALUES ('CA0006', 'Khaki',     'Brown',        345,    'SU0001', '19-NOV-2022', 400,    850);
INSERT INTO Category VALUES ('CA0007', 'Faux silk', 'Orange',       352,    'SU0001', '03-MAY-2022', 450,    1200);
INSERT INTO Category VALUES ('CA0008', 'Crewel',    'Sky Blue',     451,    'SU0001', '04-NOV-2018', 1500,   1500);
INSERT INTO Category VALUES ('CA0009', 'Crewel',    'Light Green',  273,    'SU0002', '31-DEC-2019', 550,    800);
INSERT INTO Category VALUES ('CA0010', 'Jacquard',  'Black',        398,    'SU0002', '17-NOV-2021', 600,    600);
INSERT INTO Category VALUES ('CA0011', 'Khaki',     'Beige',        514,    'SU0003', '01-JAN-2022', 650,    750);
INSERT INTO Category VALUES ('CA0012', 'Khaki',     'Olive',        154,    'SU0006', '01-DEC-2017', 500,    350);
INSERT INTO Category VALUES ('CA0013', 'Silk',      'Pink',         114,    'SU0006', '01-JUN-2022', 700,    1000);


INSERT INTO Current_Price VALUES ('CA0006', 1000,   '19-NOV-2022');
INSERT INTO Current_Price VALUES ('CA0007', 1400,   '01-JUN-2022');
INSERT INTO Current_Price VALUES ('CA0008', 1700,   '15-NOV-2018');
INSERT INTO Current_Price VALUES ('CA0009', 900,    '10-JAN-2020');
INSERT INTO Current_Price VALUES ('CA0010', 750,    '01-DEC-2021');
INSERT INTO Current_Price VALUES ('CA0011', 850,    '01-FEB-2022');
INSERT INTO Current_Price VALUES ('CA0012', 500,    '05-DEC-2017');
INSERT INTO Current_Price VALUES ('CA0013', 1100,   '01-JUN-2022');



INSERT INTO Bolt VALUES ('CA0006', 'BO0001', 30);
INSERT INTO Bolt VALUES ('CA0007', 'BO0001', 17.5);
INSERT INTO Bolt VALUES ('CA0008', 'BO0001', 22.5);
INSERT INTO Bolt VALUES ('CA0009', 'BO0001', 25);
INSERT INTO Bolt VALUES ('CA0010', 'BO0001', 27);
INSERT INTO Bolt VALUES ('CA0011', 'BO0001', 35);
INSERT INTO Bolt VALUES ('CA0012', 'BO0001', 12.5);
INSERT INTO Bolt VALUES ('CA0012', 'BO0002', 15);
INSERT INTO Bolt VALUES ('CA0013', 'BO0001', 20);


-- * Customer Phone Numbers
INSERT INTO Cus_Phone_Numbers VALUES ('CU0001', '+44 365 842 888');
INSERT INTO Cus_Phone_Numbers VALUES ('CU0002', '0800 681 0343');
INSERT INTO Cus_Phone_Numbers VALUES ('CU0002', '026 6376 7471');
INSERT INTO Cus_Phone_Numbers VALUES ('CU0003', '04 78 25 94 16');
INSERT INTO Cus_Phone_Numbers VALUES ('CU0004', '087 752 3587');

-- Customer CU0005 order Bolt<CA0012,B00001> + <CA0008, BO0001> = 20*500 + 5*1700 = 18500. New order
INSERT INTO Order_TB VALUES ('OR0005', 18500, '19-NOV-2022 08:00:00 PM', 'EM030003', 'CU0005', 'new');
INSERT INTO Contains VALUES ('CA0012', 'BO0001', 'OR0005');
INSERT INTO Contains VALUES ('CA0008', 'BO0001', 'OR0005');

-- Customer CU0006 order Bolt<CA0013,BO0001> = 7*1100 = 7700. Full paid one time
INSERT INTO Order_TB VALUES ('OR0006', 7700, '23-DEC-2022 09:13', 'EM030001', 'CU0006', 'new');
INSERT INTO Contains VALUES ('CA0013', 'BO0001', 'OR0006');
INSERT INTO Payment_History VALUES ('OR0006', 7700, '23-DEC-2022');
INSERT INTO Partial_Payments VALUES('CU0006', 7700, '23-DEC-2022');


-- Create views for application
create or replace view order_contains as
select order_tb.datetime, order_tb.order_status, order_tb.cus_code, contains.* from order_tb inner join contains on order_tb.o_code = contains.o_code;

create or replace view newest_price as
WITH cte AS (
    SELECT current_price.*, ROW_NUMBER() OVER (PARTITION BY c_code ORDER BY set_date DESC) rn
    FROM current_price
)
SELECT *
FROM cte
WHERE rn = 1;

select * from newest_price;
create or replace view testing 
as select CATEGORY.c_code from CATEGORY where S_CODE = 'SU0001';

create or replace view order_contains_price as
select order_contains.*, newest_price.price from order_contains inner join newest_price on order_contains.c_code = newest_price.c_code order by cus_code;

create or replace view order_contains_total_price as
select order_contains_price.*, bolt.length, (bolt.length * order_contains_price. price) total_price from order_contains_price inner join bolt
on order_contains_price.b_code = bolt.b_code and order_contains_price.c_code = bolt.c_code;

create or replace view cus_order as
select order_contains_total_price.*, customer.fname, customer.lname 
from order_contains_total_price inner join customer on order_contains_total_price.cus_code = customer.code;

create or replace view ret as
select to_char(datetime, 'dd-mm-yyyy' ) datepart, to_char(datetime, 'HH24:MI:SS' ) timepart, cus_order.* from cus_order;

create or replace view final_ret as
select ret.*, cancel_order.reason from ret left join cancel_order on ret.o_code = cancel_order.o_code;
