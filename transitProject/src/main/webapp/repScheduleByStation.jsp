<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*,java.text.*, dao.TrainScheduleDAO, dao.TransitLineDAO, dao.StationDAO, model.TrainSchedule, model.Station" %>
<%
   String role = (String) session.getAttribute("role");
   if (role == null || !"rep".equals(role)) {
       response.sendRedirect("login.jsp"); // Redirect to login if not a customer representative
       return;
   }
   
   SimpleDateFormat formatter = new SimpleDateFormat("EEEE, MMMM d, yyyy - h:mm a");

   // DAOs
   StationDAO stationDAO = new StationDAO();
   TrainScheduleDAO scheduleDAO = new TrainScheduleDAO();
   TransitLineDAO transitLineDAO = new TransitLineDAO();

   // Form parameters
   String stationIDParam = request.getParameter("station");

   List<TrainSchedule> schedules = new ArrayList<>();

   // Fetch schedules if search criteria are provided
   if (stationIDParam != null) {
       int stationID = Integer.parseInt(stationIDParam);

       schedules = scheduleDAO.searchSchedulesByStationWithFares(stationID);
       System.out.print(schedules.size());

   }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Train Schedules for Station</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
</head>
<body>
    <div class="customer-schedule-container">
        <div class="navbar">
            <a href="customerDashboard.jsp">Back to Dashboard</a>
        </div>
        <div class="content">
            <h2>Train Schedules for a Station</h2>

            <!-- Search form -->
           <form action="repScheduleByStation.jsp" method="get" class="search-form">
			    <label for="station">Station:</label>
			    <select name="station" id="station" required>
			    	<option value="">Select a station...</option>
			        <% for (Station station : stationDAO.getAllStations()) { %>
			            <option value="<%= station.getStationID() %>" 
			                <%= stationIDParam != null && stationIDParam.equals(String.valueOf(station.getStationID())) ? "selected" : "" %>>
			                <%= station.getName() %>
			            </option>
			        <% } %>
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
