package model;

import java.sql.Timestamp;

public class QuestionPost {
    private int questionID;
    private String question;
    private int customerID;
    private Timestamp datePosted;
    private String customerName; // Name of the customer who posted the question
    private String username; // Username of the customer who posted the question
    private String status; // New field
    
    // Constructor
    public QuestionPost(int questionID, String question, int customerID, Timestamp datePosted, String customerName, String username, String status) {
        this.questionID = questionID;
        this.question = question;
        this.customerID = customerID;
        this.datePosted = datePosted;
        this.customerName = customerName;
        this.username = username;
        this.status = status;
    }

    // Getters and setters
    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
    
    public int getQuestionID() {
        return questionID;
    }

    public String getQuestionText() {
        return question;
    }

    public int getCustomerID() {
        return customerID;
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

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }
}

