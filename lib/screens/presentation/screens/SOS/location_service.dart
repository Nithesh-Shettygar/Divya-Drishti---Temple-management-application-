import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw Exception("Location service disabled");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location Permission Denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location Permission permanently denied");
    }

    /// 🔥 High Accuracy Location Fetch
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );
  }

  /// For even more accurate result, improves after a few seconds
  static Future<Position> getPreciseLocation() async {
    late Position pos;

    await for (var position in Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      ),
    )) {
      pos = position;
      break;  // take latest precise location once
    }

    return pos;
  }
}
