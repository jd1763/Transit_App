package dao;

import model.StopsAt;
import transit.DatabaseConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class StopsAtDAO {

	public boolean addStop(StopsAt stop, int totalStops) {
	    String query = "INSERT INTO Stops_At (scheduleID, stationID, stopNumber, arrivalDateTime, departureDateTime) " +
	                   "VALUES (?, ?, ?, ?, ?)";
	    try (Connection conn = DatabaseConnection.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(query)) {
	        
	        stmt.setInt(1, stop.getScheduleID());
	        stmt.setInt(2, stop.getStationID());
	        stmt.setInt(3, stop.getStopNumber());

	        // For the first stop, set arrivalDateTime to NULL
	        if (stop.getStopNumber() == 1) {
	            stmt.setNull(4, java.sql.Types.TIMESTAMP);
	        } else {
	            stmt.setTimestamp(4, stop.getArrivalDateTime());
	        }

	        // For the last stop, set departureDateTime to NULL
	        if (stop.getStopNumber() == totalStops) {
	            stmt.setNull(5, java.sql.Types.TIMESTAMP);
	        } else {
	            stmt.setTimestamp(5, stop.getDepartureDateTime());
	        }

	        return stmt.executeUpdate() > 0;
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return false;
	}

	public boolean updateStops(int scheduleID, List<StopsAt> updatedStops) {
	    String deleteQuery = "DELETE FROM Stops_At WHERE scheduleID = ?";
	    String insertQuery = "INSERT INTO Stops_At (scheduleID, stationID, stopNumber, arrivalDateTime, departureDateTime) "
	                        + "VALUES (?, ?, ?, ?, ?)";

	    try (Connection conn = DatabaseConnection.getConnection();
	         PreparedStatement deleteStmt = conn.prepareStatement(deleteQuery);
	         PreparedStatement insertStmt = conn.prepareStatement(insertQuery)) {

	        // Step 1: Delete existing stops for the schedule
	        deleteStmt.setInt(1, scheduleID);
	        deleteStmt.executeUpdate();

	        // Step 2: Insert updated stops
	        for (StopsAt stop : updatedStops) {
	            insertStmt.setInt(1, stop.getScheduleID());
	            insertStmt.setInt(2, stop.getStationID());
	            insertStmt.setInt(3, stop.getStopNumber());
	            insertStmt.setTimestamp(4, stop.getArrivalDateTime());
	            insertStmt.setTimestamp(5, stop.getDepartureDateTime());
	            insertStmt.addBatch();
	        }
	        insertStmt.executeBatch();

	        return true; // If all operations succeed
	    } catch (SQLException e) {
	        e.printStackTrace();
	        return false; // If any exception occurs
	    }
	}

	public boolean addStops(List<StopsAt> stops) {
	    String query = "INSERT INTO Stops_At (scheduleID, stationID, stopNumber, arrivalDateTime, departureDateTime) "
	                 + "VALUES (?, ?, ?, ?, ?)";

	    try (Connection conn = DatabaseConnection.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(query)) {
	        
	        for (StopsAt stop : stops) {
	            stmt.setInt(1, stop.getScheduleID());
	            stmt.setInt(2, stop.getStationID());
	            stmt.setInt(3, stop.getStopNumber());
	            stmt.setTimestamp(4, stop.getArrivalDateTime());
	            stmt.setTimestamp(5, stop.getDepartureDateTime());

	            int rowsAffected = stmt.executeUpdate();
	            if (rowsAffected == 0) {
	                throw new SQLException("Failed to insert stop: " + stop.getStopNumber());
	            }
	        }
	        return true;
	    } catch (SQLException e) {
	        e.printStackTrace();
	        return false;
	    }
	}

	public int getTotalStopsForSchedule(int scheduleID) {
	    String query = "SELECT COUNT(*) FROM Stops_At WHERE scheduleID = ?";
	    try (Connection conn = DatabaseConnection.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(query)) {
	        stmt.setInt(1, scheduleID);
	        ResultSet rs = stmt.executeQuery();
	        if (rs.next()) {
	            return rs.getInt(1);
	        }
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return 0; // Default if no stops found
	}

    
    public List<StopsAt> getStopsByScheduleID(int scheduleID) {
        List<StopsAt> stops = new ArrayList<>();
        String query = "SELECT * FROM Stops_At WHERE scheduleID = ? ORDER BY stopNumber ASC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, scheduleID);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                stops.add(new StopsAt(
                    rs.getInt("scheduleID"),
                    rs.getInt("stationID"),
                    rs.getInt("stopNumber"),
                    rs.getTimestamp("arrivalDateTime"),
                    rs.getTimestamp("departureDateTime")
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stops;
    }

    public int getStopNumberForStation(int scheduleID, int stationID) {
        String query = "SELECT stopNumber FROM Stops_At WHERE scheduleID = ? AND stationID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, scheduleID);
            stmt.setInt(2, stationID);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("stopNumber");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1; // Default if stop number not found
    }

    public Date getArrivalTimeForStation(int scheduleID, int stationID) {
        String query = "SELECT arrivalDateTime FROM Stops_At WHERE scheduleID = ? AND stationID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, scheduleID);
            stmt.setInt(2, stationID);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getTimestamp("arrivalDateTime");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Date getDepartureTimeForStation(int scheduleID, int stationID) {
        String query = "SELECT departureDateTime FROM Stops_At WHERE scheduleID = ? AND stationID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, scheduleID);
            stmt.setInt(2, stationID);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getTimestamp("departureDateTime");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}









