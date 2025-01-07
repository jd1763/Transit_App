package model;

import java.sql.Timestamp;

public class CommentReply {
    private int commentID;
    private String comment;
    private Integer customerID;
    private Integer employeeID;
    private Timestamp datePosted;
    private String customerName;  // Name of the customer who replied
    private String employeeName;  // Name of the employee who replied
    private String username; 

    // Constructor
    public CommentReply(int commentID, String comment, Integer customerID, Integer employeeID, Timestamp datePosted, String customerName, String employeeName, String username) {
        this.commentID = commentID;
        this.comment = comment;
        this.customerID = customerID;
        this.employeeID = employeeID;
        this.datePosted = datePosted;
        this.customerName = customerName;
        this.employeeName = employeeName;
        this.username = username;
    }

    // Getters and Setters
    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }
    
    public int getCommentID() {
        return commentID;
    }

    public String getCommentText() {
        return comment;
    }

    public Integer getCustomerID() {
        return customerID;
    }

    public Integer getEmployeeID() {
        return employeeID;
    }

    public Timestamp getDatePosted() {
        return datePosted;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getEmployeeName() {
        return employeeName;
    }

    public void setEmployeeName(String employeeName) {
        this.employeeName = employeeName;
    }
}

