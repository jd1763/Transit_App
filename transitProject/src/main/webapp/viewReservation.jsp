<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.util.*, java.text.SimpleDateFormat, dao.StopsAtDAO, dao.TicketDAO, dao.StationDAO, dao.TrainScheduleDAO, dao.TransitLineDAO, model.Ticket, model.TrainSchedule" %>
<%
    String reservationIDParam = request.getParameter("reservationID");
    if (reservationIDParam == null) {
        response.sendRedirect("customerReservations.jsp");
        return;
    }

    int reservationID = Integer.parseInt(reservationIDParam);
    TicketDAO ticketDAO = new TicketDAO();
    StationDAO stationDAO = new StationDAO();
    TrainScheduleDAO scheduleDAO = new TrainScheduleDAO();
    TransitLineDAO transitLineDAO = new TransitLineDAO();
    StopsAtDAO stopsAtDAO = new StopsAtDAO();

    List<Ticket> tickets = ticketDAO.getTicketsByReservationID(reservationID);
    
    SimpleDateFormat f = new SimpleDateFormat("EEEE, MMMM d, yyyy - h:mm a");

%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>View Reservation</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
</head>
<body>
    <div class="dashboard-container">
        <div class="navbar">
            <a href="customerReservations.jsp">Back to Reservations</a>
        </div>
        <div>
            <h2>Reservation Details (ID: <%= reservationID %>)</h2>

            <% if (tickets == null || tickets.isEmpty()) { %>
                <p>No tickets found for this reservation.</p>
            <% } else { %>
                <div class="reservation-table-wrapper">
                    <table>
                        <thead>
                            <tr>
                                <th>Transit Line</th>
                                <th>Origin</th>
                                <th>Destination</th>
                                <th>Departure Time</th>
                                <th>Arrival Time</th>
                                <th>Ticket Type</th>
                                <th>Trip Type</th>
                                <th>Fare</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Ticket ticket : tickets) {
                                if ("roundTrip".equals(ticket.getTripType())) {
                                    if (ticket.getLinkedTicketID() == null) {
                                        continue;
                                    }
                                    TrainSchedule returningSchedule = scheduleDAO.getTrainSchedule(ticket.getScheduleID());
                                    String transitLineName = transitLineDAO.getTransitLineName(returningSchedule.getTransitID());
                                    String destinationName = stationDAO.getStation(ticket.getOriginID()).getName();
                                    String originName = stationDAO.getStation(ticket.getDestinationID()).getName();
                                    Date reDepartureTime = stopsAtDAO.getDepartureTimeForStation(ticket.getScheduleID(), ticket.getOriginID());
                                    Date reArrivalTime = stopsAtDAO.getArrivalTimeForStation(ticket.getScheduleID(), ticket.getDestinationID());
                                    Ticket incomingTicket = ticketDAO.getLinkedTicket(ticket.getLinkedTicketID());
                                    if (incomingTicket != null) {
                                        Date inDepartureTime = stopsAtDAO.getDepartureTimeForStation(incomingTicket.getScheduleID(), incomingTicket.getOriginID());
                                        Date inArrivalTime = stopsAtDAO.getArrivalTimeForStation(incomingTicket.getScheduleID(), incomingTicket.getDestinationID());
                            %>
                                        <tr>
                                            <td><%= transitLineName %></td>
                                            <td><%= originName %></td>
                                            <td><%= destinationName %></td>
                                            <td><%= f.format(inDepartureTime) %></td>
                                            <td><%= f.format(inArrivalTime) %></td>
                                            <td><%= incomingTicket.getTicketType() %></td>
                                            <td><%= incomingTicket.getTripType() %>(Incoming)</td>
                                            <td>$<%= incomingTicket.getFare() %></td>
                                        </tr>
                                        <tr>
                                            <td><%= transitLineName %></td>
                                            <td><%= destinationName %></td>
                                            <td><%= originName %></td>
                                            <td><%= f.format(reDepartureTime) %></td>
                                            <td><%= f.format(reArrivalTime) %></td>
                                            <td><%= ticket.getTicketType() %></td>
                                            <td><%= ticket.getTripType() %>(Return)</td>
                                            <td>$<%= ticket.getFare() %></td>
                                        </tr>
                            <%      }
                                } else {
                                    TrainSchedule schedule = scheduleDAO.getTrainSchedule(ticket.getScheduleID());
                                    String transitLineName = transitLineDAO.getTransitLineName(schedule.getTransitID());
                                    String destinationName = stationDAO.getStation(ticket.getDestinationID()).getName();
                                    String originName = stationDAO.getStation(ticket.getDestinationID()).getName();
                                    Date departureTime = stopsAtDAO.getDepartureTimeForStation(ticket.getScheduleID(), ticket.getOriginID());
                                    Date arrivalTime = stopsAtDAO.getArrivalTimeForStation(ticket.getScheduleID(), ticket.getDestinationID());
                            %>
                                    <tr>
                                        <td><%= transitLineName %></td>
                                        <td><%= originName %></td>
                                        <td><%= destinationName %></td>
                                        <td><%= f.format(departureTime) %></td>
                                        <td><%= f.format(arrivalTime) %></td>
                                        <td><%= ticket.getTicketType() %></td>
                                        <td><%= ticket.getTripType() %></td>
                                        <td>$<%= ticket.getFare() %></td>
                                    </tr>
                            <%      }
                            } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </div>
    </div>
</body>
</html>
