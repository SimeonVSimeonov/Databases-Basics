CREATE TABLE Cities 
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(20) NOT NULL,
	CountryCode CHAR(2) NOT NULL
)

CREATE TABLE Hotels
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30) NOT NULL,
	CityId INT NOT NULL FOREIGN KEY REFERENCES Cities(Id),
	EmployeeCount INT NOT NULL,
	BaseRate DECIMAL(15,2)
)

CREATE TABLE Rooms 
(
	Id INT PRIMARY KEY IDENTITY,
	Price DECIMAL(15,2) NOT NULL,
	[Type] NVARCHAR(20) NOT NULL,
	Beds INT NOT NULL,
	HotelId INT NOT NULL FOREIGN KEY REFERENCES Hotels(Id)
)

CREATE TABLE Trips 
(
	Id INT PRIMARY KEY IDENTITY,
	RoomId INT NOT NULL FOREIGN KEY REFERENCES Rooms(Id),
	BookDate DATE NOT NULL,
	ArrivalDate DATE NOT NULL,
	ReturnDate DATE NOT NULL,
	CancelDate DATE,

	CONSTRAINT CHK_ValidateArrivalDate CHECK(BookDate < ArrivalDate),
	CONSTRAINT CHK_ValidateReturnDate CHECK(ArrivalDate < ReturnDate)
)

CREATE TABLE Accounts 
(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	MiddleName NVARCHAR(20),
	LastName NVARCHAR(50) NOT NULL,
	CityId INT NOT NULL FOREIGN KEY REFERENCES Cities(Id),
	BirthDate DATE NOT NULL,
	Email VARCHAR(100) NOT NULL UNIQUE
)

CREATE TABLE AccountsTrips
(
	AccountId INT NOT NULL FOREIGN KEY REFERENCES Accounts(Id),
	TripId INT NOT NULL FOREIGN KEY REFERENCES Trips(Id),
	Luggage INT CHECK (Luggage >= 0)

	CONSTRAINT PK_AccountsTrips PRIMARY KEY (AccountId, TripId)
)

-- Insert

INSERT INTO Accounts
VALUES	('John', 'Smith', 'Smith', 34, '1975-07-21', 'j_smith@gmail.com'),
		('Gosho', NULL, 'Petrov', 11, '1978-05-16', 'g_petrov@gmail.com'),
		('Ivan', 'Petrovich', 'Pavlov', 59, '1849-09-26', 'i_pavlov@softuni.bg'),
		('Friedrich', 'Wilhelm', 'Nietzsche', 2, '1844-10-15', 'f_nietzsche@softuni.bg') 

INSERT INTO Trips
VALUES	(101, '2015-04-12', '2015-04-14', '2015-04-20', '2015-02-02'),
		(102, '2015-07-07', '2015-07-15', '2015-07-22', '2015-04-29'),
		(103, '2013-07-17', '2013-07-23', '2013-07-24', NULL),
		(104, '2012-03-17', '2012-03-31', '2012-04-01', '2012-01-10'), 
		(109, '2017-08-07', '2017-08-28', '2017-08-29', NULL) 

-- Update

UPDATE Rooms
SET Price *= 1.14
WHERE HotelId IN (5, 7, 9)

-- Delete

DELETE FROM AccountsTrips
WHERE AccountId = 47

-- 05. Bulgarian Cities

SELECT Id, [Name] 
FROM Cities
WHERE CountryCode = 'BG'
ORDER BY [Name]

-- 06. People Born After 1991

SELECT FirstName + ' ' + ISNULL(MiddleName + ' ','') + LastName AS [Full Name], DATEPART(YEAR, BirthDate) AS BirthYear
FROM Accounts
WHERE DATEPART(YEAR, BirthDate) > 1991
ORDER BY BirthYear DESC, FirstName

-- 07. EEE-Mails 

SELECT FirstName, LastName, CONVERT( VARCHAR, BirthDate, 110 ) AS BirthDate, C.Name AS Hometown, Email
FROM Accounts AS A
JOIN Cities AS C ON C.Id = A.CityId
WHERE Email LIKE 'e%'
ORDER BY C.Name DESC

-- 08. City Statistics 

SELECT C.Name AS City , COUNT(H.Name) AS Hotels
FROM Cities AS C
LEFT JOIN Hotels AS H ON H.CityId = C.Id
GROUP BY C.Name
ORDER BY COUNT(H.Name) DESC, C.Name

