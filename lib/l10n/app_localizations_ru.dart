// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get location_detect => 'Локация определена';

  @override
  String get location_error => 'Ошибка геолокации';

  @override
  String countrySelected(String country) {
    return 'Ваша страна $country выбрана как дефолтная!';
  }
}
