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
SELECT *
FROM Employees

--Task 11


--Task 12



--Task 13

