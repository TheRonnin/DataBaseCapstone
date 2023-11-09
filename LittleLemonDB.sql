-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema LittleLemonDB
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema LittleLemonDB
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `LittleLemonDB` DEFAULT CHARACTER SET utf8 ;
-- -----------------------------------------------------
-- Schema little_lemon
-- -----------------------------------------------------
USE `LittleLemonDB` ;

-- -----------------------------------------------------
-- Table `LittleLemonDB`.`Customers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Customers` (
  `CustomerID` VARCHAR(45) NOT NULL,
  `CustomerName` VARCHAR(255) NOT NULL,
  `ContactDetail` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`CustomerID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `LittleLemonDB`.`Bookings`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Bookings` (
  `BookingID` VARCHAR(45) NOT NULL,
  `BookingDate` DATE NOT NULL,
  `TableNo` INT NOT NULL,
  `CustomerID` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`BookingID`),
  INDEX `customer_id fk_idx` (`CustomerID` ASC) VISIBLE,
  CONSTRAINT `customer_id fk`
    FOREIGN KEY (`CustomerID`)
    REFERENCES `LittleLemonDB`.`Customers` (`CustomerID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `LittleLemonDB`.`Staffs`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Staffs` (
  `StaffID` VARCHAR(45) NOT NULL,
  `StaffRole` VARCHAR(45) NOT NULL,
  `StaffSalary` DECIMAL NOT NULL,
  PRIMARY KEY (`StaffID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `LittleLemonDB`.`Deliveries`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Deliveries` (
  `DeliveryID` VARCHAR(45) NOT NULL,
  `DeliveryDate` DATE NOT NULL,
  `DeliveryStatus` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`DeliveryID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `LittleLemonDB`.`MenuItems`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`MenuItems` (
  `ItemID` VARCHAR(45) NOT NULL,
  `ItemName` VARCHAR(255) NOT NULL,
  `ItemType` VARCHAR(45) NOT NULL,
  `Price` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`ItemID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `LittleLemonDB`.`Menus`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Menus` (
  `MenuID` VARCHAR(45) NOT NULL,
  `Cuisine` VARCHAR(45) NOT NULL,
  `ItemID` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`MenuID`),
  INDEX `item_id fk_idx` (`ItemID` ASC) VISIBLE,
  CONSTRAINT `item_id fk`
    FOREIGN KEY (`ItemID`)
    REFERENCES `LittleLemonDB`.`MenuItems` (`ItemID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `LittleLemonDB`.`Orders`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `LittleLemonDB`.`Orders` (
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
    REFERENCES `LittleLemonDB`.`Bookings` (`BookingID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `staff_id fk`
    FOREIGN KEY (`StaffID`)
    REFERENCES `LittleLemonDB`.`Staffs` (`StaffID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `menu_id fk`
    FOREIGN KEY (`MenuID`)
    REFERENCES `LittleLemonDB`.`Menus` (`MenuID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `delivery_id fk`
    FOREIGN KEY (`DeliveryID`)
    REFERENCES `LittleLemonDB`.`Deliveries` (`DeliveryID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
