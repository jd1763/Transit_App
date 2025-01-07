package dao;

import model.Station;
import transit.DatabaseConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class StationDAO {

    // get a station by id
    public Station getStation(int stationID) {
        String query = "SELECT * FROM Stations WHERE stationID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, stationID);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return new Station(
                    rs.getInt("stationID"),
                    rs.getString("name"),
                    rs.getString("city"),
                    rs.getString("state")
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

 // Add a new station
    public boolean addStation(String name, String city, String state) {
        String checkQuery = "SELECT 1 FROM Stations WHERE LOWER(name) = LOWER(?) AND LOWER(city) = LOWER(?) AND LOWER(state) = LOWER(?)";
        String insertQuery = "INSERT INTO Stations (name, city, state) VALUES (?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement checkStmt = conn.prepareStatement(checkQuery)) {
            
            // Check if the station already exists (case-insensitive)
            checkStmt.setString(1, name);
            checkStmt.setString(2, city);
            checkStmt.setString(3, state);
            ResultSet rs = checkStmt.executeQuery();
            if (rs.next()) {
                return false; // Station already exists
            }

            // Insert the station if it doesn't exist
            try (PreparedStatement insertStmt = conn.prepareStatement(insertQuery)) {
                insertStmt.setString(1, name);
                insertStmt.setString(2, city);
                insertStmt.setString(3, state);
                return insertStmt.executeUpdate() > 0;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    
    // get all stations 
    public List<Station> getAllStations() {
        List<Station> stations = new ArrayList<>();
        String query = "SELECT * FROM Stations";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                stations.add(new Station(
                    rs.getInt("stationID"),
                    rs.getString("name"),
                    rs.getString("city"),
                    rs.getString("state")
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stations;
    }


}
