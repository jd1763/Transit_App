-- Step 1: Determine the current maximum scheduleID
SET @currentMaxScheduleID = IFNULL((SELECT MAX(scheduleID) FROM Train_Schedules), 0);

-- Step 2: Populate Train Schedules for the next 14 days
INSERT INTO Train_Schedules (scheduleID, transitID, trainID, originID, destinationID, departureDateTime, arrivalDateTime, tripDirection)
SELECT
    (@currentMaxScheduleID + (base_schedule.scheduleID * 100) + day_offset) AS scheduleID, -- Unique scheduleID
    base_schedule.transitID,
    base_schedule.trainID,
    base_schedule.originID,
    base_schedule.destinationID,
    DATE_ADD(base_schedule.departureDateTime, INTERVAL day_offset DAY) AS departureDateTime,
    DATE_ADD(base_schedule.arrivalDateTime, INTERVAL day_offset DAY) AS arrivalDateTime,
    base_schedule.tripDirection
FROM (
    -- Base schedule for one day, adjusted to start from current date
    SELECT
        1000 AS scheduleID, 1 AS transitID, 1001 AS trainID, 1 AS originID, 7 AS destinationID,
        CONCAT(CURDATE(), ' 06:00:00') AS departureDateTime, CONCAT(CURDATE(), ' 07:30:00') AS arrivalDateTime, 'forward' AS tripDirection
    UNION ALL
    SELECT 1001, 1, 1001, 7, 1, CONCAT(CURDATE(), ' 08:00:00'), CONCAT(CURDATE(), ' 09:30:00'), 'return'
    UNION ALL
    SELECT 1002, 1, 1002, 1, 7, CONCAT(CURDATE(), ' 10:00:00'), CONCAT(CURDATE(), ' 11:30:00'), 'forward'
    UNION ALL
    SELECT 1003, 1, 1002, 7, 1, CONCAT(CURDATE(), ' 12:00:00'), CONCAT(CURDATE(), ' 13:30:00'), 'return'
    UNION ALL
    SELECT 1004, 1, 1003, 1, 7, CONCAT(CURDATE(), ' 14:00:00'), CONCAT(CURDATE(), ' 15:30:00'), 'forward'
    UNION ALL
    SELECT 1005, 1, 1003, 7, 1, CONCAT(CURDATE(), ' 16:00:00'), CONCAT(CURDATE(), ' 17:30:00'), 'return'
    UNION ALL
    SELECT
        2000 AS scheduleID, 2 AS transitID, 1004 AS trainID, 2 AS originID, 5 AS destinationID,
        CONCAT(CURDATE(), ' 07:00:00') AS departureDateTime, CONCAT(CURDATE(), ' 08:15:00') AS arrivalDateTime, 'forward' AS tripDirection
    UNION ALL
    SELECT 2001, 2, 1004, 5, 2, CONCAT(CURDATE(), ' 09:00:00'), CONCAT(CURDATE(), ' 10:15:00'), 'return'
    UNION ALL
    SELECT 2002, 2, 1005, 2, 5, CONCAT(CURDATE(), ' 11:00:00'), CONCAT(CURDATE(), ' 12:15:00'), 'forward'
    UNION ALL
    SELECT 2003, 2, 1005, 5, 2, CONCAT(CURDATE(), ' 13:00:00'), CONCAT(CURDATE(), ' 14:15:00'), 'return'
    UNION ALL
    SELECT
        3000 AS scheduleID, 3 AS transitID, 1006 AS trainID, 8 AS originID, 13 AS destinationID,
        CONCAT(CURDATE(), ' 05:30:00') AS departureDateTime, CONCAT(CURDATE(), ' 07:10:00') AS arrivalDateTime, 'forward' AS tripDirection
    UNION ALL
    SELECT 3001, 3, 1006, 13, 8, CONCAT(CURDATE(), ' 07:30:00'), CONCAT(CURDATE(), ' 09:10:00'), 'return'
    UNION ALL
    SELECT 3002, 3, 1007, 8, 13, CONCAT(CURDATE(), ' 10:00:00'), CONCAT(CURDATE(), ' 11:40:00'), 'forward'
    UNION ALL
    SELECT 3003, 3, 1007, 13, 8, CONCAT(CURDATE(), ' 12:00:00'), CONCAT(CURDATE(), ' 13:40:00'), 'return'
    UNION ALL
    SELECT 3004, 3, 1008, 8, 13, CONCAT(CURDATE(), ' 15:00:00'), CONCAT(CURDATE(), ' 17:40:00'), 'forward'
    UNION ALL
    SELECT 3005, 3, 1008, 13, 8, CONCAT(CURDATE(), ' 18:20:00'), CONCAT(CURDATE(), ' 20:00:00'), 'return'
) base_schedule
-- Generate day offsets for 14 days starting from the current date
CROSS JOIN (
    WITH RECURSIVE day_offsets AS (
        SELECT 0 AS day_offset
        UNION ALL
        SELECT day_offset + 1
        FROM day_offsets
        WHERE day_offset + 1 < 14 -- Generate for 14 days
    )
    SELECT day_offset
    FROM day_offsets
) dates
-- Avoid inserting duplicate schedules
WHERE NOT EXISTS (
    SELECT 1
    FROM Train_Schedules ts
    WHERE ts.transitID = base_schedule.transitID
      AND ts.originID = base_schedule.originID
      AND ts.destinationID = base_schedule.destinationID
      AND ts.departureDateTime = DATE_ADD(base_schedule.departureDateTime, INTERVAL day_offset DAY)
);

