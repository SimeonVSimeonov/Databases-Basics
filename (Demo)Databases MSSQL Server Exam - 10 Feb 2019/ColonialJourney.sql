CREATE DATABASE ColonialJourney

USE ColonialJourney

-- Section 1. DDL (30 pts)

CREATE TABLE Planets(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	[Name] VARCHAR(30) NOT NULL
)

CREATE TABLE Spaceports(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	[Name] VARCHAR(50) NOT NULL,
	PlanetId INT FOREIGN KEY REFERENCES Planets(Id) NOT NULL
)

CREATE TABLE Spaceships(
	Id INT IDENTITY(0,1) PRIMARY KEY,
	[Name] VARCHAR(50) NOT NULL,
	Manufacturer VARCHAR(30) NOT NULL,
	LightSpeedRate INT DEFAULT 0
)

CREATE TABLE Colonists(
	Id INT IDENTITY(0,1) PRIMARY KEY,
	FirstName VARCHAR(20) NOT NULL,
	LastName VARCHAR(20) NOT NULL,
	Ucn VARCHAR(10) NOT NULL UNIQUE,
	BirthDate DATE NOT NULL
)

CREATE TABLE Journeys(
	Id INT IDENTITY(0,1) PRIMARY KEY,
	JourneyStart DATETIME NOT NULL,
	JourneyEnd DATETIME NOT NULL,
	Purpose VARCHAR(11) NOT NULL,
	DestinationSpaceportId INT FOREIGN KEY REFERENCES Spaceports(Id) NOT NULL,
	SpaceshipId INT FOREIGN KEY REFERENCES Spaceships(Id) NOT NULL
)

CREATE TABLE TravelCards(
	Id INT IDENTITY(0,1) PRIMARY KEY,
	CardNumber CHAR(10) NOT NULL UNIQUE,
	JobDuringJourney VARCHAR(8) NOT NULL,
	ColonistId INT FOREIGN KEY REFERENCES Colonists(Id) NOT NULL,
	JourneyId INT FOREIGN KEY REFERENCES Journeys(Id) NOT NULL
)

-- Section 2. DML (10 pts)

INSERT INTO Planets(Name)
	VALUES ('Mars'),
			('Earth'),
			('Jupiter'),
			('Saturn')

INSERT INTO Spaceships(Name,Manufacturer,LightSpeedRate)
	VALUES('Golf','VW',3),
			('WakaWaka', 'Wakanda', 4),
			('Falcon9', 'SpaceX', 1),
			('Bed',	'Vidolov',6)

--

UPDATE Spaceships
SET LightSpeedRate += 1
WHERE Spaceships.Id BETWEEN 8 AND 12

-- 

DELETE FROM TravelCards WHERE JourneyId IN(1,2,3)
DELETE FROM Journeys WHERE Journeys.Id BETWEEN 1 AND 3

-- Section 3. Querying (40 pts)

-- 5. Select all travel cards

SELECT CardNumber, JobDuringJourney 
FROM TravelCards
ORDER BY CardNumber ASC

-- 6. Select all colonists

SELECT Id,CONCAT(FirstName, ' ', LastName) AS FullName, Ucn
FROM Colonists
ORDER BY FirstName,LastName,Id ASC

-- 7. Select all military journeys

SELECT Id,CONVERT (varchar(10), JourneyStart, 103) AS [JourneyStart], CONVERT(varchar(10), JourneyEnd,103) AS [JourneyEnd]
FROM Journeys
WHERE Journeys.Purpose = 'Military'
ORDER BY JourneyStart ASC

-- 8. Select all pilots

SELECT C.Id,CONCAT(FirstName,' ', LastName) AS full_name
FROM Colonists AS C
JOIN TravelCards AS TR ON TR.ColonistId = C.Id
WHERE JobDuringJourney = 'Pilot'
ORDER BY C.ID ASC

-- 9. Count colonists

SELECT COUNT(*)
FROM Colonists AS C
JOIN TravelCards AS TR ON TR.ColonistId = C.Id
JOIN Journeys AS J ON J.Id = TR.JourneyId
WHERE J.Purpose = 'Technical'

-- 10. Select the fastest spaceship

SELECT TOP(1) S.Name AS SpaceshipName, SP.Name AS SpaceportName
FROM Spaceships AS S
LEFT JOIN Journeys AS J ON J.SpaceshipId = S.Id
LEFT JOIN Spaceports AS SP ON SP.Id = J.DestinationSpaceportId
ORDER BY LightSpeedRate DESC

-- 11. Select spaceships with pilots younger than 30 years

SELECT S.Name, S.Manufacturer
FROM Spaceships AS S
JOIN Journeys AS J ON J.SpaceshipId = S.Id
JOIN TravelCards AS TR ON TR.JourneyId = J.Id
JOIN Colonists AS C ON C.Id = TR.ColonistId
WHERE DATEDIFF(YEAR, C.BirthDate, '01/01/2019') < 30 AND TR.JobDuringJourney = 'Pilot'
ORDER BY S.Name

