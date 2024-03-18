Use Cinema;

CREATE TABLE Cinema (
CinemaID INT PRIMARY KEY,
Name VARCHAR(100) NOT NULL,
Address VARCHAR(255) NOT NULL,
Phone VARCHAR(20)
);
 
CREATE TABLE Theater (
TheaterID INT PRIMARY KEY,
CinemaID INT,
Name VARCHAR(50) NOT NULL,
Capacity INT NOT NULL,
ScreenType VARCHAR(50),
FOREIGN KEY (CinemaID) REFERENCES Cinema(CinemaID)
);
 
CREATE TABLE Movie (
MovieID INT PRIMARY KEY,
Title VARCHAR(255) NOT NULL,
Director VARCHAR(100),
ReleaseDate DATE,
DurationMinutes INT,
Rating VARCHAR(5)
);
 
CREATE TABLE Showtime (
ShowtimeID INT PRIMARY KEY,
MovieID INT,
TheaterID INT,
ShowDateTime DATETIME NOT NULL,
Price DECIMAL(5,2) NOT NULL,
FOREIGN KEY (MovieID) REFERENCES Movie(MovieID),
FOREIGN KEY (TheaterID) REFERENCES Theater(TheaterID)
);
 
CREATE TABLE Customer (
CustomerID INT PRIMARY KEY,
FirstName VARCHAR(50) NOT NULL,
LastName VARCHAR(50) NOT NULL,
Email VARCHAR(100),
PhoneNumber VARCHAR(20)
);
 
CREATE TABLE Ticket (
TicketID INT PRIMARY KEY,
ShowtimeID INT,
SeatNumber VARCHAR(10) NOT NULL,
PurchasedDateTime DATETIME NOT NULL,
CustomerID INT,
FOREIGN KEY (ShowtimeID) REFERENCES Showtime(ShowtimeID),
FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);
 
CREATE TABLE Review (
ReviewID INT PRIMARY KEY,
MovieID INT,
CustomerID INT,
ReviewText TEXT,
Rating INT CHECK (Rating >= 1 AND Rating <= 5),
ReviewDate DATETIME NOT NULL,
FOREIGN KEY (MovieID) REFERENCES Movie(MovieID),
FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);
 
CREATE TABLE Employee (
EmployeeID INT PRIMARY KEY,
CinemaID INT,
FirstName VARCHAR(50) NOT NULL,
LastName VARCHAR(50) NOT NULL,
Position VARCHAR(50),
HireDate DATE,
FOREIGN KEY (CinemaID) REFERENCES Cinema(CinemaID)
);



INSERT INTO Cinema (CinemaID, Name, Address, Phone)
VALUES
(1, 'Cinema Paradiso', 'Via Roma 123', '06 1234567'),
(2, 'Cinema inferno', 'Via Napoli 222', '+ 06 8574635');
 
INSERT INTO Theater (TheaterID, CinemaID, Name, Capacity, ScreenType)
VALUES
(1, 1, 'Sala 1', 100, '2D'),
(2, 1, 'Sala 2', 80, '3D'),
(3, 2, 'Sala 3', 150, 'IMAX'),
(4, 2, 'Sala 4', 120, '2D');
 
INSERT INTO Movie (MovieID, Title, Director, ReleaseDate, DurationMinutes, Rating)
VALUES
(1, 'The Shawshank Redemption', 'Frank Darabont', '1994-09-23', 142, '4'),
(2, 'Inception', 'Christopher Nolan', '2010-07-16', 148, '4'),
(3, 'Pulp Fiction', 'Quentin Tarantino', '1994-10-14', 154, '5');
 
INSERT INTO Showtime (ShowtimeID, MovieID, TheaterID, ShowDateTime, Price)
VALUES
(1, 1, 1, '2024-03-2 18:00:00', 10.00),
(2, 2, 3, '2024-03-2 20:00:00', 12.50),
(3, 3, 2, '2024-03-2 19:30:00', 11.00);
 
INSERT INTO Customer (CustomerID, FirstName, LastName, Email, PhoneNumber)
VALUES
(1, 'Mario', 'Rossi', 'mrossi@example.com', '3334657889'),
(2, 'Valerio', 'Bianchi', 'valbianch@example.com', '336970699');
 
INSERT INTO Ticket (TicketID, ShowtimeID, SeatNumber, PurchasedDateTime, CustomerID)
VALUES
(1, 1, 'A1', '2024-03-01 15:30:00', 1),
(2, 2, 'B5', '2024-03-01 10:45:00', 2);
 
INSERT INTO Review (ReviewID, MovieID, CustomerID, ReviewText, Rating, ReviewDate)
VALUES
(1, 1, 1, 'Bellissimo film,uno dei migliori!', 5, '2024-03-01 09:15:00'),
(2, 2, 2, 'Film dell''anno.', 4, '2024-03-01 22:30:00');
 
INSERT INTO Employee (EmployeeID, CinemaID, FirstName, LastName, Position, HireDate)
VALUES
(1, 1, 'Franco', 'Rossi', 'Manager', '2020-01-15'),
(2, 2, 'Luca', 'Gialli', 'Cassiere', '2022-03-01');


