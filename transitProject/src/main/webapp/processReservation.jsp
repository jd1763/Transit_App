<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.math.BigDecimal, dao.CustomerDAO, dao.ReservationDAO, dao.TicketDAO, model.Customer, model.Reservation, utils.ReservationProcessor" %>
<%
    // Ensure the user is logged in as a customer
    String role = (String) session.getAttribute("role");
    String username = (String) session.getAttribute("username");
    
    if (role == null || !"customer".equals(role) || username == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // DAOs
    CustomerDAO customerDAO = new CustomerDAO();
    ReservationDAO reservationDAO = new ReservationDAO();
    TicketDAO ticketDAO = new TicketDAO();

    // Retrieve customer details
    Customer customer = customerDAO.getCustomerByUsername(username);
    int customerID = customer.getCustomerID();

    // Retrieve form parameters
    int incomingScheduleID = Integer.parseInt(request.getParameter("incomingScheduleID"));
    int returningScheduleID = -1;
    if (request.getParameter("returningScheduleID") != null && !request.getParameter("returningScheduleID").isEmpty()) {
        returningScheduleID = Integer.parseInt(request.getParameter("returningScheduleID"));
    }
    int originID = Integer.parseInt(request.getParameter("originID"));
    int destinationID = Integer.parseInt(request.getParameter("destinationID"));
    BigDecimal baseFare = new BigDecimal(request.getParameter("baseFare"));
    Date dateMade = new Date();
	System.out.println(dateMade);
    // Ticket quantities and types
    int adultTickets = Integer.parseInt(request.getParameter("adultTickets"));
    String adultTripType = request.getParameter("adultTripType");
    int childTickets = Integer.parseInt(request.getParameter("childTickets"));
    String childTripType = request.getParameter("childTripType");
    int seniorTickets = Integer.parseInt(request.getParameter("seniorTickets"));
    String seniorTripType = request.getParameter("seniorTripType");
    int disabledTickets = Integer.parseInt(request.getParameter("disabledTickets"));
    String disabledTripType = request.getParameter("disabledTripType");

    // Discounts for ticket types
    BigDecimal childFare = baseFare.multiply(new BigDecimal("0.75"));
    BigDecimal seniorFare = baseFare.multiply(new BigDecimal("0.65"));
    BigDecimal disabledFare = baseFare.multiply(new BigDecimal("0.5"));

    boolean success = true;

    try {
        // Create a new reservation
        Reservation reservation = new Reservation(0, customerID, dateMade, BigDecimal.ZERO);
        int reservationID = reservationDAO.createReservation(reservation);

        BigDecimal totalFare = BigDecimal.ZERO;

        // Initialize the ReservationProcessor
        ReservationProcessor processor = new ReservationProcessor(
            ticketDAO,
            reservationID,
            incomingScheduleID,
            returningScheduleID,
            new java.sql.Date(dateMade.getTime()),
            originID,
            destinationID
        );

        // Process tickets for each type
        totalFare = totalFare.add(processor.processTickets(adultTickets, "adult", adultTripType, baseFare));
        totalFare = totalFare.add(processor.processTickets(childTickets, "child", childTripType, childFare));
        totalFare = totalFare.add(processor.processTickets(seniorTickets, "senior", seniorTripType, seniorFare));
        totalFare = totalFare.add(processor.processTickets(disabledTickets, "disabled", disabledTripType, disabledFare));

        // Update total fare in the reservation
        reservationDAO.updateReservationTotalFare(reservationID, totalFare);
    } catch (Exception e) {
        e.printStackTrace();
        success = false;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Processing Reservation</title>
    <script type="text/javascript">
        window.onload = function() {
            <% if (success) { %>
                alert("Successfully made reservation.");
                window.location.href = "customerDashboard.jsp";
            <% } else { %>
                alert("Failed to make reservation. Please try again.");
                window.location.href = "reservationDetails.jsp?incomingScheduleID=<%= incomingScheduleID %>&returningScheduleID=<%= returningScheduleID %>&originID=<%= originID %>&destinationID=<%= destinationID %>&baseFare=<%= baseFare %>";
            <% } %>
        };
    </script>
</head>
<body>
</body>
</html>
