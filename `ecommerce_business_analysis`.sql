USE ecommerce_business_analysis;

SET SQL_SAFE_UPDATES = 0;

UPDATE Orders
SET OrderDate = DATE_FORMAT(
    STR_TO_DATE(OrderDate, '%d-%m-%Y %H:%i'),
    '%Y-%m-%d %H:%i:%s'
);

ALTER TABLE Orders
MODIFY COLUMN OrderDate DATE;

SET SQL_SAFE_UPDATES = 1;

DESC  Orders; 

# KPI 1 ...Retrieve all orders for a specific customer ?

SELECT o.OrderID, o.OrderDate, o.TotalAmount, p.ProductName, oi.Quantity, oi.UnitPrice
FROM Orders o 
JOIN OrderItems oi ON o.OrderID = oi.OrderID
JOIN Products p ON oi.ProductID = p.ProductID 
WHERE o.CustomerID = 2373;

#KPI 2 ... Find the Total sales for each product ?
 
SELECT p.ProductID, p.ProductName, ROUND(SUM(oi.SalesAmount), 2) AS TotalSales
FROM Products p 
JOIN OrderItems oi ON p.ProductID = oi.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY TotalSales DESC;



#  Top 10 Products By Sales
  
SELECT p.ProductID, p.ProductName, ROUND(SUM(oi.SalesAmount), 2) AS TotalSales
FROM Products p 
JOIN OrderItems oi ON p.ProductID = oi.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY TotalSales DESC
LIMIT 10;


# KPI 3 ...Calculate the Average Order Value ?

SELECT ROUND(AVG(TotalAmount), 2) AS Average_OrderValue
FROM Orders;

# KPI 4 ... List the Top 5 customers by total spending ?

SELECT o.CustomerID, c.FirstName, SUM(o.TotalAmount) AS TotalSpent
FROM Orders o 
JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY o.CustomerID, c.FirstName
ORDER BY TotalSpent DESC 
LIMIT 5;

# KPI 5 ...Retrieve the Most popular product category ?

SELECT c.CategoryID, c.CategoryName, SUM(oi.Quantity) AS TotalQTYSold 
FROM OrderItems oi 
JOIN Categories c ON oi.CategoryID = c.CategoryID
GROUP BY c.CategoryID, c.CategoryName 
ORDER BY TotalQTYSold DESC 
LIMIT 1;

# KPI 6 ...Lists all products that are Out-of-stock ?
 
 SELECT p.ProductId, p.ProductName,c.CategoryName, p.Stock
 FROM Products p 
 JOIN Categories c ON p.CategoryID = c.CategoryID
 WHERE p.Stock = 0;
 
# KPI 7 ... Find the Customers who ordered in the last 30 days ?

SELECT o.CustomerID, c.FirstName, o.OrderID, o.OrderDate, o.TotalAmount
FROM Orders o 
JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE o.OrderDate >= DATE_SUB( CURDATE(), INTERVAL 30 DAY);

SELECT c.CustomerID, c.FirstName, c.LastName, c.Email, c.Phone
FROM Customers c 
JOIN Orders o ON c.CustomerID =o.CustomerID
WHERE o.OrderDate >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);

# Number of Customers placed order within 30 day

SELECT COUNT(CustomerID) AS CustomerCount 
FROM Orders 
WHERE OrderDate >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);

#KPI 8 ... Calculate the total Number of orders placed each month ?

SELECT YEAR(o.OrderDate) AS Year, MONTH(o.OrderDate) AS Month, ROUND(SUM(oi.Quantity), 2) AS TotalOrder
FROM Orders o 
JOIN OrderItems oi ON o.OrderID = oi.OrderID
GROUP BY Year, Month
ORDER BY Year, Month;

# Month Wise Total_Sales

SELECT MONTH(o.OrderDate) AS Month, ROUND(SUM(oi.SalesAmount), 2) AS Total_Sales
FROM Orders o 
JOIN OrderItems oi ON o.OrderID = oi.OrderID
GROUP BY MONTH(o.OrderDate)
ORDER BY MONTH(o.OrderDate);

# KPI 9 ... Retrieve the details of the most recent order ?

SELECT o.CustomerID, c.FirstName, o.OrderID, o.OrderDate, o.TotalAmount
FROM Orders o 
JOIN Customers c ON o.CustomerID = c.CustomerID
ORDER BY o.OrderDate DESC 
LIMIT 1;


# KPI 10 ...Find the Average price of Products in each category ?

SELECT c.CategoryID, c.CategoryName, ROUND(AVG(p.Price), 2) AS AveragePrice
FROM Products p 
JOIN Categories c ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryID, c.CategoryName
ORDER BY AVG(p.Price)  DESC;

# KPI 11 ...List Customers who have never placed an order ?

SELECT c.CustomerID, c.FirstName, c.Email, c.Phone, o.OrderID
FROM Customers c 
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL;

SELECT COUNT(c.CustomerID) AS NeverPlaced
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL;


# KPI 12 ...Retrieve the Total quantity sold for each product?

SELECT p.ProductID, p.ProductName, SUM(oi.Quantity) AS TotalQTYSold
FROM OrderItems oi 
JOIN Products p ON oi.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY TotalQTYSold DESC;

# TOP 10 Most sold products 

SELECT p.ProductID, p.ProductName, c.CategoryName, SUM(oi.Quantity) AS TotalQTYSold
FROM OrderItems oi 
JOIN Products p ON oi.ProductID = p.ProductID
JOIN Categories c ON p.CategoryID = c.CategoryID
GROUP BY p.ProductID, p.ProductName, c.CategoryName
ORDER BY TotalQTYSold DESC
LIMIT 10;

