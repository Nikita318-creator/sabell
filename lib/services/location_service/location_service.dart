import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Запрашивает геопозицию и преобразует координаты в название страны
  Future<String> getCountryName() async {
    debugPrint('[GEO_DEBUG] 1. Вызов getCountryName()');

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    debugPrint(
      '[GEO_DEBUG] 2. Geolocator.isLocationServiceEnabled() = $serviceEnabled',
    );
    if (!serviceEnabled) {
      debugPrint(
        '[GEO_DEBUG] ERROR: Службы геолокации отключены на устройстве',
      );
      throw Exception('Службы геолокации отключены');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    debugPrint('[GEO_DEBUG] 3. Geolocator.checkPermission() = $permission');

    if (permission == LocationPermission.denied) {
      debugPrint(
        '[GEO_DEBUG] 4. Запрашиваем разрешение через requestPermission()...',
      );
      permission = await Geolocator.requestPermission();
      debugPrint('[GEO_DEBUG] 5. Результат requestPermission() = $permission');
      if (permission == LocationPermission.denied) {
        debugPrint(
          '[GEO_DEBUG] ERROR: Доступ к геолокации отклонен пользователем',
        );
        throw Exception('Доступ к геолокации отклонен');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint(
        '[GEO_DEBUG] ERROR: Доступ заблокирован навсегда (deniedForever)',
      );
      throw Exception('Доступ заблокирован навсегда');
    }

    debugPrint(
      '[GEO_DEBUG] 6. Получение координат через getCurrentPosition()...',
    );
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 10),
      ),
    );
    debugPrint(
      '[GEO_DEBUG] 7. Координаты получены: lat=${position.latitude}, lng=${position.longitude}',
    );

    try {
      debugPrint('[GEO_DEBUG] 8. Запуск geocoding.placemarkFromCoordinates...');
      final geocoding = Geocoding();
      List<Placemark> placemarks = await geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      debugPrint('[GEO_DEBUG] 9. Найдено placemarks: ${placemarks.length}');
      if (placemarks.isNotEmpty) {
        final country = placemarks.first.country;
        debugPrint(
          '[GEO_DEBUG] 10. Поле country у первого placemark = "$country"',
        );
        if (country != null && country.trim().isNotEmpty) {
          return country;
        }
      }
    } catch (e, stack) {
      debugPrint('[GEO_DEBUG] EXCEPTION в Geocoding: $e\n$stack');
      return 'Неизвестная страна';
    }

    debugPrint(
      '[GEO_DEBUG] 11. Placemark пустой или country null, возвращаем "Неизвестная страна"',
    );
    return 'Неизвестная страна';
  }
}
