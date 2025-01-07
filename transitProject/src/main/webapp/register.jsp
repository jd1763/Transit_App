<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.CustomerDAO, model.Customer" %>
<!DOCTYPE html>
<html>
<head>
   <meta charset="UTF-8">
   <title>Register</title>
   <link rel="stylesheet" type="text/css" href="styles.css">
</head>
<body>
   <div class="form-container">
       <h2>Register</h2>

       <!-- Process Registration on form submission -->
       <%
           String username = request.getParameter("username");
           String emailAddress = request.getParameter("emailAddress");
           String password = request.getParameter("password");
           String firstName = request.getParameter("firstName");
           String lastName = request.getParameter("lastName");
           String errorMessage = "";

           if (username != null && emailAddress != null && password != null && firstName != null && lastName != null) {
               CustomerDAO customerDAO = new CustomerDAO();
               
               // Check if username or email is already taken
               if (customerDAO.isUsernameOrEmailAddressTaken(username, emailAddress)) {
                   errorMessage = "Username or email is already taken.";
               } else {
                   // Create new customer and add to the database
                   Customer newCustomer = new Customer(0, username, password, emailAddress, firstName, lastName);
                   if (customerDAO.addCustomer(newCustomer)) {
                       response.sendRedirect("login.jsp?success=Registration successful!");
                   } else {
                       errorMessage = "Registration failed. Please try again.";
                   }
               }
           }
       %>

       <!-- Show error message if there is one -->
       <% if (!errorMessage.isEmpty()) { %>
           <p class="error"><%= errorMessage %></p>
       <% } %>

       <!-- Registration Form -->
       <form action="register.jsp" method="post">
           <label for="firstName">First Name:</label>
           <input type="text" id="firstName" name="firstName" required>

           <label for="lastName">Last Name:</label>
           <input type="text" id="lastName" name="lastName" required>

           <label for="username">Username:</label>
           <input type="text" id="username" name="username" required>

           <label for="emailAddress">Email Address:</label>
           <input type="text" id="emailAddress" name="emailAddress" required>

           <label for="password">Password:</label>
           <input type="password" id="password" name="password" required>

           <button type="submit">Register</button>
       </form>

       <p>Already have an account? <a href="login.jsp">Login here</a></p>
   </div>
</body>
</html>
