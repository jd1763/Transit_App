
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, dao.CustomerDAO, dao.EmployeeDAO, model.Customer, model.Employee" %>
<!DOCTYPE html>
<html>
<head>
   <meta charset="UTF-8">
   <title>Login</title>
   <link rel="stylesheet" type="text/css" href="styles.css">
</head>
<body>
   <%
       // Check if user is already logged in
       if (session.getAttribute("user") != null) {
           String role = (String) session.getAttribute("role");
           if ("customer".equals(role)) {
               response.sendRedirect("customerDashboard.jsp");
           } else if ("manager".equals(role)) {
               response.sendRedirect("managerDashboard.jsp");
           } else if ("rep".equals(role)) {
               response.sendRedirect("repDashboard.jsp");
           }
           return;
       }


       String errorMessage = "";
       String username = request.getParameter("username");
       String password = request.getParameter("password");


       if (username != null && password != null) {
           CustomerDAO customerDAO = new CustomerDAO();
           EmployeeDAO employeeDAO = new EmployeeDAO();


           Customer customer = customerDAO.getCustomerByUsernameAndPassword(username, password);
           Employee employee = employeeDAO.getEmployeeByUsernameAndPassword(username, password);


           if (customer != null) {
               session.setAttribute("user", customer);
               session.setAttribute("userID", customer.getCustomerID()); 
               session.setAttribute("username", username);
               session.setAttribute("role", "customer");
               response.sendRedirect("customerDashboard.jsp");
           } else if (employee != null) {
               session.setAttribute("user", employee);
               session.setAttribute("userID", employee.getEmployeeID()); 
               session.setAttribute("username", username);
               session.setAttribute("role", employee.isAdmin() ? "manager" : "rep");
               response.sendRedirect(employee.isAdmin() ? "managerDashboard.jsp" : "repDashboard.jsp");
           } else {
               errorMessage = "Invalid username or password";
           }
       }
   %>
   
   <div class="form-container">
       <h2>Login</h2>


       <% if (!errorMessage.isEmpty()) { %>
           <p class="error"><%= errorMessage %></p>
       <% } %>


       <form action="login.jsp" method="post">
           <label for="username">Username:</label>
           <input type="text" id="username" name="username" required>


           <label for="password">Password:</label>
           <input type="password" id="password" name="password" required>


           <button type="submit">Login</button>
       </form>
       <p>Don’t have an account? <a href="register.jsp">Register here</a></p>
   </div>
</body>
</html>

