<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="dao.ReservationDAO, dao.TransitLineDAO, java.util.List" %>
<%
    // Check if user is logged in as a manager
    String role = (String) session.getAttribute("role");
    if (role == null || !"manager".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Reservations by Transit Line</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
</head>
<body>
    <div class="reservation-transit-container">
        <div class="navbar">
            <a href="managerDashboard.jsp">Back to Dashboard</a>
        </div>
        <h2>Reservations by Transit Line</h2>
        <%
            TransitLineDAO transitLineDAO = new TransitLineDAO();
            ReservationDAO reservationDAO = new ReservationDAO();
            List<String> transitLines = transitLineDAO.getAllTransitLineNames(); // Fetch all transit lines
            String selectedTransitLine = request.getParameter("transitLine");
            List<Object[]> reservations = null;

            if (selectedTransitLine != null && !selectedTransitLine.isEmpty()) {
                reservations = reservationDAO.getReservationsByTransitLine(selectedTransitLine); // Filter reservations
            }
        %>
        
        <!-- Transit Line Dropdown -->
        <form action="reservationsByTransitLine.jsp" method="get" class="search-form">
            <label for="transitLine">Transit Line:</label>
            <select name="transitLine" id="transitLine" required>
                <option value="" disabled selected>Select a transit line</option>
                <% for (String transitLine : transitLines) { %>
                    <option value="<%= transitLine %>" <%= (transitLine.equals(selectedTransitLine) ? "selected" : "") %>>
                        <%= transitLine %>
                    </option>
                <% } %>
            </select>
            <button type="submit">Search</button>
        </form>
        
        <!-- Reservation Table -->
        <div class="reservation-table-wrapper">
            <% if (selectedTransitLine != null && reservations != null && !reservations.isEmpty()) { %>
                <table>
                    <thead>
                        <tr>
                            <th>Reservation Number</th>
                            <th>Date Made</th>
                            <th>Customer Name</th>
                            <th>Fare</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Object[] row : reservations) { %>
                            <tr>
                                <td><%= row[1] %></td>
                                <td><%= row[2] %></td>
                                <td><%= row[3] + " " + row[4] %></td>
                                <td>$<%= row[5] %></td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } else if (selectedTransitLine != null) { %>
                <p>No reservations found for the selected transit line.</p>
            <% } %>
        </div>
    </div>
</body>
</html>
