<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.math.BigDecimal, java.text.DateFormatSymbols, java.text.SimpleDateFormat, dao.ReservationDAO" %>
<%
    // Check if user is logged in as a manager
    String role = (String) session.getAttribute("role");
    if (role == null || !"manager".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    ReservationDAO reservationDAO = new ReservationDAO();
    List<Integer> years = reservationDAO.getSalesYears(); // Fetch years with sales data
    String selectedYear = request.getParameter("year");
    String selectedMonth = request.getParameter("month");
    List<Object[]> monthlySalesReport = null;
    BigDecimal totalSales = BigDecimal.ZERO;

    // Only fetch data if the form was submitted
    boolean isFormSubmitted = "Show Report".equals(request.getParameter("action"));
    if (isFormSubmitted && selectedYear != null && selectedMonth != null) {
        monthlySalesReport = reservationDAO.getSalesByMonthAndYear(Integer.parseInt(selectedYear), Integer.parseInt(selectedMonth));
        for (Object[] sale : monthlySalesReport) {
            totalSales = totalSales.add((BigDecimal) sale[4]);
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Monthly Sales Report</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
</head>
<body>
    <div class="sales-report-container">
        <!-- Navbar -->
        <div class="navbar">
            <a href="managerDashboard.jsp">Back to Dashboard</a>
        </div>
        
        <!-- Page Title and Form -->
        <h2>Monthly Sales Report</h2>
        <form action="salesReports.jsp" method="get">
            <label for="year">Year:</label>
            <select name="year" id="year">
                <% for (Integer year : years) { %>
                    <option value="<%= year %>" <%= year.toString().equals(selectedYear) ? "selected" : "" %>><%= year %></option>
                <% } %>
            </select>
            <label for="month">Month:</label>
            <select name="month" id="month">
                <% for (int i = 1; i <= 12; i++) { %>
                    <option value="<%= i %>" <%= selectedMonth != null && i == Integer.parseInt(selectedMonth) ? "selected" : "" %>><%= i %>-<%= new DateFormatSymbols().getMonths()[i-1] %></option>
                <% } %>
            </select>
            <button type="submit" name="action" value="Show Report">Show Report</button>
        </form>
        
        <!-- Sales Report Table -->
        <% if (isFormSubmitted && monthlySalesReport != null && !monthlySalesReport.isEmpty()) { %>
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
                <% for (Object[] row : monthlySalesReport) { %>
                <tr>
                    <td><%= row[0] %></td>
                    <td><%= row[1] + " " + row[2] %></td>
                    <td><%= new SimpleDateFormat("yyyy-MM-dd").format(row[3]) %></td>
                    <td>$<%= ((BigDecimal) row[4]).toPlainString() %></td>
                </tr>
                <% } %>
                <tr class="total-row">
                    <td colspan="3">Total Sales</td>
                    <td>$<%= totalSales.toPlainString() %></td>
                </tr>
            </tbody>
        </table>
        <% } else if (isFormSubmitted) { %>
            <p>No sales data available for the selected period.</p>
        <% } %>
    </div>
</body>
</html>


