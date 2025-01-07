package model;

public class Employee {
    private int employeeID;
    private String username;
    private String password;
    private boolean isAdmin;
    private String fname;
    private String lname;
    private String ssn;
    
    // Constructor, getters, and setters
    public Employee(int employeeID, String fname, String lname, String username, String password, boolean isAdmin, String ssn) {
        this.employeeID = employeeID;
        this.username = username;
        this.password = password;
        this.isAdmin = isAdmin;
        this.fname = fname;
        this.lname = lname;
        this.ssn = ssn;
    }

    public int getEmployeeID() { return employeeID; }
    public String getUsername() { return username; }
    public String getPassword() { return password; }
    public boolean isAdmin() { return isAdmin; }
    public String getFirstName() { return fname; }
    public String getLastName() { return lname; }
	public String getSsn() {return ssn;}

    public void setEmployeeID(int employeeID) { this.employeeID = employeeID; }
    public void setUsername(String username) { this.username = username; }
    public void setPassword(String password) { this.password = password; }
    public void setAdmin(boolean isAdmin) { this.isAdmin = isAdmin; }
    public void setFirstName(String fname) { this.fname = fname; }
    public void setLastName(String lname) { this.lname = lname; }
	public void setSsn(String ssn) {this.ssn = ssn;}

}