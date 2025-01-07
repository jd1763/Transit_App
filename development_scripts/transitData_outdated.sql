-- Sample data for Customers
INSERT INTO Customers (customerID, lastName, firstName, emailAddress, username, password) VALUES
(1, 'Doe', 'John', 'johndoe@example.com', 'johndoe', '123'),
(2, 'Smith', 'Jane', 'janesmith@example.com', 'jane', '123'),
(3, 'Johnson', 'Mark', 'markjohnson@example.com', 'mark', '123');

-- Sample data for Employees
INSERT INTO Employees (employeeID, ssn, lastName, firstName, username, password, isAdmin) VALUES
(1, '123-45-6789', 'Johnson', 'Alice', 'alicejohnson', 'admin', TRUE),
(2, '987-65-4321', 'Brown', 'Bob', 'bobbrown', 'rep', FALSE);

-- Insert Trains
INSERT INTO Trains (trainID) VALUES
(1001), (1002), (1003), (1004), (1005), (1006), (1007), (1008), (1009), (1010), (1011);

-- Insert Stations
INSERT INTO Stations (stationID, name, city, state) VALUES
(1, 'Perth Amboy', 'Perth Amboy', 'NJ'),
(2, 'Woodbridge', 'Woodbridge', 'NJ'),
(3, 'Rahway', 'Rahway', 'NJ'),
(4, 'Elizabeth', 'Elizabeth', 'NJ'),
(5, 'Newark Penn', 'Newark', 'NJ'),
(6, 'Secaucus', 'Secaucus', 'NJ'),
(7, 'New York Penn', 'New York', 'NY'),
(8, 'Long Branch', 'Long Branch', 'NJ'),
(9, 'Asbury Park', 'Asbury Park', 'NJ'),
(10, 'Belmar', 'Belmar', 'NJ'),
(11, 'Point Pleasant', 'Point Pleasant', 'NJ'),
(12, 'Toms River', 'Toms River', 'NJ'),
(13, 'Atlantic City', 'Atlantic City', 'NJ');

-- Insert Transit Lines
INSERT INTO TransitLine (transitID, transitLineName, baseFare, totalStops) VALUES
(1, 'Northeast Corridor', 50.00, 7),
(2, 'Atlantic City Line', 30.00, 4),
(3, 'Jersey Shore Line', 40.00, 6);

-- Train_Schedules Table (including realistic forward and return trips) - remember each trains perform a specific route a unique transit line throughout the day
INSERT INTO Train_Schedules (scheduleID, transitID, trainID, originID, destinationID, departureDateTime, arrivalDateTime, tripDirection) VALUES
-- Northeast Corridor (transitID = 1) forward and return trips
(1000, 1, 1001, 1, 7, '2024-10-01 06:00:00', '2024-10-01 07:30:00', 'forward'),  -- Forward trip 1
(1001, 1, 1001, 7, 1, '2024-10-01 08:00:00', '2024-10-01 09:30:00', 'return'),   -- Return trip 1
(1002, 1, 1002, 1, 7, '2024-10-01 10:00:00', '2024-10-01 11:30:00', 'forward'),  -- Forward trip 2
(1003, 1, 1002, 7, 1, '2024-10-01 12:00:00', '2024-10-01 13:30:00', 'return'),   -- Return trip 2
(1004, 1, 1003, 1, 7, '2024-10-01 14:00:00', '2024-10-01 15:30:00', 'forward'),  -- Forward trip 3
(1005, 1, 1003, 7, 1, '2024-10-01 16:00:00', '2024-10-01 17:30:00', 'return'),   -- Return trip 3
-- Atlantic City Line (transitID = 2) forward and return trips
(2000, 2, 1004, 2, 5, '2024-10-01 07:00:00', '2024-10-01 08:15:00', 'forward'),  -- Forward trip 1
(2001, 2, 1004, 5, 2, '2024-10-01 09:00:00', '2024-10-01 10:15:00', 'return'),   -- Return trip 1
(2002, 2, 1005, 2, 5, '2024-10-01 11:00:00', '2024-10-01 12:15:00', 'forward'),  -- Forward trip 2
(2003, 2, 1005, 5, 2, '2024-10-01 13:00:00', '2024-10-01 14:15:00', 'return'),    -- Return trip 2

