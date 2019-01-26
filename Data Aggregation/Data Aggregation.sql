
--Task 01
SELECT COUNT(*) AS [Count]
FROM WizzardDeposits

--Task 02
SELECT	MAX(MagicWandSize) AS LongestMagicWand
FROM WizzardDeposits

--Task 03
SELECT DepositGroup,MAX(MagicWandSize) AS LongestMagicWand
FROM WizzardDeposits
GROUP BY DepositGroup

--Task 04
SELECT TOP(2) DepositGroup
FROM WizzardDeposits
GROUP BY DepositGroup
ORDER BY AVG(MagicWandSize)

--Task 05
SELECT DepositGroup, SUM(DepositAmount)
FROM WizzardDeposits
GROUP BY DepositGroup

--Task 06
SELECT DepositGroup,SUM(DepositAmount) AS TotalSum
FROM WizzardDeposits
WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup

--Task 07
SELECT DepositGroup,SUM(DepositAmount) AS TotalSum
FROM WizzardDeposits
WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup
HAVING SUM(DepositAmount) < 150000
ORDER BY TotalSum DESC

--Task 08
SELECT DepositGroup,MagicWandCreator,MIN(DepositCharge) AS MinDepositCharge 
FROM WizzardDeposits
GROUP BY DepositGroup,MagicWandCreator
ORDER BY  MagicWandCreator,DepositGroup

--Task 09
SELECT AG.AgeGroup, COUNT(AG.AgeGroup) AS [Count]
FROM(
SELECT 
	CASE
	WHEN Age BETWEEN  0 AND 10 THEN '[0-10]'
	WHEN Age BETWEEN  11 AND 20 THEN '[11-20]'
	WHEN Age BETWEEN  21 AND 30 THEN '[21-30]'
	WHEN Age BETWEEN  31 AND 40 THEN '[31-40]'
	WHEN Age BETWEEN  41 AND 50 THEN '[41-50]'
	WHEN Age BETWEEN  51 AND 60 THEN '[51-60]'
	ELSE '[61+]'
	END AS AgeGroup
FROM WizzardDeposits)
AS AG
GROUP BY AG.AgeGroup

--Task 10
SELECT LEFT(FirstName, 1)
FROM WizzardDeposits
WHERE DepositGroup = 'Troll Chest'
GROUP BY LEFT(FirstName, 1)

--Task 11
SELECT DepositGroup,IsDepositExpired,AVG(DepositInterest) AS [AverageInterest] 
FROM WizzardDeposits
WHERE DATEPART(YEAR,DepositStartDate) >= 1985
GROUP BY DepositGroup,IsDepositExpired
ORDER BY DepositGroup DESC,IsDepositExpired ASC

--Task 12
SELECT SUM(D.Diff) AS SumDifference
FROM(
SELECT DepositAmount - LEAD(DepositAmount) OVER(ORDER BY Id) AS Diff
FROM WizzardDeposits) AS D

--Task 13
SELECT DepartmentID, SUM(Salary) AS TotalSalary
FROM Employees
GROUP BY DepartmentID
ORDER BY DepartmentID

--Task 14
SELECT DepartmentID,MIN(Salary) AS MinimumSalary
FROM Employees
WHERE HireDate > '01/01/2000' AND DepartmentID IN(2,5,7)
GROUP BY DepartmentID

--Task 15
SELECT * INTO EmployeesBigSalary
FROM Employees
WHERE Salary > 30000

DELETE FROM EmployeesBigSalary
WHERE ManagerID = 42

UPDATE EmployeesBigSalary
SET Salary += 5000
WHERE DepartmentID = 1

SELECT DepartmentID, AVG(Salary)
FROM EmployeesBigSalary
GROUP BY DepartmentID

--Task 16
SELECT DepartmentID, MAX(Salary) AS MaxSalary
FROM Employees
GROUP BY DepartmentID
HAVING MAX(Salary) NOT BETWEEN 30000 AND 70000

--Task 17
SELECT COUNT(*) AS [Count]
FROM Employees
WHERE ManagerID IS NULL

--Task 18
SELECT DISTINCT R.DepartmentID, R.Salary
FROM(
SELECT DepartmentID, Salary, DENSE_RANK() OVER (PARTITION BY DepartmentID ORDER BY Salary DESC) AS SalaryRank
FROM Employees) AS R
WHERE R.SalaryRank = 3

--Task 19
SELECT TOP(10) FirstName, LastName, DepartmentID
FROM Employees AS E
WHERE Salary > (SELECT  AVG(Salary) FROM Employees AS ES WHERE ES.DepartmentID = E.DepartmentID)
ORDER BY DepartmentID

