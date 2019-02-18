-- DDL OK

CREATE TABLE Students(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(30) NOT NULL,
	MiddleName NVARCHAR(25),
	LastName NVARCHAR(30) NOT NULL,
	Age INT CHECK(Age BETWEEN 5 AND 100) NOT NULL,
	[Address] NVARCHAR(50),
	Phone NCHAR(10) 
)

CREATE TABLE Subjects(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(20) NOT NULL,
	Lessons INT CHECK(Lessons > 0) NOT NULL
)

CREATE TABLE StudentsSubjects(
	Id INT PRIMARY KEY IDENTITY,
	StudentId INT NOT NULL FOREIGN KEY REFERENCES Students(Id),
	SubjectId INT NOT NULL FOREIGN KEY REFERENCES Subjects(Id),
	Grade DECIMAL (15,2) CHECK(Grade BETWEEN 2 AND 6) NOT NULL
)

CREATE TABLE Exams(
	Id INT PRIMARY KEY IDENTITY,
	[Date] DATETIME,
	SubjectId INT NOT NULL FOREIGN KEY REFERENCES Subjects(Id),
)

CREATE TABLE StudentsExams(
	StudentId INT NOT NULL FOREIGN KEY REFERENCES Students(Id),
	ExamId INT NOT NULL FOREIGN KEY REFERENCES Exams(Id),
	Grade DECIMAL (15,2) CHECK(Grade BETWEEN 2 AND 6) NOT NULL

	CONSTRAINT PK_StudentsExams PRIMARY KEY (StudentId, ExamId)
)

CREATE TABLE Teachers(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(20) NOT NULL,
	LastName NVARCHAR(20) NOT NULL,
	Address NVARCHAR(20) NOT NULL,
	Phone NCHAR(10),
	SubjectId INT NOT NULL FOREIGN KEY REFERENCES Subjects(Id)
)

CREATE TABLE StudentsTeachers(
	StudentId INT NOT NULL FOREIGN KEY REFERENCES Students(Id),
	TeacherId INT NOT NULL FOREIGN KEY REFERENCES Teachers(Id),

	CONSTRAINT PK_StudentsTeachers PRIMARY KEY (StudentId, TeacherId)
)


-- DML 2 OK

INSERT INTO Teachers
VALUES 
	('Ruthanne', 'Bamb', '84948 Mesta Junction', '3105500146', 6),
	('Gerrard',	'Lowin',	'370 Talisman Plaza',	'3324874824',	2),
	('Merrile',	'Lambdin',	'81 Dahle Plaza',	'4373065154',	5),
	('Bert',	'Ivie',	'2 Gateway Circle',	'4409584510',	4)


INSERT INTO Subjects
VALUES
	('Geometry ',	12),
	('Health',	10),
	('Drama',	7),
	('Sports'	,9)

-- 3 OK

UPDATE StudentsSubjects
SET Grade = 6.00
WHERE SubjectId IN (1,2) AND Grade >=5.50

--4 OK

DELETE
FROM StudentsTeachers
WHERE TeacherId IN (7,12,15,18,24,26)
DELETE FROM Teachers
WHERE Phone LIKE '%72%'

--5 OK
SELECT FirstName, LastName, Age 
FROM Students
WHERE Age >= 12
ORDER BY FirstName, LastName  

--6 OK

SELECT FirstName + ' ' + ISNULL(MiddleName + ' ',' ') + LastName AS [Full Name], Address
FROM Students 
WHERE Address LIKE '%Road'
ORDER BY FirstName,LastName, Address

--7 OK

SELECT FirstName,Address,Phone
FROM Students
WHERE MiddleName IS NOT NULL AND Phone LIKE '42%'
ORDER BY FirstName

--8 OK

SELECT S.FirstName, S.LastName, COUNT(ST.TeacherId) AS TeachersCount
FROM Students AS S
JOIN StudentsTeachers AS ST ON ST.StudentId = S.Id
JOIN Teachers AS T ON T.Id = ST.TeacherId
GROUP BY S.FirstName, S.LastName 

