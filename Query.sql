use littlelemondb;
-- Insert random data into Customers table
INSERT INTO Customers (CustomerID, CustomerName, ContactDetail)
VALUES 
('Cust001', 'John Doe', '123-456-7890'),
('Cust002', 'Alice Smith', '234-567-8901'),
('Cust003', 'Mary Johnson', '345-678-9012'),
('Cust004', 'David Wilson', '456-789-0123'),
('Cust005', 'Sarah Brown', '567-890-1234');
-- Add more rows as needed

-- Insert random data into Bookings table
INSERT INTO Bookings (BookingID, BookingDate, TableNo, CustomerID)
VALUES 
('B001', '2023-11-09', 1, 'Cust001'),
('B002', '2023-11-10', 2, 'Cust002'),
('B003', '2023-11-11', 3, 'Cust003'),
('B004', '2023-11-12', 4, 'Cust004'),
('B005', '2023-11-13', 5, 'Cust005');
-- Add more rows as needed

-- Insert random data into Staffs table
INSERT INTO Staffs (StaffID, StaffRole, StaffSalary)
VALUES 
('S001', 'Waiter', 2000),
('S002', 'Chef', 2500),
('S003', 'Bartender', 1800),
('S004', 'Manager', 3000),
('S005', 'Busser', 1500);
-- Add more rows as needed

-- Insert random data into Deliveries table
INSERT INTO Deliveries (DeliveryID, DeliveryDate, DeliveryStatus)
VALUES 
('D001', '2023-11-09', 'Delivered'),
('D002', '2023-11-10', 'Pending'),
('D003', '2023-11-11', 'Delivered'),
('D004', '2023-11-12', 'Pending'),
('D005', '2023-11-13', 'Shipped');
-- Add more rows as needed

-- Insert random data into MenuItems table
INSERT INTO MenuItems (ItemID, ItemName, ItemType, Price)
VALUES 
('M001', 'Pasta', 'Main Course', 12.99),
('M002', 'Salad', 'Appetizer', 8.99),
('M003', 'Burger', 'Main Course', 10.99),
('M004', 'Soup', 'Appetizer', 6.99),
('M005', 'Cheesecake', 'Dessert', 7.99);
-- Add more rows as needed

-- Insert random data into Menus table
INSERT INTO Menus (MenuID, Cuisine, ItemID)
VALUES 
('Menu001', 'Italian', 'M001'),
('Menu002', 'American', 'M002'),
('Menu003', 'American', 'M003'),
('Menu004', 'French', 'M004'),
('Menu005', 'Desserts', 'M005');
-- Add more rows as needed

-- Insert random data into Orders table
INSERT INTO Orders (OrderID, OrderDate, BookingID, StaffID, MenuID, DeliveryID, Quantity, TotalCost)
VALUES 
('Order001', '2023-11-09', 'B001', 'S001', 'Menu001', 'D001', 2, 25.98),
('Order002', '2023-11-10', 'B002', 'S002', 'Menu002', 'D002', 3, 35.97),
('Order003', '2023-11-11', 'B003', 'S003', 'Menu003', 'D003', 1, 10.99),
('Order004', '2023-11-12', 'B004', 'S004', 'Menu004', 'D004', 2, 20.98),
('Order005', '2023-11-13', 'B005', 'S005', 'Menu005', 'D005', 1, 7.99);
-- Add more rows as needed

CREATE VIEW CustomerOrdersView AS
SELECT
    C.CustomerID,
    C.CustomerName,
    O.OrderID,
    O.TotalCost,
    M.Cuisine,
    MI.ItemName AS MenuItem
FROM
    Customers C
JOIN
    Bookings B ON C.CustomerID = B.CustomerID
JOIN
    Orders O ON B.BookingID = O.BookingID
JOIN
    Menus M ON O.MenuID = M.MenuID
JOIN
    MenuItems MI ON M.ItemID = MI.ItemID
WHERE
    O.TotalCost > 15 AND MI.ItemType = 'Main Course';


-- Create a view to find menu items with more than 2 orders
CREATE VIEW PopularMenuItems AS
SELECT
    M.MenuID,
    M.Cuisine,
    MI.ItemID,
    MI.ItemName,
    COUNT(O.OrderID) AS OrderCount
FROM
    Menus M
JOIN
    MenuItems MI ON M.ItemID = MI.ItemID
LEFT JOIN
    Orders O ON M.MenuID = O.MenuID
GROUP BY
    M.MenuID, MI.ItemID, MI.ItemName, M.Cuisine
HAVING
    OrderCount > 2;
    
SELECT * FROM CustomerOrdersView;

SELECT * FROM PopularMenuItems;

