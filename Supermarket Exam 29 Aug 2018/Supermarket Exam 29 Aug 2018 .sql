
-- 01. DDL 

CREATE TABLE Categories (
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30) NOT NULL 
)

CREATE TABLE Items (
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30) NOT NULL,
	Price DECIMAL (15,2) NOT NULL,
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL
)

CREATE TABLE Employees (
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Phone CHAR(12) NOT NULL,
	Salary DECIMAL (15,2) NOT NULL
)

CREATE TABLE Orders (
	Id INT PRIMARY KEY IDENTITY,
	[DateTime] DATETIME NOT NULL,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL,
)

CREATE TABLE OrderItems (
	OrderId INT FOREIGN KEY REFERENCES Orders(Id) NOT NULL,
	ItemId INT FOREIGN KEY REFERENCES Items(Id) NOT NULL,
	Quantity INT NOT NULL CHECK(Quantity >= 1),

	CONSTRAINT PK_OrderItems PRIMARY KEY (OrderId, ItemId)
)

CREATE TABLE Shifts(
	Id INT IDENTITY,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id),
	CheckIn DATETIME NOT NULL,
	CheckOut DATETIME NOT NULL,

	CONSTRAINT PK_Shifts PRIMARY KEY (Id, EmployeeId),
	CONSTRAINT CHK_ValidateCheckOut CHECK(CheckIn < CheckOut)
)

-- 02. Insert 

INSERT INTO Employees
VALUES 
	 ('Stoyan',	'Petrov',	'888-785-8573',	500.25),
	 ('Stamat',	'Nikolov',	'789-613-1122',	999995.25),
	 ('Evgeni',	'Petkov',	'645-369-9517',	1234.51),
	 ('Krasimir',	'Vidolov',	'321-471-9982',	50.25)

INSERT INTO Items--(Name, Price, CategoryId)
VALUES 
	 ('Tesla battery',154.25	,8),
	 ('Chess',	30.25,	8),
	 ('Juice',	5.32,1),
	 ('Glasses',10,	8),
	 ('Bottle of water',	1,	1)

-- 03. Update 

UPDATE Items
SET Price *= 1.27
WHERE CategoryId IN (1,2,3)

-- 04. Delete 

DELETE FROM OrderItems
WHERE OrderId = 48

-- 05. Richest People 

SELECT Id, FirstName
FROM Employees
WHERE Salary > 6500
ORDER BY FirstName, Id

-- 06. Cool Phone Numbers 

SELECT FirstName + ' ' + LastName AS [Full Name], Phone AS [Phone Number]
FROM Employees
WHERE Phone LIKE '3%'
ORDER BY FirstName, Phone DESC

-- 07. Employee Statistics 

SELECT E.FirstName, E.LastName, COUNT(O.Id) AS [Count]
FROM Employees AS E
JOIN Orders AS O ON O.EmployeeId = E.Id
GROUP BY  E.FirstName, E.LastName
ORDER BY [Count] DESC, FirstName

-- 08. Hard Workers Club 

SELECT E.FirstName, E.LastName, AVG(DATEDIFF(HOUR,CheckIn,CheckOut)) AS [Work hours]
FROM Employees AS E
JOIN Shifts AS SH ON SH.EmployeeId = E.Id
GROUP BY E.FirstName, E.LastName, E.Id
HAVING AVG(DATEDIFF(HOUR,CheckIn,CheckOut)) > 7
ORDER BY [Work hours] DESC, E.Id

-- 09. The Most Expensive Order 

SELECT TOP(1) OT.OrderId, SUM(OT.Quantity * IT.Price) AS [TotalPrice]
FROM OrderItems AS OT
JOIN Items AS IT ON IT.Id = OT.ItemId
GROUP BY OT.OrderId
ORDER BY TotalPrice DESC

-- 10. Rich Item, Poor Item 

SELECT TOP(10) OrderId, MAX(I.Price) AS ExpensivePrice, MIN(I.Price) AS CheapPrice
FROM OrderItems AS OI
JOIN Items AS I ON I.Id = OI.ItemId
GROUP BY OrderId
ORDER BY ExpensivePrice DESC, OrderId

-- 11. Cashiers 

