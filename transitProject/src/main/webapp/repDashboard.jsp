<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Check if user is logged in as a customer representative
    String role = (String) session.getAttribute("role");
    if (role == null || !"rep".equals(role)) {
        response.sendRedirect("login.jsp"); // Redirect to login if not a customer representative
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Customer Representative Dashboard</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
</head>
<body>
    <div class="dashboard-container">
        <!-- Navbar -->
        <div class="navbar">
            <a href="repDashboard.jsp">Home</a>
            <a href="logout.jsp">Logout</a>
        </div>

        <!-- Content -->
        <div class="content">
            <h2>Welcome to the Employee Dashboard</h2>
            <p>Use the options below to manage reservations, train schedules, or respond to customer inquiries:</p>
            
            <!-- Action Buttons -->
            <div class="option-buttons">
           
                <!-- Respond to Customer Questions -->
                <form action="respondToCustomerQuestions.jsp" method="get">
                    <button type="submit" class="long-button">Respond to Customer Questions</button>
                </form>
                
                <form action="repModifySchedules.jsp" method="get">
                    <button type="submit" class="long-button">Modify Train Schedules</button>
                </form>
                
                 <!-- list of all customers who have reservations on a given transit line and date -->
                <form action="repCustomerReservations.jsp" method="get">
                    <button type="submit" class="long-button">Customer Reservations</button>
                </form>
                
                <!-- List of Train Schedules For A Given Station -->
                <form action="repScheduleByStation.jsp" method="get">
                    <button type="submit" class="long-button">List of Schedules For A Given Station</button>
                </form>
                
            </div>
        </div>
    </div>
</body>
</html>