-- TASK 1

SELECT TOP(5) EmployeeID,JobTitle,A.AddressID,AddressText
FROM Employees AS E
INNER JOIN Addresses AS A
ON E.AddressID = A.AddressID
ORDER BY AddressID ASC

-- TASK 2 

SELECT TOP(50) FirstName, LastName, T.Name, A.AddressText
FROM Employees AS E
INNER JOIN Addresses AS A
ON E.AddressID = A.AddressID
INNER JOIN Towns AS T
ON T.TownID = A.TownID
ORDER BY E.FirstName, E.LastName

-- TASK 3

SELECT EmployeeID, FirstName, LastName, Name 
FROM Employees AS E
INNER JOIN Departments AS D
ON E.DepartmentID = D.DepartmentID
WHERE D.Name = 'Sales'
ORDER BY E.EmployeeID ASC 

-- TASK 4

SELECT TOP(5) EmployeeID, FirstName, Salary, D.Name 
FROM Employees AS E
INNER JOIN Departments AS D
ON E.DepartmentID = D.DepartmentID
WHERE D.Name = 'Engineering' AND E.Salary > 15000
ORDER BY D.DepartmentID ASC

-- TASK 5

SELECT TOP(3) E.EmployeeID,E.FirstName
FROM Employees AS E 
LEFT JOIN EmployeesProjects AS EP
ON E.EmployeeID = EP.EmployeeID
WHERE EP.EmployeeID IS NULL
ORDER BY E.EmployeeID


-- TASK 6

SELECT FirstName, LastName,HireDate, D.Name 
FROM Employees AS E
JOIN Departments AS D
ON E.DepartmentID = D.DepartmentID
WHERE D.Name = 'Sales' OR D.Name = 'Finance' AND HireDate > '1.1.1999'
ORDER BY HireDate ASC

-- TASK 7

SELECT TOP(5) E.EmployeeID, E.FirstName, P.[Name]
FROM Employees AS E 
INNER JOIN EmployeesProjects AS EP
ON E.EmployeeID = EP.EmployeeID
INNER JOIN Projects AS P
ON P.ProjectID = EP.ProjectID
WHERE P.StartDate > '8-13-2002' AND P.EndDate IS NULL
ORDER BY E.EmployeeID

-- TASK 8

SELECT E.EmployeeID, E.FirstName,
CASE 
	WHEN DATEPART(YEAR, P.StartDate) >= 2005 THEN NULL
	ELSE P.Name
	END AS ProjectName 
FROM Employees AS E 
INNER JOIN EmployeesProjects AS EP
ON E.EmployeeID = EP.EmployeeID AND E.EmployeeID = 24
INNER JOIN Projects AS P
ON P.ProjectID = EP.ProjectID
ORDER BY E.EmployeeID

-- TASK 9

SELECT E.EmployeeID, E.FirstName, E.ManagerID, M.FirstName AS ManagerName
FROM Employees AS E
INNER JOIN Employees AS M
ON E.ManagerID = M.EmployeeID
WHERE E.ManagerID = 3 OR E.ManagerID = 7
ORDER BY E.EmployeeID ASC

-- TASK 10

SELECT TOP(50) E.EmployeeID,
	CONCAT(E.FirstName, ' ', E.LastName) AS [EmployeeName],
	CONCAT(M.FirstName, ' ', M.LastName) AS [EmployeeName],
	D.Name AS [DepartmentName]
FROM Employees AS E
INNER JOIN Employees AS M
ON E.ManagerID = M.EmployeeID
INNER JOIN Departments AS D
ON E.DepartmentID = D.DepartmentID
ORDER BY EmployeeID

-- TASK 11

SELECT TOP(1) AVG(Salary)
FROM Employees
GROUP BY DepartmentID
ORDER BY AVG(Salary) ASC

-- TASK 12

SELECT MC.CountryCode, M.MountainRange, P.PeakName, P.Elevation 
FROM Peaks AS P
JOIN Mountains AS M
ON P.MountainId = M.Id
JOIN MountainsCountries AS MC
ON M.Id = MC.MountainId AND MC.CountryCode = 'BG'
WHERE P.Elevation > 2835
ORDER BY P.Elevation DESC

