<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, dao.ReservationDAO" %>
<%
    String role = (String) session.getAttribute("role");
    if (role == null || !"manager".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    ReservationDAO dao = new ReservationDAO();
    List<Object[]> activeTransitLines = dao.getTopActiveTransitLines();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Most Active Transit Lines</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
</head>
<body>
    <div class="navbar">
        <a href="managerDashboard.jsp">Back to Dashboard</a>
    </div>
    <div class="transit-lines-container">
        <h2>Top 5 Most Active Transit Lines</h2>
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Rank</th>
                        <th>Transit Line Name</th>
                        <th>Total Reservations</th>
                    </tr>
                </thead>
                <tbody>
                    <% int rank = 1;
                       for (Object[] line : activeTransitLines) {
                           String transitLineName = (String) line[0];
                           Integer reservationCount = (Integer) line[1];
                    %>
                    <tr>
                        <td><%= rank %></td>
                        <td><%= transitLineName %></td>
                        <td><%= reservationCount %></td>
                    </tr>
                    <% rank++;
                       } %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