# KPI 13 ...Calculate the total Revenue generated from each category ?

SELECT c.CategoryID, c.CategoryName, ROUND(SUM(oi.SalesAmount), 2) AS TotalRevenue
FROM OrderItems oi 
JOIN Categories c ON oi.CategoryID = c.CategoryID
GROUP BY c.CategoryID, c.CategoryName
ORDER BY TotalRevenue DESC;

# KPI 14 ... Find the highest - priced product in each Category ?

SELECT t.ProductID, t.ProductName, t.CategoryName, t.Price 
FROM (SELECT p.ProductID, p.ProductName, c.CategoryName, p.Price,
 DENSE_RANK() OVER (PARTITION BY c.CategoryName ORDER BY p.Price DESC) AS rnk
 FROM Products p 
JOIN Categories c ON p.CategoryID = c.CategoryID ) as t
 WHERE rnk =1;

# KPI 15 ... Retrieve Orders with a total amount  greater than specific value  (e.g $5000)

SELECT *
FROM Orders 
WHERE TotalAmount > 5000;

# OR 

SELECT c.CustomerID, o.OrderID, c.FirstName, c.LastName, SUM(o.TotalAmount) AS TotalSpent
FROM Orders o 
JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerID, o.OrderID, c.FirstName, c.LastName
HAVING SUM(o.TotalAmount) > 5000
ORDER BY TotalSpent DESC;


# KPI 16 ... Lists products along with the Number of orders they appears in ? / Most Ordered Product

SELECT p.ProductID, p.ProductName, c.CategoryName, COUNT(oi.OrderID) AS OrderCount
 FROM OrderItems oi 
 JOIN Products p ON oi.ProductID = p.ProductID
 JOIN Categories c ON p.CategoryID = c.CategoryID
 GROUP BY p.ProductID, p.ProductName, c.CategoryName
 ORDER BY OrderCount DESC;
 
 # OR Top 10 Most Ordered Products or Popular Products

SELECT p.ProductID, p.ProductName, c.CategoryName, COUNT(oi.OrderID) AS OrderCount
 FROM OrderItems oi 
 JOIN Products p ON oi.ProductID = p.ProductID
 JOIN Categories c ON p.CategoryID = c.CategoryID
 GROUP BY p.ProductID, p.ProductName, c.CategoryName
 ORDER BY OrderCount DESC
 LIMIT 10 ;
 
 
 # KPI 17 ... Find the Top 3 frequently ordered products ?

SELECT p.ProductID, p.ProductName, c.CategoryName, COUNT(oi.OrderID) AS OrderCount
 FROM OrderItems oi 
 JOIN Products p ON oi.ProductID = p.ProductID
 JOIN Categories c ON p.CategoryID = c.CategoryID
 GROUP BY p.ProductID, p.ProductName, c.CategoryName
 ORDER BY OrderCount DESC
 LIMIT 3 ;


# KPI 18 ...Calculate the total Number of customers from each City ?

SELECT City, COUNT(CustomerID) AS CustomerCount
FROM Customers 
GROUP BY City;

# OR TOP 10 CITIES WITH MORE CUSTOMER

SELECT City, COUNT(CustomerID) AS CustomerCount
FROM Customers 
GROUP BY City
ORDER BY CustomerCount DESC 
LIMIT 10;

# KPI 19 ...Retrieve the list of Customer along with their total spending ?

SELECT c.CustomerID, c.FirstName, c.LastName, ROUND(SUM(o.TotalAmount), 2) AS TotalSpent
FROM Orders o 
JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName
ORDER BY TotalSpent DESC;


# KPI 20 ...List Orders with more than a specified number of items(e.g 5 Items)

SELECT o.OrderID, o.CustomerID, SUM(oi.Quantity) AS TotalItems
FROM Orders o 
JOIN OrderItems oi ON o.OrderID = oi.OrderID
GROUP BY o.OrderID, o.CustomerID
HAVING SUM(oi.Quantity) > 5
ORDER BY TotalItems DESC ;

# KPI .. Find the Top 3 products by Sales/Revenue in each Category ?  

SELECT t.ProductID, t.ProductName, t.CategoryName, t.Revenue 
FROM (SELECT p.ProductID, p.ProductName, c.CategoryName, ROUND(SUM(oi.SalesAmount), 2) AS Revenue,
 DENSE_RANK() OVER (PARTITION BY c.CategoryName ORDER BY ROUND(SUM(oi.SalesAmount), 2) DESC) AS rnk
 FROM OrderItems oi 
JOIN Products p ON oi.ProductID = p.ProductID 
JOIN Categories c ON p.CategoryID = c.CategoryID
GROUP BY p.ProductID, p.ProductName, c.CategoryName) AS t
WHERE rnk <=3;

SELECT t.*
FROM (SELECT p.ProductID, p.ProductName, c.CategoryName, ROUND(SUM(oi.SalesAmount), 2) AS Revenue,
 DENSE_RANK() OVER (PARTITION BY c.CategoryName ORDER BY ROUND(SUM(oi.SalesAmount), 2) DESC) AS rnk
 FROM OrderItems oi 
JOIN Products p ON oi.ProductID = p.ProductID 
JOIN Categories c ON p.CategoryID = c.CategoryID
GROUP BY p.ProductID, p.ProductName, c.CategoryName) AS t
WHERE rnk <=3;



