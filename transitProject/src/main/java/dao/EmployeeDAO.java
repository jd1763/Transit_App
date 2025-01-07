package dao;

//This is for customer-Rep and Manager DAOs
import model.Employee;
import transit.DatabaseConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class EmployeeDAO {
	public Employee getEmployeeByUsernameAndPassword(String username, String password) {
	    String query = "SELECT * FROM Employees WHERE username = ? AND password = ?";
	    try (Connection conn = DatabaseConnection.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(query)) {
	        stmt.setString(1, username);
	        stmt.setString(2, password);
	        ResultSet rs = stmt.executeQuery();
	        if (rs.next()) {
	            return new Employee(
	                rs.getInt("employeeID"),
	                rs.getString("firstName"),
	                rs.getString("lastName"),
	                rs.getString("username"),
	                rs.getString("password"),
	                rs.getBoolean("isAdmin"),
	                rs.getString("ssn")
	            );
	        }
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return null;
	} 
    
	public boolean isUsernameTaken(String username) {
	    String query = """
	        SELECT 1 FROM Customers WHERE username = ?
	        UNION
	        SELECT 1 FROM Employees WHERE username = ?
	    """;
	    try (Connection conn = DatabaseConnection.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(query)) {

	        // Set the username parameter for both tables
	        stmt.setString(1, username); // For Customers table
	        stmt.setString(2, username); // For Employees table

	        // Execute the query
	        ResultSet rs = stmt.executeQuery();

	        // Return true if there is a match
	        return rs.next();
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return false; // Return false if an exception occurs or no match is found
	}
	
	public boolean isSSNTaken(String ssn) {
	    String query = "SELECT 1 FROM Employees WHERE ssn = ?";
	    try (Connection conn = DatabaseConnection.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(query)) {
	        stmt.setString(1, ssn);
	        ResultSet rs = stmt.executeQuery();
	        return rs.next();
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return false;
	}

	public boolean addCustomerRep(Employee employee) {
	    String query = "INSERT INTO Employees (firstName, lastName, username, password, ssn, isAdmin) VALUES (?, ?, ?, ?, ?, 0)";
	    try (Connection conn = DatabaseConnection.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(query)) {
	        stmt.setString(1, employee.getFirstName());
	        stmt.setString(2, employee.getLastName());
	        stmt.setString(3, employee.getUsername());
	        stmt.setString(4, employee.getPassword());
	        stmt.setString(5, employee.getSsn());
	        return stmt.executeUpdate() > 0;
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return false;
	}
    
	public boolean updateCustomerRep(Employee employee) {
	    String query = "UPDATE Employees SET firstName = ?, lastName = ?, username = ?, password = ?, ssn = ? WHERE employeeID = ?";
	    try (Connection conn = DatabaseConnection.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(query)) {
	        stmt.setString(1, employee.getFirstName());
	        stmt.setString(2, employee.getLastName());
	        stmt.setString(3, employee.getUsername());
	        stmt.setString(4, employee.getPassword());
	        stmt.setString(5, employee.getSsn());
	        stmt.setInt(6, employee.getEmployeeID());
	        return stmt.executeUpdate() > 0;
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return false;
	}
    
	public boolean deleteCustomerRep(int employeeID) {
	    String query = "DELETE FROM Employees WHERE employeeID = ?";
	    try (Connection conn = DatabaseConnection.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(query)) {
	        stmt.setInt(1, employeeID);
	        return stmt.executeUpdate() > 0;
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return false;
	}

	public List<Employee> getAllCustomerReps() {
	    String query = "SELECT * FROM Employees WHERE isAdmin = 0";
	    List<Employee> customerReps = new ArrayList<>();
	    
	    try (Connection conn = DatabaseConnection.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(query);
	         ResultSet rs = stmt.executeQuery()) {
	        
	        while (rs.next()) {
	            Employee employee = new Employee(
	                rs.getInt("employeeID"),
	                rs.getString("firstName"),
	                rs.getString("lastName"),
	                rs.getString("username"),
	                rs.getString("password"),
	                rs.getBoolean("isAdmin"),
	                rs.getString("ssn")
	            );
	            customerReps.add(employee);
	        }
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return customerReps;
	}
	public Employee getEmployeeById(int employeeID) {
	    String query = "SELECT * FROM Employees WHERE employeeID = ?";
	    try (Connection conn = DatabaseConnection.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(query)) {
	        stmt.setInt(1, employeeID);
	        ResultSet rs = stmt.executeQuery();
	        if (rs.next()) {
	            return new Employee(
	                rs.getInt("employeeID"),
	                rs.getString("firstName"),
	                rs.getString("lastName"),
	                rs.getString("username"),
	                rs.getString("password"),
	                rs.getBoolean("isAdmin"),
	                rs.getString("ssn")
	            );
	        }
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return null;
	}

}