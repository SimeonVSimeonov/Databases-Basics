
-- Section I. Functions and Procedures

-- TASK 1

CREATE PROCEDURE usp_GetEmployeesSalaryAbove35000
AS
SELECT FirstName, LastName
FROM Employees
WHERE Salary > 35000

EXEC usp_GetEmployeesSalaryAbove35000

-- TASK 2 

GO
CREATE PROCEDURE usp_GetEmployeesSalaryAboveNumber(@Salary DECIMAL(18,4)) AS
SELECT FirstName, LastName
FROM Employees
WHERE Salary >= @Salary  

EXEC usp_GetEmployeesSalaryAboveNumber 48100

-- TASK 3

GO
CREATE PROCEDURE usp_GetTownsStartingWith (@StartWith VARCHAR(50)) AS 
SELECT NAME AS Town FROM Towns
WHERE Name LIKE @StartWith + '%'

EXEC usp_GetTownsStartingWith 'B'

-- TASK 4

GO
CREATE PROC usp_GetEmployeesFromTown(@Town NVARCHAR(30)) AS
SELECT FirstName, LastName
FROM Employees AS E
JOIN Addresses AS A ON A.AddressID = E.AddressID
JOIN Towns AS T ON T.TownID = A.TownID
WHERE T.Name = @Town

EXEC usp_GetEmployeesFromTown @Town = 'Sofia'

-- TASK 5

GO
CREATE FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4))
RETURNS VARCHAR(10) AS 
BEGIN 
	DECLARE @SalaryLevel VARCHAR(10)
	SET @SalaryLevel = 
		CASE 
			WHEN @salary < 30000 THEN 'Low'
			WHEN @salary <= 50000 THEN 'Average'
			ELSE 'High'
		END
	RETURN @SalaryLevel
END
GO
SELECT Salary, dbo.ufn_GetSalaryLevel(Salary) AS [Salary Level] FROM Employees

-- TASK 6

GO
CREATE PROC usp_EmployeesBySalaryLevel(@SalaryLevel VARCHAR(10)) AS 
SELECT FirstName, LastName 
FROM Employees
WHERE dbo.ufn_GetSalaryLevel(Salary) = @SalaryLevel

EXEC usp_EmployeesBySalaryLevel 'High'

-- TASK 7

CREATE FUNCTION ufn_IsWordComprised(@setOfLetters VARCHAR(MAX), @word VARCHAR(MAX))
RETURNS BIT AS 
BEGIN 
	DECLARE @WordLength INT  = LEN(@word)
	DECLARE @Index INT = 1

	WHILE (@Index <= @WordLength)
	BEGIN 
		IF (CHARINDEX(SUBSTRING(@word, @Index, 1), @setOfLetters) = 0)
		BEGIN
			RETURN 0
		END

		SET @Index += 1
	END

	RETURN 1 
END

SELECT dbo.ufn_IsWordComprised('oistmiahf', 'Sofia')
SELECT dbo.ufn_IsWordComprised('oistmiahf', 'halves')
SELECT dbo.ufn_IsWordComprised('bobr', 'Rob')
SELECT dbo.ufn_IsWordComprised('pppp', 'Guy')

-- TASK 8

CREATE PROC usp_DeleteEmployeesFromDepartment (@departmentId INT) AS
ALTER TABLE Employees
DROP CONSTRAINT FK_Employees_Employees

ALTER TABLE EmployeesProjects
DROP CONSTRAINT FK_EmployeesProjects_Employees

ALTER TABLE EmployeesProjects
ADD CONSTRAINT FK_EmployeesProjects_Employees FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID) ON DELETE CASCADE

ALTER TABLE Departments
DROP CONSTRAINT FK_Departments_Employees

ALTER TABLE Departments
ALTER COLUMN ManagerID INT NULL

UPDATE Departments
SET ManagerID = NULL
WHERE DepartmentID = @departmentId

UPDATE Employees
SET ManagerID = NULL
WHERE DepartmentID = @departmentId

DELETE FROM Employees
WHERE DepartmentID = @departmentId AND ManagerID IS NULL

DELETE FROM Departments
WHERE DepartmentID = @departmentId

IF OBJECT_ID('[Employees].[FK_Employees_Employees]') IS NULL
    ALTER TABLE [Employees] WITH NOCHECK
        ADD CONSTRAINT [FK_Employees_Employees] FOREIGN KEY ([ManagerID]) REFERENCES [Employees]([EmployeeID]) ON DELETE NO ACTION ON UPDATE NO ACTION

IF OBJECT_ID('[Departments].[FK_Departments_Employees]') IS NULL
    ALTER TABLE [Departments] WITH NOCHECK
        ADD CONSTRAINT [FK_Departments_Employees] FOREIGN KEY ([ManagerID]) REFERENCES [Employees]([EmployeeID]) ON DELETE NO ACTION ON UPDATE NO ACTION

SELECT COUNT(*) FROM Employees
WHERE DepartmentID = @departmentId

EXEC usp_DeleteEmployeesFromDepartment 4
GO

-- TASK 9