(3000, 3, 1006, 8, 13, '2024-10-01 05:30:00', '2024-10-01 07:10:00', 'forward'), -- Foward trip 1
(3001, 3, 1006, 13, 8, '2024-10-01 07:30:00', '2024-10-01 09:10:00', 'return'), -- Return trip 1
(3002, 3, 1007, 8, 13, '2024-10-01 10:00:00', '2024-10-01 11:40:00', 'forward'), -- Forward trip 2
(3003, 3, 1007, 13, 8, '2024-10-01 12:00:00', '2024-10-01 13:40:00', 'return'), -- Return trip 2
(3004, 3, 1008, 8, 13, '2024-10-01 15:00:00', '2024-10-01 17:40:00', 'forward'), -- Forward trip 3
(3005, 3, 1008, 13, 8, '2024-10-01 18:20:00', '2024-10-01 20:00:00', 'return');-- Return trip 3

-- Stops_At Data for Forward and Return trips

-- Stops for Northeast Corridor forward trip 1 (scheduleID 1000)
INSERT INTO Stops_At (scheduleID, stationID, stopNumber, arrivalDateTime, departureDateTime) VALUES
(1000, 1, 1, NULL, '2024-10-01 06:00:00'),
(1000, 2, 2, '2024-10-01 06:15:00', '2024-10-01 06:20:00'),
(1000, 3, 3, '2024-10-01 06:30:00', '2024-10-01 06:35:00'),
(1000, 4, 4, '2024-10-01 06:50:00', '2024-10-01 06:55:00'),
(1000, 5, 5, '2024-10-01 07:05:00', '2024-10-01 07:10:00'),
(1000, 6, 6, '2024-10-01 07:20:00', '2024-10-01 07:25:00'),
(1000, 7, 7, '2024-10-01 07:30:00', NULL);
-- Stops for Northeast Corridor return trip 1 (scheduleID 1001)
INSERT INTO Stops_At (scheduleID, stationID, stopNumber, arrivalDateTime, departureDateTime) VALUES
(1001, 7, 1, NULL, '2024-10-01 08:00:00'),
(1001, 6, 2, '2024-10-01 08:15:00', '2024-10-01 08:20:00'),
(1001, 5, 3, '2024-10-01 08:30:00', '2024-10-01 08:35:00'),
(1001, 4, 4, '2024-10-01 08:50:00', '2024-10-01 08:55:00'),
(1001, 3, 5, '2024-10-01 09:05:00', '2024-10-01 09:10:00'),
(1001, 2, 6, '2024-10-01 09:20:00', '2024-10-01 09:25:00'),
(1001, 1, 7, '2024-10-01 09:30:00', NULL);

-- Stops for Northeast Corridor forward trip 2 (scheduleID 1002)
INSERT INTO Stops_At (scheduleID, stationID, stopNumber, arrivalDateTime, departureDateTime) VALUES
(1002, 1, 1, NULL, '2024-10-01 10:00:00'),
(1002, 2, 2, '2024-10-01 10:15:00', '2024-10-01 10:20:00'),
(1002, 3, 3, '2024-10-01 10:30:00', '2024-10-01 10:35:00'),
(1002, 4, 4, '2024-10-01 10:50:00', '2024-10-01 10:55:00'),
(1002, 5, 5, '2024-10-01 11:05:00', '2024-10-01 11:10:00'),
(1002, 6, 6, '2024-10-01 11:20:00', '2024-10-01 11:25:00'),
(1002, 7, 7, '2024-10-01 11:30:00', NULL);
-- Stops for Northeast Corridor return trip 2 (scheduleID 1003)
INSERT INTO Stops_At (scheduleID, stationID, stopNumber, arrivalDateTime, departureDateTime) VALUES
(1003, 7, 1, NULL, '2024-10-01 12:00:00'),
(1003, 6, 2, '2024-10-01 12:15:00', '2024-10-01 12:20:00'),
(1003, 5, 3, '2024-10-01 12:30:00', '2024-10-01 12:35:00'),
(1003, 4, 4, '2024-10-01 12:50:00', '2024-10-01 12:55:00'),
(1003, 3, 5, '2024-10-01 13:05:00', '2024-10-01 13:10:00'),
(1003, 2, 6, '2024-10-01 13:20:00', '2024-10-01 13:25:00'),
(1003, 1, 7, '2024-10-01 13:30:00', NULL);

