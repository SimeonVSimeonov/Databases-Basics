--Task 1
CREATE DATABASE Minions

--Task 2
CREATE TABLE Minions(
    Id INT NOT NULL, 
    [Name] NVARCHAR(50) NOT NULL, 
    Age INT, 
    CONSTRAINT PK_Minions PRIMARY KEY (Id)
)

SELECT * FROM Minions

CREATE TABLE Towns(
    Id INT NOT NULL, 
    [Name] NVARCHAR(50) NOT NULL, 
    CONSTRAINT PK_Towns PRIMARY KEY (Id)
)

SELECT * FROM Towns

--Task 3
ALTER TABLE Minions
ADD TownId INT  

ALTER TABLE Minions
ADD CONSTRAINT PK_MinionTown FOREIGN KEY (TownId) REFERENCES Towns (Id)

--Task 4
INSERT INTO Towns(Id,Name) VALUES
(1, 'Sofia'), 
(2, 'Plovdiv'), 
(3, 'Varna')

INSERT INTO Minions(Id,Name,Age,TownId) VALUES
(1,'Kevin', 22, 1), 
(2, 'Bob', 15,3),
(3, 'Steward', NULL, 2)

Select * FROM Minions

--Task 5
TRUNCATE TABLE Minions

--Task 6
DROP TABLE Minions

DROP TABLE Towns

--Task 7
CREATE TABLE People(
    Id INT IDENTITY, 
    [Name] NVARCHAR(200) NOT NULL, 
    Picture VARBINARY(MAX), 
    Height DECIMAL(3, 2), 
    [Weight] DECIMAL(5, 2),
    Gender CHAR(1) NOT NULL, 
    BirthDate DATE NOT NULL, 
    Biography NVARCHAR(MAX),
    CONSTRAINT PK_PeopleId PRIMARY KEY (Id),
    CONSTRAINT CK_Picture_Size CHECK (DATALENGTH(Picture) > 1024 * 1024 * 2),
    CONSTRAINT CK_Person_Gender CHECK (Gender = 'm' OR Gender = 'f')
)

INSERT INTO People VALUES
('Maria', NULL, 2, 100, 'm', '2000/12/31', NULL),
('Penka', NULL, 2.10, 220, 'f', '1980/02/10', 'hello'),
('Stoyanka', NULL, 1.69, 55.03, 'f', '1993/03/17', 'ne mi znaish istoriqta !1!11!!!!'),
('jay-z', NULL, 1.90, 150.4, 'm', '1970/12/31', NULL), 
('beyonce', NULL, 1.77, 66, 'f', '1970/12/31', NULL)


SELECT * FROM People

--Task 8
CREATE TABLE Users(
        Id BIGINT IDENTITY, 
        Username VARCHAR(30) NOT NULL, 
        [Password] VARCHAR(26) NOT NULL, 
        ProfilePicture VARBINARY(MAX), 
        LastLoginTime SMALLDATETIME,
        IsDeleted BIT
        CONSTRAINT PK_User_Id PRIMARY KEY (Id),
        CONSTRAINT UQ_Username UNIQUE(Username),
        CONSTRAINT CK_ProfilePicture CHECK (DATALENGTH(ProfilePicture) <= 900 * 1024)
)

INSERT INTO Users VALUES
('goshoOtPochivka', 'parolata', NULL, NULL, 1),
('pesho', 'parolata', NULL, NULL, 0),
('ivan', 'parolata', NULL, NULL, 1),
('dragan', 'parolata', NULL, NULL, 44),
('rrr', 'parolata', NULL, NULL,-1)

Select * from Users

--Task 9
USE Minions
 
ALTER TABLE Users 
DROP CONSTRAINT PK_User_Id

ALTER TABLE Users
ADD CONSTRAINT PK_ID_USERNAME PRIMARY KEY(Id, Username)

--Task 10
ALTER TABLE Users
ADD CONSTRAINT CK_Password_Lenght CHECK (DATALENGTH([Password]) >= 5)
--  OR CHECK (LEN([Password]) >= 5)

SELECT * FROM Users 

