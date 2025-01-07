<%@ page import="java.util.*, dao.TrainScheduleDAO, dao.StopsAtDAO, dao.StationDAO, dao.TransitLineDAO, dao.TrainDAO, model.Station, model.TransitLine, model.TrainSchedule, model.StopsAt, model.Train" %>
<%
    // Check if the user is logged in and has manager privileges
    String role = (String) session.getAttribute("role");
    if (role == null || !"rep".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    TrainScheduleDAO trainScheduleDAO = new TrainScheduleDAO();
    StopsAtDAO stopsAtDAO = new StopsAtDAO();
    StationDAO stationDAO = new StationDAO();
    TransitLineDAO transitLineDAO = new TransitLineDAO();
    TrainDAO trainDAO = new TrainDAO();

    // Retrieve the scheduleID to edit
    int scheduleID = Integer.parseInt(request.getParameter("scheduleID"));

    // Retrieve the schedule, stops, stations, and available trains
    TrainSchedule schedule = trainScheduleDAO.getTrainSchedule(scheduleID);
    List<StopsAt> stops = stopsAtDAO.getStopsByScheduleID(scheduleID);
    List<Station> allStations = stationDAO.getAllStations();
    List<Train> allTrains = trainDAO.getAllTrains();
    String message = null;

    if ("edit".equals(request.getParameter("action"))) {
        try {
            // Get updated parameters
            int transitID = Integer.parseInt(request.getParameter("transitLine"));
            int trainID = Integer.parseInt(request.getParameter("trainID"));
            int originID = Integer.parseInt(request.getParameter("originStation"));
            int destinationID = Integer.parseInt(request.getParameter("destinationStation"));
            String departureDateTime = request.getParameter("departureDateTime");
            String arrivalDateTime = request.getParameter("arrivalDateTime");
            String tripDirection = request.getParameter("tripDirection");

            java.sql.Timestamp departureTimestamp = java.sql.Timestamp.valueOf(departureDateTime);
            java.sql.Timestamp arrivalTimestamp = java.sql.Timestamp.valueOf(arrivalDateTime);

            // Update the train schedule
            boolean success = trainScheduleDAO.updateTrainSchedule(
                transitID, trainID, originID, destinationID, 
                departureTimestamp, arrivalTimestamp, tripDirection, scheduleID
            );

            if (success) {
                // Update stops
                List<StopsAt> updatedStops = new ArrayList<>();
                for (int i = 1; i <= stops.size(); i++) {
                    int stationID = Integer.parseInt(request.getParameter("stations[" + i + "]"));
                    String stopArrival = request.getParameter("arrivalTimes[" + i + "]"); // Null for origin stop
                    String stopDeparture = request.getParameter("departureTimes[" + i + "]"); // Null for destination stop

                    java.sql.Timestamp arrival = stopArrival != null && !stopArrival.isEmpty()
                        ? java.sql.Timestamp.valueOf(stopArrival) : null;
                    java.sql.Timestamp departure = stopDeparture != null && !stopDeparture.isEmpty()
                        ? java.sql.Timestamp.valueOf(stopDeparture) : null;

                    updatedStops.add(new StopsAt(scheduleID, stationID, i, arrival, departure));
                }

                boolean stopsUpdated = stopsAtDAO.updateStops(scheduleID, updatedStops);
                message = stopsUpdated ? "Train Schedule updated successfully." : "Failed to update stops.";

                // Refetch the updated schedule and stops
                schedule = trainScheduleDAO.getTrainSchedule(scheduleID);
                stops = stopsAtDAO.getStopsByScheduleID(scheduleID);
            } else {
                message = "Failed to update Train Schedule.";
            }
        } catch (Exception e) {
            e.printStackTrace();
            message = "Error: " + e.getMessage();
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Train Schedule</title>
    <link rel="stylesheet" href="styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/flatpickr/4.6.13/flatpickr.min.css">
</head>
<body>
    <div class="edit-schedule-container">
    	<div class="navbar">
            <a href="managerDashboard.jsp">Back to Dashboard</a>
            <%
        	String referer = request.getHeader("referer");
            if (referer != null && !referer.isEmpty()) {
		    %>
		        <a href="repModifySchedules.jsp" class="back-to-schedule">Back to Schedule</a>
		    <%
		        }
		    %>
        </div>
        <h2>Edit Train Schedule</h2>

        <% if (message != null) { %>
            <div class="toaster <%= message.contains("successfully") ? "success" : "error" %>">
                <%= message %>
            </div>
        <% } %>

        <form action="repEditSchedule.jsp" method="post">
            <input type="hidden" name="action" value="edit">
            <input type="hidden" name="scheduleID" value="<%= scheduleID %>">

            <label for="transitLine">Transit Line:</label>
            <select id="transitLine" name="transitLine" required>
                <% for (TransitLine transitLine : transitLineDAO.getAllTransitLines()) { %>
                    <option value="<%= transitLine.getTransitID() %>"
                        <%= transitLine.getTransitID() == schedule.getTransitID() ? "selected" : "" %>>
                        <%= transitLine.getTransitLineName() %>
                    </option>
                <% } %>
            </select><br>

            <label for="trainID">Train:</label>
            <select id="trainID" name="trainID" required>
                <% for (Train train : allTrains) { %>
                    <option value="<%= train.getTrainID() %>"
                        <%= train.getTrainID() == schedule.getTrainID() ? "selected" : "" %>>
                        Train <%= train.getTrainID() %>
                    </option>
                <% } %>
            </select><br>

            <label for="originStation">Origin Station:</label>
            <select id="originStation" name="originStation" required>
                <% for (Station station : allStations) { %>
                    <option value="<%= station.getStationID() %>"
                        <%= station.getStationID() == schedule.getOriginID() ? "selected" : "" %>>
                        <%= station.getName() %>
                    </option>
                <% } %>
            </select><br>

            <label for="destinationStation">Destination Station:</label>
            <select id="destinationStation" name="destinationStation" required>
                <% for (Station station : allStations) { %>
                    <option value="<%= station.getStationID() %>"
                        <%= station.getStationID() == schedule.getDestinationID() ? "selected" : "" %>>
                        <%= station.getName() %>
                    </option>
                <% } %>
            </select><br>

            <label for="departureDateTime">Departure Date & Time:</label>
            <input type="text" id="departureDateTime" name="departureDateTime" value="<%= schedule.getDepartureDateTime() %>" required><br>

            <label for="arrivalDateTime">Arrival Date & Time:</label>
            <input type="text" id="arrivalDateTime" name="arrivalDateTime" value="<%= schedule.getArrivalDateTime() %>" required><br>

            <label for="tripDirection">Trip Direction:</label>
            <select id="tripDirection" name="tripDirection" required>
                <option value="forward" <%= "forward".equals(schedule.getTripDirection()) ? "selected" : "" %>>Forward</option>
                <option value="return" <%= "return".equals(schedule.getTripDirection()) ? "selected" : "" %>>Return</option>
            </select><br>

            <div id="stopsContainer">
                <h3>Stops</h3>
                <% for (int i = 0; i < stops.size(); i++) { 
                    StopsAt stop = stops.get(i); %>
                    <div class="stop">
                        <label>Station:</label>
                        <select name="stations[<%= i + 1 %>]" required>
                            <% for (Station station : allStations) { %>
                                <option value="<%= station.getStationID() %>"
                                    <%= station.getStationID() == stop.getStationID() ? "selected" : "" %>>
                                    <%= station.getName() %>
                                </option>
                            <% } %>
                        </select><br>
                        <% if (i > 0) { %> <!-- Ignore arrival time for origin -->
                            <label>Arrival Time:</label>
                            <input type="text" name="arrivalTimes[<%= i + 1 %>]" value="<%= stop.getArrivalDateTime() %>"><br>
                        <% } %>
                        <% if (i < stops.size() - 1) { %> <!-- Ignore departure time for destination -->
                            <label>Departure Time:</label>
                            <input type="text" name="departureTimes[<%= i + 1 %>]" value="<%= stop.getDepartureDateTime() %>"><br>
                        <% } %>
                    </div>
                <% } %>
            </div>

            <button type="submit">Save Changes</button>
        </form>
    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/flatpickr/4.6.13/flatpickr.min.js"></script>
    <script>
        document.addEventListener("DOMContentLoaded", () => {
            flatpickr("#departureDateTime", { enableTime: true, dateFormat: "Y-m-d H:i:S" });
            flatpickr("#arrivalDateTime", { enableTime: true, dateFormat: "Y-m-d H:i:S" });
         	// Dynamically initialize Flatpickr for intermediate stops
            document.querySelectorAll("input[name^='arrivalTimes'], input[name^='departureTimes']").forEach(input => {
                flatpickr(input, { enableTime: true, dateFormat: "Y-m-d H:i:S" });
            });
        });
    </script>
</body>
</html>
