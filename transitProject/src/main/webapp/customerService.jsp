<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, dao.CustomerSupportDAO, model.QuestionPost, model.CommentReply" %>
<%

    String role = (String) session.getAttribute("role");
    Integer userID = (Integer) session.getAttribute("userID"); // Ensure this is properly set during login
    boolean isCustomer = "customer".equals(role);
    boolean isEmployee = "employee".equals(role);

    if (role == null || (!isCustomer && !isEmployee)) {
        response.sendRedirect("login.jsp");
        return;
    }

    CustomerSupportDAO supportDAO = new CustomerSupportDAO();
    String keyword = request.getParameter("keyword");
    List<QuestionPost> questions = supportDAO.getAllQuestionPosts();

    if (keyword != null && !keyword.isEmpty()) {
        questions = supportDAO.searchQuestionsByKeyword(keyword, null);
    }

    // Handling POST requests for submitting questions and replies
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String newQuestion = request.getParameter("newQuestion");
        String replyText = request.getParameter("replyText");
        String parentQuestionIDParam = request.getParameter("parentQuestionID");

        if (newQuestion != null && !newQuestion.trim().isEmpty()) {
            // New Question Submission
            supportDAO.submitQuestionPost(newQuestion, userID);
        } else if (replyText != null && !replyText.trim().isEmpty() && parentQuestionIDParam != null) {
            // Reply Submission
            int parentQuestionID = Integer.parseInt(parentQuestionIDParam);
            Integer customerID = isCustomer ? userID : null;
            Integer employeeID = isEmployee ? userID : null;
            supportDAO.submitCommentReply(replyText, customerID, employeeID, parentQuestionID);
        }
        response.sendRedirect("customerService.jsp"); // Refresh the page after submission
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Customer Support</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
    <script>
        function toggleReplyForm(questionId) {
            var form = document.getElementById('replyForm' + questionId);
            form.style.display = (form.style.display === 'none' || form.style.display === '') ? 'block' : 'none';
        }
    </script>
</head>
<body>
    <div class="customer-service-container">
        <div class="navbar">
            <a href="customerDashboard.jsp">Back to Dashboard</a>
            <a href="logout.jsp">Logout</a>
        </div>
        <div class="content">
            <h2>Customer Support</h2>
			<form action="customerService.jsp" method="get" class="search-form">
			    <label for="keyword">Search Questions:</label>
			    <input type="text" name="keyword" id="keyword" placeholder="Enter keyword" value="<%= keyword != null ? keyword : "" %>">
			    <button type="submit">Search</button>
			</form>
            <div class="results">
                <h3>Questions and Answers</h3>
				<% if (questions.isEmpty()) { %>
				    <p>No questions found.</p>
				<% } else { %>
					<% for (QuestionPost question : questions) { %>
					    <div class="question-box">
			                <p><strong>Question:</strong> <%= question.getQuestionText() %></p>
			                <p><strong>Asked by:</strong> <%= question.getUsername() %> (<%= question.getCustomerName() %>) on <%= question.getDatePosted() %></p>
					        
					        <!-- Display Replies -->
					        <% List<CommentReply> replies = supportDAO.getCommentsForQuestion(question.getQuestionID()); %>
					        <div class="replies-container">
					            <% if (!replies.isEmpty()) { %>
					                <% for (CommentReply reply : replies) { %>
					                    <div class="reply">
					                        <p><strong><%= reply.getUsername() %></strong> (<%= reply.getCustomerName() != null ? reply.getCustomerName() : reply.getEmployeeName() %>)</p>
					                        <p><%= reply.getCommentText() %></p>
					                        <p class="reply-date"><%= reply.getDatePosted() %></p>
					                    </div>
					                <% } %>
					            <% } else { %>
					                <p>No replies yet.</p>
					            <% } %>
					        </div>
					        
					        <!-- Reply Form -->
					        <% if (isEmployee || (isCustomer && question.getCustomerID() == userID.intValue())) { %>
					            <button onclick="toggleReplyForm('<%= question.getQuestionID() %>')">Reply</button>
					            <div id="replyForm<%= question.getQuestionID() %>" style="display:none;">
					                <form action="customerService.jsp" method="post">
					                    <input type="hidden" name="parentQuestionID" value="<%= question.getQuestionID() %>">
					                    <textarea name="replyText" placeholder="Enter your reply here" required></textarea>
					                    <button type="submit">Post</button>
					                </form>
					            </div>
					        <% } %>
					    </div>
					<% } %>
				<% } %>
			<!-- Section: Post a Question -->
			<% if (isCustomer) { %>
			    <div class="post-question-section">
			        <h4>Post a Question</h4>
			        <form action="customerService.jsp" method="post" class="question-form">
			            <label for="newQuestion">Enter your question:</label>
			            <textarea name="newQuestion" id="newQuestion" required></textarea>
			            <button type="submit">Submit Question</button>
			        </form>
			    </div>
			<% } %>
        </div>
    </div>
</body>
</html>