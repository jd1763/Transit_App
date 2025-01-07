<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.util.*, dao.TrainDAO, dao.StationDAO, dao.StopsAtDAO, dao.TransitLineDAO, dao.TrainScheduleDAO, model.Train, model.Station, model.TransitLine, model.TrainSchedule, model.StopsAt" %>
<%
    // Check if the user is logged in and has manager privileges
    String role = (String) session.getAttribute("role");
    if (role == null || !"rep".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    TrainDAO trainDAO = new TrainDAO();
    StationDAO stationDAO = new StationDAO();
    TransitLineDAO transitLineDAO = new TransitLineDAO();
    TrainScheduleDAO trainScheduleDAO = new TrainScheduleDAO();
    StopsAtDAO stopsAtDAO = new StopsAtDAO();

    List<Train> unusedTrains = trainDAO.getUnusedTrains();
    List<Station> allStations = stationDAO.getAllStations();
    List<TransitLine> transitLines = transitLineDAO.getAllTransitLines();

    String action = request.getParameter("action");
    String message = null;

    if ("addTrain".equals(action)) {
        int trainID = Integer.parseInt(request.getParameter("trainID"));
        boolean success = trainDAO.addTrain(trainID);
        message = success ? "Train added successfully." : "Train ID already exists. Please use a different Train ID.";
    } else if ("addStation".equals(action)) {
        String name = request.getParameter("stationName");
        String city = request.getParameter("city");
        String state = request.getParameter("state");
        boolean success = stationDAO.addStation(name, city, state);
        message = success ? "Station added successfully." : "Station already exists with the same details.";
    } else if ("addTransitLine".equals(action)) {
        String name = request.getParameter("transitLineName");
        float baseFare = Float.parseFloat(request.getParameter("baseFare"));
        int totalStops = Integer.parseInt(request.getParameter("totalStops"));
        boolean success = transitLineDAO.addTransitLine(name, baseFare, totalStops);
        message = success ? "Transit Line added successfully." : "Transit Line with the same name already exists.";
    } else if ("addSchedule".equals(action)) {
        int transitID = Integer.parseInt(request.getParameter("transitLine"));
        int trainID = Integer.parseInt(request.getParameter("trainID"));
        int originID = Integer.parseInt(request.getParameter("originStation"));
        int destinationID = Integer.parseInt(request.getParameter("destinationStation"));
        String departureDateTime = request.getParameter("departureDateTime");
        String arrivalDateTime = request.getParameter("arrivalDateTime");
        String tripDirection = request.getParameter("tripDirection");

        if (departureDateTime == null || departureDateTime.isEmpty() || 
            arrivalDateTime == null || arrivalDateTime.isEmpty()) {
            message = "Departure and Arrival times cannot be empty.";
        } else {
	       	try {
	       	    // Convert departure and arrival times to Timestamps
	       	    java.sql.Timestamp departureTimestamp = java.sql.Timestamp.valueOf(departureDateTime);
	       	    java.sql.Timestamp arrivalTimestamp = java.sql.Timestamp.valueOf(arrivalDateTime);
	
	       	    // Create the train schedule
	       	    TrainSchedule schedule = trainScheduleDAO.createTrainSchedule(
	       	        transitID, trainID, originID, destinationID, 
	       	        departureTimestamp, arrivalTimestamp, tripDirection
	       	    );
	
	       	    if (schedule == null) {
	       	        throw new Exception("Failed to create Train Schedule.");
	       	    }
	
	       	    // Prepare stops
	       	    List<StopsAt> stops = new ArrayList<>();
	       	    int totalStops = transitLineDAO.getTotalStops(transitID);
	       	    System.out.println("Total stops: " + totalStops);
	
	       	    // Add the origin stop
	       	    stops.add(new StopsAt(schedule.getScheduleID(), originID, 1, null, departureTimestamp));
	
	       	    // Add intermediate stops (if any)
	       	    for (int i = 2; i < totalStops; i++) {
	       	        String stationParam = request.getParameter("stations[" + i + "]");
	       	        String arrivalParam = request.getParameter("arrivalTimes[" + i + "]");
	       	        String departureParam = request.getParameter("departureTimes[" + i + "]");
	
	       	        System.out.println("Intermediate Stop: " + stationParam + " " + arrivalParam + " " + departureParam);
	
	       	        if (stationParam == null || arrivalParam == null || departureParam == null) {
	       	            throw new IllegalArgumentException("Missing parameters for stop: " + i);
	       	        }
	
	       	        int stationID = Integer.parseInt(stationParam);
	       	        java.sql.Timestamp arrival = java.sql.Timestamp.valueOf(arrivalParam);
	       	        java.sql.Timestamp departure = java.sql.Timestamp.valueOf(departureParam);
	
	       	        stops.add(new StopsAt(schedule.getScheduleID(), stationID, i, arrival, departure));
	       	    }
	
	       	    // Add the destination stop
	       	    stops.add(new StopsAt(schedule.getScheduleID(), destinationID, totalStops, arrivalTimestamp, null));
	
	       	    // Add stops to the database
	       	    boolean success = stopsAtDAO.addStops(stops);
	       	    message = success ? "Train Schedule and stops added successfully."
	       	                      : "Failed to add stops.";
	       	} catch (IllegalArgumentException e) {
	       	    e.printStackTrace();
	       	    message = "Invalid datetime format. Please ensure the format is YYYY-MM-DD HH:MM:SS.";
	       	} catch (Exception e) {
	       	    e.printStackTrace();
	       	    message = "Error: " + e.getMessage();
	       	}
        }
    }


%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Schedules</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
    <!-- Include a Date-Time Picker Library -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/flatpickr/4.6.13/flatpickr.min.css">
</head>
<body>
    <div class="manage-schedule-container">
        <!-- Navbar -->
        <div class="navbar">
            <a href="managerDashboard.jsp">Back to Dashboard</a>
        </div>

        <h2>Manage Schedules</h2>

        <!-- Toaster Notification -->
        <% if (message != null) { %>
            <div class="toaster <%= message.contains("successfully") ? "success" : "error" %>">
                <%= message %>
            </div>
        <% } %>

        <!-- Add Train Section -->
        <h3>Add Train</h3>
        <form action="repAddSchedules.jsp" method="post">
            <input type="hidden" name="action" value="addTrain">
            <label for="trainID">Train ID (4-digit number):</label>
            <input type="number" id="trainID" name="trainID" required><br>
            <button type="submit">Add Train</button>
        </form>

        <!-- Add Station Section -->
        <h3>Add Station</h3>
        <form action="repAddSchedules.jsp" method="post">
            <input type="hidden" name="action" value="addStation">
            <label for="stationName">Station Name:</label>
            <input type="text" id="stationName" name="stationName" required><br>
            <label for="city">City:</label>
            <input type="text" id="city" name="city" required><br>
            <label for="state">State:</label>
            <input type="text" id="state" name="state" required><br>
            <button type="submit">Add Station</button>
        </form>
        
         <!-- Add Transit Line Section -->
        <h3>Add Transit Line</h3>
        <form action="repAddSchedules.jsp" method="post">
            <input type="hidden" name="action" value="addTransitLine">
            <label for="transitLineName">Transit Line Name:</label>
            <input type="text" id="transitLineName" name="transitLineName" required><br>
            <label for="baseFare">Base Fare:</label>
            <input type="number" step="0.01" id="baseFare" name="baseFare" required><br>
            <label for="totalStops">Total Stops:</label>
            <input type="number" id="totalStops" name="totalStops" required><br>
            <button type="submit">Add Transit Line</button>
        </form>
        
        <!-- Add Train Schedule Section -->
        <h3>Add Train Schedule</h3>
        <form action="repAddSchedules.jsp" method="post">
            <input type="hidden" name="action" value="addSchedule">
            <input type="hidden" name="totalStops" value="">

            <label for="transitLine">Select Transit Line:</label>
            <select id="transitLine" name="transitLine" required>
                <option value="" selected disabled>Select Transit Line</option>
                <% for (TransitLine transitLine : transitLines) { %>
                    <option value="<%= transitLine.getTransitID() %>" data-total-stops="<%= transitLine.getTotalStops() %>">
                        <%= transitLine.getTransitLineName() %>
                    </option>
                <% } %>
            </select><br>

            <label for="trainID">Select Train:</label>
            <select id="trainID" name="trainID" required>
                <% for (Train train : unusedTrains) { %>
                    <option value="<%= train.getTrainID() %>">Train <%= train.getTrainID() %></option>
                <% } %>
            </select><br>

            <label for="originStation">Select Origin Station:</label>
            <select id="originStation" name="originStation" required>
                <% for (Station station : allStations) { %>
                    <option value="<%= station.getStationID() %>"><%= station.getName() %> (<%= station.getCity() %>, <%= station.getState() %>)</option>
                <% } %>
            </select><br>

            <label for="destinationStation">Select Destination Station:</label>
            <select id="destinationStation" name="destinationStation" required>
                <% for (Station station : allStations) { %>
                    <option value="<%= station.getStationID() %>"><%= station.getName() %> (<%= station.getCity() %>, <%= station.getState() %>)</option>
                <% } %>
            </select><br>

            <label for="departureDateTime">Departure Date & Time:</label>
            <input type="text" id="departureDateTime" name="departureDateTime" required><br>

            <label for="arrivalDateTime">Arrival Date & Time:</label>
            <input type="text" id="arrivalDateTime" name="arrivalDateTime" required><br>

            <label for="tripDirection">Trip Direction:</label>
            <select id="tripDirection" name="tripDirection" required>
                <option value="forward">Forward</option>
                <option value="return">Return</option>
            </select><br>

            <!-- Dynamic Stops Section -->
            <div id="stopsContainer" class="stops-container" style="display: none;">
                <h3>Configure Stops</h3>
                <div id="originStop" class="stop">
                    <h4>Origin Stop</h4>
                    <p>Station: <span id="originStationName"></span></p>
                    <label>Departure Time:</label>
                    <input type="text" id="originDepartureTime" readonly><br>
                </div>
                <div id="intermediateStops"></div>
                <div id="destinationStop" class="stop">
                    <h4>Destination Stop</h4>
                    <p>Station: <span id="destinationStationName"></span></p>
                    <label>Arrival Time:</label>
                    <input type="text" id="destinationArrivalTime" readonly><br>
                </div>
            </div>

            <button type="submit">Add Train Schedule</button>
        </form>
    </div>

    <!-- Include JavaScript for Date-Time Picker -->
	<script src="https://cdnjs.cloudflare.com/ajax/libs/flatpickr/4.6.13/flatpickr.min.js"></script>
	<script>
	    document.addEventListener("DOMContentLoaded", () => {
	        const transitLineSelect = document.getElementById("transitLine");
	        const stopsContainer = document.getElementById("stopsContainer");
	        const intermediateStops = document.getElementById("intermediateStops");
	        const originStationSelect = document.getElementById("originStation");
	        const destinationStationSelect = document.getElementById("destinationStation");
	        const originStationName = document.getElementById("originStationName");
	        const destinationStationName = document.getElementById("destinationStationName");
	        const departureDateTime = document.getElementById("departureDateTime");
	        const arrivalDateTime = document.getElementById("arrivalDateTime");
	        const originDepartureTime = document.getElementById("originDepartureTime");
	        const destinationArrivalTime = document.getElementById("destinationArrivalTime");
	        const form = document.querySelector("form[action='repAddSchedules.jsp']");
	        
	        // Initialize Flatpickr for Date-Time Pickers
	        flatpickr(departureDateTime, { enableTime: true, dateFormat: "Y-m-d H:i:S" });
	        flatpickr(arrivalDateTime, { enableTime: true, dateFormat: "Y-m-d H:i:S" });
	
	        // Populate Stops Based on Transit Line Selection
	        transitLineSelect.addEventListener("change", () => {
	            const totalStops = parseInt(transitLineSelect.options[transitLineSelect.selectedIndex]?.getAttribute("data-total-stops") || 0);
	            stopsContainer.style.display = totalStops > 0 ? "block" : "none";
	            intermediateStops.innerHTML = "";
	
	            for (let i = 2; i < totalStops; i++) {
	                const stopDiv = document.createElement("div");
	                stopDiv.classList.add("stop");
	                stopDiv.innerHTML = `
	                    <h4>Stop \${i}</h4> <!-- Escape ${i} -->
	                    <label>Station:</label>
	                    <select name="stations[\${i}]" class="station-select" required>
	                        <% for (Station station : allStations) { %>
	                            <option value="<%= station.getStationID() %>"><%= station.getName() %></option>
	                        <% } %>
	                    </select><br>
	                    <label>Arrival Time:</label>
	                    <input type="text" name="arrivalTimes[\${i}]" class="arrival-picker" required><br>
	                    <label>Departure Time:</label>
	                    <input type="text" name="departureTimes[\${i}]" class="departure-picker" required><br>
	                `;
	                intermediateStops.appendChild(stopDiv);
	            }
	
	            flatpickr(".arrival-picker", {
	                enableTime: true,
	                dateFormat: "Y-m-d H:i:S",
	                minDate: departureDateTime.value,
	                maxDate: arrivalDateTime.value,
	            });
	            flatpickr(".departure-picker", {
	                enableTime: true,
	                dateFormat: "Y-m-d H:i:S",
	                minDate: departureDateTime.value,
	                maxDate: arrivalDateTime.value,
	            });
	        });
	
	        // Reflect Selected Departure and Arrival Times
	        departureDateTime.addEventListener("change", () => {
	            originDepartureTime.value = departureDateTime.value;
	        });
	        arrivalDateTime.addEventListener("change", () => {
	            destinationArrivalTime.value = arrivalDateTime.value;
	        });
	
	        // Update Station Names in Stops Section
	        function updateStops() {
	            originStationName.textContent = originStationSelect.options[originStationSelect.selectedIndex]?.text || "";
	            destinationStationName.textContent = destinationStationSelect.options[destinationStationSelect.selectedIndex]?.text || "";
	        }
	
	        originStationSelect.addEventListener("change", updateStops);
	        destinationStationSelect.addEventListener("change", updateStops);
	        updateStops();
	     // Log `stations[i]` Values When Selected (Event Delegation)
	        intermediateStops.addEventListener("change", (event) => {
	            if (event.target && event.target.classList.contains("station-select")) {
	                console.log(`Station selected for ${event.target.name}: ${event.target.value}`);
	            }
	        });
	        document.querySelector("form[action='repAddSchedules.jsp']").addEventListener("submit", (event) => {
	            console.log("Form is being submitted...");
	            window.location.reload();
	        });
	    });
	</script>
    
</body>
</html>