CREATE PROCEDURE MaxOrder()
SELECT max(Quantity) FROM Orders;
CALL MaxOrder();

PREPARE GetOrderDetails FROM 'SELECT OrderID, Quantity, TotalCost FROM Orders WHERE BookingID=?';
SET @customerid='B001';
EXECUTE GetOrderDetails USING @customerid;

DELIMITER //
CREATE PROCEDURE CancelOrder(IN ID varchar(45) )
DELETE FROM Orders WHERE OrderID=ID;
DELIMITER ;

CALL CancelOrder('Order002');
SELECT * FROM Orders;

DELIMITER //
SET @bookingCount = 0;
CREATE PROCEDURE CheckBooking(IN checkBookingDate DATE, IN checkTableNo INT)
BEGIN
    -- Count the number of bookings for the specified date and table number
    SELECT COUNT(*) INTO @bookingCount
    FROM Bookings
    WHERE BookingDate = checkBookingDate AND TableNo = checkTableNo;

    -- If there are bookings, print a message, otherwise, indicate the table is available
    IF @bookingCount > 0 THEN
        SELECT CONCAT('Table ', checkTableNo, ' is already booked on ', checkBookingDate) AS Result;
    ELSE
        SELECT CONCAT('Table ', checkTableNo, ' is available on ', checkBookingDate) AS Result;
    END IF;
END //
DELIMITER ;

CALL CheckBooking('2023-11-09', 1);

DELIMITER //

CREATE PROCEDURE AddValidBookings(IN pBookingDate DATE, IN pTableNo INT)
BEGIN
    DECLARE bookingExists INT;

    -- Check if the table is already booked for the given date
    SELECT COUNT(*) INTO bookingExists
    FROM Bookings
    WHERE BookingDate = pBookingDate AND TableNo = pTableNo;

    -- Begin a transaction
    START TRANSACTION;

    -- If the table is not already booked, insert the new booking with a generated customer ID
    IF bookingExists = 0 THEN
        -- Generate a unique customer ID using CONCAT and UUID
        SET @newCustomerID = CONCAT('Cust', REPLACE(UUID(), '-', ''));

        INSERT INTO Bookings (BookingDate, TableNo, CustomerID)
        VALUES (pBookingDate, pTableNo, @newCustomerID);

        -- Commit the transaction if everything is successful
        COMMIT;
        SELECT CONCAT('Booking added successfully. Assigned CustomerID: ', @newCustomerID) AS Result;
    ELSE
        -- Rollback the transaction if the table is already booked
        ROLLBACK;
        SELECT 'Table is already booked for the given date.' AS Result;
    END IF;
END //

DELIMITER ;

-- Call the AddValidBookings procedure
CALL AddValidBookings('2023-11-09', 1);

DELIMITER //

CREATE PROCEDURE ManageBooking(
    IN pChoice INT,
    IN pBookingID VARCHAR(45),
    IN pBookingDate DATE,
    IN pTableNo INT,
    IN pCustomerID VARCHAR(45)
)
BEGIN
    DECLARE duplicateEntry INT DEFAULT 0;

    -- Begin a transaction
    START TRANSACTION;

    -- Process user's choice
    CASE pChoice
        WHEN 1 THEN
            -- Add new booking
            BEGIN
                -- Declare handler for SQLException
                DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
                    SET duplicateEntry = 1;

                INSERT INTO Bookings (BookingID, BookingDate, TableNo, CustomerID)
                VALUES (pBookingID, pBookingDate, pTableNo, pCustomerID);

                -- Check for duplicate entry
                IF duplicateEntry = 0 THEN
                    SELECT 'New booking added successfully.' AS Result;
                ELSE
                    SELECT 'Error: Duplicate entry found. Booking not added.' AS Result;
                END IF;
            END;

        WHEN 2 THEN
            -- Update existing booking
            UPDATE Bookings
            SET BookingDate = pBookingDate, TableNo = pTableNo, CustomerID = pCustomerID
            WHERE BookingID = pBookingID;
            SELECT 'Booking updated successfully.' AS Result;

        WHEN 3 THEN
            -- Cancel booking
            DELETE FROM Bookings WHERE BookingID = pBookingID;
            SELECT 'Booking canceled successfully.' AS Result;

        WHEN 4 THEN
            -- Exit the procedure
            SELECT 'Exiting the procedure.' AS Result;
    END CASE;

    -- Commit the transaction if everything is successful
    COMMIT;

    -- Rollback the transaction if there was an error
    ROLLBACK;
END //

DELIMITER ;


CALL ManageBooking(1, 'B001', '2023-11-09', 1, 'Cust001');