--9 OK

SELECT T.FirstName  + ' ' + T.LastName AS FullName, S.Name+ '-' + CONVERT(NVARCHAR(10),S.Lessons) AS Subjects, COUNT(ST.StudentId) AS Students
FROM Teachers AS T 
JOIN Subjects AS S ON S.Id = T.SubjectId
JOIN StudentsTeachers AS ST ON ST.TeacherId = T.Id
JOIN Students AS STUD ON STUD.Id = ST.StudentId
GROUP BY T.FirstName, T.LastName, S.Name , S.Lessons
ORDER BY Students DESC

--10 OK

SELECT FirstName + ' ' + LastName AS [Full Name]
FROM Students AS S
LEFT JOIN StudentsExams AS SE ON SE.StudentId = S.Id
--LEFT JOIN Exams AS E ON E.Id = SE.ExamId
WHERE SE.ExamId IS NULL
ORDER BY [Full Name] ASC

-- 11 OK

SELECT TOP(10) T.FirstName, T.LastName, COUNT(ST.StudentId) AS StudentsCount
FROM Teachers AS T
JOIN StudentsTeachers AS ST ON ST.TeacherId = T.Id
GROUP BY T.FirstName, T.LastName
ORDER BY StudentsCount DESC, T.FirstName, T.LastName

-- 12 OK

SELECT TOP(10) S.FirstName,S.LastName, FORMAT(AVG(SE.Grade),'N') AS Grade
FROM Students AS S
JOIN StudentsExams AS SE ON SE.StudentId = S.Id
GROUP BY  S.FirstName,S.LastName
ORDER BY Grade DESC, S.FirstName,S.LastName

-- 13 ?
SELECT DISTINCT Temp.FirstName,Temp.LastName,Temp.Grade
FROM
(SELECT S.FIRSTNAME, S.LASTNAME,SS.GRADE,
DENSE_RANK () OVER (PARTITION BY S.FirstName,S.LastName ORDER BY SS.GRADE DESC, AVG(SS.GRADE)) AS [Rank]

FROM StudentsSubjects AS SS
 JOIN Students AS S ON S.Id = SS.StudentId
GROUP BY SS.SubjectId,SS.Grade,S.FirstName,S.LastName,SS.StudentId) AS Temp
WHERE Temp.Rank=2
ORDER BY Temp.FirstName,Temp.LastName

-- 14 OK
SELECT S.FirstName + ' ' + ISNULL(S.MiddleName + ' ','') + S.LastName AS [Full Name]
FROM Students AS S
LEFT JOIN StudentsSubjects AS SS ON SS.StudentId = S.Id 
WHERE SS.SubjectId IS NULL
ORDER BY [Full Name]

-- 15 ?

SELECT T.FirstName + ' ' + T.LastName AS [Teacher Full Name],
S.FirstName + ' ' + ISNULL(S.MiddleName + ' ','') + S.LastName AS [Full Name],
SB.Name , 
AVG(SS.Grade) AS GRADE

FROM Teachers AS T
JOIN StudentsTeachers AS ST ON ST.TeacherId = T.Id
JOIN Students AS S ON S.Id = ST.StudentId
JOIN StudentsSubjects AS SS ON SS.StudentId = S.Id
JOIN Subjects AS SB ON SB.Id = SS.SubjectId
GROUP BY T.FirstName,T.LastName,S.FirstName,S.MiddleName,S.LastName,SB.Name
ORDER BY SB.Name ,[Teacher Full Name],GRADE DESC

-- 16 OK

SELECT S.Name, AVG(SS.Grade) AS AverageGrade
FROM StudentsSubjects AS SS
JOIN Subjects AS S ON S.Id = SS.SubjectId
GROUP BY  S.Name,S.ID
ORDER BY S.ID

