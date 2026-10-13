CREATE DATABASE NICHE7;
USE NICHE7;

CREATE TABLE Customer (
    Customer_ID INT PRIMARY KEY,
    Customer_Name VARCHAR(50) NOT NULL,
    Phone VARCHAR(15),
    Email VARCHAR(100) UNIQUE
);

CREATE TABLE Product (
    Product_ID INT PRIMARY KEY,
    Product_Name VARCHAR(50) NOT NULL,
    Price DECIMAL(10,2) NOT NULL CHECK (Price >= 0),
    Stock INT NOT NULL CHECK (Stock >= 0)
);

CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY,
    Customer_ID INT NOT NULL,
    Order_Date DATE NOT NULL,
    Total_Amount DECIMAL(10,2) NOT NULL ,
    Order_Status VARCHAR(20) DEFAULT 'Pending'
        CHECK (Order_Status IN ('Pending', 'Shipped', 'Delivered', 'Cancelled')),
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID)
);

CREATE TABLE Order_Details (
    Order_Detail_ID INT PRIMARY KEY,
    Order_ID INT NOT NULL,
    Product_ID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    Price DECIMAL(10,2) NOT NULL CHECK (Price >= 0),
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID) ON DELETE CASCADE,
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID)
);

INSERT INTO Customer VALUES
(101, 'Rahul', '9876543210', 'rahul@gmail.com'),
(102, 'Priya', '9876543211', 'priya@gmail.com'),
(103, 'Arun', '9876543212', 'arun@gmail.com');

INSERT INTO Product VALUES
(201, 'Laptop', 50000, 10),
(202, 'Mouse', 500, 50),
(203, 'Mobile', 20000, 20),
(204, 'Keyboard', 1000, 30);

INSERT INTO Orders
(Order_ID, Customer_ID, Order_Date, Total_Amount, Order_Status)
VALUES
(5001, 101, '2026-10-01', 51000, 'Pending'),
(5002, 102, '2026-10-02', 20000, 'Shipped'),
(5003, 101, '2026-10-03', 2000, 'Delivered');

INSERT INTO Order_Details VALUES
(1, 5001, 201, 1, 50000),
(2, 5001, 202, 2, 500),
(3, 5002, 203, 1, 20000),
(4, 5003, 204, 2, 1000);

UPDATE Orders
SET Total_Amount = (
    SELECT SUM(Quantity * Price)
    FROM Order_Details
    WHERE Order_ID = 5001
)
WHERE Order_ID = 5001;

UPDATE Orders
SET Order_Status = 'Delivered'
WHERE Order_ID = 5001;

UPDATE Order_Details
SET Quantity = 3
WHERE Order_Detail_ID = 2;

UPDATE Orders
SET Total_Amount = (
    SELECT SUM(Quantity * Price)
    FROM Order_Details
    WHERE Order_ID = 5001
)
WHERE Order_ID = 5001;

INSERT INTO Orders
(Order_ID, Customer_ID, Order_Date, Total_Amount, Order_Status)
VALUES
(5004, 103, CURDATE(), 20000, 'Pending');

INSERT INTO Order_Details VALUES
(5, 5004, 203, 1, 20000);

UPDATE Orders
SET Total_Amount = (
    SELECT SUM(Quantity * Price)
    FROM Order_Details
    WHERE Order_ID = 5004
)
WHERE Order_ID = 5004;

DELETE FROM Orders
WHERE Order_ID = 5004
AND Order_Status = 'Cancelled';

SELECT
    C.Customer_Name,
    O.Order_ID,
    O.Order_Date,
    O.Total_Amount,
    O.Order_Status
FROM Customer C
JOIN Orders O
ON C.Customer_ID = O.Customer_ID
ORDER BY O.Order_Date;

SELECT
    P.Product_Name,
    COUNT(DISTINCT OD.Order_ID) AS Times_Ordered,
    SUM(OD.Quantity) AS Total_Quantity_Sold
FROM Product P
LEFT JOIN Order_Details OD
ON P.Product_ID = OD.Product_ID
GROUP BY P.Product_ID, P.Product_Name;

SELECT SUM(Total_Amount) AS Total_Sales
FROM Orders
WHERE Order_Status <> 'Cancelled';

SELECT
    C.Customer_Name,
    COUNT(O.Order_ID) AS Total_Orders
FROM Customer C
LEFT JOIN Orders O
ON C.Customer_ID = O.Customer_ID
AND O.Order_Status <> 'Cancelled'
GROUP BY C.Customer_ID, C.Customer_Name
ORDER BY Total_Orders DESC;

SELECT
    C.Customer_Name,
    COALESCE(SUM(
        CASE
            WHEN O.Order_Status <> 'Cancelled'
            THEN O.Total_Amount
            ELSE 0
        END
    ), 0) AS Total_Spending
FROM Customer C
LEFT JOIN Orders O
ON C.Customer_ID = O.Customer_ID
GROUP BY C.Customer_ID, C.Customer_Name;

SELECT
    C.Customer_Name,
    AVG(O.Total_Amount) AS Average_Order_Value
FROM Customer C
JOIN Orders O
ON C.Customer_ID = O.Customer_ID
WHERE O.Order_Status <> 'Cancelled'
GROUP BY C.Customer_ID, C.Customer_Name;

SELECT
    O.Order_ID,
    C.Customer_Name,
    O.Order_Date,
    P.Product_Name,
    OD.Quantity,
    OD.Price,
    OD.Quantity * OD.Price AS Subtotal,
    O.Total_Amount,
    O.Order_Status
FROM Orders O
JOIN Customer C
ON O.Customer_ID = C.Customer_ID
JOIN Order_Details OD
ON O.Order_ID = OD.Order_ID
JOIN Product P
ON OD.Product_ID = P.Product_ID
ORDER BY O.Order_ID;

SELECT
    Order_ID,
    Customer_ID,
    Order_Date,
    Total_Amount,
    Order_Status
FROM Orders
WHERE Order_Status = 'Pending';