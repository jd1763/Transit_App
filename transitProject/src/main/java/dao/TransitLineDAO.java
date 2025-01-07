package dao;

import model.TransitLine;
import transit.DatabaseConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class TransitLineDAO {
    
	public String getTransitLineName(int transitID) {
	    String query = "SELECT transitLineName FROM TransitLine WHERE transitID = ?";
	    try (Connection conn = DatabaseConnection.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(query)) {
	        stmt.setInt(1, transitID);
	        ResultSet rs = stmt.executeQuery();
	        if (rs.next()) {
	            return rs.getString("transitLineName");
	        }
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return "Unknown";
	}

	    
    public TransitLine getTransitLine(int transitID) {
        String query = "SELECT * FROM TransitLine WHERE transitID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, transitID);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return new TransitLine(
                    rs.getInt("transitID"),
                    rs.getString("transitLineName"),
                    rs.getFloat("baseFare"),
                    rs.getInt("totalStops")
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    public float getBaseFareByTransitID(int transitID) {
        String query = "SELECT baseFare FROM TransitLine WHERE transitID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, transitID);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getFloat("baseFare");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    public int getTotalStops(int transitID) {
        String query = "SELECT totalStops FROM TransitLine WHERE transitID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, transitID);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("totalStops");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0; // Default if no stops found
    }
    
    public List<String> getAllTransitLineNames() {
        List<String> transitLines = new ArrayList<>();
        String query = "SELECT transitLineName FROM TransitLine ORDER BY transitLineName";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                transitLines.add(rs.getString("transitLineName"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return transitLines;
    }

    // Fetch unused transit lines
    public List<TransitLine> getUnusedTransitLines() {
        List<TransitLine> unusedTransitLines = new ArrayList<>();
        String query = "SELECT tl.transitID, tl.transitLineName, tl.baseFare, tl.totalStops "
                     + "FROM TransitLine tl "
                     + "LEFT JOIN Train_Schedules ts ON tl.transitID = ts.transitID "
                     + "WHERE ts.transitID IS NULL";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                unusedTransitLines.add(new TransitLine(
                    rs.getInt("transitID"),
                    rs.getString("transitLineName"),
                    rs.getFloat("baseFare"),
                    rs.getInt("totalStops")
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return unusedTransitLines;
    }

 // Add a new transit line
    public boolean addTransitLine(String name, float baseFare, int totalStops) {
        String query = "INSERT INTO TransitLine (transitLineName, baseFare, totalStops) VALUES (?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, name);
            stmt.setFloat(2, baseFare);
            stmt.setInt(3, totalStops);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Method to fetch all transit lines
    public List<TransitLine> getAllTransitLines() {
        List<TransitLine> transitLines = new ArrayList<>();
        String query = "SELECT * FROM TransitLine";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                TransitLine transitLine = new TransitLine(
                    rs.getInt("transitID"),
                    rs.getString("transitLineName"),
                    rs.getFloat("baseFare"),
                    rs.getInt("totalStops")
                );
                transitLines.add(transitLine);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return transitLines;
    }
}