-- 09. Expensive First Class Rooms

SELECT R.Id, R.Price, H.Name, C.Name 
FROM Rooms AS R
JOIN Hotels AS H ON H.Id = R.HotelId
JOIN Cities AS C ON C.Id = H.CityId
WHERE R.Type = 'First Class'
ORDER BY R.Price DESC, R.Id

-- 10. Longest and Shortest Trips

SELECT A.Id, A.FirstName + ' ' + A.LastName AS FullName,
MAX(DATEDIFF(DAY,ArrivalDate,ReturnDate)) AS LongestTrip,
MIN(DATEDIFF(DAY,ArrivalDate,ReturnDate)) AS ShortestTrip
FROM Accounts AS A
JOIN AccountsTrips AS AT ON AT.AccountId = A.Id
JOIN Trips AS T ON T.Id = AT.TripId
WHERE A.MiddleName IS NULL AND T.CancelDate IS NULL
GROUP BY A.Id, FirstName, LastName
ORDER BY MAX(DATEDIFF(DAY,ArrivalDate,ReturnDate)) DESC, A.Id

-- 11. Metropolis

SELECT TOP(5) C.Id, C.Name, C.CountryCode, COUNT(A.Id) AS Accounts
FROM Cities AS C
JOIN Accounts AS A ON A.CityId = C.Id
GROUP BY C.CountryCode, C.Name, C.Id
ORDER BY Accounts DESC

-- 12. Romantic Getaways

SELECT A.Id, A.Email, C.Name, COUNT(T.Id) AS Trips
FROM Accounts AS A
JOIN AccountsTrips AS ATR ON ATR.AccountId = A.Id
JOIN Trips AS T ON T.Id = ATR.TripId
JOIN Rooms AS R ON R.Id = T.RoomId
JOIN Hotels AS H ON  H.Id = R.HotelId
JOIN Cities AS C ON C.Id = H.CityId
WHERE A.CityId = C.Id
GROUP BY A.Id, A.Email, C.Name
ORDER BY Trips DESC, A.Id

-- 13. Lucrative Destinations 

SELECT TOP(10) C.Id, C.Name, SUM(H.BaseRate + R.Price) AS TotalRevenue, COUNT(TR.Id) AS Trips
FROM Cities AS C
JOIN Hotels AS H ON H.CityId = C.Id
JOIN Rooms AS R ON R.HotelId = H.Id
JOIN Trips AS TR ON TR.RoomId = R.Id
WHERE DATEPART(YEAR,TR.BookDate) = 2016
GROUP BY C.Id, C.Name
ORDER BY TotalRevenue DESC, Trips DESC

-- 14. Trip Revenues

SELECT TR.Id, H.Name, R.Type,
CASE 
	WHEN TR.CancelDate IS NOT NULL THEN 0.00
	ELSE  SUM(H.BaseRate+R.Price)
END  AS Revenue
FROM Trips AS TR
JOIN Rooms AS R ON R.Id = TR.RoomId
JOIN Hotels AS H ON H.Id = R.HotelId
JOIN AccountsTrips AS AT ON AT.TripId = TR.Id
GROUP BY TR.Id, H.Name, R.Type, TR.CancelDate
ORDER BY R.Type, TR.Id

-- 15. Top Travelers 

SELECT RA.Id, RA.Email, RA.CountryCode, RA.Trips
FROM
(SELECT a.Id, a.Email, c.CountryCode, COUNT(*) AS Trips,
	DENSE_RANK() OVER(PARTITION BY C.CountryCode ORDER BY COUNT(*) DESC, A.Id) AS RankTrip

FROM Accounts AS A 
JOIN AccountsTrips AS ATR ON ATR.AccountId = A.Id
JOIN Trips AS T ON T.Id = ATR.TripId
JOIN Rooms AS R ON R.Id = T.RoomId
JOIN Hotels AS H ON H.Id = R.HotelId
JOIN Cities AS C ON C.Id = H.CityId
GROUP BY c.CountryCode, a.Email, a.Id) AS RA
WHERE RA.RankTrip = 1
ORDER BY Trips DESC, RA.Id

-- 16. Luggage Fees 

