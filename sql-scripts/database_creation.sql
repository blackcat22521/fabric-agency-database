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