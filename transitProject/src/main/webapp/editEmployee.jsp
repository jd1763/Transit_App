<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="model.Employee" %>
<%@ page import="dao.EmployeeDAO" %>
<%
    // Check if the user is logged in as a manager
    String role = (String) session.getAttribute("role");
    if (role == null || !"manager".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Initialize DAOs and retrieve employee details
    int employeeID = Integer.parseInt(request.getParameter("employeeID"));
    EmployeeDAO employeeDAO = new EmployeeDAO();
    Employee employee = employeeDAO.getEmployeeById(employeeID); // Add this method in EmployeeDAO

    // Initialize a message variable for success/error
    String message = null;

    if ("update".equals(request.getParameter("action"))) {
        String fname = request.getParameter("fname");
        String lname = request.getParameter("lname");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String ssn = request.getParameter("ssn");

        // Check for duplicate username and SSN (excluding current employee)
        boolean usernameTaken = employeeDAO.isUsernameTaken(username);
        boolean ssnTaken = employeeDAO.isSSNTaken(ssn);

        if (usernameTaken && !(employee.getUsername().equals(username)) ) {
            message = "Error: Username is already taken.";
        } else if (ssnTaken && !(employee.getSsn().equals(ssn))) {
            message = "Error: SSN is already in use.";
        } else {
            // Update employee details
            employee.setFirstName(fname);
            employee.setLastName(lname);
            employee.setUsername(username);
            employee.setPassword(password);
            employee.setSsn(ssn);

            if (employeeDAO.updateCustomerRep(employee)) {
                // Set success message
                message = "Employee updated successfully.";

                // Reload updated employee data
                employee = employeeDAO.getEmployeeById(employeeID);
            } else {
                // Set error message
                message = "Failed to update employee.";
            }
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Employee</title>
    <link rel="stylesheet" href="styles.css">
    <script>
        // Display toaster
        document.addEventListener("DOMContentLoaded", () => {
            const toaster = document.querySelector(".toaster");
            if (toaster) {
                // Fade-in effect
                setTimeout(() => {
                    toaster.style.opacity = "1";
                    toaster.style.transform = "translateY(0)";
                }, 100);

                // Auto-hide after 3 seconds
                setTimeout(() => {
                    toaster.style.opacity = "0";
                    toaster.style.transform = "translateY(-20px)";
                    setTimeout(() => {
                        toaster.remove();
                    }, 500);
                }, 3000);
            }
        });

        // Client-side validation for SSN
        function validateSSN() {
            const ssnInput = document.getElementById("ssn");
            const ssnValue = ssnInput.value;
            const ssnPattern = /^\d{3}-\d{2}-\d{4}$/; // SSN pattern XXX-XX-XXXX

            if (!ssnPattern.test(ssnValue)) {
                alert("Invalid SSN format. Please use XXX-XX-XXXX.");
                ssnInput.focus();
                return false;
            }
            return true;
        }
    </script>
</head>
<body>
    <div class="edit-employee-container">
        <!-- Navigation Bar -->
        <div class="navbar">
            <a href="managerDashboard.jsp">Back to Dashboard</a>
            <%
                String referer = request.getHeader("referer");
                if (referer != null && !referer.isEmpty()) {
            %>
                <a href="manageEmployees.jsp" class="back-to-schedule">Back to Employees</a>
            <%
                }
            %>
        </div>

        <!-- Page Title -->
        <h2>Edit Employee</h2>

        <!-- Display Toaster -->
        <% if (message != null) { %>
            <div class="toaster <%= message.contains("successfully") ? "success" : "error" %>">
                <%= message %>
            </div>
        <% } %>

        <!-- Edit Employee Form -->
        <form action="editEmployee.jsp" method="post" onsubmit="return validateSSN()">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="employeeID" value="<%= employee.getEmployeeID() %>">

            <div class="form-group">
                <label for="fname">First Name:</label>
                <input type="text" id="fname" name="fname" value="<%= employee.getFirstName() %>" required>
            </div>

            <div class="form-group">
                <label for="lname">Last Name:</label>
                <input type="text" id="lname" name="lname" value="<%= employee.getLastName() %>" required>
            </div>

            <div class="form-group">
                <label for="username">Username:</label>
                <input type="text" id="username" name="username" value="<%= employee.getUsername() %>" required>
            </div>

            <div class="form-group">
                <label for="password">Password:</label>
                <input type="password" id="password" name="password" value="<%= employee.getPassword() %>" required>
            </div>

            <div class="form-group">
                <label for="ssn">SSN (xxx-xx-xxxx):</label>
                <input type="text" id="ssn" name="ssn" value="<%= employee.getSsn() %>" placeholder="XXX-XX-XXXX" required>
            </div>

            <div class="form-buttons">
                <button type="submit" class="update-button">Update Employee</button>
            </div>
        </form>
    </div>
</body>
</html>

