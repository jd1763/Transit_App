<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, dao.CustomerDAO, dao.ReservationDAO, dao.TransitLineDAO" %>
<%
    String role = (String) session.getAttribute("role");
    if (role == null || !"manager".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    // DAOs
    ReservationDAO reservationDAO = new ReservationDAO();
    TransitLineDAO transitLineDAO = new TransitLineDAO();
    CustomerDAO customerDAO = new CustomerDAO();

    // View type selection
    String viewType = request.getParameter("viewType");
    String selectedItem = request.getParameter("selectedItem");

    // Data for dropdowns
    List<String> customerList = customerDAO.getAllCustomerNames();
    List<String> transitLines = transitLineDAO.getAllTransitLineNames();

    // Reservations
    List<Object[]> reservations = null;
    if ("customer".equals(viewType) && selectedItem != null && !selectedItem.isEmpty()) {
        reservations = reservationDAO.getReservationsByCustomerName(selectedItem);
    } else if ("transitLine".equals(viewType) && selectedItem != null && !selectedItem.isEmpty()) {
        reservations = reservationDAO.getReservationsByTransitLine(selectedItem);
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>View Reservations</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
</head>
<body>
    <div class="view-reservations-container">
        <div class="navbar">
            <a href="managerDashboard.jsp">Back to Dashboard</a>
        </div>

        <h2>View Reservations</h2>

        <!-- View Type Dropdown -->
        <form action="reservationsBy.jsp" method="get">
            <label for="viewType">View By:</label>
            <select name="viewType" id="viewType" onchange="this.form.submit()">
                <option value="">-- Select View --</option>
                <option value="customer" <%= "customer".equals(viewType) ? "selected" : "" %>>Customer Name</option>
                <option value="transitLine" <%= "transitLine".equals(viewType) ? "selected" : "" %>>Transit Line</option>
            </select>
        </form>

        <% if ("customer".equals(viewType)) { %>
            <!-- Customer Name Dropdown -->
            <form action="reservationsBy.jsp" method="get">
                <input type="hidden" name="viewType" value="customer">
                <label for="selectedItem">Select Customer:</label>
                <select name="selectedItem" id="selectedItem" required>
                    <option value="">-- Select Customer --</option>
                    <% for (String customer : customerList) { %>
                        <option value="<%= customer %>" <%= selectedItem != null && selectedItem.equals(customer) ? "selected" : "" %>>
                            <%= customer %>
                        </option>
                    <% } %>
                </select>
                <button type="submit">Search</button>
            </form>
        <% } else if ("transitLine".equals(viewType)) { %>
            <!-- Transit Line Dropdown -->
            <form action="reservationsBy.jsp" method="get">
                <input type="hidden" name="viewType" value="transitLine">
                <label for="selectedItem">Select Transit Line:</label>
                <select name="selectedItem" id="selectedItem" required>
                    <option value="">-- Select Transit Line --</option>
                    <% for (String transitLine : transitLines) { %>
                        <option value="<%= transitLine %>" <%= selectedItem != null && selectedItem.equals(transitLine) ? "selected" : "" %>>
                            <%= transitLine %>
                        </option>
                    <% } %>
                </select>
                <button type="submit">Search</button>
            </form>
        <% } %>

        <!-- Results Section -->
        <% if (reservations != null) { %>
            <div class="reservation-table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <% if ("customer".equals(viewType)) { %>
                                <th>Reservation Number</th>
                                <th>Date Made</th>
                                <th>Transit Line</th>
                                <th>Fare</th>
                            <% } else if ("transitLine".equals(viewType)) { %>
                                <th>Reservation Number</th>
                                <th>Date Made</th>
                                <th>Customer Name</th>
                                <th>Fare</th>
                            <% } %>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (reservations.isEmpty()) { %>
                            <tr>
                                <td colspan="4">No reservations found for the selected criteria.</td>
                            </tr>
                        <% } else { 
                            for (Object[] row : reservations) { %>
                                <tr>
                                    <td><%= row[1] %></td> <!-- Reservation Number -->
                                    <td><%= row[2] %></td> <!-- Date Made -->
                                    <% if ("customer".equals(viewType)) { %>
                                        <td><%= row[3] %></td> <!-- Transit Line -->
                                        <td>$<%= row[4] %></td> <!-- Fare -->
                                    <% } else if ("transitLine".equals(viewType)) { %>
                                        <td><%= row[3] + " " + row[4] %></td> <!-- Customer Name -->
                                        <td>$<%= row[5] %></td> <!-- Fare -->
                                    <% } %>
                                </tr>
                            <% } %>
                        <% } %>
                    </tbody>
                </table>
            </div>
        <% } %>
    </div>
</body>
</html>
