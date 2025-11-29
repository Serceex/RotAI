import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Konum servisleri kapalı');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Konum izni reddedildi');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Konum izni kalıcı olarak reddedildi');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// GeoFirePoint oluşturma - şimdilik basit bir Map döndürüyoruz
  /// Gelecekte geoflutterfire_plus paketi düzgün yapılandırıldığında güncellenebilir
  Map<String, dynamic> createGeoPoint(double latitude, double longitude) {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'geohash': _generateGeohash(latitude, longitude),
    };
  }

  Future<double> calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) async {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Basit geohash oluşturma (gerçek geohash algoritması yerine basit bir hash)
  String _generateGeohash(double latitude, double longitude) {
    // Basit bir geohash benzeri string oluştur
    return '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}';
  }
}