-- TASK 13

SELECT C.CountryCode, COUNT(*)
FROM Countries AS C
INNER JOIN MountainsCountries AS MC
ON MC.CountryCode = C.CountryCode
WHERE C.CountryName IN ('BULGARIA', 'Russia', 'United States')
GROUP BY C.CountryCode

-- TASK 14

SELECT TOP(5) C.CountryName, R.RiverName
FROM Rivers AS R
INNER JOIN CountriesRivers AS CR
ON CR.RiverId = R.Id
RIGHT OUTER JOIN Countries AS C
ON C.CountryCode = CR.CountryCode
WHERE C.ContinentCode = 'AF'
ORDER BY C.CountryName ASC

-- TASK 15
SELECT 
	secondQuerry.ContinentCode, 
	secondQuerry.CurrencyCode, 
	secondQuerry.UsageCounter AS [CurrencyUsage]
FROM 
	(SELECT *, 
		DENSE_RANK() OVER(PARTITION BY ContinentCode ORDER BY firstQuerry.UsageCounter DESC) AS DenseRank
FROM
		(SELECT	
			ContinentCode, CurrencyCode, COUNT(*) AS UsageCounter
		FROM Countries
		GROUP BY ContinentCode, CurrencyCode) AS firstQuerry) AS secondQuerry
WHERE secondQuerry.DenseRank = 1 
AND secondQuerry.UsageCounter <> 1
ORDER BY secondQuerry.ContinentCode, secondQuerry.CurrencyCode
 
-- TASK 16

SELECT COUNT(*) AS CountryCode
FROM Countries AS C
LEFT OUTER JOIN MountainsCountries AS MC
ON MC.CountryCode = C.CountryCode
WHERE MC.CountryCode IS NULL

-- TASK 17

WITH CTE_AllTablesJoined(CountryName, HighestPeakElevation, LongestRiverLength, dRank) AS 
(
	SELECT 
		c.CountryName,  
		p.Elevation AS [HighestPeakElevation],
		r.[Length] AS [LongestRiverLength],
		DENSE_RANK() OVER 
		(PARTITION BY c.CountryName ORDER BY p.Elevation DESC, r.[Length] DESC) AS [dRank]
	FROM Countries AS c
	LEFT JOIN MountainsCountries AS mc
		ON mc.CountryCode = c.CountryCode
	LEFT JOIN Peaks AS p
		ON p.MountainId = mc.MountainId
	LEFT JOIN CountriesRivers AS cr
		ON cr.CountryCode = c.CountryCode
	LEFT JOIN Rivers AS r
		ON r.Id = cr.RiverId
)

SELECT TOP(5) 
	CountryName, HighestPeakElevation, LongestRiverLength
FROM CTE_AllTablesJoined
WHERE dRank = 1
ORDER BY HighestPeakElevation DESC, LongestRiverLength DESC, CountryName

-- TASK 18

WITH CTE_AllCountriesInfo(CountryName, [Highest Peak Name], [Highest Peak Elevation], Mountain, [dRank]) AS 
(
	SELECT 
		c.CountryName,
		ISNULL(p.PeakName, '(no highest peak)'),
		ISNULL(p.Elevation, 0), 
		ISNULL(m.MountainRange, '(no mountain)'),
		DENSE_RANK() OVER (PARTITION BY c.CountryName ORDER BY p.Elevation DESC)
	FROM Countries AS c
	LEFT OUTER JOIN MountainsCountries AS mc
		ON mc.CountryCode = c.CountryCode
	LEFT OUTER JOIN Peaks AS p
		ON p.MountainId = mc.MountainId
	LEFT OUTER JOIN Mountains AS m
		ON m.Id = mc.MountainId
)

SELECT TOP(5)
   CountryName, [Highest Peak Name], [Highest Peak Elevation], Mountain
FROM CTE_AllCountriesInfo
WHERE dRank = 1
ORDER BY CountryName, [Highest Peak Name]