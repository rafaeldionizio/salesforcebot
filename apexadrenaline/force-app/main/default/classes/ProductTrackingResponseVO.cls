public class ProductTrackingResponseVO {
    public String trackingId;
    public String status;
    public DateTime lastUpdate; 
    public Date estimatedDeliveryDate;
    public Recipient recipient;
    public Sender sender;
    public PackageDetails packageDetails;
    public List<TrackingEvent> trackingEvents;

    public ProductTrackingResponseVO() {
        this.trackingEvents = new List<TrackingEvent>();
    }

    public static ProductTrackingResponseVO parse(String jsonString) {
        return (ProductTrackingResponseVO) JSON.deserialize(jsonString, ProductTrackingResponseVO.class);
    }

    public class Recipient {
        public String name;
        public String address;
    }

    public class Sender {
        public String name;
        public String address;
    }

    public class PackageDetails {
        public Decimal weightKg;
        public String dimensionsCm;
        public String description;
    }

    public class TrackingEvent {
        public DateTime timestamp;
        public String location;
        public String status;
    }
}