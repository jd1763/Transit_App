<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.text.SimpleDateFormat, dao.TrainScheduleDAO, dao.StopsAtDAO, dao.TransitLineDAO, dao.StationDAO, model.StopsAt, model.TrainSchedule" %>
<%

	//Ensure the user is logged in as a customer
	String role = (String) session.getAttribute("role");
	if (role == null || !"customer".equals(role)) {
	    response.sendRedirect("login.jsp");
	    return;
	}

   // Retrieve parameters and initialize DAOs as before
   String scheduleIDParam = request.getParameter("scheduleID");
   String originIDParam = request.getParameter("originID");
   String destinationIDParam = request.getParameter("destinationID");
   String baseFareParam = request.getParameter("baseFare");

   if (scheduleIDParam == null || originIDParam == null || destinationIDParam == null || baseFareParam == null) {
       response.sendRedirect("customerDashboard.jsp");
       return;
   }

   int scheduleID = Integer.parseInt(scheduleIDParam);
   int originID = Integer.parseInt(originIDParam);
   int destinationID = Integer.parseInt(destinationIDParam);
   float baseFare = Float.parseFloat(baseFareParam);

   // DAOs
   TrainScheduleDAO scheduleDAO = new TrainScheduleDAO();
   StopsAtDAO stopsAtDAO = new StopsAtDAO();
   StationDAO stationDAO = new StationDAO();
   TransitLineDAO transitLineDAO = new TransitLineDAO();

   // Get the schedule details
   TrainSchedule schedule = scheduleDAO.getTrainSchedule(scheduleID);
   List<StopsAt> stops = stopsAtDAO.getStopsByScheduleID(scheduleID);
   String transitLineName = transitLineDAO.getTransitLineName(schedule.getTransitID());

   // Get arrival time for the specific destination and find return schedules
   Date subrouteArrivalTime = stopsAtDAO.getArrivalTimeForStation(scheduleID, destinationID);
   List<TrainSchedule> returnSchedules = scheduleDAO.availableOppositeDirectionSchedules(
       schedule.getTransitID(), subrouteArrivalTime, schedule.getTripDirection(), destinationID, originID
   );
   SimpleDateFormat formatter = new SimpleDateFormat("EEEE, MMMM d, yyyy - h:mm a");
   boolean hasRoundTripAvailable = !returnSchedules.isEmpty();

%>
<!DOCTYPE html>
<html>
<head>
   <meta charset="UTF-8">
   <title>Schedule Details</title>
   <link rel="stylesheet" type="text/css" href="styles.css">
   <style>
       .return-schedule-details { display: none; } /* Hide all return schedule details initially */
   </style>