--Task 11
ALTER TABLE Users
ADD CONSTRAINT DF_Last_Login DEFAULT GETDATE() FOR LastLoginTime

INSERT INTO Users(Username, Password, ProfilePicture, IsDeleted) VALUES
('Marinka', 'SECRETPASSWORD', NULL, 1)

SELECT * FROM Users

--Task 12
ALTER TABLE Users
DROP CONSTRAINT PK_New_Id_Username

ALTER TABLE Users
ADD CONSTRAINT PK_Id PRIMARY KEY (Id)

ALTER TABLE Users
ADD CONSTRAINT CK_Username_Lenght CHECK (LEN(Username) >= 3)

--Task 13
USE Movies

CREATE TABLE Directors(
    Id INT IDENTITY, 
    DirectorName NVARCHAR(50) NOT NULL, 
    Notes NVARCHAR(MAX), 
    CONSTRAINT PK_Director PRIMARY KEY (Id) 
)

INSERT INTO Directors VALUES
('Q. Tarantino', NULL),
('Christopher Nolan', NULL),
('Mel Gibbson', NULL),
('Lana Wachowski', NULL),
('David Fincher', NULL)

SELECT * FROM Directors

CREATE TABLE Genres(
    Id INT IDENTITY, 
    GenreName NVARCHAR(50) NOT NULL, 
    Notes NVARCHAR(MAX),
    CONSTRAINT PK_Genre PRIMARY KEY (Id)
)

INSERT INTO Genres VALUES
('Drama', NULL),
('Comedy', NULL),
('Crime', NULL),
('Horror', NULL),
('Action', NULL)

--SELECT * FROM Genres

CREATE TABLE Categories(
    Id INT IDENTITY, 
    CategoryName NVARCHAR(50) NOT NULL, 
    Notes NVARCHAR(MAX),
    CONSTRAINT PK_Category PRIMARY KEY (Id)
)

INSERT INTO Categories VALUES
('A', NULL),
('B', NULL),
('C', NULL),
('D', NULL),
('F', NULL)

SELECT * FROM Categories

CREATE TABLE Movies(
    Id INT IDENTITY, 
    Title NVARCHAR(150) NOT NULL, 
    DirectorId INT NOT NULL, 
    CopyrightYear INT NOT NULL, 
    [Length] INT NOT NULL,  
    GenreId INT NOT NULL, 
    CategoryId INT NOT NULL, 
    Rating NUMERIC(2, 1), 
    Notes NVARCHAR(MAX), 
    CONSTRAINT PK_Movie PRIMARY KEY (Id), 
    CONSTRAINT FK_Director FOREIGN KEY (DirectorId) REFERENCES Directors (Id), 
    CONSTRAINT FK_Genre FOREIGN KEY (GenreId) REFERENCES Genres (Id), 
    CONSTRAINT FK_Category FOREIGN KEY (CategoryId) REFERENCES Categories (Id), 
    CONSTRAINT CHK_Movie_Length CHECK ([Length] > 0),
    CONSTRAINT CHK_Rating_Value CHECK (Rating <= 10)
)

--SELECT * FROM Movies

INSERT INTO Movies(Title, DirectorId, CopyrightYear, Length, GenreId, CategoryId, Rating, Notes)
VALUES
('Pulp Fiction', 1, 1994, 120, 3, 1, 9.1, 'Very good movie!'),
('Seven', 5, 1994, 120, 4, 1, 7.2, 'Scary movie'),
('Inception', 2, 2010, 134, 1, 3, 9.9, NULL),
('Matrix', 4, 1994, 100, 5, 1, 7.0, NULL),
('Fight Club', 5, 1994, 120, 1, 1, 8.9, 'Nice one')

--Task 14
CREATE TABLE Categories(
    Id INT IDENTITY, 
    CategoryName NVARCHAR(50) NOT NULL, 
    DailyRate INT NOT NULL, 
    WeeklyRate INT NOT NULL, 
    MonthlyRate INT NOT NULL, 
    WeekendRate INT NOT NULL,
    CONSTRAINT PK_Category PRIMARY KEY (Id)
)

INSERT INTO Categories VALUES
('DISEL', 100, 600, 2500, 180),
('PETROL', 110, 660, 3000, 200),
('ELECTRIC', 200, 1000, 3500, 390)

