CREATE DATABASE HospitalityHotelDb;

CREATE TABLE GuestMaster(
GuestID VARCHAR(20) PRIMARY KEY,
GuestName VARCHAR(20),
RoomID VARCHAR(20),
FOREIGN KEY(RoomID) REFERENCES Room(RoomID),
CheckInDate DATE,
CheckOutDate DATE,
StateID INTEGER,
FOREIGN KEY(StateID) REFERENCES StateMaster(StateID)); 

CREATE TABLE Room(
RoomID VARCHAR(20) PRIMARY KEY,
RoomType VARCHAR(20),
Price INTEGER,
Status VARCHAR(20));

SELECT * FROM Booking, GuestMaster, Room

CREATE TABLE Booking(
BookingID VARCHAR(20) PRIMARY KEY,
GuestID VARCHAR(20),
FOREIGN KEY(GuestID) REFERENCES GuestMaster(GuestID),
RoomID VARCHAR(20),
FOREIGN KEY(RoomID) REFERENCES Room(RoomID),
CheckInDate DATE,
CheckOutDate DATE,
TotalAmount INTEGER);

CREATE TABLE StateMaster(
StateID INTEGER PRIMARY KEY,
StateName VARCHAR(20));

INSERT INTO GuestMaster(GuestID, GuestName, RoomID, CheckInDate, CheckOutDate, StateID)
VALUES 
('G01','John Doe','R01','2024-08-01','2024-08-05',101),
('G02','Jane Smith','R02','2024-08-02','2024-08-07',102),
('G03','Mike Johnson','R03','2024-08-03','2024-08-08',103),
('G04','Sara Williams','R04','2024-08-04','2024-08-09',104),
('G05','David Brown','R05','2024-08-05','2024-08-10',105),
('G06','Emma Davis','R06','2024-08-06','2024-08-11',106),
('G07','Frank Miller','R07','2024-08-07','2024-08-12',107),
('G08','Grace Wilson','R08','2024-08-08','2024-08-13',108),
('G09','Henry Moore','R09','2024-08-09','2024-08-14',109),
('G10','Linda Taylor','R10','2024-08-10','2024-08-15',110);

INSERT INTO Room(RoomID,RoomType,Price,Status)
VALUES
('R01','Single',100,'Booked'),
('R02','Double',200,'Booked'),
('R03','Suite',500,'Booked'),
('R04','Deluxe',300,'Booked'),
('R05','Single',100,'Booked'),
('R06','Double',200,'Booked'),
('R07','Suite',500,'Booked'),
('R08','Deluxe',300,'Booked'),
('R09','Single',100,'Booked'),
('R10','Suite',500,'Booked');

INSERT INTO Booking(BookingID, GuestID, RoomID, CheckInDate, CheckOutDate, TotalAmount)
VALUES 
('B01', 'G01', 'R01', '2024-08-01', '2024-08-05', 400),
('B02', 'G02', 'R02', '2024-08-02', '2024-08-07', 1000),
('B03', 'G03', 'R03', '2024-08-03', '2024-08-08', 2500),
('B04', 'G04', 'R04', '2024-08-04', '2024-08-09', 1500),
('B05', 'G05', 'R05', '2024-08-05', '2024-08-10', 500),
('B06', 'G06', 'R06', '2024-08-06', '2024-08-11', 1000),
('B07', 'G07', 'R07', '2024-08-07', '2024-08-12', 2500),
('B08', 'G08', 'R08', '2024-08-08', '2024-08-13', 1500),
('B09', 'G09', 'R09', '2024-08-09', '2024-08-14', 500),
('B10', 'G10', 'R10', '2024-08-10', '2024-08-15', 2500);

INSERT INTO StateMaster(StateID,StateName)
VALUES 
(101,'Lagos'),
(102,'Abuja'),
(103,'Kano'),
(104,'Delta'),
(105,'Ido'),
(106,'Ibadan'),
(107,'Enugu'),
(108,'Kaduna'),
(109,'Ogun'),
(110,'Anambra');

UPDATE StateMaster
SET StateName = 'Lagos'
WHERE StateID = 103;

ALTER TABLE Room
ADD Doorstyle VARCHAR(20),
Doortype VARCHAR(20);

--1. Fetch guests who stayed for the same number of days.

SELECT GuestName, CheckInDate, CheckOutDate, 
DATEDIFF(day, CheckInDate, CheckOutDate) AS DaysStayed
FROM GuestMaster
GROUP BY DATEDIFF(day, CheckInDate, CheckOutDate)
HAVING COUNT(GuestID) > 1;

--2. Find the second most expensive booking and the guest associated with it.

SELECT BookingID, GuestID, TotalAmount
FROM Booking
ORDER BY TotalAmount DESC
OFFSET 1 ROW
FETCH NEXT 1 ROW ONLY;

--3. Get the maximum room price per room type and the guest name.

SELECT r.RoomType, MAX(r.Price) AS MaxPrice, gm.GuestName
FROM Room r
JOIN GuestMaster gm ON r.RoomID = gm.RoomID
GROUP BY r.RoomType;

--4. Room type-wise count of guests sorted by count in descending order.

SELECT r.RoomType, COUNT(gm.GuestID) AS GuestCount
FROM Room r
JOIN GuestMaster gm ON r.RoomID = gm.RoomID
GROUP BY r.RoomType
ORDER BY GuestCount DESC;

--5. Fetch only the first name from the GuestName and append the total amount spent.

SELECT SUBSTRING_INDEX(gm.GuestName, ' ', 1) AS FirstName, b.TotalAmount
FROM GuestMaster gm
JOIN Booking b ON gm.GuestID = b.GuestID;

--6. Fetch bookings with odd total amounts.

SELECT *
FROM Booking
WHERE TotalAmount % 2 != 0;

--7. Create a view to fetch bookings with a total amount greater than $1000.

CREATE VIEW HighValueBookings AS
SELECT *
FROM Booking
WHERE TotalAmount > 1000;

--8. Create a procedure to update the room prices by 10% where the room type is 'Suite' and the state is not 'Lagos'.

DELIMITER //
CREATE PROCEDURE UpdateRoomPrices()
BEGIN
    UPDATE Room r
    JOIN GuestMaster gm ON r.RoomID = gm.RoomID
    JOIN StateMaster sm ON gm.StateID = sm.StateID
    SET r.Price = r.Price * 1.10
    WHERE r.RoomType = 'Suite' AND sm.StateName != 'Lagos';
END //
DELIMITER ;

--9. Create a stored procedure to fetch booking details along with the guest, room, and state, including error handling.

DELIMITER //
CREATE PROCEDURE FetchBookingDetails()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error occurred while fetching booking details';
    END;

    START TRANSACTION;
    SELECT b.BookingID, gm.GuestName, r.RoomType, sm.StateName, b.TotalAmount
    FROM Booking b
    JOIN GuestMaster gm ON b.GuestID = gm.GuestID
    JOIN Room r ON b.RoomID = r.RoomID
    JOIN StateMaster sm ON gm.StateID = sm.StateID;
    COMMIT;
END //
DELIMITER ;
