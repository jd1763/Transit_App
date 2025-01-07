<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, dao.ReservationDAO, dao.TransitLineDAO" %>
<%
    String role = (String) session.getAttribute("role");
    if (role == null || !"rep".equals(role)) {
        response.sendRedirect("login.jsp"); // Redirect to login if not a customer representative
        return;
    }

    ReservationDAO reservationDAO = new ReservationDAO();
    TransitLineDAO transitLineDAO = new TransitLineDAO();
    List<Object[]> customers = null;
    List<String> transitLines = transitLineDAO.getAllTransitLineNames(); // Fetch all transit lines
    String transitLine = request.getParameter("transitLine");
    String reservationDate = request.getParameter("reservationDate");

    // This will store whether the form has been submitted
    boolean isSubmitted = "POST".equalsIgnoreCase(request.getMethod()) && transitLine != null && reservationDate != null;
    if (isSubmitted) {
        customers = reservationDAO.getCustomersByTransitLineAndDate(transitLine, reservationDate);
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Customer Reservations by Transit Line and Date</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
</head>
<body>
<div class="rep-customer-reservations-container">
        <!-- Navbar -->
        <div class="navbar">
            <a href="repDashboard.jsp">Back to Dashboard</a>
        </div>

        <!-- Content -->
        <div class="content">
            <h2>Customer Reservations by Transit Line and Date</h2>
            <form action="repCustomerReservations.jsp" method="post">
                <label for="transitLine">Transit Line:</label>
                <select name="transitLine" id="transitLine" required>
                    <option value="">Select a line...</option>
                    <% for(String line : transitLines) { %>
                        <option value="<%= line %>" <%= line.equals(transitLine) ? "selected" : "" %>><%= line %></option>
                    <% } %>
                </select>
                <label for="reservationDate">Date:</label>
                <input type="date" name="reservationDate" id="reservationDate" required value="<%= reservationDate != null ? reservationDate : "" %>">
                <button type="submit">Search</button>
            </form>

            <% if (isSubmitted && customers != null && !customers.isEmpty()) { %>
                <table>
                    <thead>
                        <tr>
                            <th>Username</th>
                            <th>Customer Name</th>
                            <th>Date Made</th>
                            <th>Total Fare</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Object[] customer : customers) { %>
                        <tr>
                            <td><%= customer[0] %></td>
                            <td><%= customer[1] %></td>
                            <td><%= customer[2] %></td>
                            <td>$<%= customer[3] %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } else if (isSubmitted) { %>
                <p>No reservations found for the specified criteria.</p>
            <% } %>
        </div>
    </div>
</body>
</html>



