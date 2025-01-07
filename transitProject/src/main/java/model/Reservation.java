package model; 

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

public class Reservation {
    private int reservationID;          // Unique ID for the reservation
    private int customerID;             // ID of the customer who made the reservation
    private Date dateMade;              // Date when the reservation was created
    private BigDecimal totalFare;           // Total fare for the reservation
    private List<Ticket> tickets;       // List of tickets associated with this reservation

    // Constructor
    public Reservation(int reservationID, int customerID, Date dateMade, BigDecimal totalFare) {
        this.reservationID = reservationID;
        this.customerID = customerID;
        this.dateMade = dateMade;
        this.totalFare = totalFare;
    }

    // Getters and Setters
    public int getReservationID() {
        return reservationID;
    }

    public void setReservationID(int reservationID) {
        this.reservationID = reservationID;
    }

    public int getCustomerID() {
        return customerID;
    }

    public void setCustomerID(int customerID) {
        this.customerID = customerID;
    }

    public Date getDateMade() {
        return dateMade;
    }

    public void setDateMade(Date dateMade) {
        this.dateMade = dateMade;
    }

    public BigDecimal getTotalFare() {
        return totalFare;
    }

    public void setTotalFare(BigDecimal totalFare) {
        this.totalFare = totalFare;
    }

    public List<Ticket> getTickets() {
        return tickets;
    }

    public void setTickets(List<Ticket> tickets) {
        this.tickets = tickets;
    }

    @Override
    public String toString() {
        return "Reservation{" +
                "reservationID=" + reservationID +
                ", customerID=" + customerID +
                ", dateMade=" + dateMade +
                ", totalFare=" + totalFare +
                ", tickets=" + tickets +
                '}';
    }
}
