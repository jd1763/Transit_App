package dao;

import model.Train;
import transit.DatabaseConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class TrainDAO {

    public Train getTrain(int trainID) {
        String query = "SELECT * FROM Trains WHERE trainID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, trainID);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return new Train(rs.getInt("trainID"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }


    // Fetch unused trains
    public List<Train> getUnusedTrains() {
        List<Train> unusedTrains = new ArrayList<>();
        String query = "SELECT t.trainID FROM Trains t "
                     + "LEFT JOIN Train_Schedules ts ON t.trainID = ts.trainID "
                     + "WHERE ts.trainID IS NULL";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                unusedTrains.add(new Train(rs.getInt("trainID")));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return unusedTrains;
    }

    // Add a new train
    public boolean addTrain(int trainID) {
        String query = "INSERT INTO Trains (trainID) VALUES (?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, trainID);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    public List<Train> getAllTrains() {
        List<Train> trains = new ArrayList<>();
        String query = "SELECT * FROM Trains";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                trains.add(new Train(rs.getInt("trainID")));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return trains;
    }
    
}