SELECT E.Id, E.FirstName, E.LastName
FROM Employees AS E
JOIN Orders AS O ON O.EmployeeId = E.Id
GROUP BY E.Id, E.FirstName, E.LastName
ORDER BY E.Id

-- 12. Lazy Employees 

SELECT E.Id, E.FirstName + ' ' + E.LastName AS [Full Name]
FROM Employees AS E
JOIN Shifts AS S ON S.EmployeeId = E.Id
WHERE DATEDIFF(HOUR, CheckIn, CheckOut) < 4
GROUP BY E.Id, E.FirstName, E.LastName
ORDER BY E.Id

-- 13. Sellers 

SELECT E.FirstName + ' ' + E.LastName AS [Full Name],
		SUM(I.Price * OI.Quantity) AS [Total Price],
		SUM(OI.Quantity) AS [Items]
FROM Employees AS E 
JOIN Orders AS O ON O.EmployeeId = E.Id
JOIN OrderItems AS OI ON OI.OrderId = O.Id
JOIN Items AS I ON I.Id = OI.ItemId
WHERE O.DateTime < '2018-06-15'
GROUP BY E.FirstName, E.LastName
ORDER BY [Total Price] DESC, Items DESC

-- 14. Tough Days

SELECT E.FirstName + ' ' + E.LastName AS [Full Name], DATENAME(dw,S.CheckIn) AS [Day of week]
FROM Employees AS E
LEFT JOIN Orders AS O ON O.EmployeeId = E.Id
JOIN Shifts AS S ON S.EmployeeId = E.Id
WHERE O.Id IS NULL AND DATEDIFF(HOUR,CheckIn,CheckOut) > 12
ORDER BY E.Id

-- 15. Top Order per Employee
SELECT E.FirstName + ' ' + E.LastName AS [Full Name], DATEDIFF(HOUR,CheckIn,CheckOut) AS WorkHours, TEMP.TotalPrice AS TotalPrice
FROM
	(SELECT ORDERS.EmployeeId, SUM(ORDERITEMS.Quantity * ITEMS.Price) AS TotalPrice, ORDERS.DateTime,
	DENSE_RANK() OVER (PARTITION BY ORDERS.EmployeeId ORDER BY ORDERS.EmployeeId, SUM(ORDERITEMS.Quantity * ITEMS.Price) DESC) AS [RANK]
	FROM Orders AS [ORDERS]
	JOIN OrderItems AS ORDERITEMS ON ORDERITEMS.OrderId = ORDERS.Id
	JOIN Items AS ITEMS ON ITEMS.Id = ORDERITEMS.ItemId
	GROUP BY ORDERS.EmployeeId, ORDERS.DateTime, ORDERS.Id) AS TEMP
JOIN Employees AS E ON E.Id = TEMP.EmployeeId
JOIN Shifts AS S ON S.EmployeeId = TEMP.EmployeeId
WHERE TEMP.RANK = 1 AND TEMP.DateTime BETWEEN S.CheckIn AND S.CheckOut
ORDER BY [Full Name],WorkHours DESC, TotalPrice DESC

-- 16. Average Profit per Day 

SELECT DATEPART(DAY,O.DateTime) AS [DayOfMonth],
		CAST(AVG(I.Price * OI.Quantity) AS decimal(15,2))AS [TotalPrice]
FROM Orders AS O
JOIN OrderItems AS OI ON OI.OrderId = O.Id
JOIN Items AS I ON I.Id = OI.ItemId
GROUP BY DATEPART(DAY,O.DateTime)
ORDER BY DayOfMonth ASC

-- 17. Top Products

SELECT I.Name AS Item, C.Name AS Category, SUM(OI.Quantity) AS [Count], (I.Price * SUM(OI.Quantity)) AS TotalPrice
FROM OrderItems AS OI
RIGHT JOIN Items AS I ON I.Id = OI.ItemId
JOIN Categories AS C ON C.Id = I.CategoryId
GROUP BY I.Name, C.Name,I.Price
ORDER BY TotalPrice DESC, [Count] DESC	

-- 18. Promotion Days 

