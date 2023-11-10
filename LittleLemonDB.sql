-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema littlelemondb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema littlelemondb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `littlelemondb` DEFAULT CHARACTER SET utf8mb3 ;
USE `littlelemondb` ;

-- -----------------------------------------------------
-- Table `littlelemondb`.`customers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `littlelemondb`.`customers` (
  `CustomerID` VARCHAR(45) NOT NULL,
  `CustomerName` VARCHAR(255) NOT NULL,
  `ContactDetail` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`CustomerID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `littlelemondb`.`bookings`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `littlelemondb`.`bookings` (
  `BookingID` VARCHAR(45) NOT NULL,
  `BookingDate` DATE NOT NULL,
  `TableNo` INT NOT NULL,
  `CustomerID` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`BookingID`),
  INDEX `customer_id fk_idx` (`CustomerID` ASC) VISIBLE,
  CONSTRAINT `customer_id fk`
    FOREIGN KEY (`CustomerID`)
    REFERENCES `littlelemondb`.`customers` (`CustomerID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `littlelemondb`.`deliveries`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `littlelemondb`.`deliveries` (
  `DeliveryID` VARCHAR(45) NOT NULL,
  `DeliveryDate` DATE NOT NULL,
  `DeliveryStatus` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`DeliveryID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `littlelemondb`.`menuitems`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `littlelemondb`.`menuitems` (
  `ItemID` VARCHAR(45) NOT NULL,
  `ItemName` VARCHAR(255) NOT NULL,
  `ItemType` VARCHAR(45) NOT NULL,
  `Price` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`ItemID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `littlelemondb`.`menus`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `littlelemondb`.`menus` (
  `MenuID` VARCHAR(45) NOT NULL,
  `Cuisine` VARCHAR(45) NOT NULL,
  `ItemID` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`MenuID`),
  INDEX `item_id fk_idx` (`ItemID` ASC) VISIBLE,
  CONSTRAINT `item_id fk`
    FOREIGN KEY (`ItemID`)
    REFERENCES `littlelemondb`.`menuitems` (`ItemID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `littlelemondb`.`staffs`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `littlelemondb`.`staffs` (
  `StaffID` VARCHAR(45) NOT NULL,
  `StaffRole` VARCHAR(45) NOT NULL,
  `StaffSalary` DECIMAL(10,0) NOT NULL,
  PRIMARY KEY (`StaffID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `littlelemondb`.`orders`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `littlelemondb`.`orders` (
  `OrderID` VARCHAR(45) NOT NULL,
  `OrderDate` DATE NOT NULL,
  `BookingID` VARCHAR(45) NOT NULL,
  `StaffID` VARCHAR(45) NOT NULL,
  `MenuID` VARCHAR(45) NOT NULL,
  `DeliveryID` VARCHAR(45) NOT NULL,
  `Quantity` INT NOT NULL,
  `TotalCost` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`OrderID`),
  INDEX `booking_id fk_idx` (`BookingID` ASC) VISIBLE,
  INDEX `staff_id fk_idx` (`StaffID` ASC) VISIBLE,
  INDEX `menu_id fk_idx` (`MenuID` ASC) VISIBLE,
  INDEX `delivery_id fk_idx` (`DeliveryID` ASC) VISIBLE,
  CONSTRAINT `booking_id fk`
    FOREIGN KEY (`BookingID`)
    REFERENCES `littlelemondb`.`bookings` (`BookingID`),
  CONSTRAINT `delivery_id fk`
    FOREIGN KEY (`DeliveryID`)
    REFERENCES `littlelemondb`.`deliveries` (`DeliveryID`),
  CONSTRAINT `menu_id fk`
    FOREIGN KEY (`MenuID`)
    REFERENCES `littlelemondb`.`menus` (`MenuID`),
  CONSTRAINT `staff_id fk`
    FOREIGN KEY (`StaffID`)
    REFERENCES `littlelemondb`.`staffs` (`StaffID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

USE `littlelemondb` ;

-- -----------------------------------------------------
-- Placeholder table for view `littlelemondb`.`customerordersview`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `littlelemondb`.`customerordersview` (`CustomerID` INT, `CustomerName` INT, `OrderID` INT, `TotalCost` INT, `Cuisine` INT, `MenuItem` INT);

-- -----------------------------------------------------
-- Placeholder table for view `littlelemondb`.`popularmenuitems`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `littlelemondb`.`popularmenuitems` (`MenuID` INT, `Cuisine` INT, `ItemID` INT, `ItemName` INT, `OrderCount` INT);

-- -----------------------------------------------------
-- procedure AddValidBookings
-- -----------------------------------------------------

DELIMITER $$
USE `littlelemondb`$$
CREATE DEFINER=`littlelemon`@`localhost` PROCEDURE `AddValidBookings`(IN pBookingDate DATE, IN pTableNo INT)
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
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure CancelOrder
-- -----------------------------------------------------

DELIMITER $$
USE `littlelemondb`$$
CREATE DEFINER=`littlelemon`@`localhost` PROCEDURE `CancelOrder`(IN ID varchar(45) )
DELETE FROM Orders WHERE OrderID=ID$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure CheckBooking
-- -----------------------------------------------------

DELIMITER $$
USE `littlelemondb`$$
CREATE DEFINER=`littlelemon`@`localhost` PROCEDURE `CheckBooking`(IN checkBookingDate DATE, IN checkTableNo INT)
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
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure ManageBooking
-- -----------------------------------------------------

DELIMITER $$
USE `littlelemondb`$$
CREATE DEFINER=`littlelemon`@`localhost` PROCEDURE `ManageBooking`(
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
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure MaxOrder
-- -----------------------------------------------------

DELIMITER $$
USE `littlelemondb`$$
CREATE DEFINER=`littlelemon`@`localhost` PROCEDURE `MaxOrder`()
SELECT max(Quantity) FROM Orders$$

DELIMITER ;

-- -----------------------------------------------------
-- View `littlelemondb`.`customerordersview`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `littlelemondb`.`customerordersview`;
USE `littlelemondb`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`littlelemon`@`localhost` SQL SECURITY DEFINER VIEW `littlelemondb`.`customerordersview` AS select `c`.`CustomerID` AS `CustomerID`,`c`.`CustomerName` AS `CustomerName`,`o`.`OrderID` AS `OrderID`,`o`.`TotalCost` AS `TotalCost`,`m`.`Cuisine` AS `Cuisine`,`mi`.`ItemName` AS `MenuItem` from ((((`littlelemondb`.`customers` `c` join `littlelemondb`.`bookings` `b` on((`c`.`CustomerID` = `b`.`CustomerID`))) join `littlelemondb`.`orders` `o` on((`b`.`BookingID` = `o`.`BookingID`))) join `littlelemondb`.`menus` `m` on((`o`.`MenuID` = `m`.`MenuID`))) join `littlelemondb`.`menuitems` `mi` on((`m`.`ItemID` = `mi`.`ItemID`))) where ((`o`.`TotalCost` > 15) and (`mi`.`ItemType` = 'Main Course'));

-- -----------------------------------------------------
-- View `littlelemondb`.`popularmenuitems`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `littlelemondb`.`popularmenuitems`;
USE `littlelemondb`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`littlelemon`@`localhost` SQL SECURITY DEFINER VIEW `littlelemondb`.`popularmenuitems` AS select `m`.`MenuID` AS `MenuID`,`m`.`Cuisine` AS `Cuisine`,`mi`.`ItemID` AS `ItemID`,`mi`.`ItemName` AS `ItemName`,count(`o`.`OrderID`) AS `OrderCount` from ((`littlelemondb`.`menus` `m` join `littlelemondb`.`menuitems` `mi` on((`m`.`ItemID` = `mi`.`ItemID`))) left join `littlelemondb`.`orders` `o` on((`m`.`MenuID` = `o`.`MenuID`))) group by `m`.`MenuID`,`mi`.`ItemID`,`mi`.`ItemName`,`m`.`Cuisine` having (`OrderCount` > 2);

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