--SELECT * FROM Categories

CREATE TABLE Cars(
    Id INT IDENTITY, 
    PlateNumber NVARCHAR(20) NOT NULL UNIQUE, 
    Manufacturer NVARCHAR(50) NOT NULL, 
    Model NVARCHAR(50) NOT NULL, 
    CarYear INT NOT NULL, 
    CategoryId INT NOT NULL, 
    Doors INT, 
    Picture VARBINARY(MAX), 
    Condition NVARCHAR(MAX), 
    Available BIT ,
    CONSTRAINT PK_Car PRIMARY KEY (Id), 
    CONSTRAINT FK_Category FOREIGN KEY (CategoryId) REFERENCES Categories(Id),
    CONSTRAINT CHK_PictureSize CHECK (DATALENGTH(Picture) <= 900 * 1024),
    CONSTRAINT CHK_DoorsCount CHECK (Doors > 0 AND Doors <= 5)
)

INSERT INTO Cars(PlateNumber, Manufacturer, Model, CarYear, CategoryId, Doors, Picture, Condition, Available)
VALUES
('СА 4441 АС', 'BMW', 'X4', 2006, 2, 5, NULL, 'Kat chisto nova', 1),
('A 1457 BA', 'Ford', 'Focus', 2010, 1, 3, NULL, 'BARAKA', 1),
('СA 1111111 АС', 'TESLA', 'CHUK', 2030, 3, 2, NULL, 'TOVA E BADESHTETO', 0)

--SELECT * FROM Cars

CREATE TABLE Employees(
    Id INT IDENTITY, 
    FirstName NVARCHAR(50) NOT NULL, 
    LastName NVARCHAR(50) NOT NULL, 
    Title VARCHAR(4), 
    Notes NVARCHAR(MAX),
    CONSTRAINT PK_Employee PRIMARY KEY (Id)
)

INSERT INTO Employees VALUES
('Haralampi', 'Haralampiev', NULL, NULL),
('Ivan', 'Karakolev', NULL, NULL),
('Dimitar', 'Peshov', NULL, NULL)

--SELECT * FROM Employees

CREATE TABLE Customers(
    Id INT IDENTITY, 
    DriverLicenceNumber INT NOT NULL, 
    FullName NVARCHAR(50) NOT NULL, 
    [Address] NVARCHAR(200) NOT NULL,
    City NVARCHAR(50) NOT NULL, 
    ZIPCode NVARCHAR(10), 
    Notes NVARCHAR(MAX), 
    CONSTRAINT PK_Custromer PRIMARY KEY (Id)
)

INSERT INTO Customers VALUES
(111111007, 'James Bondov', 'Fakulteta', 'Sofia', 1000, NULL), 
(101020302, 'Gosho Peshov', 'Mladost 1', 'Varna', 3010, NULL), 
(101291921, 'Ivan Ivanov', 'Zaharna Fabrika', 'Sofia', 1001, NULL)

--SELECT * FROM Customers

CREATE TABLE RentalOrders(
    Id INT IDENTITY, 
    EmployeeId INT NOT NULL, 
    CustomerId INT NOT NULL, 
    CarId INT NOT NULL, 
    TankLevel INT NOT NULL, 
    KilometrageStart FLOAT NOT NULL,
    KilometrageEnd FLOAT NOT NULL, 
    TotalKilometrage AS KilometrageEnd - KilometrageStart, 
    StartDate DATE NOT NULL, 
    EndDate DATE NOT NULL, 
    TotalDays AS DATEDIFF(DAY, StartDate, EndDate),
    RateApplied MONEY NOT NULL,
    TaxRate MONEY NOT NULL, 
    OrderStatus NVARCHAR(50) NOT NULL,
    Notes NVARCHAR(MAX),
    CONSTRAINT PK_Order PRIMARY KEY (Id), 
    CONSTRAINT FK_Employee FOREIGN KEY (EmployeeId) REFERENCES Employees(Id), 
    CONSTRAINT FK_Customer FOREIGN KEY (CustomerId) REFERENCES Customers(Id), 
    CONSTRAINT FK_Car FOREIGN KEY (CarId) REFERENCES Cars(Id),
    CONSTRAINT CHK_TankLevel CHECK (TankLevel >= 0), 
    CONSTRAINT CHK_EndDate CHECK (EndDate >= StartDate)
)