</head>
<body>
   <div class="customer-schedule-container">
       <div class="navbar">
           <a href="customerDashboard.jsp">Back to Dashboard</a>
       </div>
       <div class="schedule-details-container">
           <h2>Schedule Overview for Transit Line: <%= transitLineName %></h2>
           <p>Below is the overview of the transit line that belongs to your schedule. Origin is the start of your schedule, and destination is the end of your schedule.</p>

           <!-- Incoming Trip Overview -->
           <div class="schedule-overview">
               <h3>Incoming Trip</h3>
               <table>
                   <thead>
                       <tr>
                           <th>Stop Number</th>
                           <th>Station</th>
                           <th>Arrival Time</th>
                           <th>Departure Time</th>
                       </tr>
                   </thead>
                   <tbody>
                       <% for (StopsAt stop : stops) { %>
                           <tr>
                               <td><%= stop.getStopNumber() %>
                                   <% if (stop.getStationID() == originID) { %> (Origin)<% } 
                                      else if (stop.getStationID() == destinationID) { %> (Destination)<% } %>
                               </td>
                               <td><%= stationDAO.getStation(stop.getStationID()).getName() %></td>
                               <td><%= stop.getArrivalDateTime() != null ? formatter.format(stop.getArrivalDateTime()) : "Start of Route" %></td>
                               <td><%= stop.getDepartureDateTime() != null ? formatter.format(stop.getDepartureDateTime()) : "End of Route" %></td>
                           </tr>
                       <% } %>
                   </tbody>
               </table>
           </div>
           <!-- Round-Trip Selection -->
			<div class="round-trip-container">
			    <label for="returnSchedule">Round Trip:</label>
				<% int idx = 0; %>
			    
			    <% if (returnSchedules.isEmpty()) { %>
			        <!-- Display message if no return trips are available -->
			        <p>No return trips available for this schedule</p>
			    <% } else { %>
			        <!-- Display dropdown if return trips are available -->
			        <select id="returnSchedule" name="returnSchedule" onchange="showReturnDetails(this)">
			            <option value="">Select a Return Trip</option>
			            <% for (TrainSchedule returnSchedule : returnSchedules) { %>
			                <option value="return-schedule-<%= idx %>">
			                    Return: <%= formatter.format(returnSchedule.getDepartureDateTime()) %> - <%= formatter.format(returnSchedule.getArrivalDateTime()) %>
			                </option>
			                <% idx++; %>
			            <% } %>
			        </select>
			    <% } %>
			</div>
           <!-- Pre-populated Return Schedule Details -->
           <% idx = 0; %>
           <% for (TrainSchedule returnSchedule : returnSchedules) { %>
               <div id="return-schedule-<%= idx %>" class="return-schedule-details">
                   <h3>Return Trip Details</h3>
                   <table>
                       <thead>
                           <tr>
                               <th>Stop Number</th>
                               <th>Station</th>
                               <th>Arrival Time</th>
                               <th>Departure Time</th>
                           </tr>
                       </thead>
                       <tbody>
                           <% List<StopsAt> returnStops = stopsAtDAO.getStopsByScheduleID(returnSchedule.getScheduleID()); %>
                           <% for (StopsAt returnStop : returnStops) { %>
                               <tr>
                                   <td><%= returnStop.getStopNumber() %>
                                   <% if (returnStop.getStationID() == destinationID) { %> (Origin)<% } 
                                      else if (returnStop.getStationID() == originID) { %> (Destination)<% } %></td>                               
                                   <td><%= stationDAO.getStation(returnStop.getStationID()).getName() %></td>
                                   <td><%= returnStop.getArrivalDateTime() != null ? formatter.format(returnStop.getArrivalDateTime()) : "Start of Route" %></td>
                                   <td><%= returnStop.getDepartureDateTime() != null ? formatter.format(returnStop.getDepartureDateTime()) : "End of Route" %></td>
                               </tr>
                           <% } %>
                       </tbody>
                   </table>
               </div>
               <% idx++; %>
           <% } %>

           <!-- Fare and Make Reservation button -->
           <div class="fare-container">
               <p class="fare-label">Fare per one-way adult ticket: $<%= baseFare %></p>
               <form action="reservationDetails.jsp" method="get">
                   <input type="hidden" name="incomingScheduleID" value="<%= scheduleID %>">
                   <input type="hidden" name="returningScheduleID" id="returnScheduleInput" value="">
                   <input type="hidden" name="originID" value="<%= originID %>">
                   <input type="hidden" name="destinationID" value="<%= destinationID %>">
                   <input type="hidden" name="baseFare" value="<%= baseFare %>">
                   <input type="hidden" name="hasRoundTripAvailable" value="<%= hasRoundTripAvailable %>">                   
                   <button type="submit" class="confirm-button">Make Reservation(s)</button>
               </form>
           </div>
       </div>
   </div>

   <script>
       function showReturnDetails(select) {
           // Hide all return schedule details
           document.querySelectorAll('.return-schedule-details').forEach(el => el.style.display = 'none');
           
           // Show selected return schedule details
           const selectedId = select.value;
           if (selectedId) {
               document.getElementById(selectedId).style.display = 'block';
               const idx = parseInt(selectedId.split('-')[2], 10);
               const returnSchedules = <%= returnSchedules.stream().map(TrainSchedule::getScheduleID).toList() %>;
               console.log(returnSchedules[idx]);
               document.getElementById('returnScheduleInput').value = returnSchedules[idx];
           }
       }
   </script>
</body>
</html>



