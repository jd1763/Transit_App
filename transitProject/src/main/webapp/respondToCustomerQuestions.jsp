<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.net.URLEncoder, dao.CustomerSupportDAO, model.QuestionPost, model.CommentReply" %>
<%
    String role = (String) session.getAttribute("role");
    if (role == null || !"rep".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    CustomerSupportDAO supportDAO = new CustomerSupportDAO();
    List<QuestionPost> questions;

    String filter = request.getParameter("filter");
    if (filter == null || filter.isEmpty()) {
        filter = "all"; // Default filter
    }

    String keyword = request.getParameter("keyword");
    if (keyword != null && !keyword.isEmpty()) {
        questions = supportDAO.searchQuestionsByKeyword(keyword, filter);
    } else {
        if ("answered".equalsIgnoreCase(filter)) {
            questions = supportDAO.getAnsweredQuestions();
        } else if ("unanswered".equalsIgnoreCase(filter)) {
            questions = supportDAO.getUnansweredQuestions();
        } else {
            questions = supportDAO.getAllQuestionPosts();
        }
    }

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String replyText = request.getParameter("replyText");
        String parentQuestionIDParam = request.getParameter("parentQuestionID");

        if (replyText != null && !replyText.trim().isEmpty() && parentQuestionIDParam != null) {
            int parentQuestionID = Integer.parseInt(parentQuestionIDParam);
            Integer employeeID = (Integer) session.getAttribute("userID");
            supportDAO.submitCommentReply(replyText, null, employeeID, parentQuestionID);
        }
        response.sendRedirect("respondToCustomerQuestions.jsp?filter=" + filter + "&keyword=" + URLEncoder.encode(keyword != null ? keyword : "", "UTF-8"));
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Respond to Customer Questions</title>
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
            <a href="repDashboard.jsp">Back to Dashboard</a>
            <a href="logout.jsp">Logout</a>
        </div>

        <div class="content">
			<form action="respondToCustomerQuestions.jsp" method="get" class="filter-form">
			    <label for="filter">Filter Questions:</label>
			    <select name="filter" id="filter" onchange="this.form.submit()">
			        <option value="all" <%= "all".equalsIgnoreCase(filter) ? "selected" : "" %>>All Questions</option>
			        <option value="answered" <%= "answered".equalsIgnoreCase(filter) ? "selected" : "" %>>Answered Questions</option>
			        <option value="unanswered" <%= "unanswered".equalsIgnoreCase(filter) ? "selected" : "" %>>Unanswered Questions</option>
			    </select>
			    <label for="keyword">Search Questions:</label>
			    <input type="text" name="keyword" id="keyword" placeholder="Enter keyword" value="<%= keyword != null ? keyword : "" %>">
			    <button type="submit">Search</button>
			</form>
        </div>

        <div class="content">
            <h2>Respond to Customer Questions</h2>
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
							                <p><strong><%= reply.getUsername() != null ? reply.getUsername() : "Unknown" %></strong> 
							                    (<%= reply.getCustomerName() != null ? reply.getCustomerName() : reply.getEmployeeName() %>)</p>
							                <p><%= reply.getCommentText() %></p>
							                <p class="reply-date"><%= reply.getDatePosted() %></p>
							            </div>
							        <% } %>
							    <% } else { %>
							        <p>No replies yet.</p>
							    <% } %>
							</div>

                            <!-- Reply Form -->
                            <button onclick="toggleReplyForm('<%= question.getQuestionID() %>')">Reply</button>
                            <div id="replyForm<%= question.getQuestionID() %>" class="reply-form">
                                <form action="respondToCustomerQuestions.jsp" method="post">
                                    <input type="hidden" name="parentQuestionID" value="<%= question.getQuestionID() %>">
                                    <textarea name="replyText" placeholder="Enter your reply here" required></textarea>
                                    <button type="submit">Submit Reply</button>
                                </form>
                            </div>
                        </div>
                    <% } %>
                <% } %>
            </div>
        </div>
    </div>
</body>
</html>

