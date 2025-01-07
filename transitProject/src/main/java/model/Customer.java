package model;

public class Customer {
   private int customerID;
   private String username;
   private String password;
   private String emailAddress;
   private String firstName;
   private String lastName;

   public Customer(int customerID, String username, String password, String emailAddress, String firstName, String lastName) {
       this.customerID = customerID;
       this.username = username;
       this.password = password;
       this.emailAddress = emailAddress;
       this.firstName = firstName;
       this.lastName = lastName;
   }


    public int getCustomerID() { return customerID; }
    public String getUsername() { return username; }
    public String getPassword() { return password; }
    public String getEmailAddress() { return emailAddress; }
    public String getFirstName() { return firstName; }
    public String getLastName() { return lastName; }

    public void setCustomerID(int customerID) { this.customerID = customerID; }
    public void setUsername(String username) { this.username = username; }
    public void setPassword(String password) { this.password = password; }
    public void setEmailAddress(String emailAddress) { this.emailAddress = emailAddress;}
    public void setFirstName(String firstName) { this.firstName = firstName; }
    public void setLastName(String lastName) { this.lastName = lastName; }

}

