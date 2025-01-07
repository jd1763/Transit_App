package model;

public class QuestionHasComment {
    private int questionID;
    private int commentID;

    public QuestionHasComment(int questionID, int commentID) {
        this.questionID = questionID;
        this.commentID = commentID;
    }

    // Getters and Setters
    public int getQuestionID() {
        return questionID;
    }

    public void setQuestionID(int questionID) {
        this.questionID = questionID;
    }

    public int getCommentID() {
        return commentID;
    }

    public void setCommentID(int commentID) {
        this.commentID = commentID;
    }
}
