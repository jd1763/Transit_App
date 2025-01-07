<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, dao.TrainScheduleDAO, dao.CustomerDAO, model.TrainSchedule" %>
<%
    // Ensure the user is logged in as a customer
    String role = (String) session.getAttribute("role");
    if (role == null || !"customer".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Retrieve schedule details passed from scheduleDetails.jsp
    String inScheduleIDParam = request.getParameter("incomingScheduleID");
    String reScheduleIDParam = request.getParameter("returningScheduleID");
    String originIDParam = request.getParameter("originID");
    String destinationIDParam = request.getParameter("destinationID");
    String baseFareParam = request.getParameter("baseFare");
    String hasRoundTripAvailable = request.getParameter("hasRoundTripAvailable");

    int incomingScheduleID = Integer.parseInt(inScheduleIDParam);
    int returningScheduleID = -1;
    if (reScheduleIDParam != null && !reScheduleIDParam.isEmpty()) {
        returningScheduleID = Integer.parseInt(reScheduleIDParam);
    }
    int originID = Integer.parseInt(originIDParam);
    int destinationID = Integer.parseInt(destinationIDParam);
    float baseFare = Float.parseFloat(baseFareParam);
    boolean roundTripAvailable = Boolean.parseBoolean(hasRoundTripAvailable);
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Reservation Details</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
    <script>
        // Function to calculate the total fare
        function calculateTotal() {
            const baseFare = parseFloat(<%= baseFare %>);
            let total = 0;

            // Ticket types and their discounts
            const ticketTypes = ["adult", "child", "senior", "disabled"];
            const discounts = {
                "adult": 0.0,
                "child": 0.25,
                "senior": 0.35,
                "disabled": 0.5
            };

            ticketTypes.forEach(type => {
                const quantity = parseInt(document.getElementById(type + "Tickets").value) || 0;
                const tripType = document.getElementById(type + "TripType").value;
                const discount = discounts[type];

                let fare = baseFare * (1 - discount);
                if (tripType === "roundTrip") {
                    fare *= 2;
                }

                total += fare * quantity;
            });

            document.getElementById("totalAmount").textContent = "$" + total.toFixed(2);
        }

        // Function to lock trip types to "One-Way" if no round trips are available and no returning trip selected 
        function lockTripType() {
            const roundTripAvailable = <%= roundTripAvailable %>;
			const returningScheduleID = <%= returningScheduleID %>;
            if (!roundTripAvailable || returningScheduleID === -1 ) {
                const tripTypes = ["adultTripType", "childTripType", "seniorTripType", "disabledTripType"];
                tripTypes.forEach(id => {
                    const select = document.getElementById(id);
                    select.querySelectorAll('option[value="roundTrip"]').forEach(option => {
                        option.disabled = true;
                    });
                 	// Set the selected value to "One-Way"
                    select.value = "oneWay";
                });
            }
        }

        // Function to validate ticket quantities before submission
        function validateForm(event) {
            const ticketTypes = ["adult", "child", "senior", "disabled"];
            let totalQuantity = 0;

            ticketTypes.forEach(type => {
                const quantity = parseInt(document.getElementById(type + "Tickets").value) || 0;
                totalQuantity += quantity;
            });

            if (totalQuantity === 0) {
                alert("Please select at least one ticket quantity.");
                event.preventDefault(); // Prevent form submission
                return false;
            }

            return true;
        }

        window.onload = () => {
            lockTripType();
            calculateTotal();
        };
    </script>
</head>
<body>
    <div class="dashboard-container">
        <div class="navbar">
            <a href="customerDashboard.jsp">Back to Dashboard</a>
            <%
	        // Check if the referer exists to generate the Back to Schedule button
	        String referer = request.getHeader("referer");
	        if (referer != null && !referer.isEmpty()) {
		    %>
		        <a href="<%= referer %>" class="back-to-schedule">Back to Schedule</a>
		    <%
		        }
		    %>
        </div>
        <div class="reservation-details-container">
            <h2>Reservation Details</h2>
            <p>Fare per one-way adult ticket: $<%= baseFare %></p>
            
            <form action="processReservation.jsp" method="post" onsubmit="return validateForm(event)">
                <input type="hidden" name="incomingScheduleID" value="<%= incomingScheduleID %>">
                <input type="hidden" name="returningScheduleID" value="<%= returningScheduleID %>">
                <input type="hidden" name="hasRoundTripAvailable" value="<%= roundTripAvailable %>">
                <input type="hidden" name="originID" value="<%= originID %>">
                <input type="hidden" name="destinationID" value="<%= destinationID %>">
                <input type="hidden" name="baseFare" value="<%= baseFare %>">

                <table>
                    <thead>
                        <tr>
                            <th>Ticket Type</th>
                            <th>Quantity</th>
                            <th>Trip Type</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>Adult</td>
                            <td><input type="number" id="adultTickets" name="adultTickets" min="0" value="0" onchange="calculateTotal()"></td>
                            <td>
                                <select id="adultTripType" name="adultTripType" onchange="calculateTotal()">
                                	<option value="roundTrip">Round Trip</option>
                                    <option value="oneWay">One-Way</option>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <td>Child (25% Discount)</td>
                            <td><input type="number" id="childTickets" name="childTickets" min="0" value="0" onchange="calculateTotal()"></td>
                            <td>
                                <select id="childTripType" name="childTripType" onchange="calculateTotal()">
                                	<option value="roundTrip">Round Trip</option>
                                    <option value="oneWay">One-Way</option>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <td>Senior (35% Discount)</td>
                            <td><input type="number" id="seniorTickets" name="seniorTickets" min="0" value="0" onchange="calculateTotal()"></td>
                            <td>
                                <select id="seniorTripType" name="seniorTripType" onchange="calculateTotal()">
                                	<option value="roundTrip">Round Trip</option>
                                    <option value="oneWay">One-Way</option>                                    
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <td>Disabled (50% Discount)</td>
                            <td><input type="number" id="disabledTickets" name="disabledTickets" min="0" value="0" onchange="calculateTotal()"></td>
                            <td>
                                <select id="disabledTripType" name="disabledTripType" onchange="calculateTotal()">
                                    <option value="roundTrip">Round Trip</option>                       
                                    <option value="oneWay">One-Way</option>
                                </select>
                            </td>
                        </tr>
                    </tbody>
                </table>

                <div class="fare-container">
                    <span class="fare-label">Total Amount: <span id="totalAmount">$0.00</span></span>
                </div>

                <button type="submit" class="confirm-button">Confirm Reservation</button>
            </form>
        </div>
    </div>
</body>
</html>