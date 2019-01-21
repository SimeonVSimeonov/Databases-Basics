--Task 01
SELECT FirstName,LastName 
FROM Employees
WHERE FirstName LIKE 'SA%'

--Task 02
SELECT FirstName,LastName
FROM Employees
WHERE LastName LIKE '%EI%'

--Task 03
SELECT FirstName
FROM Employees
WHERE DepartmentID IN (3,10)
AND DATEPART(YEAR,HireDate) BETWEEN 1995 AND 2005

--Task 04
SELECT FirstName,LastName
FROM Employees
WHERE JobTitle NOT LIKE('%engineer%')

--Task 05
SELECT Name 
FROM Towns
WHERE LEN(NAME) BETWEEN 5 AND 6  
ORDER BY Name

--Task 06
SELECT *
FROM Towns
WHERE Name LIKE 'M%'
OR Name LIKE 'K%'
OR Name LIKE 'B%'
OR Name LIKE 'E%'
ORDER BY Name

--Task 07
SELECT *
FROM Towns
WHERE Name NOT LIKE 'R%'
AND Name NOT LIKE 'B%'
AND Name NOT LIKE 'D%'
ORDER BY Name

--Task 08
CREATE VIEW V_EmployeesHiredAfter2000 
AS 
SELECT FirstName,LastName 
FROM Employees
WHERE DATEPART(YEAR,HireDate) > 2000

--Task 09
SELECT FirstName,LastName
FROM Employees
WHERE LEN(LastName) = 5

--Task 10
SELECT EmployeeID,FirstName,LastName,Salary,
	DENSE_RANK()OVER(PARTITION BY Salary  ORDER BY EmployeeID ) AS Rank
FROM Employees AS R
WHERE Salary BETWEEN 10000 AND 50000
ORDER BY Salary DESC

--Task 11
SELECT * 
FROM(
SELECT  EmployeeID,FirstName,LastName,Salary,
DENSE_RANK()OVER (PARTITION BY Salary  ORDER BY EmployeeID ) AS 
Rank FROM Employees AS R
) Employees
WHERE Rank = 2 AND Salary BETWEEN 10000 AND 50000
ORDER BY Salary DESC

--Task 12
SELECT CountryName,IsoCode
FROM Countries
WHERE CountryName LIKE '%A%A%A%'
ORDER BY IsoCode

--Task 13
SELECT PeakName, RiverName,
LOWER(PeakName + SUBSTRING(RiverName,2, LEN(RiverName)-1)) AS [MIX]
FROM Peaks
JOIN Rivers ON RIGHT(PeakName,1) = LEFT(RiverName,1)
ORDER BY MIX

--Task 14
SELECT TOP(50) [Name],FORMAT(Start,' yyyy-MM-dd') AS [Start]
FROM Games
WHERE  DATEPART(YEAR,Start) IN (2011,2012)
ORDER BY [Start],[Name]

--Task 15
SELECT Username,RIGHT(Email, LEN(Email) - CHARINDEX('@', Email, 1)) AS [Email Provider]
FROM Users
ORDER BY [Email Provider],Username

--Task 16
SELECT Username,IpAddress AS [IP Address]
FROM Users
WHERE IpAddress LIKE '___.1%.%.___'
ORDER BY Username

--Task 17
SELECT [Name] AS [Game],
CASE 
		WHEN DATEPART(HOUR,Start) < 12
				THEN 'Morning'
		WHEN DATEPART(HOUR, Start) < 18 
				THEN 'Afternoon'
		ELSE 'Evening'
END AS [Part Of The Day],
CASE
	WHEN Duration <= 3 
		THEN 'Extra Short'
	WHEN Duration <= 6 
		THEN 'Short'
	WHEN Duration > 6 
		THEN 'Long'
	WHEN Duration IS NULL 
		THEN 'Extra Long'
END AS Duration
FROM Games
ORDER BY [Name], Duration, [Part Of The Day]

--Task 18
SELECT ProductName,OrderDate,
DATEADD(DAY, 3, OrderDate) AS [Pay Due],
DATEADD(MONTH, 1, OrderDate) AS [Deliver Due]
FROM Orders 