INSERT INTO RentalOrders VALUES
(2, 3, 1, 60, 2500, 10000, CONVERT(datetime, '18-10-2010', 103), CONVERT(datetime, '18-10-2020', 103), 100, 0.50, 'Rented', NULL),
(1, 2, 2, 100, 1000, 100000, CONVERT(datetime, '08-10-2015', 103), CONVERT(datetime, '18-11-2015', 103), 50, 2, 'BOOKED', NULL),
(3, 1, 3, 20, 0, 100, CONVERT(datetime, '10-06-2030', 103), CONVERT(datetime, '11-06-2030', 103), 100, 0.50, 'Rented', NULL)


--SELECT * FROM RentalOrders


--Task 15
CREATE TABLE Employees(
    Id INT IDENTITY, 
    FirstName NVARCHAR(50) NOT NULL, 
    LastName NVARCHAR(50) NOT NULL, 
    Title NVARCHAR(50) NOT NULL, 
    NOTES NVARCHAR(MAX),
    CONSTRAINT PK_Employees PRIMARY KEY (Id)
)

INSERT INTO Employees VALUES
('Blago', 'Djiizasa', 'title', NULL),
('Valeri', 'Bozhinkata', 'title', NULL),
('Chernata', 'Zlatka', 'TITLE', NULL)

--SELECT * FROM Employees

CREATE TABLE Customers(
    AccountNumber INT NOT NULL, 
    FirstName NVARCHAR(50) NOT NULL, 
    LastName NVARCHAR(50) NOT NULL, 
    PhoneNumber VARCHAR(20) NOT NULL, 
    EmergencyName  NVARCHAR(50) NOT NULL, 
    EmergencyNumber VARCHAR(20) NOT NULL, 
    NOTES NVARCHAR(MAX),
    CONSTRAINT PK_Customers PRIMARY KEY (AccountNumber)
)

INSERT INTO Customers
 VALUES
(1123123, 'Volen', 'Siderov', '0898949232', 'GERGI','2131313131',NULL),
(2121313, 'VaLERI', 'siMEONOV', '0898949232', 'GERGI','2131313131',NULL),
(19991291, 'KRASIMIR', 'karakachanov', '0898949232', 'GERGI','2131313131',NULL)

--SELECT *  FROM Customers

CREATE TABLE RoomStatus(
    RoomStatus NVARCHAR(10) UNIQUE NOT NULL, 
    NOTES NVARCHAR(MAX),
    CONSTRAINT PK_Status PRIMARY KEY (RoomStatus)
)

--SELECT * FROM RoomStatus

INSERT INTO RoomStatus (RoomStatus)
VALUES
	('Booked'),
    ('Occupied'),
    ('Available')

CREATE TABLE RoomTypes(
    RoomType NVARCHAR(50) UNIQUE NOT NULL, 
    NOTES NVARCHAR(MAX), 
    CONSTRAINT PK_Type PRIMARY KEY (RoomType)
)

INSERT INTO RoomTypes (RoomType)
VALUES
	('Single'),
    ('Double'),
    ('Suite')

--SELECT * FROM RoomTypes

CREATE TABLE BedTypes(
    BedType NVARCHAR(50) UNIQUE NOT NULL, 
    NOTES NVARCHAR(MAX), 
    CONSTRAINT PK_BedType PRIMARY KEY (BedType)
)

INSERT INTO BedTypes (BedType)
VALUES
	('SINGLE'),
    ('DOUble'),
    ('KingSIZE')

--SELECT * FROM BedTypes

