package less.green.openpudo.common;

import java.math.BigDecimal;
import java.math.RoundingMode;

public class GPSUtils {

    private static final double EARTH_RADIUS_KM = 6372.8;

    private static double haversineDistance(double lat1, double lon1, double lat2, double lon2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        lat1 = Math.toRadians(lat1);
        lat2 = Math.toRadians(lat2);
        double a = Math.pow(Math.sin(dLat / 2), 2) + Math.pow(Math.sin(dLon / 2), 2) * Math.cos(lat1) * Math.cos(lat2);
        double c = 2 * Math.asin(Math.sqrt(a));
        return EARTH_RADIUS_KM * c;
    }

    public static BigDecimal calculateDistanceFromOrigin(BigDecimal lat1, BigDecimal lon1, BigDecimal lat2, BigDecimal lon2) {
        double distance = haversineDistance(lat1.doubleValue(), lon1.doubleValue(), lat2.doubleValue(), lon2.doubleValue());
        BigDecimal ret = BigDecimal.valueOf(distance).setScale(3, RoundingMode.HALF_UP);
        return ret;
    }

}
