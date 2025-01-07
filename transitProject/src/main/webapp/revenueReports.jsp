<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, dao.CustomerDAO, dao.ReservationDAO, dao.TransitLineDAO, java.math.BigDecimal, java.text.SimpleDateFormat" %>
<%
    String role = (String) session.getAttribute("role");
    if (role == null || !"manager".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    ReservationDAO reservationDAO = new ReservationDAO();
    TransitLineDAO transitLineDAO = new TransitLineDAO();
    CustomerDAO customerDAO = new CustomerDAO();
    String action = request.getParameter("action");
    String selectedItem = request.getParameter("selectedItem");
    String submit = request.getParameter("submit"); // New parameter to check if the 'Show Report' button was pressed
    List<Object[]> detailsData = null;
    List<String> dropdownItems = null;

    if ("Show Report".equals(submit) && selectedItem != null && !selectedItem.isEmpty()) {
        if ("Transit Line Revenue".equals(action)) {
            detailsData = reservationDAO.getDetailsByTransitLine(selectedItem);
        } else if ("Customer Revenue".equals(action)) {
            detailsData = reservationDAO.getDetailsByCustomerName(selectedItem);
        }
    }

    if ("Transit Line Revenue".equals(action)) {
        dropdownItems = transitLineDAO.getAllTransitLineNames();
    } else if ("Customer Revenue".equals(action)) {
        dropdownItems = customerDAO.getAllCustomerNames();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Revenue Reports</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
</head>
<body>
    <div class="revenue-report-container">
        <div class="navbar">
            <a href="managerDashboard.jsp">Back to Dashboard</a>
        </div>
        <h2>Revenue Reports</h2>
        <form action="revenueReports.jsp" method="post">
            <select name="action" onchange="this.form.submit()">
                <option value="">Select Report Type...</option>
                <option value="Transit Line Revenue" <%= "Transit Line Revenue".equals(action) ? "selected" : "" %>>Revenue by Transit Line</option>
                <option value="Customer Revenue" <%= "Customer Revenue".equals(action) ? "selected" : "" %>>Revenue by Customer Name</option>
            </select>
        </form>

        <% if (dropdownItems != null && !dropdownItems.isEmpty()) { %>
            <form action="revenueReports.jsp" method="post">
                <input type="hidden" name="action" value="<%= action %>">
                <select name="selectedItem">
                    <option>Select...</option>
                    <% for (String item : dropdownItems) { %>
                        <option value="<%= item %>" <%= item.equals(selectedItem) ? "selected" : "" %>><%= item %></option>
                    <% } %>
                </select>
                <button type="submit" name="submit" value="Show Report">Show Report</button>
            </form>
        <% } %>

		<% if (detailsData != null && !detailsData.isEmpty()) { %>
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
		            <% BigDecimal totalRevenue = BigDecimal.ZERO;
		               for (Object[] row : detailsData) {
		                   totalRevenue = totalRevenue.add((BigDecimal)row[3]); %>
		            <tr>
		                <td><%= row[0] %></td>
		                <td><%= row[1] %></td>
		                <td><%= new SimpleDateFormat("yyyy-MM-dd").format(row[2]) %></td>
		                <td>$<%= ((BigDecimal)row[3]).toString() %></td>
		            </tr>
		            <% } %>
		            <tr>
		                <td colspan="3">Total Revenue:</td>
		                <td>$<%= totalRevenue.toString() %></td>
		            </tr>
		        </tbody>
		    </table>
		<% } else { %>
		    <p>No revenue report found</p>
		<% } %>
    </div>
</body>
</html>
