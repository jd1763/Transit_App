package dao;

import model.QuestionPost;
import model.CommentReply;
import model.QuestionHasComment;
import transit.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CustomerSupportDAO {
	
	// Method to get all answered questions
	public List<QuestionPost> getAnsweredQuestions() {
	    List<QuestionPost> questions = new ArrayList<>();
	    String query = "SELECT qp.questionID, qp.question, qp.customerID, qp.datePosted, qp.status, " +
	                   "c.username, CONCAT(c.firstName, ' ', c.lastName) AS customerName " +
	                   "FROM QuestionPost qp " +
	                   "JOIN Customers c ON qp.customerID = c.customerID " +
	                   "WHERE qp.status = 'answered' " +
	                   "ORDER BY qp.datePosted DESC";

	    try (Connection conn = DatabaseConnection.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(query);
	         ResultSet rs = stmt.executeQuery()) {

	        while (rs.next()) {
	            questions.add(new QuestionPost(
	                rs.getInt("questionID"),
	                rs.getString("question"),
	                rs.getInt("customerID"),
	                rs.getTimestamp("datePosted"),
	                rs.getString("customerName"),
	                rs.getString("username"),
	                rs.getString("status") // Include status
	            ));
	        }
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return questions;
	}


	public List<QuestionPost> getUnansweredQuestions() {
	    List<QuestionPost> questions = new ArrayList<>();
	    String query = "SELECT qp.questionID, qp.question, qp.customerID, qp.datePosted, qp.status, " +
	                   "c.username, CONCAT(c.firstName, ' ', c.lastName) AS customerName " +
	                   "FROM QuestionPost qp " +
	                   "JOIN Customers c ON qp.customerID = c.customerID " +
	                   "WHERE qp.status = 'unanswered' " +
	                   "ORDER BY qp.datePosted DESC";

	    try (Connection conn = DatabaseConnection.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(query);
	         ResultSet rs = stmt.executeQuery()) {

	        while (rs.next()) {
	            questions.add(new QuestionPost(
	                rs.getInt("questionID"),
	                rs.getString("question"),
	                rs.getInt("customerID"),
	                rs.getTimestamp("datePosted"),
	                rs.getString("customerName"),
	                rs.getString("username"),
	                rs.getString("status") // Include status
	            ));
	        }
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return questions;
	}

    
	// Method to get all question posts with customer details
	public List<QuestionPost> getAllQuestionPosts() {
	    List<QuestionPost> questions = new ArrayList<>();
	    String query = "SELECT qp.questionID, qp.question, qp.customerID, qp.datePosted, qp.status, " +
	                   "c.username, CONCAT(c.firstName, ' ', c.lastName) AS customerName " +
	                   "FROM QuestionPost qp " +
	                   "JOIN Customers c ON qp.customerID = c.customerID " +
	                   "ORDER BY qp.datePosted DESC";

	    try (Connection conn = DatabaseConnection.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(query);
	         ResultSet rs = stmt.executeQuery()) {

	        while (rs.next()) {
	            questions.add(new QuestionPost(
	                rs.getInt("questionID"),
	                rs.getString("question"),
	                rs.getInt("customerID"),
	                rs.getTimestamp("datePosted"),
	                rs.getString("customerName"),
	                rs.getString("username"),
	                rs.getString("status") // Include status
	            ));
	        }
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return questions;
	}

	

    // Method to get comments/replies for a specific question post
	public List<CommentReply> getCommentsForQuestion(int questionID) {
	    List<CommentReply> comments = new ArrayList<>();
	    String query = "SELECT cr.commentID, cr.comment, cr.customerID, cr.employeeID, cr.datePosted, " +
	                   "cu.username AS customerUsername, CONCAT(cu.firstName, ' ', cu.lastName) AS customerName, " +
	                   "em.username AS employeeUsername, CONCAT(em.firstName, ' ', em.lastName) AS employeeName " +
	                   "FROM CommentReply cr " +
	                   "LEFT JOIN Customers cu ON cr.customerID = cu.customerID " +
	                   "LEFT JOIN Employees em ON cr.employeeID = em.employeeID " +
	                   "WHERE cr.questionID = ? ORDER BY cr.datePosted ASC";

	    try (Connection conn = DatabaseConnection.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(query)) {
	        stmt.setInt(1, questionID);
	        ResultSet rs = stmt.executeQuery();

	        while (rs.next()) {
	            comments.add(new CommentReply(
	                rs.getInt("commentID"),
	                rs.getString("comment"),
	                (Integer) rs.getObject("customerID"),
	                (Integer) rs.getObject("employeeID"),
	                rs.getTimestamp("datePosted"),
	                rs.getString("customerName"),
	                rs.getString("employeeName"),
	                rs.getString("customerUsername") != null ? rs.getString("customerUsername") : rs.getString("employeeUsername")
	            ));
	        }
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return comments;
	}


    // Method to submit a new question post
	public boolean submitQuestionPost(String question, int customerID) {
	    String query = "INSERT INTO QuestionPost (question, customerID) VALUES (?, ?)";
	    try (Connection conn = DatabaseConnection.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(query)) {
	        stmt.setString(1, question);
	        stmt.setInt(2, customerID);
	        return stmt.executeUpdate() > 0;
	    } catch (SQLException e) {
	        e.printStackTrace();
	        return false;
	    }
	}


    // Method to submit a new comment/reply
	public boolean submitCommentReply(String comment, Integer customerID, Integer employeeID, int questionID) {
	    String insertCommentQuery = "INSERT INTO CommentReply (comment, customerID, employeeID, questionID, datePosted) VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)";
	    String updateQuestionStatusQuery = "UPDATE QuestionPost SET status = ? WHERE questionID = ?";

	    try (Connection conn = DatabaseConnection.getConnection();
	         PreparedStatement insertStmt = conn.prepareStatement(insertCommentQuery);
	         PreparedStatement updateStmt = conn.prepareStatement(updateQuestionStatusQuery)) {

	        // Insert the comment
	        insertStmt.setString(1, comment);
	        if (customerID != null) {
	            insertStmt.setInt(2, customerID);
	        } else {
	            insertStmt.setNull(2, java.sql.Types.INTEGER);
	        }
	        if (employeeID != null) {
	            insertStmt.setInt(3, employeeID);
	        } else {
	            insertStmt.setNull(3, java.sql.Types.INTEGER);
	        }
	        insertStmt.setInt(4, questionID);
	        insertStmt.executeUpdate();

	        
	        // Update the question status
	        if (employeeID != null) {
	            // If the reply is made by an employee, mark as 'answered'
	            updateStmt.setString(1, "answered");
	        } else if (customerID != null) {
	            // If the reply is made by a customer, mark as 'unanswered'
	            updateStmt.setString(1, "unanswered");
	        }
	        updateStmt.setInt(2, questionID);
	        updateStmt.executeUpdate();

	        return true;
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return false;
	}

    
	public List<QuestionPost> searchQuestionsByKeyword(String keyword, String filter) {
	    List<QuestionPost> questions = new ArrayList<>();
	    String query = "SELECT qp.questionID, qp.question, qp.customerID, qp.datePosted, "
	                 + "qp.status, cu.username AS customerUsername, "
	                 + "CONCAT(cu.firstName, ' ', cu.lastName) AS customerName "
	                 + "FROM QuestionPost qp "
	                 + "JOIN Customers cu ON qp.customerID = cu.customerID ";

	    // Add filter conditions
	    if ("answered".equalsIgnoreCase(filter)) {
	        query += "WHERE qp.status = 'answered' ";
	    } else if ("unanswered".equalsIgnoreCase(filter)) {
	        query += "WHERE qp.status = 'unanswered' ";
	    }

	    // Add keyword filter
	    if (keyword != null && !keyword.trim().isEmpty()) {
	        if (query.contains("WHERE")) {
	            query += "AND qp.question LIKE ? ";
	        } else {
	            query += "WHERE qp.question LIKE ? ";
	        }
	    }

	    query += "ORDER BY qp.datePosted DESC";

	    try (Connection conn = DatabaseConnection.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(query)) {

	        if (keyword != null && !keyword.trim().isEmpty()) {
	            stmt.setString(1, "%" + keyword + "%");
	        }

	        ResultSet rs = stmt.executeQuery();
	        while (rs.next()) {
	            questions.add(new QuestionPost(
	                rs.getInt("questionID"),
	                rs.getString("question"),
	                rs.getInt("customerID"),
	                rs.getTimestamp("datePosted"),
	                rs.getString("customerName"),
	                rs.getString("customerUsername"),
	                rs.getString("status") // Fetch the status
	            ));
	        }
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return questions;
	}
}