CREATE TABLE Rooms(
    RoomNumber INT IDENTITY NOT NULL, 
    RoomType NVARCHAR(50) NOT NULL, 
    BedType NVARCHAR(50) NOT NULL, 
    Rate MONEY NOT NULL, 
    RoomStatus NVARCHAR(10) NOT NULL, 
    NOTES NVARCHAR(MAX),
    CONSTRAINT PR_Rooms PRIMARY KEY (RoomNumber), 
    CONSTRAINT FK_RoomType FOREIGN KEY (RoomType) REFERENCES RoomTypes (RoomType), 
    CONSTRAINT FK_BedType FOREIGN KEY (BedType) REFERENCES BedTypes (BedType), 
    CONSTRAINT FK_Status FOREIGN KEY (RoomStatus) REFERENCES RoomStatus (RoomStatus)  
)


INSERT INTO Rooms(RoomType, BedType, Rate, RoomStatus)
VALUES
('SINGLE', 'KINGSIZE', 100, 'Booked'),
('Double', 'SINGLE', 200, 'Booked'),
('SINGLE', 'SINGLE', 50, 'Booked')

--SELECT * FROM Rooms

CREATE TABLE Payments(
    Id INT IDENTITY, 
    EmployeeId INT NOT NULL, 
    PaymentDate DATETIME NOT NULL, 
    AccountNumber INT NOT NULL, 
    FirstDateOccupied DATE NOT NULL, 
    LastDateOccupied DATE NOT NULL, 
    TotalDays AS DATEDIFF(DAY, FirstDateOccupied, LastDateOccupied),
    AmountCharged DECIMAL(6,2) NOT NULL, 
    TaxRate DECIMAL(6,2) NOT NULL, 
    TaxAmount DECIMAL(6,2) NOT NULL, 
    PaymentTotal AS AmountCharged + TaxRate + TaxAmount, 
    NOTES NVARCHAR(MAX),
    CONSTRAINT PK_Payments PRIMARY KEY (Id), 
    CONSTRAINT FK_Employee FOREIGN KEY (EmployeeId) REFERENCES Employees (Id), 
    CONSTRAINT FK_AccountNumber FOREIGN KEY (AccountNumber) REFERENCES Customers (AccountNumber),
    CONSTRAINT CHK_EndDate CHECK (LastDateOccupied >= FirstDateOccupied)
)

INSERT INTO Payments(EmployeeId, PaymentDate, AccountNumber, FirstDateOccupied, LastDateOccupied, AmountCharged, TaxRate, TaxAmount)
VALUES
(1, GETDATE(),1123123, CONVERT([datetime], '10-10-2010', 103), CONVERT([datetime], '12-12-2010'), 303, 20,10),
(2, GETDATE(),1123123, CONVERT([datetime], '10-10-2010', 103), CONVERT([datetime], '12-12-2010'), 303, 20,10),
(3, GETDATE(),1123123, CONVERT([datetime], '10-10-2010', 103), CONVERT([datetime], '12-12-2010'), 303, 20,10)

--SELECT * FROM Payments

CREATE TABLE Occupancies(
    Id INT IDENTITY, 
    EmployeeId INT NOT NULL, 
    DateOccupied DATE NOT NULL, 
    AccountNumber INT NOT NULL, 
    RoomNumber INT NOT NULL, 
    RateApplied DECIMAL(6,2) NOT NULL,
    PhoneCharge DECIMAL(6,2) NOT NULL, 
    NOTES NVARCHAR(MAX),
    CONSTRAINT PK_Occupancies PRIMARY KEY (Id), 
    CONSTRAINT FK_Employees FOREIGN KEY (EmployeeId) REFERENCES Employees (Id), 
    CONSTRAINT FK_Customers FOREIGN KEY (AccountNumber) REFERENCES Customers (AccountNumber), 
    CONSTRAINT FK_RoomNumber FOREIGN KEY (RoomNumber) REFERENCES Rooms (RoomNumber),
    CONSTRAINT CHK_PhoneCharge CHECK (PhoneCharge >= 0) 
)

INSERT INTO Occupancies (EmployeeId, DateOccupied, AccountNumber, RoomNumber, RateApplied, PhoneCharge)
VALUES
	(1, CONVERT([datetime], '2014-02-10', 103), 1123123, 1, 70, 0),
	(2, CONVERT([datetime], '2014-02-10', 103), 1123123, 2, 70, 0),
	(3, CONVERT([datetime], '2014-02-10', 103), 1123123, 3, 70, 0)