-- Stops for Northeast Corridor forward trip 3 (scheduleID 1004)
INSERT INTO Stops_At (scheduleID, stationID, stopNumber, arrivalDateTime, departureDateTime) VALUES
(1004, 1, 1, NULL, '2024-10-01 14:00:00'),
(1004, 2, 2, '2024-10-01 14:15:00', '2024-10-01 14:20:00'),
(1004, 3, 3, '2024-10-01 14:30:00', '2024-10-01 14:35:00'),
(1004, 4, 4, '2024-10-01 14:50:00', '2024-10-01 14:55:00'),
(1004, 5, 5, '2024-10-01 15:05:00', '2024-10-01 15:10:00'),
(1004, 6, 6, '2024-10-01 15:20:00', '2024-10-01 15:25:00'),
(1004, 7, 7, '2024-10-01 15:30:00', NULL);
-- Stops for Northeast Corridor return trip 3 (scheduleID 1005)
INSERT INTO Stops_At (scheduleID, stationID, stopNumber, arrivalDateTime, departureDateTime) VALUES
(1005, 7, 1, NULL, '2024-10-01 16:00:00'),
(1005, 6, 2, '2024-10-01 16:15:00', '2024-10-01 16:20:00'),
(1005, 5, 3, '2024-10-01 16:30:00', '2024-10-01 16:35:00'),
(1005, 4, 4, '2024-10-01 16:50:00', '2024-10-01 16:55:00'),
(1005, 3, 5, '2024-10-01 17:05:00', '2024-10-01 17:10:00'),
(1005, 2, 6, '2024-10-01 17:20:00', '2024-10-01 17:25:00'),
(1005, 1, 7, '2024-10-01 17:30:00', NULL);
-- Stops for Atlantic City Line forward trip 1 (scheduleID 2000)
INSERT INTO Stops_At (scheduleID, stationID, stopNumber, arrivalDateTime, departureDateTime) VALUES
(2000, 2, 1, NULL, '2024-10-01 07:00:00'),
(2000, 6, 2, '2024-10-01 07:15:00', '2024-10-01 07:20:00'),
(2000, 7, 3, '2024-10-01 07:30:00', '2024-10-01 07:35:00'),
(2000, 5, 4, '2024-10-01 07:45:00', NULL);
-- Stops for Atlantic City Line return trip 1 (scheduleID 2001)
INSERT INTO Stops_At (scheduleID, stationID, stopNumber, arrivalDateTime, departureDateTime) VALUES
(2001, 5, 1, NULL, '2024-10-01 09:00:00'),
(2001, 7, 2, '2024-10-01 09:15:00', '2024-10-01 09:20:00'),
(2001, 6, 3, '2024-10-01 09:30:00', '2024-10-01 09:35:00'),
(2001, 2, 4, '2024-10-01 09:45:00', NULL);
-- Stops for Atlantic City Line forward trip 2 (scheduleID 2002)
INSERT INTO Stops_At (scheduleID, stationID, stopNumber, arrivalDateTime, departureDateTime) VALUES
(2002, 2, 1, NULL, '2024-10-01 11:00:00'),
(2002, 6, 2, '2024-10-01 11:15:00', '2024-10-01 11:20:00'),
(2002, 7, 3, '2024-10-01 11:30:00', '2024-10-01 11:35:00'),
(2002, 5, 4, '2024-10-01 11:45:00', NULL);