SELECT ATR.TripId, SUM(ATR.Luggage) AS Luggage,
'$' + CONVERT(VARCHAR(10),CASE 
					WHEN SUM(ATR.Luggage) > 5 THEN  SUM(ATR.Luggage) * 5
					ELSE 0
					END) AS Fee

FROM AccountsTrips AS ATR
GROUP BY ATR.TripId
HAVING SUM(ATR.Luggage) > 0
ORDER BY Luggage DESC

-- 17. GDPR Violation 

SELECT T.Id, A.FirstName + ' ' + ISNULL(A.MiddleName + ' ','') + A.LastName AS [FullName],
HC.Name AS [From], C.Name AS [To], 
CASE 
 WHEN T.CancelDate IS NOT NULL THEN 'Canceled'
 ELSE CONVERT(VARCHAR(10),DATEDIFF(DAY,T.ArrivalDate,T.ReturnDate))+ ' days'
 END 
 AS Duration
FROM Accounts AS A
JOIN AccountsTrips AS ATR ON ATR.AccountId = A.Id
JOIN Trips AS T ON T.Id = ATR.TripId
JOIN Rooms AS R ON R.Id  = T.RoomId
JOIN Hotels AS H ON H.Id = R.HotelId
JOIN Cities AS C ON C.Id = H.CityId
JOIN Cities AS HC ON HC.Id = A.CityId
ORDER BY FullName, T.Id

-- 18. Available Room 

GO
CREATE FUNCTION udf_GetAvailableRoom(@HotelId INT, @Date DATE, @People INT)
RETURNS VARCHAR(MAX)
AS BEGIN
	DECLARE @AvailableRoom NVARCHAR(MAX) = (SELECT TOP(1) CONCAT('Room ', r.Id, ': ', r.Type,' (', r.Beds, ' beds) - $', (h.BaseRate + r.Price) * @People)
					FROM Hotels AS H
					JOIN Rooms AS R ON R.HotelId = H.Id
					JOIN Trips AS T ON T.RoomId = R.Id
					WHERE @Date NOT BETWEEN T.ArrivalDate AND T.ReturnDate
					AND H.Id = @HotelId AND R.Beds > @People
					AND T.CancelDate IS NULL
					ORDER BY R.Price DESC)
					
	IF(@AvailableRoom IS NULL)
	BEGIN
		RETURN 'No rooms available' 
	END 

	RETURN @AvailableRoom
END
GO
SELECT dbo.udf_GetAvailableRoom(112, '2011-12-17', 2)
SELECT dbo.udf_GetAvailableRoom(94, '2015-07-26', 3)

-- 19. Switch Room 

GO
CREATE PROC usp_SwitchRoom(@TripId INT, @TargetRoomId INT)
AS
BEGIN
DECLARE @HotelId INT = (SELECT TOP(1) R.HotelId
						FROM Trips AS T
						JOIN Rooms AS R
						ON T.RoomId = R.Id
						WHERE T.Id = @TripId)

DECLARE @TargetRoomHotelId INT = (SELECT TOP(1) R.HotelId
									FROM Rooms AS R
									WHERE R.Id = @TargetRoomId)

IF(@HotelId != @TargetRoomHotelId)
BEGIN 
RAISERROR ('Target room is in another hotel!', 16, 1)
	RETURN
END
 
DECLARE @NumberOfPeople INT = (SELECT COUNT(*)
	                                  FROM AccountsTrips AS at
	                                  WHERE at.TripId = @TripId)
  
IF((SELECT TOP(1) r.Beds FROM Rooms AS r WHERE r.Id = @TargetRoomId) < @NumberOfPeople)
BEGIN 
RAISERROR('Not enough beds in target room!', 16, 1)
	RETURN
END

UPDATE Trips
SET RoomId = @TargetRoomId
WHERE Id = @TripId

END

GO

EXEC usp_SwitchRoom 10, 11
SELECT RoomId FROM Trips WHERE Id = 10

EXEC usp_SwitchRoom 10, 7
EXEC usp_SwitchRoom 10, 8

-- 20. Cancel Trip 
GO
CREATE TRIGGER tr_CancelTrip ON Trips
INSTEAD OF DELETE
AS
UPDATE Trips
SET CancelDate = GETDATE()
WHERE Id IN (SELECT Id FROM deleted WHERE CancelDate IS NULL)

