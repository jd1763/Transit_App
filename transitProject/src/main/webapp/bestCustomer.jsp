<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, dao.ReservationDAO, java.math.BigDecimal" %>
<%
    String role = (String) session.getAttribute("role");
    if (role == null || !"manager".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    ReservationDAO dao = new ReservationDAO();
    String filter = request.getParameter("filter");
    if (filter == null) {
        filter = "totalSpent"; // Default filter
    }

    List<Object[]> customers;
    if ("totalReservations".equals(filter)) {
        customers = dao.getCustomersByMostReservations();
    } else {
        customers = dao.getCustomersByTotalSpent();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Best Customers</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
</head>
<body>
    <div class="navbar">
        <a href="managerDashboard.jsp">Back to Dashboard</a>
    </div>
    <div class="customer-leaderboard-container">
        <h2>Best Customers Leaderboard</h2>
        <form action="bestCustomer.jsp" method="get" class="filter-form">
            <select name="filter" onchange="this.form.submit()">
                <option value="totalSpent" <%= "totalSpent".equals(filter) ? "selected" : "" %>>Most Total Amount Spent</option>
                <option value="totalReservations" <%= "totalReservations".equals(filter) ? "selected" : "" %>>Most Reservations Made</option>
            </select>
        </form>
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Rank</th>
                        <th>Username</th>
                        <th>First Name</th>
                        <th>Last Name</th>
                        <th>Value</th>
                    </tr>
                </thead>
                <tbody>
                    <% int rank = 1; // Initialize rank counter
                       for (Object[] customer : customers) {
                           String displayValue = customer[3] instanceof BigDecimal ? ((BigDecimal)customer[3]).toString() : customer[3].toString();
                           String formattedValue = "totalSpent".equals(filter) ? "$" + displayValue : displayValue;
                    %>
                    <tr>
                        <td><%= rank++ %></td>
                        <td><%= customer[0] %></td>
                        <td><%= customer[1] %></td>
                        <td><%= customer[2] %></td>
                        <td><%= formattedValue %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>

