package model;

public class TransitLine {
    private int transitID;
    private String transitLineName;
    private float baseFare;
    private int totalStops;

    // Constructor
    public TransitLine(int transitID, String transitLineName, float baseFare, int totalStops) {
        this.transitID = transitID;
        this.transitLineName = transitLineName;
        this.baseFare = baseFare;
        this.totalStops = totalStops;
    }

    public int getTotalStops() {
    	return totalStops;
    }
    
    // Getters and Setters
    public int getTransitID() {
        return transitID;
    }

    public void setTransitID(int transitID) {
        this.transitID = transitID;
    }

    public String getTransitLineName() {
        return transitLineName;
    }

    public void setTransitLineName(String transitLineName) {
        this.transitLineName = transitLineName;
    }

    public float getBaseFare() {
        return baseFare;
    }

    public void setBaseFare(float baseFare) {
        this.baseFare = baseFare;
    }

    @Override
    public String toString() {
        return "TransitLine{" +
                "transitID=" + transitID +
                ", transitLineName='" + transitLineName + '\'' +
                ", baseFare=" + baseFare +
                ",totalStops=" + totalStops +
                '}';
    }
}
