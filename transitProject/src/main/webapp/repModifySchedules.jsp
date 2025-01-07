<%@ page import="java.text.SimpleDateFormat, java.util.*, dao.TrainScheduleDAO, dao.TransitLineDAO, dao.StationDAO, model.TrainSchedule" %>
<%
    // Check if the user is logged in and has manager privileges
    String role = (String) session.getAttribute("role");
    if (role == null || !"rep".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    TrainScheduleDAO trainScheduleDAO = new TrainScheduleDAO();
    TransitLineDAO transitLineDAO = new TransitLineDAO();
    StationDAO stationDAO = new StationDAO();

    // Retrieve the selected date from the request
    String selectedDate = request.getParameter("selectedDate");

    if (selectedDate != null && !selectedDate.isEmpty()) {
        session.setAttribute("selectedDate", selectedDate);
    } else {
        // Retrieve the previously selected date from the session
        selectedDate = (String) session.getAttribute("selectedDate");
    }
    
    // Fetch train schedules based on the selected date
    List<TrainSchedule> trainSchedules = null;
    if (selectedDate != null && !selectedDate.isEmpty()) {
        java.sql.Date sqlDate = java.sql.Date.valueOf(selectedDate);
        trainSchedules = trainScheduleDAO.getAllUnreservedTrainSchedules(sqlDate);
    }

    String action = request.getParameter("action");
    String message = null;

    if ("delete".equals(action)) {
    	java.sql.Date sqlDate = java.sql.Date.valueOf(selectedDate);
        int scheduleID = Integer.parseInt(request.getParameter("scheduleID"));
        boolean success = trainScheduleDAO.deleteTrainSchedule(scheduleID);
        trainScheduleDAO.getAllUnreservedTrainSchedules(sqlDate);
        message = success ? "Train Schedule deleted successfully." : "Failed to delete Train Schedule.";
        response.sendRedirect("repModifySchedules.jsp");
        
    }

    SimpleDateFormat f = new SimpleDateFormat("EEEE, MMMM d, yyyy - h:mm a");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Train Schedules</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
    <!-- Include Flatpickr Library -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/flatpickr/4.6.13/flatpickr.min.css">
</head>
<body>
    <div class="modify-schedules-container">
        <div class="navbar">
            <a href="managerDashboard.jsp">Back to Dashboard</a>
        </div>
        <h2>Manage Train Schedules</h2>

        <!-- Toaster Notification -->
        <% if (message != null) { %>
            <div class="toaster <%= message.contains("successfully") ? "success" : "error" %>">
                <%= message %>
            </div>
        <% } %>

        <!-- Date Picker and Search -->
        <form action="repModifySchedules.jsp" method="get">
            <label for="selectedDate">Select Date:</label>
            <input type="text" id="selectedDate" name="selectedDate" placeholder="YYYY-MM-DD"
                   value="<%= selectedDate != null ? selectedDate : "" %>">
            <button type="submit">Search</button>
        </form>

        <% if (selectedDate != null && !selectedDate.isEmpty()) { %>
            <!-- Train Schedules Table -->
            <table>
                <thead>
                    <tr>
                        <th>Transit Line</th>
                        <th>Origin</th>
                        <th>Destination</th>
                        <th>Departure</th>
                        <th>Arrival</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (trainSchedules != null && !trainSchedules.isEmpty()) { %>
                        <% for (TrainSchedule schedule : trainSchedules) { %>
                            <tr>
                                <td><%= transitLineDAO.getTransitLineName(schedule.getTransitID()) %></td>
                                <td><%= stationDAO.getStation(schedule.getOriginID()).getName() %></td>
                                <td><%= stationDAO.getStation(schedule.getDestinationID()).getName() %></td>
                                <td><%= f.format(schedule.getDepartureDateTime()) %></td>
                                <td><%= f.format(schedule.getArrivalDateTime()) %></td>
                                <td>
                                    <form action="repEditSchedule.jsp" method="get" style="display: inline;">
                                        <input type="hidden" name="scheduleID" value="<%= schedule.getScheduleID() %>">
                                        <button type="submit">Edit</button>
                                    </form>
                                    <form action="repModifySchedules.jsp" method="post" style="display: inline;">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="scheduleID" value="<%= schedule.getScheduleID() %>">
                                        <button type="submit" onclick="return confirm('Are you sure you want to delete this schedule?');">Delete</button>
                                    </form>
                                </td>
                            </tr>
                        <% } %>
                    <% } else { %>
                        <tr>
                            <td colspan="6">No train schedules found for the selected date.</td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        <% } %>
    </div>

    <!-- Include Flatpickr Script -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/flatpickr/4.6.13/flatpickr.min.js"></script>
    <script>
        document.addEventListener("DOMContentLoaded", () => {
            // Initialize Flatpickr for the date picker
            flatpickr("#selectedDate", {
                dateFormat: "Y-m-d"
            });
        });
    </script>
</body>
</html>

