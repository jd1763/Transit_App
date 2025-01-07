package model;

import java.math.BigDecimal;
import java.util.Date;

public class Ticket {
    private int ticketID;
    private int reservationID;
    private int scheduleID;
    private Date dateMade;
    private int originID;
    private int destinationID;
    private String ticketType; // "adult", "child", etc.
    private String tripType;   // "oneWay", "roundTrip"
    private BigDecimal fare;
    private Integer linkedTicketID; // Nullable field to link round-trip tickets

    // Constructor
    public Ticket(int ticketID, int reservationID, int scheduleID, Date dateMade,
                  int originID, int destinationID, String ticketType, String tripType,
                  BigDecimal fare, Integer linkedTicketID) {
        this.ticketID = ticketID;
        this.reservationID = reservationID;
        this.scheduleID = scheduleID;
        this.dateMade = dateMade;
        this.originID = originID;
        this.destinationID = destinationID;
        this.ticketType = ticketType;
        this.tripType = tripType;
        this.fare = fare;
        this.linkedTicketID = linkedTicketID;
    }

    // Getters and Setters
    public int getTicketID() { return ticketID; }
    public void setTicketID(int ticketID) { this.ticketID = ticketID; }

    public int getReservationID() { return reservationID; }
    public void setReservationID(int reservationID) { this.reservationID = reservationID; }

    public int getScheduleID() { return scheduleID; }
    public void setScheduleID(int scheduleID) { this.scheduleID = scheduleID; }

    public Date getDateMade() { return dateMade; }
    public void setDateMade(Date dateMade) { this.dateMade = dateMade; }

    public int getOriginID() { return originID; }
    public void setOriginID(int originID) { this.originID = originID; }

    public int getDestinationID() { return destinationID; }
    public void setDestinationID(int destinationID) { this.destinationID = destinationID; }

    public String getTicketType() { return ticketType; }
    public void setTicketType(String ticketType) { this.ticketType = ticketType; }

    public String getTripType() { return tripType; }
    public void setTripType(String tripType) { this.tripType = tripType; }

    public BigDecimal getFare() { return fare; }
    public void setFare(BigDecimal fare) { this.fare = fare; }

    public Integer getLinkedTicketID() { return linkedTicketID; }
    public void setLinkedTicketID(Integer linkedTicketID) { this.linkedTicketID = linkedTicketID; }
}