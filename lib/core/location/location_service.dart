import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

enum LocationStatus { granted, denied, serviceDisabled, unavailable }

/// Acceso a la ubicación real del dispositivo (GPS/navegador). Todo va envuelto
/// en try/catch para que nunca rompa la UI (p. ej. en tests o plataformas sin
/// soporte devuelve [LocationStatus.unavailable]).
abstract final class LocationService {
  static Future<LocationStatus> ensurePermission() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return LocationStatus.serviceDisabled;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return LocationStatus.denied;
      }
      return LocationStatus.granted;
    } catch (_) {
      return LocationStatus.unavailable;
    }
  }

  static Future<LatLng?> current() async {
    try {
      final p = await Geolocator.getCurrentPosition();
      return LatLng(p.latitude, p.longitude);
    } catch (_) {
      return null;
    }
  }

  static Stream<LatLng> positionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).map((p) => LatLng(p.latitude, p.longitude));
  }

  static double distanceMeters(LatLng a, LatLng b) => Geolocator.distanceBetween(
        a.latitude,
        a.longitude,
        b.latitude,
        b.longitude,
      );
}