create view FilmInProgrammazione 
AS
select m.Title,m.Rating,m.DurationMinutes,st.ShowDateTime
from Movie m inner join Showtime st on m.MovieID = st.MovieID;

select * from FilmInProgrammazione;

create view AvailableSeat
AS
select m.Title, st.ShowDateTime, t.Capacity, m.MovieID as id
from Movie m inner join Showtime st on m.MovieID = st.MovieID
	inner join Theater t on st.TheaterID = t.TheaterID;


create view nTicketVenduti AS
SELECT count (*) as 'numero vendite', m.MovieID as id
		from Movie m inner join Showtime st on m.MovieID = st.MovieID
		inner join Ticket t on t.ShowtimeID = st.ShowtimeID
		group by(m.MovieID);


create view AvailableSeatForMovie
AS
select Title,ShowDateTime, Capacity - [numero vendite] as 'Biglietti disponibbili'
from AvailableSeat left join nTicketVenduti on AvailableSeat.id = nTicketVenduti.id;

create view TotalForMovie
AS
select m.Title, t.[numero vendite] * Price AS 'Incasso' 
from nTicketVenduti t inner join Showtime s on t.id = s.MovieID
inner join Movie m on s.MovieID = m.MovieID;

create view MostraFeedback
AS
select m.Title, r.Rating, r.ReviewText, r.ReviewDate, c.*
from Movie m inner join Review r on m.MovieID = r.MovieID
inner join Customer c on r.CustomerID = c.CustomerID;


create procedure InsertNewMovie
	@MovieID int,
	@Title VARCHAR(255),
	@Director VARCHAR(100),
	@ReleaseDate DATE,
	@DurationMinutes INT,
	@Rating VARCHAR(5)
AS
BEGIN
	BEGIN TRY
		IF (@Title IS NULL)
			THROW 50001, 'Prenotazione non consentita', 1
		IF (@DurationMinutes <= 0)
			THROW 50001, 'Prenotazione non consentita', 1
		IF (@ReleaseDate < CURRENT_TIMESTAMP)
			THROW 50001, 'Prenotazione non consentita', 1

		INSERT INTO Movie (MovieID, Title, Director, ReleaseDate, DurationMinutes, Rating) values
			(@MovieID,@Title,@Director,@ReleaseDate,@DurationMinutes,@Rating);
			
	END TRY
	BEGIN CATCH
		PRINT 'ERRORE'
	END CATCH
END

exec InsertNewMovie
	@MovieID = 5,
	@Title = 'The Shawshank Redemption',
	@Director = 'Frank Darabont',
	@ReleaseDate = '1994-09-23',
	@DurationMinutes = 142,
	@Rating ='4';


CREATE PROCEDURE AcquistaBiglietto
	@TicketID int,
	@ShowtimeID int,
	@SeatNumber varchar,
	@PurchasedDateTime varchar,
	@CustomerID int
AS
BEGIN
	DECLARE @Vendite int = 0;
    BEGIN TRY
		BEGIN TRANSACTION
			
			select @Vendite = [numero vendite]
			from Movie m inner join Showtime s on m.MovieID = s.MovieID
			inner join nTicketVenduti n on s.MovieID = n.id
			where s.ShowtimeID = @ShowtimeID;

			IF (@Vendite > 0)
				BEGIN
					INSERT INTO Ticket (TicketID, ShowtimeID, SeatNumber, PurchasedDateTime, CustomerID)
					VALUES(@TicketID, @ShowtimeID, @SeatNumber, @PurchasedDateTime, @CustomerID);
				END
				
			ELSE
				THROW 50001, 'Prenotazione non consentita', 1
				
		COMMIT TRANSACTION
	END TRY
    BEGIN CATCH
        PRINT 'ERRORE'
		ROLLBACK
    END CATCH
END


CREATE PROCEDURE LasciaRecenzione
	@ReviewID int,
	@MovieID int,
	@CustomerID int,
	@ReviewText varchar,
	@Rating varchar
AS
BEGIN
	DECLARE @Value int = 0;
    BEGIN TRY
		BEGIN TRANSACTION
			
			select @Value = COUNT(c.CustomerID)
			from Ticket t inner join Customer c on t.CustomerID = c.CustomerID
			inner join Showtime s on t.ShowtimeID = s.ShowtimeID
			where c.CustomerID = @CustomerID AND s.MovieID = @MovieID

			IF (@Value > 0)
				BEGIN
					INSERT INTO Review (ReviewID, MovieID, CustomerID, ReviewText, Rating, ReviewDate)
					VALUES (@ReviewID, @MovieID, @CustomerID, @ReviewText, @Rating, CURRENT_TIMESTAMP);
				END
				
			ELSE
				THROW 50001, 'Prenotazione non consentita', 1
				
		COMMIT TRANSACTION
	END TRY
    BEGIN CATCH
        PRINT 'ERRORE'
		ROLLBACK
    END CATCH
END