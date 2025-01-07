package model;

import java.util.Date;

public class TrainSchedule {

    private int scheduleID;
    private int transitID;
    private int trainID;
    private int originID;
    private int destinationID;
    private Date departureDateTime;
    private Date arrivalDateTime;
    private float fare;
    private long travelTime;
    private String tripDirection;    // New field to mark forward trips

    // Updated Constructor
    public TrainSchedule(int scheduleID, int transitID, int trainID, int originID, int destinationID, 
                         Date departureDateTime, Date arrivalDateTime, float fare, long travelTime, 
                         String tripDirection) {
        this.scheduleID = scheduleID;
        this.transitID = transitID;
        this.trainID = trainID;
        this.originID = originID;
        this.destinationID = destinationID;
        this.departureDateTime = departureDateTime;
        this.arrivalDateTime = arrivalDateTime;
        this.fare = fare;
        this.travelTime = travelTime;
        this.tripDirection = tripDirection;
    }

    // Getters and Setters
    public int getScheduleID() { return scheduleID; }
    public void setScheduleID(int scheduleID) { this.scheduleID = scheduleID; }

    public int getTransitID() { return transitID; }
    public void setTransitID(int transitID) { this.transitID = transitID; }

    public int getTrainID() { return trainID; }
    public void setTrainID(int trainID) { this.trainID = trainID; }

    public int getOriginID() { return originID; }
    public void setOriginID(int originID) { this.originID = originID; }

    public int getDestinationID() { return destinationID; }
    public void setDestinationID(int destinationID) { this.destinationID = destinationID; }

    public Date getDepartureDateTime() { return departureDateTime; }
    public void setDepartureDateTime(Date departureDateTime) { this.departureDateTime = departureDateTime; }

    public Date getArrivalDateTime() { return arrivalDateTime; }
    public void setArrivalDateTime(Date arrivalDateTime) { this.arrivalDateTime = arrivalDateTime; }

    public float getFare() { return fare; }
    public void setFare(float fare) { this.fare = fare; }

    public long getTravelTime() { return travelTime; }
    public void setTravelTime(long travelTime) { this.travelTime = travelTime; }

    public String getTripDirection() { return tripDirection; }
    public void setForwardTrip(String tripDirection) { this.tripDirection = tripDirection; }
}

