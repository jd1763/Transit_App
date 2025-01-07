drop database IF EXISTS transitDatabase;

-- Step 1: Create the database
CREATE DATABASE IF NOT EXISTS transitDatabase;
USE transitDatabase;

-- Step 2: Create the tables

-- Trains Table
CREATE TABLE IF NOT EXISTS Trains (
    trainID INT CHECK (trainID BETWEEN 1000 AND 9999) PRIMARY KEY
);

-- Stations Table
CREATE TABLE IF NOT EXISTS Stations (
    stationID INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100)
);

-- TransitLine Table
CREATE TABLE IF NOT EXISTS TransitLine (
    transitID INT PRIMARY KEY AUTO_INCREMENT,
    transitLineName VARCHAR(100) UNIQUE,
    baseFare FLOAT,
    totalStops INT
);

-- Customers Table
CREATE TABLE IF NOT EXISTS Customers (
    customerID INT PRIMARY KEY AUTO_INCREMENT,
    lastName VARCHAR(50),
    firstName VARCHAR(50),
    emailAddress VARCHAR(250) UNIQUE,
    username VARCHAR(40) UNIQUE,
    password VARCHAR(50)
);

-- Employees Table
CREATE TABLE IF NOT EXISTS Employees (
    employeeID INT PRIMARY KEY AUTO_INCREMENT,
    ssn VARCHAR(11) UNIQUE,
    lastName VARCHAR(50),
    firstName VARCHAR(50),
    username VARCHAR(40) UNIQUE,
    password VARCHAR(50),
    isAdmin BOOLEAN
);

-- Train_Schedules Table 
CREATE TABLE IF NOT EXISTS Train_Schedules (
    scheduleID INT PRIMARY KEY AUTO_INCREMENT,
    transitID INT,
    trainID INT,
    originID INT,
    destinationID INT,
    departureDateTime DATETIME,
    arrivalDateTime DATETIME,
    tripDirection ENUM('forward', 'return') NOT NULL, -- Added field to distinguish forward and return trips
    FOREIGN KEY (transitID) REFERENCES TransitLine(transitID),
    FOREIGN KEY (trainID) REFERENCES Trains(trainID),
    FOREIGN KEY (originID) REFERENCES Stations(stationID),
    FOREIGN KEY (destinationID) REFERENCES Stations(stationID)
);

-- Reservations Table
CREATE TABLE IF NOT EXISTS Reservations (
    reservationID INT PRIMARY KEY AUTO_INCREMENT, -- Unique ID for the reservation
    customerID INT NOT NULL,                               -- Customer making the reservation
    dateMade DATE NOT NULL,                       -- Date the reservation was created
    totalFare DECIMAL(10, 2) NOT NULL,            -- Total fare for the reservation
    FOREIGN KEY (customerID) REFERENCES Customers(customerID)
);

-- Tickets Table
CREATE TABLE IF NOT EXISTS Tickets (
    ticketID INT PRIMARY KEY AUTO_INCREMENT,
    reservationID INT,
    scheduleID INT,
    dateMade DATE,
    originID INT,
    destinationID INT,
    ticketType ENUM('adult', 'child', 'senior', 'disabled') NOT NULL,
    tripType ENUM('oneWay', 'roundTrip') NOT NULL,
    fare DECIMAL(10, 2) NOT NULL,
    linkedTicketID INT DEFAULT NULL, -- Link to the incoming ticket for round trips
    FOREIGN KEY (reservationID) REFERENCES Reservations(reservationID),
    FOREIGN KEY (scheduleID) REFERENCES Train_Schedules(scheduleID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (originID) REFERENCES Stations(stationID),
    FOREIGN KEY (destinationID) REFERENCES Stations(stationID),
    FOREIGN KEY (linkedTicketID) REFERENCES Tickets(ticketID) -- Self-referencing foreign key
);

-- Stops_At Table
CREATE TABLE IF NOT EXISTS Stops_At (
	stopsAtID INT PRIMARY KEY AUTO_INCREMENT,
    scheduleID INT,
    stationID INT,
    stopNumber INT,
    arrivalDateTime DATETIME,
    departureDateTime DATETIME,
    FOREIGN KEY (scheduleID) REFERENCES Train_Schedules(scheduleID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (stationID) REFERENCES Stations(stationID)
);

-- Table to store questions posted by customers with default status
CREATE TABLE IF NOT EXISTS QuestionPost (
    questionID INT AUTO_INCREMENT PRIMARY KEY,
    question TEXT NOT NULL,
    customerID INT,
    customerName VARCHAR(255),
    username VARCHAR(255),
    datePosted TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(225) DEFAULT 'unanswered',  -- Setting default status to 'unanswered'
    FOREIGN KEY (customerID) REFERENCES Customers(customerID)
);

-- Table to store replies or comments on questions
CREATE TABLE IF NOT EXISTS CommentReply (
    commentID INT AUTO_INCREMENT PRIMARY KEY,
    comment TEXT NOT NULL,
    customerID INT,
    employeeID INT,
    questionID INT, -- Direct reference to QuestionPost
    datePosted TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customerID) REFERENCES Customers(customerID),
    FOREIGN KEY (employeeID) REFERENCES Employees(employeeID) ON DELETE CASCADE,
    FOREIGN KEY (questionID) REFERENCES QuestionPost(questionID) -- Ensuring foreign key constraint
);

CREATE TABLE Schedule_Generation_Log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    last_generated_date DATE,
    days_generated INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);