-- 12. Select all educational mission planets and spaceports

SELECT P.Name,SP.Name 
FROM Journeys AS J
JOIN Spaceports AS SP ON SP.Id = J.DestinationSpaceportId
JOIN Planets AS P ON P.Id = SP.PlanetId
WHERE Purpose = 'Educational'
ORDER BY SP.Name DESC

-- 13. Select all planets and their journey count

SELECT P.Name, COUNT(J.ID) AS JourneysCount
FROM Planets AS P 
LEFT JOIN Spaceports AS SP ON SP.PlanetId = P.Id
 JOIN Journeys AS J ON J.DestinationSpaceportId = SP.Id
GROUP BY P.Name
ORDER BY JourneysCount DESC, P.Name ASC

-- 14. Select the shortest journey

SELECT TOP(1) J.Id, P.Name AS PlanetName, SP.Name AS SpaceportName, J.Purpose AS JourneyPurpose
FROM Journeys AS J 
JOIN Spaceports AS SP ON SP.Id = J.DestinationSpaceportId
JOIN Planets AS P ON P.Id = SP.PlanetId
ORDER BY DATEDIFF(SECOND, J.JourneyStart, J.JourneyEnd) ASC

-- 15. Select the less popular job

SELECT TOP(1) TC.JourneyId, TC.JobDuringJourney
FROM TravelCards AS TC
WHERE TC.JourneyId = (SELECT TOP(1) J.Id FROM Journeys AS J ORDER BY DATEDIFF(MINUTE, J.JourneyStart, J.JourneyEnd) DESC)
GROUP BY TC.JobDuringJourney, TC.JourneyId
ORDER BY COUNT(TC.JobDuringJourney) ASC

-- 16. Select Second Oldest Important Colonist

SELECT k.JobDuringJourney, CONCAT(c.FirstName, ' ', c.LastName) AS FullName, JobRank
  FROM (
		SELECT tc.JobDuringJourney,
				tc.ColonistId,
				DENSE_RANK() OVER (PARTITION BY tc.JobDuringJourney ORDER BY co.Birthdate ASC) AS JobRank
		FROM TravelCards AS tc
		JOIN Colonists AS co ON co.Id = tc.ColonistId
		GROUP BY tc.JobDuringJourney, co.Birthdate, tc.ColonistId
		 ) AS k
  JOIN Colonists AS c ON c.Id = k.ColonistId
  WHERE k.JobRank = 2
  ORDER BY k.JobDuringJourney

-- 17. Planets and Spaceports

SELECT P.Name AS [Name] , COUNT(SP.Name) AS [Count]
FROM Planets AS P
LEFT JOIN Spaceports AS SP ON SP.PlanetId = P.Id
GROUP BY P.Name
ORDER BY Count DESC, Name ASC

-- Section 4. Programmability (20 pts)

-- 18. Get Colonists Count

GO
CREATE FUNCTION udf_GetColonistsCount(@PlanetName VARCHAR(30))
RETURNS INT
AS
BEGIN
	RETURN ( SELECT COUNT(*) FROM Journeys AS J
	JOIN Spaceports AS SP ON SP.Id = J.DestinationSpaceportId
	JOIN Planets AS P ON P.Id = SP.PlanetId
	JOIN TravelCards AS TC ON TC.JourneyId = J.Id
	JOIN Colonists AS  C ON C.Id = TC.ColonistId 
	WHERE P.Name = @PlanetName
	)
END

-- 19. Change Journey Purpose
GO
CREATE PROCEDURE usp_ChangeJourneyPurpose(@JourneyId INT, @NewPurpose VARCHAR(30))
AS
BEGIN
	DECLARE @TargetJourneyId INT = (SELECT Id FROM Journeys WHERE Id = @JourneyId)

	IF(@TargetJourneyId IS NULL)
	BEGIN
		;THROW 51000, 'The journey does not exist!', 1
	END

	DECLARE @CurrentJourneyPurpose VARCHAR(30) = (SELECT Purpose FROM Journeys WHERE Id = @JourneyId)

	IF(@CurrentJourneyPurpose = @NewPurpose)
	BEGIN
		;THROW 51000, 'You cannot change the purpose!', 2
	END

	UPDATE Journeys
	SET Purpose = @NewPurpose
	WHERE Id = @JourneyId
END

-- 20. Deleted Journeys

CREATE TABLE DeletedJourneys
(
	Id INT,
	JourneyStart DATETIME,
	JourneyEnd DATETIME,
	Purpose VARCHAR(11),
	DestinationSpaceportId INT,
	SpaceshipId INT
)

GO

CREATE TRIGGER t_DeleteJourney
	ON Journeys
	AFTER DELETE
AS
	BEGIN 
		INSERT INTO DeletedJourneys(Id,JourneyStart,JourneyEnd,Purpose,DestinationSpaceportId,
		SpaceshipId)
		SELECT Id, JourneyStart, JourneyEnd, Purpose, DestinationSpaceportId, SpaceshipId FROM deleted
	END