GO
CREATE PROC usp_GetHoldersFullName AS
SELECT CONCAT(FirstName, ' ', LastName) AS [Full Name] FROM AccountHolders

EXEC usp_GetHoldersFullName
GO

-- TASK 10

GO
CREATE PROC usp_GetHoldersWithBalanceHigherThan(@money DECIMAL(16,2)) AS
SELECT ah.FirstName, ah.LastName FROM Accounts AS a
JOIN AccountHolders AS ah
ON a.AccountHolderId = ah.Id
GROUP BY ah.FirstName, ah.LastName
HAVING SUM(a.Balance) > @money
ORDER BY ah.FirstName, ah.LastName

EXEC usp_GetHoldersWithBalanceHigherThan 20000
GO

-- TASK 11

GO
CREATE FUNCTION ufn_CalculateFutureValue(@sum decimal(18,4), @yearlyInterestRate FLOAT, @numberOfYears INT)
RETURNS DECIMAL (18,4)
BEGIN
	RETURN @sum * POWER((1 + @yearlyInterestRate), @numberOfYears)
END
GO
SELECT dbo.ufn_CalculateFutureValue(1000, 0.1, 5)

-- TASK 12

GO
CREATE PROC usp_CalculateFutureValueForAccount(@AccountID INT, @InterestRate FLOAT) AS 
SELECT
		A.Id AS [Account Id],
		AH.FirstName AS [First Name],
		AH.LastName AS [Last Name],
		A.Balance AS [Current Balance],
		dbo.ufn_CalculateFutureValue(A.Balance, @InterestRate, 5) AS [Balance in 5 years]
	FROM Accounts AS A
	JOIN AccountHolders AS AH 
	ON AH.Id = A.AccountHolderId AND A.Id = @AccountID

EXEC usp_CalculateFutureValueForAccount 1, 0.1
GO

-- TASK 13

CREATE FUNCTION ufn_CashInUsersGames(@gameName VARCHAR(MAX))
RETURNS TABLE AS
RETURN	SELECT SUM(Cash) AS SumCash FROM
	(
		SELECT ug.Cash, ROW_NUMBER() OVER(ORDER BY Cash DESC) AS RowNum FROM UsersGames AS ug
		JOIN Games AS g
		ON g.Id = ug.GameId
		WHERE g.Name = @gameName
	) AS AllGameRows
	WHERE RowNum % 2 = 1
GO

SELECT * FROM dbo.ufn_CashInUsersGames('Lily Stargazer')


-- Section II. Triggers and Transactions

-- TASK 14

CREATE TABLE Logs
(
	LogId INT IDENTITY,
	AccountID INT NOT NULL,
	OldSum DECIMAL(16,2) NOT NULL,
	NewSum DECIMAL(16,2) NOT NULL

	CONSTRAINT PK_Logs
	PRIMARY KEY (LogId)
	
	CONSTRAINT FK_Logs_Accounts
	FOREIGN KEY (AccountID)
	REFERENCES Accounts(Id)
)

GO

CREATE TRIGGER tr_ChangeBalance ON  Accounts AFTER UPDATE
AS
BEGIN
	INSERT INTO Logs
	SELECT inserted.Id, deleted.Balance, inserted.Balance
	FROM inserted
	JOIN deleted
	ON inserted.Id = deleted.Id
END

UPDATE Accounts
SET Balance += 567
WHERE Id = 3

-- TASK 15

CREATE TABLE NotificationEmails
(
	ID INT IDENTITY PRIMARY KEY, 
	Recipient INT FOREIGN KEY REFERENCES Accounts(ID), 
	Subject NVARCHAR(MAX) NOT NULL, 
	Body NVARCHAR(MAX) NOT NULL
)

GO

CREATE TRIGGER tr_SendEmail ON Logs AFTER INSERT
AS
BEGIN
	INSERT INTO NotificationEmails
	SELECT
		inserted.AccountID,
		CONCAT('Balance change for account: ', inserted.AccountID),
		CONCAT('On ', GETDATE(), ' your balance was changed from ', inserted.OldSum, ' to ', inserted.NewSum)
	FROM inserted
END
GO

SELECT * FROM Logs
SELECT * FROM NotificationEmails

UPDATE Accounts 
SET Balance += 1500000
WHERE Id = 1
GO

-- TASK 16

CREATE PROC usp_DepositMoney(@accountId INT, @moneyAmount DECIMAL(16,4))
AS
BEGIN
	BEGIN TRANSACTION
	UPDATE Accounts
	SET Balance += @moneyAmount
	WHERE Id = @accountId

	IF @moneyAmount < 0
	BEGIN 
		ROLLBACK;
		RETURN;
	END
		COMMIT
END

EXEC usp_DepositMoney 2, 5000

SELECT * FROM Accounts
GO

-- TASK 17

CREATE PROC usp_WithdrawMoney(@accountId INT, @moneyAmount DECIMAL(16,4))
AS
BEGIN
		BEGIN TRANSACTION
			IF (@moneyAmount > 0)
			BEGIN
				UPDATE Accounts
				SET Balance -= @moneyAmount
				WHERE Id = @accountId

				IF(@@ROWCOUNT <> 1)
				BEGIN
					RAISERROR('INVALID ACCOUNT!',16, 2)
					ROLLBACK; 
					RETURN; 
				END
		END
	COMMIT
