package dao;

import model.Reservation;
import transit.DatabaseConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReservationDAO {

    // Create a new reservation
    public int createReservation(Reservation reservation) {
        String sql = "INSERT INTO Reservations (customerID, dateMade, totalFare) VALUES (?, ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, reservation.getCustomerID());
            stmt.setDate(2, new java.sql.Date(reservation.getDateMade().getTime()));
            stmt.setBigDecimal(3, reservation.getTotalFare());

            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected > 0) {
                ResultSet rs = stmt.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1); // Return the generated reservation ID
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1; // Indicates failure
    }

    // Retrieve reservations by customer ID
    public List<Reservation> getReservationsByCustomerID(int customerID) {
        List<Reservation> reservations = new ArrayList<>();
        String sql = "SELECT * FROM Reservations WHERE customerID = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, customerID);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Reservation reservation = new Reservation(
                    rs.getInt("reservationID"),
                    rs.getInt("customerID"),
                    rs.getDate("dateMade"),
                    rs.getBigDecimal("totalFare")
                );
                reservations.add(reservation);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reservations;
    }

    // Update total fare for a reservation
    public boolean updateReservationTotalFare(int reservationID, BigDecimal totalFare) {
        String sql = "UPDATE Reservations SET totalFare = ? WHERE reservationID = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setBigDecimal(1, totalFare);
            stmt.setInt(2, reservationID);

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

   // Delete a reservation 
    public boolean deleteReservation(int reservationID) {
        Connection conn = null;
        PreparedStatement deleteLinkedTicketsStmt = null;
        PreparedStatement deleteUnlinkedTicketsStmt = null;
        PreparedStatement deleteReservationStmt = null;
        boolean success = false;

        try {
            conn = DatabaseConnection.getConnection();

            // Step 1: Delete tickets with non-null linkedTicketID
            String deleteLinkedTicketsQuery = "DELETE FROM tickets WHERE reservationID = ? AND linkedTicketID IS NOT NULL";
            deleteLinkedTicketsStmt = conn.prepareStatement(deleteLinkedTicketsQuery);
            deleteLinkedTicketsStmt.setInt(1, reservationID);
            deleteLinkedTicketsStmt.executeUpdate();

            // Step 2: Delete tickets with null linkedTicketID
            String deleteUnlinkedTicketsQuery = "DELETE FROM tickets WHERE reservationID = ? AND linkedTicketID IS NULL";
            deleteUnlinkedTicketsStmt = conn.prepareStatement(deleteUnlinkedTicketsQuery);
            deleteUnlinkedTicketsStmt.setInt(1, reservationID);
            deleteUnlinkedTicketsStmt.executeUpdate();

            // Step 3: Delete the reservation itself
            String deleteReservationQuery = "DELETE FROM reservations WHERE reservationID = ?";
            deleteReservationStmt = conn.prepareStatement(deleteReservationQuery);
            deleteReservationStmt.setInt(1, reservationID);
            int rowsAffected = deleteReservationStmt.executeUpdate();

            success = (rowsAffected > 0); // If the reservation row was deleted, consider it a success
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (deleteLinkedTicketsStmt != null) deleteLinkedTicketsStmt.close();
                if (deleteUnlinkedTicketsStmt != null) deleteUnlinkedTicketsStmt.close();
                if (deleteReservationStmt != null) deleteReservationStmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        return success;
    }

    // transit line names are unique, get reservation by transit line name (manager)
    public List<Object[]> getReservationsByTransitLine(String transitLineName) {
        String query = "SELECT DISTINCT " +
                       "tl.transitLineName, " +
                       "r.reservationID, " +
                       "r.dateMade, " +
                       "c.firstName, " +
                       "c.lastName, " +
                       "r.totalFare " +
                       "FROM Reservations r " +
                       "JOIN Tickets t ON r.reservationID = t.reservationID " +
                       "JOIN Train_Schedules ts ON t.scheduleID = ts.scheduleID " +
                       "JOIN TransitLine tl ON ts.transitID = tl.transitID " +
                       "JOIN Customers c ON r.customerID = c.customerID " +
                       "WHERE tl.transitLineName = ? " +
                       "ORDER BY r.reservationID";

        List<Object[]> results = new ArrayList<>();

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            // Set the transit line parameter
            stmt.setString(1, transitLineName);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Object[] row = {
                        rs.getString("transitLineName"),
                        rs.getInt("reservationID"),
                        rs.getDate("dateMade"),
                        rs.getString("firstName"),
                        rs.getString("lastName"),
                        rs.getBigDecimal("totalFare")
                    };
                    results.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return results;
    }


    // Get reservations by customer name "firstName + lastName" (manager)
    public List<Object[]> getReservationsByCustomerName(String customerName) {
        String query = "SELECT DISTINCT c.username, r.reservationID, r.dateMade, tl.transitLineName, r.totalFare " +
                       "FROM Reservations r " +
                       "JOIN Customers c ON r.customerID = c.customerID " +
                       "JOIN Tickets t ON r.reservationID = t.reservationID " +
                       "JOIN Train_Schedules ts ON t.scheduleID = ts.scheduleID " +
                       "JOIN TransitLine tl ON ts.transitID = tl.transitID " +
                       "WHERE CONCAT(c.firstName, ' ', c.lastName) = ? " +
                       "ORDER BY c.username, r.reservationID";

        List<Object[]> results = new ArrayList<>();

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, customerName);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Object[] row = {
                    rs.getString("username"),       // Username
                    rs.getInt("reservationID"),     // Reservation ID
                    rs.getDate("dateMade"),         // Date Made
                    rs.getString("transitLineName"),// Transit Line
                    rs.getBigDecimal("totalFare")   // Fare
                };
                results.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return results;
    }

    // TODO: double check
	public List<Object[]> getTopActiveTransitLines() {
	    List<Object[]> lines = new ArrayList<>();
	    String query = "SELECT tl.transitLineName, COALESCE(COUNT(DISTINCT r.reservationID), 0) AS NumberOfReservations " +
	                   "FROM TransitLine tl " +
	                   "LEFT JOIN Train_Schedules ts ON tl.transitID = ts.transitID " +
	                   "LEFT JOIN Tickets t ON ts.scheduleID = t.scheduleID " +
	                   "LEFT JOIN Reservations r ON t.reservationID = r.reservationID " +
	                   "GROUP BY tl.transitLineName " +
	                   "ORDER BY NumberOfReservations DESC, tl.transitLineName " +
	                   "LIMIT 5";

	    try (Connection conn = DatabaseConnection.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(query);
	         ResultSet rs = stmt.executeQuery()) {
	        while (rs.next()) {
	            lines.add(new Object[]{rs.getString("transitLineName"), rs.getInt("NumberOfReservations")});
	        }
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return lines;
	}

	// Get the customer ordered by total reservations
	public List<Object[]> getCustomersByMostReservations() {
	    List<Object[]> results = new ArrayList<>();
	    String query = "SELECT c.username, c.firstName, c.lastName, COUNT(r.reservationID) AS totalReservations " +
	                   "FROM Reservations r " +
	                   "JOIN Customers c ON r.customerID = c.customerID " +
	                   "GROUP BY c.username, c.firstName, c.lastName " +
	                   "ORDER BY totalReservations DESC";

	    try (Connection conn = DatabaseConnection.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(query)) {
	        ResultSet rs = stmt.executeQuery();
	        while (rs.next()) {
	            results.add(new Object[]{
	                rs.getString("username"),
	                rs.getString("firstName"),
	                rs.getString("lastName"),
	                rs.getInt("totalReservations")
	            });
	        }
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return results;
	}

	// Get the customers ordered by total spent
	public List<Object[]> getCustomersByTotalSpent() {
	    List<Object[]> results = new ArrayList<>();
	    String query = "SELECT c.username, c.firstName, c.lastName, SUM(r.totalFare) AS totalSpent " +
	                   "FROM Reservations r " +
	                   "JOIN Customers c ON r.customerID = c.customerID " +
	                   "GROUP BY c.username, c.firstName, c.lastName " +
	                   "ORDER BY totalSpent DESC";

	    try (Connection conn = DatabaseConnection.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(query)) {
	        ResultSet rs = stmt.executeQuery();
	        while (rs.next()) {
	            results.add(new Object[]{
	                rs.getString("username"),
	                rs.getString("firstName"),
	                rs.getString("lastName"),
	                rs.getBigDecimal("totalSpent")
	            });
	        }
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return results;
	}

	// Get reservation and customer details by transit line name
    public List<Object[]> getDetailsByTransitLine(String transitLine) {
        List<Object[]> results = new ArrayList<>();
        String query = "SELECT DISTINCT r.reservationID, c.username, c.firstName, c.lastName, r.dateMade, r.totalFare " +
                       "FROM Reservations r " +
                       "JOIN Customers c ON r.customerID = c.customerID " +
                       "JOIN Tickets t ON r.reservationID = t.reservationID " +
                       "JOIN Train_Schedules ts ON t.scheduleID = ts.scheduleID " +
                       "JOIN TransitLine tl ON ts.transitID = tl.transitID " +
                       "WHERE tl.transitLineName = ? " +
                       "ORDER BY r.dateMade DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, transitLine);

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Object[] row = {
                    rs.getString("username"),
                    rs.getString("firstName") + " " + rs.getString("lastName"),
                    rs.getDate("dateMade"),
                    rs.getBigDecimal("totalFare")
                };
                results.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return results;
    }
    
    // Get reservation and customer details by customer name
    public List<Object[]> getDetailsByCustomerName(String customerName) {
        List<Object[]> results = new ArrayList<>();
        String query = "SELECT c.username, CONCAT(c.firstName, ' ', c.lastName) AS fullName, r.dateMade, SUM(r.totalFare) AS totalFare " +
                       "FROM Reservations r JOIN Customers c ON r.customerID = c.customerID " +
                       "WHERE CONCAT(c.firstName, ' ', c.lastName) = ? " +
                       "GROUP BY c.username, c.firstName, c.lastName, r.dateMade " +
                       "ORDER BY r.dateMade DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, customerName);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Object[] row = {
                    rs.getString("username"),
                    rs.getString("fullName"),
                    rs.getDate("dateMade"),
                    rs.getBigDecimal("totalFare")
                };
                results.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return results;
    }

    // Get the unique sale years in which reservations were made
	public List<Integer> getSalesYears() {
	    List<Integer> years = new ArrayList<>();
	    String query = "SELECT DISTINCT YEAR(dateMade) as Year FROM Reservations ORDER BY Year DESC";

	    try (Connection conn = DatabaseConnection.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(query);
	         ResultSet rs = stmt.executeQuery()) {
	        while (rs.next()) {
	            years.add(rs.getInt("Year"));
	        }
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return years;
	}

    // Get the reservations by month and year
	public List<Object[]> getSalesByMonthAndYear(int year, int month) {
	    List<Object[]> results = new ArrayList<>();
	    String query = "SELECT c.username, c.firstName, c.lastName, r.dateMade, r.totalFare " +
	                   "FROM Reservations r " +
	                   "JOIN Customers c ON r.customerID = c.customerID " +
	                   "WHERE YEAR(r.dateMade) = ? AND MONTH(r.dateMade) = ? " +
	                   "ORDER BY r.dateMade DESC";

	    try (Connection conn = DatabaseConnection.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(query)) {
	        stmt.setInt(1, year);
	        stmt.setInt(2, month);

	        ResultSet rs = stmt.executeQuery();
	        while (rs.next()) {
	            Object[] row = {
	                rs.getString("username"),
	                rs.getString("firstName"),
	                rs.getString("lastName"),
	                rs.getDate("dateMade"),
	                rs.getBigDecimal("totalFare")
	            };
	            results.add(row);
	        }
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return results;
	}

	// Get reservations by transit line name and reservation made date 
	public List<Object[]> getCustomersByTransitLineAndDate(String transitLine, String reservationDate) {
	    List<Object[]> customers = new ArrayList<>();
	    String query = "SELECT DISTINCT r.reservationID, c.username, c.firstName, c.lastName, r.dateMade, r.totalFare " +
	                   "FROM Reservations r " +
	                   "JOIN Customers c ON r.customerID = c.customerID " +
	                   "JOIN Tickets t ON t.reservationID = r.reservationID " +
	                   "JOIN Train_Schedules ts ON t.scheduleID = ts.scheduleID " +
	                   "JOIN TransitLine tl ON ts.transitID = tl.transitID " +
	                   "WHERE tl.transitLineName = ? AND DATE(r.dateMade) = ? " +
	                   "ORDER BY r.dateMade, c.lastName, c.firstName";

	    try (Connection conn = DatabaseConnection.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(query)) {
	        stmt.setString(1, transitLine);
	        stmt.setString(2, reservationDate);

	        try (ResultSet rs = stmt.executeQuery()) {
	            while (rs.next()) {
	                Object[] row = {
	                    rs.getString("username"),
	                    rs.getString("firstName") + " " + rs.getString("lastName"),
	                    rs.getDate("dateMade"),
	                    rs.getBigDecimal("totalFare")
	                };
	                customers.add(row);
	            }
	        }
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return customers;
	}
	
}

