<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.util.*, dao.ReservationDAO, dao.TicketDAO, dao.StopsAtDAO, dao.TrainScheduleDAO, model.Ticket" %>
<%
    String reservationIDParam = request.getParameter("reservationID");

    if (reservationIDParam == null || reservationIDParam.isEmpty()) {
        out.println("<script>alert('Invalid reservation ID.'); window.location.href='customerReservations.jsp';</script>");
        return;
    }

    int reservationID;
    try {
        reservationID = Integer.parseInt(reservationIDParam);
    } catch (NumberFormatException e) {
        out.println("<script>alert('Invalid reservation ID.'); window.location.href='customerReservations.jsp';</script>");
        return;
    }

    // DAO initialization
    ReservationDAO reservationDAO = new ReservationDAO();
    TicketDAO ticketDAO = new TicketDAO();
    StopsAtDAO stopsAtDAO = new StopsAtDAO();

    // Retrieve tickets for the given reservation
    List<Ticket> tickets = ticketDAO.getTicketsByReservationID(reservationID);
    Date now = new Date();
    boolean isCancelable = false;

    // Check if the reservation can be canceled
    for (Ticket ticket : tickets) {
        if ("oneWay".equals(ticket.getTripType())) {
            // Check departure time for one-way tickets
            Date departureTime = stopsAtDAO.getDepartureTimeForStation(ticket.getScheduleID(), ticket.getOriginID());
            if (departureTime != null && departureTime.after(now)) {
                isCancelable = true;
                break;
            }
        } else if ("roundTrip".equals(ticket.getTripType()) && ticket.getLinkedTicketID() == null) {
            // Check departure time for incoming ticket of round trips (linkedTicketID is null for incoming)
            Date departureTime = stopsAtDAO.getDepartureTimeForStation(ticket.getScheduleID(), ticket.getOriginID());
            if (departureTime != null && departureTime.after(now)) {
                isCancelable = true;
                break;
            }
        }
    }

    // If cancelable, proceed to delete the reservation
    if (isCancelable) {
        boolean success = reservationDAO.deleteReservation(reservationID);

        if (success) {
%>
            <script>
                alert('Reservation cancelled successfully.');
                window.location.href = 'customerReservations.jsp';
            </script>
<%
        } else {
%>
            <script>
                alert('Failed to cancel reservation. Please try again.');
                window.location.href = 'customerReservations.jsp';
            </script>
<%
        }
    } else {
%>
        <script>
            alert('This reservation cannot be canceled because its tickets have already passed their departure times.');
            window.location.href = 'customerReservations.jsp';
        </script>
<%
    }
%>