-- 17 OK

SELECT 
	CASE	
		WHEN DATEPART(QUARTER, E.Date) = 1 THEN 'Q1'
		WHEN DATEPART(QUARTER, E.Date) = 2 THEN 'Q2'
		WHEN DATEPART(QUARTER, E.Date) = 3 THEN 'Q3'
		WHEN DATEPART(QUARTER, E.Date) = 4 THEN 'Q4'
		ELSE 'TBA'
	END AS Quarter,
	S.Name AS SubjectName,
 COUNT(SE.StudentId) AS StudentsCount

FROM StudentsExams AS SE 
JOIN Exams AS E ON E.Id = SE.ExamId
JOIN Subjects AS S ON S.Id = E.SubjectId
WHERE SE.Grade >= 4.00
GROUP BY DATEPART(QUARTER, E.Date),S.Name
ORDER BY CASE	
		WHEN DATEPART(QUARTER, E.Date) = 1 THEN '1'
		WHEN DATEPART(QUARTER, E.Date) = 2 THEN '2'
		WHEN DATEPART(QUARTER, E.Date) = 3 THEN '3'
		WHEN DATEPART(QUARTER, E.Date) = 4 THEN '4'
		WHEN DATEPART(QUARTER, E.Date) IS NULL THEN '5'
END  ASC , SubjectName ASC

-- 18 ?

GO
CREATE FUNCTION udf_ExamGradesToUpdate(@studentId INT, @grade DECIMAL(15,2))
RETURNS VARCHAR(MAX)
AS BEGIN
	DECLARE @student INT = (SELECT Id FROM Students WHERE Id = @StudentId)
	DECLARE @gradeIns DECIMAL(15,2) = (SELECT Grade FROM StudentsSubjects WHERE StudentId = @StudentId)
	DECLARE @studentName NVARCHAR(MAX) = (SELECT FirstName FROM Students WHERE Id = @StudentId)

			IF(@gradeIns > @grade)
			BEGIN
				RETURN 'Grade cannot be above 6.00!' 
			END 



			IF(@student != @studentId)
			BEGIN
				RETURN 'The student with provided id does not exist in the school!' 
			END 


		--RETURN  'You have to update {count} grades for the student ' + @studentName

END


-- 19 OK
GO

CREATE PROCEDURE usp_ExcludeFromSchool(@StudentId INT)
AS
BEGIN

	DECLARE @student INT = (SELECT Id FROM Students WHERE Id = @StudentId)

	IF(@student IS NULL)
	BEGIN 
		RAISERROR ('This school has no student with the provided id!', 16, 1)
		RETURN
	END
		DELETE FROM StudentsSubjects
		WHERE StudentId = @StudentId

		DELETE FROM StudentsTeachers
		WHERE StudentId = @StudentId
	
		DELETE FROM StudentsExams
		WHERE StudentId = @StudentId

		DELETE FROM Students
		WHERE Id = @StudentId

END

-- TEST

EXEC usp_ExcludeFromSchool 1
SELECT COUNT(*)FROM Students

EXEC usp_ExcludeFromSchool 301



-- 20 OK


GO
CREATE TABLE ExcludedStudents(
	StudentId INT,
	StudentName NVARCHAR(MAX)
)

GO
CREATE TRIGGER t_ExcludedStudents
	ON Students
	AFTER DELETE
AS
	BEGIN 
		INSERT INTO ExcludedStudents(StudentId, StudentName)
		SELECT D.Id, D.FirstName + ' ' + D.LastName AS [StudentName]
		FROM deleted AS D
		
END
-- TEST
DELETE FROM StudentsExams
WHERE StudentId= 1

DELETE FROM StudentsTeachers
WHERE StudentId= 1

DELETE FROM StudentsSubjects
WHERE StudentId= 1

DELETE FROM Students
WHERE Id= 1

SELECT* FROM ExcludedStudents


