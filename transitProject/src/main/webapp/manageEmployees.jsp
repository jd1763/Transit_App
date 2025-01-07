<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.util.List, dao.EmployeeDAO, model.Employee" %>
<%
    // Check if user is logged in as a manager
    String role = (String) session.getAttribute("role");
    if (role == null || !"manager".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    EmployeeDAO employeeDAO = new EmployeeDAO();
    List<Employee> employees = employeeDAO.getAllCustomerReps();

    String action = request.getParameter("action");
    if ("add".equals(action)) {
    	String username = request.getParameter("username");
        String password = request.getParameter("password");
        String fname = request.getParameter("fname");
        String lname = request.getParameter("lname");
        String ssn = request.getParameter("ssn");

        boolean usernameTaken = employeeDAO.isUsernameTaken(username);
        boolean ssnTaken = employeeDAO.isSSNTaken(ssn);

        if (usernameTaken) {
            request.setAttribute("message", "Error: Username is already taken.");
        } else if (ssnTaken) {
            request.setAttribute("message", "Error: SSN is already in use.");
        } else {
            Employee newEmployee = new Employee(0, fname, lname, username, password, false, ssn);
            boolean success = employeeDAO.addCustomerRep(newEmployee);
            request.setAttribute("message", success ? "Employee added successfully." : "Failed to add employee.");
            response.sendRedirect("manageEmployees.jsp"); // Redirect to refresh the table
        }
    } else if ("delete".equals(action)) {
    	int employeeID = Integer.parseInt(request.getParameter("employeeID"));
        boolean success = employeeDAO.deleteCustomerRep(employeeID);
        request.setAttribute("message", success ? "Employee deleted successfully." : "Failed to delete employee.");
        response.sendRedirect("manageEmployees.jsp"); // Redirect to refresh the table
    } else if ("update".equals(action)) {
        int employeeID = Integer.parseInt(request.getParameter("employeeID"));
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String fname = request.getParameter("fname");
        String lname = request.getParameter("lname");
        String ssn = request.getParameter("ssn");
        Employee updatedEmployee = new Employee(employeeID, fname, lname, username, password, false, ssn);
        boolean success = employeeDAO.updateCustomerRep(updatedEmployee);
        request.setAttribute("message", success ? "Employee updated successfully." : "Failed to update employee.");
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Employees</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
</head>
<body>
    <div class="manage-employee-container">
        <!-- Navbar -->
        <div class="navbar">
            <a href="managerDashboard.jsp">Back to Dashboard</a>
        </div>

        <!-- Page Content -->
        <h2>Manage Employees</h2>

       <!-- Display Toaster -->
        <% 
            String message = (String) request.getAttribute("message");
        %>
        <% if (message != null) { %>
            <div class="toaster <%= message.contains("successfully") ? "success" : "error" %>">
                <%= message %>
            </div>
        <% } %>

        <!-- Add New Employee Form -->
        <h3>Add New Employee</h3>
        <form action="manageEmployees.jsp" method="post">
            <input type="hidden" name="action" value="add">
            <label for="fname">First Name:</label>
            <input type="text" id="fname" name="fname" required><br>
            <label for="lname">Last Name:</label>
            <input type="text" id="lname" name="lname" required><br>
            <label for="username">Username:</label>
            <input type="text" id="username" name="username" required><br>
            <label for="password">Password:</label>
            <input type="password" id="password" name="password" required><br>
            <label for="ssn">SSN (xxx-xx-xxxx):</label>
            <input type="text" id="ssn" name="ssn" required><br>
            <button type="submit" class="button">Add Employee</button>
        </form>
		<br></br>
        <!-- Employee List -->
        <h3>Employee List</h3>
        <table>
            <thead>
                <tr>
                    <th>Employee ID</th>
                    <th>First Name</th>
                    <th>Last Name</th>
                    <th>Username</th>
                    <th>SSN</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <% for (Employee employee : employees) { %>
                <tr>
                    <td><%= employee.getEmployeeID() %></td>
                    <td><%= employee.getFirstName() %></td>
                    <td><%= employee.getLastName() %></td>
                    <td><%= employee.getUsername() %></td>
                    <td><%= employee.getSsn() %></td>
                    <td>
                        <form action="editEmployee.jsp" method="get" style="display:inline;">
                            <input type="hidden" name="employeeID" value="<%= employee.getEmployeeID() %>">
                            <button type="submit" class="button open-button">Edit</button>
                        </form>
                        <form action="manageEmployees.jsp" method="post" style="display:inline;">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="employeeID" value="<%= employee.getEmployeeID() %>">
                            <button type="submit" class="button cancel-button">Delete</button>
                        </form>
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</body>
</html>