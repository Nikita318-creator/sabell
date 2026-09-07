// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get location_detect => 'Location detected!';

  @override
  String get location_error => 'Location error';

  @override
  String countrySelected(String country) {
    return 'Your country $country is selected as default!';
  }
}
