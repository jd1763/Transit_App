<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*,java.text.*, dao.TrainScheduleDAO, dao.TransitLineDAO, dao.StationDAO, model.TrainSchedule, model.Station" %>
<%
   String role = (String) session.getAttribute("role");
   if (role == null || !"customer".equals(role)) {
       response.sendRedirect("login.jsp");
       return;
   }

   SimpleDateFormat formatter = new SimpleDateFormat("EEEE, MMMM d, yyyy - h:mm a");

   // DAOs
   StationDAO stationDAO = new StationDAO();
   TrainScheduleDAO scheduleDAO = new TrainScheduleDAO();
   TransitLineDAO transitLineDAO = new TransitLineDAO();

   // Retrieve search input parameters
   String originIDParam = request.getParameter("origin");
   String destinationIDParam = request.getParameter("destination");
   String travelDateParam = request.getParameter("travelDate");
   String sortBy = request.getParameter("sortBy");

   // Persist search inputs in session
   if (originIDParam != null) {
       session.setAttribute("originID", originIDParam);
   } else {
       originIDParam = (String) session.getAttribute("originID");
   }

   if (destinationIDParam != null) {
       session.setAttribute("destinationID", destinationIDParam);
   } else {
       destinationIDParam = (String) session.getAttribute("destinationID");
   }

   if (travelDateParam != null) {
       session.setAttribute("travelDate", travelDateParam);
   } else {
       travelDateParam = (String) session.getAttribute("travelDate");
   }

   if (sortBy != null) {
       session.setAttribute("sortBy", sortBy);
   } else {
       sortBy = (String) session.getAttribute("sortBy");
   }

   // Fetch schedules based on inputs
   List<TrainSchedule> schedules = new ArrayList<>();
   if (originIDParam != null && destinationIDParam != null && travelDateParam != null) {
       int originID = Integer.parseInt(originIDParam);
       int destinationID = Integer.parseInt(destinationIDParam);
       Date travelDate = java.sql.Date.valueOf(travelDateParam);

       schedules = scheduleDAO.searchSchedules(originID, destinationID, travelDate);

       // Sort schedules based on criteria
       if (sortBy != null) {
           if (sortBy.equals("arrival")) {
               schedules.sort(Comparator.comparing(TrainSchedule::getArrivalDateTime));
           } else if (sortBy.equals("departure")) {
               schedules.sort(Comparator.comparing(TrainSchedule::getDepartureDateTime));
           } else if (sortBy.equals("fare")) {
               schedules.sort(Comparator.comparingDouble(TrainSchedule::getFare));
           }
       }
   }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Browse Schedules</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
</head>
<body>
    <div class="customer-schedule-container">
        <div class="navbar">
            <a href="customerDashboard.jsp">Back to Dashboard</a>
        </div>
        <div class="content">
            <h2>Browse and Search Train Schedules</h2>

            <!-- Search form -->
            <form action="customerSchedules.jsp" method="get" class="search-form">
                <label for="origin">Origin:</label>
                <select name="origin" id="origin" required>
                    <% for (Station station : stationDAO.getAllStations()) { %>
                        <option value="<%= station.getStationID() %>" 
                            <%= originIDParam != null && originIDParam.equals(String.valueOf(station.getStationID())) ? "selected" : "" %>>
                            <%= station.getName() %>
                        </option>
                    <% } %>
                </select>

                <label for="destination">Destination:</label>
                <select name="destination" id="destination" required>
                    <% for (Station station : stationDAO.getAllStations()) { %>
                        <option value="<%= station.getStationID() %>" 
                            <%= destinationIDParam != null && destinationIDParam.equals(String.valueOf(station.getStationID())) ? "selected" : "" %>>
                            <%= station.getName() %>
                        </option>
                    <% } %>
                </select>

                <label for="travelDate">Travel Date:</label>
                <input type="date" id="travelDate" name="travelDate" 
                       value="<%= travelDateParam != null ? travelDateParam : "" %>" required>
				<script>
				    const today = new Date().toISOString().split('T')[0];
				    document.getElementById('travelDate').setAttribute('min', today);
				</script>

                <label for="sortBy">Sort By:</label>
                <select name="sortBy" id="sortBy">
                    <option value="arrival" <%= "arrival".equals(sortBy) ? "selected" : "" %>>Arrival Time</option>
                    <option value="departure" <%= "departure".equals(sortBy) ? "selected" : "" %>>Departure Time</option>
                    <option value="fare" <%= "fare".equals(sortBy) ? "selected" : "" %>>Fare</option>
                </select>

                <button type="submit">Search</button>
            </form>

            <!-- Display search results -->
            <div class="results">
                <h3>Search Results</h3>
                <% if (schedules.isEmpty()) { %>
                    <p>No schedules found for the selected criteria.</p>
                <% } else { %>
                    <table> 
                        <thead>
                            <tr>
                                <th>Transit Line</th>
                                <th>Train</th>
                                <th>Origin</th>
                                <th>Destination</th>
                                <th>Departure</th>
                                <th>Arrival</th>
                                <th>Fare</th>
                                <th>Travel Time</th>
                                <th>Details</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (TrainSchedule schedule : schedules) { %>
                                <tr>
                                    <td><%= transitLineDAO.getTransitLineName(schedule.getTransitID()) %></td>
                                    <td><%= schedule.getTrainID() %></td>
                                    <td><%= stationDAO.getStation(schedule.getOriginID()).getName() %></td>
                                    <td><%= stationDAO.getStation(schedule.getDestinationID()).getName() %></td>
                                    <td><%= formatter.format(schedule.getDepartureDateTime()) %></td>
                                    <td><%= formatter.format(schedule.getArrivalDateTime()) %></td>
                                    <td><%= "$" + (Math.round(schedule.getFare() * 100.0) / 100.0) %></td>
                                    <td><%= schedule.getTravelTime() %> mins</td>
                                    <td>
                                        <form action="scheduleDetails.jsp" method="get" style="display:inline;">
                                            <input type="hidden" name="scheduleID" value="<%= schedule.getScheduleID() %>">
                                            <input type="hidden" name="originID" value="<%= schedule.getOriginID() %>">
                                            <input type="hidden" name="destinationID" value="<%= schedule.getDestinationID() %>">
                                            <input type="hidden" name="baseFare" value="<%= (Math.round(schedule.getFare() * 100.0) / 100.0) %>">
                                            <button type="submit" class="open-button">Open</button>
                                        </form>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } %>
            </div>
        </div>
    </div>
</body>
</html>

