package less.green.openpudo.common;

import less.green.openpudo.rest.dto.map.PudoMarker;
import lombok.Data;
import lombok.extern.log4j.Log4j2;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Log4j2
public class GPSUtils {

    private static final double EARTH_RADIUS_KM = 6372.8;

    private static double haversine(double lat1, double lon1, double lat2, double lon2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        lat1 = Math.toRadians(lat1);
        lat2 = Math.toRadians(lat2);
        double a = Math.pow(Math.sin(dLat / 2), 2) + Math.pow(Math.sin(dLon / 2), 2) * Math.cos(lat1) * Math.cos(lat2);
        double c = 2 * Math.asin(Math.sqrt(a));
        return EARTH_RADIUS_KM * c;
    }

    public static List<PudoMarker> sortByDistance(List<PudoMarker> markers, double originLat, double originLon) {
        if (markers == null || markers.size() <= 1) {
            return markers;
        }
        List<PudoMarkerDecorator> decs = new ArrayList<>(markers.size());
        for (PudoMarker marker : markers) {
            PudoMarkerDecorator dec = new PudoMarkerDecorator(marker, haversine(originLat, originLon, marker.getLat().doubleValue(), marker.getLon().doubleValue()));
            decs.add(dec);
        }
        decs.sort(Comparator.comparingDouble(PudoMarkerDecorator::getDistance));
        return decs.stream().map(PudoMarkerDecorator::getMarker).collect(Collectors.toList());
    }

    @Data
    private static class PudoMarkerDecorator {

        private final PudoMarker marker;
        private final double distance;

    }

}
