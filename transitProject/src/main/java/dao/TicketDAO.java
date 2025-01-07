package dao;

import model.Ticket;
import transit.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TicketDAO {

    // Method to create a ticket
    public int createTicket(Ticket ticket) {
        String sql = "INSERT INTO Tickets (reservationID, scheduleID, dateMade, originID, destinationID, ticketType, tripType, fare, linkedTicketID) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, ticket.getReservationID());
            stmt.setInt(2, ticket.getScheduleID());
            stmt.setDate(3, new java.sql.Date(ticket.getDateMade().getTime()));
            stmt.setInt(4, ticket.getOriginID());
            stmt.setInt(5, ticket.getDestinationID());
            stmt.setString(6, ticket.getTicketType());
            stmt.setString(7, ticket.getTripType());
            stmt.setBigDecimal(8, ticket.getFare());

            if (ticket.getLinkedTicketID() != null) {
                stmt.setInt(9, ticket.getLinkedTicketID());
            } else {
                stmt.setNull(9, Types.INTEGER);
            }

            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected > 0) {
                ResultSet rs = stmt.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1); // Return the generated ticket ID
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1; // Indicates failure
    }

    // Retrieve tickets for a reservation
    public List<Ticket> getTicketsByReservationID(int reservationID) {
        List<Ticket> tickets = new ArrayList<>();
        String sql = "SELECT * FROM Tickets WHERE reservationID = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, reservationID);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Ticket ticket = new Ticket(
                    rs.getInt("ticketID"),
                    rs.getInt("reservationID"),
                    rs.getInt("scheduleID"),
                    rs.getDate("dateMade"),
                    rs.getInt("originID"),
                    rs.getInt("destinationID"),
                    rs.getString("ticketType"),
                    rs.getString("tripType"),
                    rs.getBigDecimal("fare"),
                    rs.getInt("linkedTicketID")
                );
                if (ticket.getLinkedTicketID() == 0) {
                	ticket.setLinkedTicketID(null);
                }
                tickets.add(ticket);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tickets;
    }

    // Delete tickets for a reservation
    public boolean deleteTicketsByReservationID(int reservationID) {
        String sql = "DELETE FROM Tickets WHERE reservationID = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, reservationID);
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    public Ticket getLinkedTicket(Integer ticketID) {
       	System.out.println("entered:"+ticketID);
        String sql = "SELECT * FROM Tickets WHERE ticketID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, ticketID);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return new Ticket(
                    rs.getInt("ticketID"),
                    rs.getInt("reservationID"),
                    rs.getInt("scheduleID"),
                    rs.getDate("dateMade"),
                    rs.getInt("originID"),
                    rs.getInt("destinationID"),
                    rs.getString("ticketType"),
                    rs.getString("tripType"),
                    rs.getBigDecimal("fare"),
                    rs.getObject("linkedTicketID", Integer.class) // Handles nullable linkedTicketID
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
