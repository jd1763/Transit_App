package model;

import java.sql.Timestamp;

public class StopsAt {
    private int scheduleID;
    private int stationID;
    private int stopNumber;
    private Timestamp arrivalDateTime;
    private Timestamp departureDateTime;

    public StopsAt(int scheduleID, int stationID, int stopNumber, Timestamp arrivalDateTime, Timestamp departureDateTime) {
        this.scheduleID = scheduleID;
        this.stationID = stationID;
        this.stopNumber = stopNumber;
        this.arrivalDateTime = arrivalDateTime;
        this.departureDateTime = departureDateTime;
    }

    public int getScheduleID() {
        return scheduleID;
    }

    public int getStationID() {
        return stationID;
    }

    public int getStopNumber() {
        return stopNumber;
    }

    public Timestamp getArrivalDateTime() {
        return arrivalDateTime;
    }

    public Timestamp getDepartureDateTime() {
        return departureDateTime;
    }
}