-- Step 4: insert stops at data
INSERT INTO Stops_At (scheduleID, stationID, stopNumber, arrivalDateTime, departureDateTime)
SELECT
    sa.scheduleID,
    sa.stationID,
    sa.stopNumber,
    sa.arrivalDateTime,
    sa.departureDateTime
FROM (
    SELECT
		-- Create unique scheduleID by adding day_offset
		(@currentMaxScheduleID + (base_schedule.scheduleID * 100) + day_offset) AS scheduleID, -- Unique scheduleID
		base_schedule.stationID,
		base_schedule.stopNumber,
		DATE_ADD(base_schedule.arrivalDateTime, INTERVAL day_offset DAY) AS arrivalDateTime,
		DATE_ADD(base_schedule.departureDateTime, INTERVAL day_offset DAY) AS departureDateTime
	FROM (
		-- Base stops for each trip (forward and return) with original scheduleID, stationID, and stop information
		SELECT
			1000 AS scheduleID, 1 AS stationID, 1 AS stopNumber, NULL AS arrivalDateTime, CONCAT(CURDATE(), ' 06:00:00') AS departureDateTime
		UNION ALL
		SELECT 1000, 2, 2, CONCAT(CURDATE(), ' 06:15:00'), CONCAT(CURDATE(), ' 06:20:00')
		UNION ALL
		SELECT 1000, 3, 3, CONCAT(CURDATE(), ' 06:30:00'), CONCAT(CURDATE(), ' 06:35:00')
		UNION ALL
		SELECT 1000, 4, 4, CONCAT(CURDATE(), ' 06:50:00'), CONCAT(CURDATE(), ' 06:55:00')
		UNION ALL
		SELECT 1000, 5, 5, CONCAT(CURDATE(), ' 07:05:00'), CONCAT(CURDATE(), ' 07:10:00')
		UNION ALL
		SELECT 1000, 6, 6, CONCAT(CURDATE(), ' 07:20:00'), CONCAT(CURDATE(), ' 07:25:00')
		UNION ALL
		SELECT 1000, 7, 7, CONCAT(CURDATE(), ' 07:30:00'), NULL
		UNION ALL
		
		SELECT 1001, 7, 1, NULL, CONCAT(CURDATE(), ' 08:00:00')
		UNION ALL
		SELECT 1001, 6, 2, CONCAT(CURDATE(), ' 08:15:00'), CONCAT(CURDATE(), ' 08:20:00')
		UNION ALL
		SELECT 1001, 5, 3, CONCAT(CURDATE(), ' 08:30:00'), CONCAT(CURDATE(), ' 08:35:00')
		UNION ALL
		SELECT 1001, 4, 4, CONCAT(CURDATE(), ' 08:50:00'), CONCAT(CURDATE(), ' 08:55:00')
		UNION ALL
		SELECT 1001, 3, 5, CONCAT(CURDATE(), ' 09:05:00'), CONCAT(CURDATE(), ' 09:10:00')
		UNION ALL
		SELECT 1001, 2, 6, CONCAT(CURDATE(), ' 09:20:00'), CONCAT(CURDATE(), ' 09:25:00')
		UNION ALL
		SELECT 1001, 1, 7, CONCAT(CURDATE(), ' 09:30:00'), NULL
		
		UNION ALL
		SELECT 1002, 1, 1, NULL, CONCAT(CURDATE(), ' 10:00:00')
		UNION ALL
		SELECT 1002, 2, 2, CONCAT(CURDATE(), ' 10:15:00'), CONCAT(CURDATE(), ' 10:20:00')
		UNION ALL
		SELECT 1002, 3, 3, CONCAT(CURDATE(), ' 10:30:00'), CONCAT(CURDATE(), ' 10:35:00')
		UNION ALL
		SELECT 1002, 4, 4, CONCAT(CURDATE(), ' 10:50:00'), CONCAT(CURDATE(), ' 10:55:00')
		UNION ALL
		SELECT 1002, 5, 5, CONCAT(CURDATE(), ' 11:05:00'), CONCAT(CURDATE(), ' 11:10:00')
		UNION ALL
		SELECT 1002, 6, 6, CONCAT(CURDATE(), ' 11:20:00'), CONCAT(CURDATE(), ' 11:25:00')
		UNION ALL
		SELECT 1002, 7, 7, CONCAT(CURDATE(), ' 11:30:00'), NULL
		
		UNION ALL
		SELECT 1003, 7, 1, NULL, CONCAT(CURDATE(), ' 12:00:00')
		UNION ALL
		SELECT 1003, 6, 2, CONCAT(CURDATE(), ' 12:15:00'), CONCAT(CURDATE(), ' 12:20:00')
		UNION ALL
		SELECT 1003, 5, 3, CONCAT(CURDATE(), ' 12:30:00'), CONCAT(CURDATE(), ' 12:35:00')
		UNION ALL
		SELECT 1003, 4, 4, CONCAT(CURDATE(), ' 12:50:00'), CONCAT(CURDATE(), ' 12:55:00')
		UNION ALL
		SELECT 1003, 3, 5, CONCAT(CURDATE(), ' 13:05:00'), CONCAT(CURDATE(), ' 13:10:00')
		UNION ALL
		SELECT 1003, 2, 6, CONCAT(CURDATE(), ' 13:20:00'), CONCAT(CURDATE(), ' 13:25:00')
		UNION ALL
		SELECT 1003, 1, 7, CONCAT(CURDATE(), ' 13:30:00'), NULL

		UNION ALL
		SELECT 1004, 1, 1, NULL, CONCAT(CURDATE(), ' 14:00:00')
		UNION ALL
		SELECT 1004, 2, 2, CONCAT(CURDATE(), ' 14:15:00'), CONCAT(CURDATE(), ' 14:20:00')
		UNION ALL
		SELECT 1004, 3, 3, CONCAT(CURDATE(), ' 14:30:00'), CONCAT(CURDATE(), ' 14:35:00')
		UNION ALL
		SELECT 1004, 4, 4, CONCAT(CURDATE(), ' 14:50:00'), CONCAT(CURDATE(), ' 14:55:00')
		UNION ALL
		SELECT 1004, 5, 5, CONCAT(CURDATE(), ' 15:05:00'), CONCAT(CURDATE(), ' 15:10:00')
		UNION ALL
		SELECT 1004, 6, 6, CONCAT(CURDATE(), ' 15:20:00'), CONCAT(CURDATE(), ' 15:25:00')
		UNION ALL
		SELECT 1004, 7, 7, CONCAT(CURDATE(), ' 15:30:00'), NULL
		
		UNION ALL
		SELECT 1005, 7, 1, NULL, CONCAT(CURDATE(), ' 16:00:00')
		UNION ALL
		SELECT 1005, 6, 2, CONCAT(CURDATE(), ' 16:15:00'), CONCAT(CURDATE(), ' 16:20:00')
		UNION ALL
		SELECT 1005, 5, 3, CONCAT(CURDATE(), ' 16:30:00'), CONCAT(CURDATE(), ' 16:35:00')
		UNION ALL
		SELECT 1005, 4, 4, CONCAT(CURDATE(), ' 16:50:00'), CONCAT(CURDATE(), ' 16:55:00')
		UNION ALL
		SELECT 1005, 3, 5, CONCAT(CURDATE(), ' 17:05:00'), CONCAT(CURDATE(), ' 17:10:00')
		UNION ALL
		SELECT 1005, 2, 6, CONCAT(CURDATE(), ' 17:20:00'), CONCAT(CURDATE(), ' 17:25:00')
		UNION ALL
		SELECT 1005, 1, 7, CONCAT(CURDATE(), ' 17:30:00'), NULL
		
		UNION ALL
		SELECT 2000, 2, 1, NULL, CONCAT(CURDATE(), ' 07:00:00')
		UNION ALL
		SELECT 2000, 6, 2, CONCAT(CURDATE(), ' 07:15:00'), CONCAT(CURDATE(), ' 07:20:00')
		UNION ALL
		SELECT 2000, 7, 3, CONCAT(CURDATE(), ' 07:30:00'), CONCAT(CURDATE(), ' 07:35:00')
		UNION ALL
		SELECT 2000, 5, 4, CONCAT(CURDATE(), ' 07:45:00'), NULL
		
		UNION ALL
		SELECT 2001, 5, 1, NULL, CONCAT(CURDATE(), ' 09:00:00')
		UNION ALL
		SELECT 2001, 7, 2, CONCAT(CURDATE(), ' 09:15:00'), CONCAT(CURDATE(), ' 09:20:00')
		UNION ALL
		SELECT 2001, 6, 3, CONCAT(CURDATE(), ' 09:30:00'), CONCAT(CURDATE(), ' 09:35:00')
		UNION ALL
		SELECT 2001, 2, 4, CONCAT(CURDATE(), ' 09:45:00'), NULL
		
		UNION ALL
		SELECT 2002, 2, 1, NULL, CONCAT(CURDATE(), ' 11:00:00')
		UNION ALL
		SELECT 2002, 6, 2, CONCAT(CURDATE(), ' 11:15:00'), CONCAT(CURDATE(), ' 11:20:00')
		UNION ALL
		SELECT 2002, 7, 3, CONCAT(CURDATE(), ' 11:30:00'), CONCAT(CURDATE(), ' 11:35:00')
		UNION ALL
		SELECT 2002, 5, 4, CONCAT(CURDATE(), ' 11:45:00'), NULL

		UNION ALL
		SELECT 2003, 5, 1, NULL, CONCAT(CURDATE(), ' 13:00:00')
		UNION ALL
		SELECT 2003, 7, 2, CONCAT(CURDATE(), ' 13:15:00'), CONCAT(CURDATE(), ' 13:20:00')
		UNION ALL
		SELECT 2003, 6, 3, CONCAT(CURDATE(), ' 13:30:00'), CONCAT(CURDATE(), ' 13:35:00')
		UNION ALL
		SELECT 2003, 2, 4, CONCAT(CURDATE(), ' 13:45:00'), NULL    
		
		UNION ALL
		SELECT 3000, 8, 1, NULL, CONCAT(CURDATE(), ' 05:30:00')
		UNION ALL
		SELECT 3000, 9, 2, CONCAT(CURDATE(), ' 05:50:00'), CONCAT(CURDATE(), ' 05:55:00')
		UNION ALL
		SELECT 3000, 10, 3, CONCAT(CURDATE(), ' 06:10:00'), CONCAT(CURDATE(), ' 06:15:00')
		UNION ALL
		SELECT 3000, 11, 4, CONCAT(CURDATE(), ' 06:30:00'), CONCAT(CURDATE(), ' 06:35:00')
		UNION ALL
		SELECT 3000, 12, 5, CONCAT(CURDATE(), ' 06:50:00'), CONCAT(CURDATE(), ' 06:55:00')
		UNION ALL
		SELECT 3000, 13, 6, '2024-10-01 7:10:00', NULL
		
		UNION ALL
		SELECT 3001, 13 , 1 , NULL, CONCAT(CURDATE(), ' 07:30:00')
		UNION ALL
		SELECT 3001, 12, 2, CONCAT(CURDATE(), ' 07:50:00'), CONCAT(CURDATE(), ' 07:55:00')
		UNION ALL
		SELECT 3001, 11, 3, CONCAT(CURDATE(), ' 08:10:00'), CONCAT(CURDATE(), ' 08:15:00')
		UNION ALL
		SELECT 3001, 10, 4, CONCAT(CURDATE(), ' 08:30:00'), CONCAT(CURDATE(), ' 08:35:00')
		UNION ALL
		SELECT 3001, 9, 5, CONCAT(CURDATE(), ' 08:50:00'), CONCAT(CURDATE(), ' 08:55:00')
		UNION ALL
		SELECT 3001, 8, 6, CONCAT(CURDATE(), ' 09:10:00'), NULL

		UNION ALL
		SELECT 3002, 8, 1, NULL, CONCAT(CURDATE(), ' 10:00:00')
		UNION ALL
		SELECT 3002, 9, 2, CONCAT(CURDATE(), ' 10:20:00'), CONCAT(CURDATE(), ' 10:25:00')
		UNION ALL
		SELECT 3002, 10, 3, CONCAT(CURDATE(), ' 10:40:00'), CONCAT(CURDATE(), ' 10:45:00')
		UNION ALL
		SELECT 3002, 11, 4, CONCAT(CURDATE(), ' 11:00:00'), CONCAT(CURDATE(), ' 11:05:00')
		UNION ALL
		SELECT 3002, 12, 5, CONCAT(CURDATE(), ' 11:20:00'), CONCAT(CURDATE(), ' 11:25:00')
		UNION ALL
		SELECT 3002, 13, 6, CONCAT(CURDATE(), ' 11:40:00'), NULL
		UNION ALL
		SELECT 3003, 13, 1, NULL, CONCAT(CURDATE(), ' 12:00:00')
		UNION ALL
		SELECT 3003, 12, 2, CONCAT(CURDATE(), ' 12:20:00'), CONCAT(CURDATE(), ' 12:25:00')
		UNION ALL
		SELECT 3003, 11, 3, CONCAT(CURDATE(), ' 12:40:00'), CONCAT(CURDATE(), ' 12:45:00')
		UNION ALL
		SELECT 3003, 10, 4, CONCAT(CURDATE(), ' 13:00:00'), CONCAT(CURDATE(), ' 13:05:00')
		UNION ALL
		SELECT 3003, 9, 5, CONCAT(CURDATE(), ' 13:20:00'), CONCAT(CURDATE(), ' 13:25:00')
		UNION ALL
		SELECT 3003, 8, 6, CONCAT(CURDATE(), ' 13:40:00'), NULL
		
		UNION ALL
		SELECT 3004, 8, 1, NULL, CONCAT(CURDATE(), ' 15:00:00')
		UNION ALL
		SELECT 3004, 9, 2, CONCAT(CURDATE(), ' 15:20:00'), CONCAT(CURDATE(), ' 15:25:00')
		UNION ALL
		SELECT 3004, 10, 3, CONCAT(CURDATE(), ' 15:40:00'), CONCAT(CURDATE(), ' 15:45:00')
		UNION ALL
		SELECT 3004, 11, 4, CONCAT(CURDATE(), ' 16:00:00'), CONCAT(CURDATE(), ' 16:05:00')
		UNION ALL
		SELECT 3004, 12, 5, CONCAT(CURDATE(), ' 17:20:00'), CONCAT(CURDATE(), ' 17:25:00')
		UNION ALL
		SELECT 3004, 12, 6, CONCAT(CURDATE(), ' 17:40:00'), NULL
		
		UNION ALL
		SELECT 3005, 13, 1, NULL, CONCAT(CURDATE(), ' 18:20:00')
		UNION ALL
		SELECT 3005, 12, 2, CONCAT(CURDATE(), ' 18:40:00'), CONCAT(CURDATE(), ' 19:45:00')
		UNION ALL
		SELECT 3005, 11, 3, CONCAT(CURDATE(), ' 19:00:00'), CONCAT(CURDATE(), ' 19:05:00')
		UNION ALL
		SELECT 3005, 10, 4, CONCAT(CURDATE(), ' 19:20:00'), CONCAT(CURDATE(), ' 14:25:00')
		UNION ALL
		SELECT 3005, 9, 5, CONCAT(CURDATE(), ' 19:40:00'), CONCAT(CURDATE(), ' 19:45:00')
		UNION ALL
		SELECT 3005, 8, 6, CONCAT(CURDATE(), ' 20:00:00'), NULL
	) base_schedule
	-- Generate valid days for 14 days starting from the current date
	CROSS JOIN (
		WITH RECURSIVE day_offsets AS (
			SELECT 0 AS day_offset
			UNION ALL
			SELECT day_offset + 1
			FROM day_offsets
			WHERE day_offset + 1 < 14 -- Generate for 14 days
		)
		SELECT day_offset
		FROM day_offsets
	) dates
) sa
-- Ensure only valid scheduleIDs are inserted
WHERE EXISTS (
    SELECT 1
    FROM Train_Schedules ts
    WHERE ts.scheduleID = sa.scheduleID
);