END

EXECUTE dBO.usp_WithdrawMoney 1, 100
GO

-- TASK 18

CREATE PROCEDURE usp_TransferMoney(@SenderId INT, @ReceiverId INT, @Amount DECIMAL (16,4))
AS
BEGIN 
	BEGIN TRANSACTION 
	IF(@Amount > 0)
	BEGIN 
		EXECUTE usp_WithdrawMoney @SenderId, @Amount
		EXECUTE usp_DepositMoney @ReceiverId, @Amount
	END
	COMMIT
END 

SELECT * FROM Accounts
EXECUTE dbo.usp_TransferMoney 1, 2, 1000
GO

-- TASK 19

-- TASK 20

DECLARE @gameId INT = (SELECT Id FROM Games AS g WHERE g.[Name] = 'Safflower'); 
DECLARE @userId INT = (SELECT u.Id FROM Users AS u WHERE u.Username = 'Stamat');	
DECLARE @userGameId INT = (SELECT ug.Id FROM UsersGames AS ug WHERE ug.GameId = @gameId AND ug.UserId = @userId);
DECLARE @userCash DECIMAL(15, 2) = (SELECT ug.Cash FROM UsersGames AS ug WHERE ug.Id = @userGameId);  
DECLARE @itemsPricesSummed DECIMAL(15, 2) = (SELECT SUM(i.Price) FROM Items AS i WHERE i.MinLevel BETWEEN 11 AND 12); 

IF(@userCash >= @itemsPricesSummed)
BEGIN
	BEGIN TRANSACTION
		INSERT UserGameItems
		SELECT i.Id, @UserGameId
		FROM Items AS i
		WHERE i.MinLevel BETWEEN 11 AND 12

		UPDATE UsersGames 
		SET Cash -= @itemsPricesSummed
		WHERE Id = @UserGameId 
	COMMIT
END

SET @itemsPricesSummed = (SELECT SUM(i.Price) FROM Items AS i WHERE i.MinLevel BETWEEN 19 AND 21); 
SET @UserCash = (SELECT ug.Cash FROM UsersGames AS ug WHERE ug.Id = @UserGameId);  

IF(@UserCash >= @itemsPricesSummed)
BEGIN 	
	BEGIN TRANSACTION
		INSERT UserGameItems
		SELECT i.Id, @UserGameId
		FROM Items AS i
		WHERE i.MinLevel BETWEEN 19 AND 21

		UPDATE UsersGames 
		SET Cash -= @itemsPricesSummed
		WHERE Id = @UserGameId 
	COMMIT TRANSACTION 
END

SELECT i.[Name] 
FROM UsersGames AS ug
JOIN Users AS u
ON u.Id = ug.UserId
JOIN Games AS g
ON g.Id = ug.GameId
JOIN UserGameItems AS ugi
ON ugi.UserGameId = ug.Id
JOIN Items AS i
ON i.Id = ugi.ItemId
WHERE (u.Username = 'Stamat' 
AND g.[Name] = 'Safflower')
ORDER BY i.[Name]

-- TASK 21

CREATE PROCEDURE usp_AssignProject(@emloyeeId INT, @projectID INT)
AS
BEGIN 
	DECLARE @maxProjectsAllowed INT = 3; 
	DECLARE @currentProjects INT;

	SET @currentProjects = 
	(SELECT COUNT(*) 
	FROM Employees AS e
	JOIN EmployeesProjects AS ep
	ON ep.EmployeeID = e.EmployeeID
	WHERE ep.EmployeeID = @emloyeeId)

BEGIN TRANSACTION 	
	IF(@currentProjects >= @maxProjectsAllowed)
	BEGIN 
		RAISERROR('The employee has too many projects!', 16, 1);
		ROLLBACK;
		RETURN;
	END

	INSERT INTO EmployeesProjects
	VALUES
	(@emloyeeId, @projectID)

COMMIT	
END 

-- TASK 22

CREATE TABLE Deleted_Employees
(
	EmployeeId INT NOT NULL IDENTITY, 
	FirstName NVARCHAR(64) NOT NULL, 
	LastName NVARCHAR(64) NOT NULL, 
	MiddleName NVARCHAR(64), 
	JobTitle NVARCHAR(64) NOT NULL, 
	DepartmentID INT NOT NULL, 
	Salary DECIMAL(15, 2) NOT NULL

	CONSTRAINT PK_Deleted_Emp
	PRIMARY KEY (EmployeeId), 

	CONSTRAINT FK_DeletedEmp_Departments
	FOREIGN KEY (DepartmentID)
	REFERENCES Departments(DepartmentID)
)
GO

CREATE TRIGGER tr_DeletedEmp 
ON Employees 
AFTER DELETE 
AS
	INSERT INTO Deleted_Employees
	SELECT 	
		d.FirstName, 
		d.LastName, 
		d.MiddleName, 
		d.JobTitle, 
		d.DepartmentID, 
		d.Salary
FROM deleted as d