--SELECT * FROM Occupancies 

--Task 16
--CREATE DATABASE SoftUni
--USE SoftUni

CREATE TABLE Towns(
    Id INT IDENTITY, 
    Name NVARCHAR(50) NOT NULL, 
    CONSTRAINT PK_Towns PRIMARY KEY (Id)
)

CREATE TABLE Addresses(
    Id INT IDENTITY, 
    AddressText NVARCHAR(200) NOT NULL, 
    TownId INT NOT NULL, 
    CONSTRAINT PK_Addresses PRIMARY KEY (Id),
    CONSTRAINT FK_TownId FOREIGN KEY (TownId) REFERENCES Towns(Id)
)

CREATE TABLE Departments(
    Id INT IDENTITY, 
    Name NVARCHAR(100) NOT NULL
    CONSTRAINT PK_Departments PRIMARY KEY (Id)
)

CREATE TABLE Employees(
    Id INT IDENTITY, 
    FirstName NVARCHAR(20) NOT NULL, 
    MiddleName NVARCHAR(20) NOT NULL, 
    LastName NVARCHAR(20) NOT NULL,
    JobTitle NVARCHAR(50) NOT NULL, 
    DepartmentId INT NOT NULL,
    HireDate DATE NOT NULL,
    Salary DECIMAL(7,2) NOT NULL, 
    AddressId INT NOT NULL,
    CONSTRAINT PK_Employees PRIMARY KEY (Id), 
    CONSTRAINT FK_Department FOREIGN KEY (DepartmentId) REFERENCES Departments(Id), 
    CONSTRAINT FK_Address FOREIGN KEY (AddressId) REFERENCES Addresses(Id)
)

ALTER TABLE Employees
ADD CONSTRAINT CHK_Salary CHECK (Salary > 0)

--Task 17
BACKUP DATABASE SoftUni
TO DISK = 'D:\Downloads\softuni-backup.bak'

--Task 18
INSERT INTO Addresses VALUES
('ул. Тинтява 17', 1),
('жк. Възраждане', 3),
('жк. Славейков', 4),
('ул. Кораб Планина', 1)

SELECT * FROM Addresses

INSERT INTO Towns VALUES
('Sofia'), ('Plovdiv'), ('Varna'), ('Burgas')

SELECT * FROM Towns

INSERT INTO Departments VALUES
('Engineering'), ('Sales'), ('Marketing'), ('Software Development'), ('Quality Assurance')

SELECT * FROM Departments

INSERT INTO Employees VALUES
('Ivan', 'Ivanov', 'Ivanov', '.NET Developer', 4, CONVERT([datetime], '01-02-2013',103), 3500, 1),
('Petar', 'Petrov', 'Petrov', 'Senior Engineer', 1, CONVERT([datetime], '02-03-2014',103), 4000, 4),
('Maria', 'Petrova', 'Ivanova', 'Intern', 5, CONVERT([datetime], '28-08-2016',103), 525.25, 1), 
('Georgi', 'Terziev', 'Ivanov', 'CEO', 2, CONVERT([datetime], '09-12-2007',103), 3000, 2), 
('Peter', 'Pan', 'Pan', 'Intern', 3, CONVERT([datetime], '28-08-2016',103), 599.88, 3) 

SELECT * FROM Employees

--Task 19
SELECT * FROM Towns

SELECT * FROM Departments

SELECT * FROM Employees

--Task 20

SELECT * FROM Towns 
ORDER BY Name ASC

SELECT * FROM Departments
ORDER BY Name ASC

SELECT * FROM Employees
ORDER BY Salary DESC

--Task 21
--USE SoftUni

SELECT Name FROM Towns
ORDER BY Name

SELECT Name FROM Departments
ORDER BY Name

SELECT FirstName, LastName, JobTitle, Salary FROM Employees
ORDER BY Salary DESC

--Task 22
UPDATE Employees
SET Salary *= 1.10 

SELECT Salary FROM Employees

--Task 23
UPDATE Payments 
SET TaxRate *= 0.97

SELECT TaxRate FROM Payments

--Task 24
TRUNCATE TABLE Occupancies