CREATE FUNCTION udf_GetPromotedProducts(@CurrentDate DATETIME, @StartDate DATETIME, @EndDate DATETIME, @Discount INT, @FirstItemId INT, @SecondItemId INT, @ThirdItemId INT)
RETURNS VARCHAR(80)
AS
BEGIN
	DECLARE @FirstItemPrice DECIMAL(15,2) = (SELECT Price FROM Items WHERE Id = @FirstItemId)
	DECLARE @SecondItemPrice DECIMAL(15,2) = (SELECT Price FROM Items WHERE Id = @SecondItemId)
	DECLARE @ThirdItemPrice DECIMAL(15,2) = (SELECT Price FROM Items WHERE Id = @ThirdItemId)

	IF (@FirstItemPrice IS NULL OR @SecondItemPrice IS NULL OR @ThirdItemPrice IS NULL)
	BEGIN
	 RETURN 'One of the items does not exists!'
	END

	IF (@CurrentDate <= @StartDate OR @CurrentDate >= @EndDate)
	BEGIN
	 RETURN 'The current date is not within the promotion dates!'
	END

	DECLARE @NewFirstItemPrice DECIMAL(15,2) = @FirstItemPrice - (@FirstItemPrice * @Discount / 100)
	DECLARE @NewSecondItemPrice DECIMAL(15,2) = @SecondItemPrice - (@SecondItemPrice * @Discount / 100)
	DECLARE @NewThirdItemPrice DECIMAL(15,2) = @ThirdItemPrice - (@ThirdItemPrice * @Discount / 100)

	DECLARE @FirstItemName VARCHAR(50) = (SELECT [Name] FROM Items WHERE Id = @FirstItemId)
	DECLARE @SecondItemName VARCHAR(50) = (SELECT [Name] FROM Items WHERE Id = @SecondItemId)
	DECLARE @ThirdItemName VARCHAR(50) = (SELECT [Name] FROM Items WHERE Id = @ThirdItemId)

	RETURN @FirstItemName + ' price: ' + CAST(ROUND(@NewFirstItemPrice,2) as varchar) + ' <-> ' +
		   @SecondItemName + ' price: ' + CAST(ROUND(@NewSecondItemPrice,2) as varchar)+ ' <-> ' +
		   @ThirdItemName + ' price: ' + CAST(ROUND(@NewThirdItemPrice,2) as varchar)
END

-- TEST
SELECT dbo.udf_GetPromotedProducts('2018-08-02', '2018-08-01', '2018-08-03',13, 3,4,5)

SELECT dbo.udf_GetPromotedProducts('2018-08-01', '2018-08-02', '2018-08-03',13,3 ,4,5)

-- 19. Cancel Order 

CREATE PROCEDURE usp_CancelOrder(@OrderId INT, @CancelDate DATETIME)
AS
BEGIN
	DECLARE @order INT = (SELECT Id FROM Orders WHERE Id = @OrderId)

	IF (@order IS NULL)
	BEGIN
		;THROW 51000, 'The order does not exist!', 1
	END

	DECLARE @OrderDate DATETIME = (SELECT [DateTime] FROM Orders WHERE Id = @OrderId)
	DECLARE @DateDiff INT = (SELECT DATEDIFF(DAY, @OrderDate, @CancelDate))

	IF (@DateDiff > 3)
	BEGIN
		;THROW 51000, 'You cannot cancel the order!', 2
	END

	DELETE FROM OrderItems
	WHERE OrderId = @OrderId

	DELETE FROM Orders
	WHERE Id = @OrderId
END

-- TEST
EXEC usp_CancelOrder 1, '2018-06-02' 
SELECT COUNT(*) FROM Orders 
SELECT COUNT(*) FROM OrderItems

EXEC usp_CancelOrder 1, '2018-06-15'

EXEC usp_CancelOrder 124231, '2018-06-15'

-- 20. Deleted Orders 

CREATE TABLE DeletedOrders
(
	OrderId INT,
	ItemId INT,
	ItemQuantity INT,
)

GO

CREATE TRIGGER t_DeleteOrders
	ON OrderItems
	AFTER DELETE
AS
	BEGIN 
		INSERT INTO DeletedOrders(OrderId, ItemId, ItemQuantity)
		SELECT D.OrderId, D.ItemId, D.Quantity
		 FROM deleted AS D
END
-- TEST
DELETE FROM OrderItems 
WHERE OrderId = 5 
DELETE FROM Orders 
WHERE Id = 5 