-- Stops for Atlantic City Line return trip 2 (scheduleID 2003)
INSERT INTO Stops_At (scheduleID, stationID, stopNumber, arrivalDateTime, departureDateTime) VALUES
(2003, 5, 1, NULL, '2024-10-01 13:00:00'),
(2003, 7, 2, '2024-10-01 13:15:00', '2024-10-01 13:20:00'),
(2003, 6, 3, '2024-10-01 13:30:00', '2024-10-01 13:35:00'),
(2003, 2, 4, '2024-10-01 13:45:00', NULL);
-- Stops for Train Schedule 3000
INSERT INTO Stops_At (scheduleID, stationID, stopNumber, arrivalDateTime, departureDateTime) VALUES
(3000, 8, 1, NULL, '2024-10-01 05:30:00'),
(3000, 9, 2, '2024-10-01 05:50:00', '2024-10-01 05:55:00'),
(3000, 10, 3, '2024-10-01 06:10:00', '2024-10-01 06:15:00'),
(3000, 11, 4, '2024-10-01 06:30:00', '2024-10-01 06:35:00'),
(3000, 12, 5, '2024-10-01 06:50:00', '2024-10-01 06:55:00'),
(3000, 13, 6, '2024-10-01 7:10:00', NULL);
-- Stops for Train Schedule 3001
INSERT INTO Stops_At (scheduleID, stationID, stopNumber, arrivalDateTime, departureDateTime) VALUES
(3001, 13, 1, NULL, '2024-10-01 07:30:00'),
(3001, 12, 2, '2024-10-01 07:50:00', '2024-10-01 07:55:00'),
(3001, 11, 3, '2024-10-01 08:10:00', '2024-10-01 08:15:00'),
(3001, 10, 4, '2024-10-01 08:30:00', '2024-10-01 08:35:00'),
(3001, 9, 5, '2024-10-01 08:50:00', '2024-10-01 08:55:00'),
(3001, 8, 6, '2024-10-01 09:10:00', NULL);
-- Stops for Train Schedule 3002
INSERT INTO Stops_At (scheduleID, stationID, stopNumber, arrivalDateTime, departureDateTime) VALUES
(3002, 8, 1, NULL, '2024-10-01 10:00:00'),
(3002, 9, 2, '2024-10-01 10:20:00', '2024-10-01 10:25:00'),
(3002, 10, 3, '2024-10-01 10:40:00', '2024-10-01 10:45:00'),
(3002, 11, 4, '2024-10-01 11:00:00', '2024-10-01 11:05:00'),
(3002, 12, 5, '2024-10-01 11:20:00', '2024-10-01 11:25:00'),
(3002, 13, 6, '2024-10-01 11:40:00', NULL);
-- Stops for Train Schedule 3003
INSERT INTO Stops_At (scheduleID, stationID, stopNumber, arrivalDateTime, departureDateTime) VALUES
(3003, 13, 1, NULL, '2024-10-01 12:00:00'),
(3003, 12, 2, '2024-10-01 12:20:00', '2024-10-01 12:25:00'),
(3003, 11, 3, '2024-10-01 12:40:00', '2024-10-01 12:45:00'),
(3003, 10, 4, '2024-10-01 13:00:00', '2024-10-01 13:05:00'),
(3003, 9, 5, '2024-10-01 13:20:00', '2024-10-01 13:25:00'),
(3003, 8, 6, '2024-10-01 13:40:00', NULL);
-- Stops for Train Schedule 3004
INSERT INTO Stops_At (scheduleID, stationID, stopNumber, arrivalDateTime, departureDateTime) VALUES
(3004, 8, 1, NULL, '2024-10-01 15:00:00'),
(3004, 9, 2, '2024-10-01 15:20:00', '2024-10-01 15:25:00'),
(3004, 10, 3, '2024-10-01 15:40:00', '2024-10-01 15:45:00'),
(3004, 11, 4, '2024-10-01 16:00:00', '2024-10-01 16:05:00'),
(3004, 12, 5, '2024-10-01 17:20:00', '2024-10-01 17:25:00'),
(3004, 13, 6, '2024-10-01 17:40:00', NULL);
-- Stops for Train Schedule 3005
INSERT INTO Stops_At (scheduleID, stationID, stopNumber, arrivalDateTime, departureDateTime) VALUES
(3005, 13, 1, NULL, '2024-10-01 18:20:00'),
(3005, 12, 2, '2024-10-01 18:40:00', '2024-10-01 19:45:00'),
(3005, 11, 3, '2024-10-01 19:00:00', '2024-10-01 19:05:00'),
(3005, 10, 4, '2024-10-01 19:20:00', '2024-10-01 14:25:00'),
(3005, 9, 5, '2024-10-01 19:40:00', '2024-10-01 19:45:00'),
(3005, 8, 6, '2024-10-01 20:00:00', NULL);

INSERT INTO Reservations (reservationID, customerID, dateMade, totalFare) VALUES
(1, 1, '2024-11-13', 87.75),
(2, 1, '2024-11-13', 33.34);

INSERT INTO Tickets (ticketID, reservationID, scheduleID, dateMade, originID, destinationID, ticketType, tripType, fare, linkedTicketID) VALUES
(1, 1, 2000, '2024-10-01', 2, 5, 'adult', 'roundTrip', 22.50, NULL), -- incoming
(2, 1, 2003, '2024-10-01', 5, 2, 'adult', 'roundTrip', 22.50, 1), -- return
(3, 1, 2000, '2024-10-01', 2, 5, 'child', 'oneWay', 16.88, NULL), -- oneway/standalone
(4, 1, 2000, '2024-10-01', 2, 5, 'senior', 'oneWay', 14.63, NULL), -- oneway/standalone
(5, 1, 2000, '2024-10-01', 2, 5, 'disabled', 'oneWay', 11.25, NULL), -- oneway/standalone

(6, 2, 1000, '2024-10-01', 2, 4, 'adult', 'roundTrip', 22.50, NULL), -- incoming
(7, 2, 1001, '2024-10-01', 4, 2, 'adult', 'roundTrip', 22.50, 6); -- return

