package model;

public class Station {
    private int stationID;
    private String name;
    private String city;
    private String state;

    // Constructor
    public Station(int stationID, String name, String city, String state) {
        this.stationID = stationID;
        this.name = name;
        this.city = city;
        this.state = state;
    }

    // Getters and Setters
    public int getStationID() {
        return stationID;
    }

    public void setStationID(int stationID) {
        this.stationID = stationID;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    @Override
    public String toString() {
        return "Station{" +
                "stationID=" + stationID +
                ", name='" + name + '\'' +
                ", city='" + city + '\'' +
                ", state='" + state + '\'' +
                '}';
    }
}

