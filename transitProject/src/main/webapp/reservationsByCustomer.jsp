<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="dao.ReservationDAO, dao.CustomerDAO, java.util.List" %>
<%
    // Check if user is logged in as a manager
    String role = (String) session.getAttribute("role");
    if (role == null || !"manager".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    // DAOs
    CustomerDAO customerDAO = new CustomerDAO();
    ReservationDAO reservationDAO = new ReservationDAO();

    // Get the selected customer name from the request
    String selectedCustomerName = request.getParameter("customerName");

    // Get all customers for the dropdown
    List<Object[]> customers = customerDAO.getAllCustomers();

    // Initialize reservations list
    List<Object[]> reservations = null;

    // If a customer name is selected, fetch reservations for that name
    if (selectedCustomerName != null && !selectedCustomerName.isEmpty()) {
        reservations = reservationDAO.getReservationsByCustomerName(selectedCustomerName);
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Reservations by Customer Name</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
</head>
<body>
    <div class="reservation-by-customer-container">
        <!-- Navbar -->
        <div class="navbar">
            <a href="managerDashboard.jsp">Back to Dashboard</a>
        </div>

        <!-- Page Title -->
        <h2>Reservations by Customer Name</h2>

        <!-- Search Form -->
        <form action="reservationsByCustomer.jsp" method="get" class="search-form">
            <label for="customerName">Select Customer:</label>
            <select name="customerName" id="customerName" required>
                <option value="">-- Select Customer --</option>
                <% for (Object[] customer : customers) { %>
                    <option value="<%= customer[2] + " " + customer[3] %>">
                        <%= customer[2] + " " + customer[3] %>
                    </option>
                <% } %>
            </select>
            <button type="submit">Search</button>
        </form>

        <!-- Display Results -->
        <% if (selectedCustomerName != null && !selectedCustomerName.isEmpty()) { %>
        <div class="reservation-table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>Reservation Number</th>
                        <th>Date Made</th>
                        <th>Transit Line</th>
                        <th>Fare</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (reservations == null || reservations.isEmpty()) { %>
                        <tr>
                            <td colspan="4">No reservations found for the selected customer.</td>
                        </tr>
                    <% } else { 
                        String currentUsername = ""; // Track the current username
                        for (Object[] row : reservations) {
                            String username = (String) row[0]; // Username
                            if (!username.equals(currentUsername)) {
                                currentUsername = username;
                    %>
                    <tr class="username-row">
                        <td colspan="4"><strong>Username: <%= username %></strong></td>
                    </tr>
                    <%      } %>
                    <tr>
                        <td><%= row[1] %></td> <!-- Reservation Number -->
                        <td><%= row[2] %></td> <!-- Date Made -->
                        <td><%= row[3] %></td> <!-- Transit Line -->
                        <td>$<%= row[4] %></td> <!-- Fare -->
                    </tr>
                    <%  } // End for loop 
                    } // End else %>
                </tbody>
            </table>
        </div>
        <% } %>
    </div>
</body>
</html>

