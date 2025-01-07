package utils;

import dao.TicketDAO;
import model.Ticket;

import java.math.BigDecimal;
import java.sql.Date;

public class ReservationProcessor {
    private TicketDAO ticketDAO;
    private int reservationID;
    private int incomingScheduleID;
    private int returningScheduleID;
    private Date dateMade;
    private int originID;
    private int destinationID;

    public ReservationProcessor(TicketDAO ticketDAO, int reservationID, int incomingScheduleID, int returningScheduleID, Date dateMade, int originID, int destinationID) {
        this.ticketDAO = ticketDAO;
        this.reservationID = reservationID;
        this.incomingScheduleID = incomingScheduleID;
        this.returningScheduleID = returningScheduleID;
        this.dateMade = dateMade;
        this.originID = originID;
        this.destinationID = destinationID;
    }

    /**
     * Creates an incoming ticket.
     *
     * @param ticketType The type of the ticket (e.g., adult, child).
     * @param tripType   The trip type (e.g., one-way, round-trip).
     * @param fare       The fare for the ticket.
     * @return The ticket ID of the created incoming ticket.
     */
    public int createIncomingTicket(String ticketType, String tripType, BigDecimal fare) {
        Ticket ticket = new Ticket(
            0,
            reservationID,
            incomingScheduleID,
            dateMade,
            originID,
            destinationID,
            ticketType,
            tripType,
            fare,
            null
        );
        return ticketDAO.createTicket(ticket);
    }

    /**
     * Creates a return ticket linked to an incoming ticket.
     *
     * @param linkedTicketID The ticket ID of the incoming ticket.
     * @param ticketType     The type of the ticket (e.g., adult, child).
     * @param tripType       The trip type (e.g., round-trip).
     * @param fare           The fare for the return ticket.
     */
    public void createReturnTicket(Integer linkedTicketID, String ticketType, String tripType, BigDecimal fare) {
        if (returningScheduleID == -1) {
            throw new IllegalArgumentException("Returning schedule ID must be valid for round-trip tickets.");
        }

        Ticket ticket = new Ticket(
            0,
            reservationID,
            returningScheduleID,
            dateMade,
            destinationID,
            originID,
            ticketType,
            tripType,
            fare,
            linkedTicketID // Linking the return ticket to the incoming ticket
        );
        ticketDAO.createTicket(ticket);
    }
    
    /**
     * Processes tickets for a specific type.
     *
     * @param quantity The quantity of tickets.
     * @param ticketType The type of the tickets (e.g., adult, child).
     * @param tripType The trip type (e.g., one-way, round-trip).
     * @param fare The base fare for the tickets.
     * @return The total fare for the processed tickets.
     */
    public BigDecimal processTickets(int quantity, String ticketType, String tripType, BigDecimal fare) {
        BigDecimal totalFare = BigDecimal.ZERO;

        for (int i = 0; i < quantity; i++) {
            // Create the incoming ticket
            int incomingTicketID = createIncomingTicket(ticketType, tripType, fare);

            // Create the return ticket if it's a round trip
            if ("roundTrip".equals(tripType)) {
                createReturnTicket(incomingTicketID, ticketType, tripType, fare);
                totalFare = totalFare.add(fare.multiply(new BigDecimal(2))); // Add fare for both tickets
            } else {
                totalFare = totalFare.add(fare);
            }
        }

        return totalFare;
    }
}

