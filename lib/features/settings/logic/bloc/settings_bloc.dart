import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  static const String _countryKey = 'user_selected_country';

  static const List<String> defaultCountries = [
    'Беларусь',
    'Россия',
    'Казахстан',
    'Армения',
    'Грузия',
    'Узбекистан',
    'ОАЭ',
  ];

  SettingsBloc() : super(const SettingsInitialState()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<UpdateCountryEvent>(_onUpdateCountry);
  }

  Future<void> _onLoadSettings(
    LoadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final savedCountry = prefs.getString(_countryKey) ?? 'Беларусь';

    emit(
      SettingsLoadedState(
        selectedCountry: savedCountry,
        availableCountries: defaultCountries,
      ),
    );
  }

  Future<void> _onUpdateCountry(
    UpdateCountryEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_countryKey, event.country);

    emit(
      SettingsLoadedState(
        selectedCountry: event.country,
        availableCountries: defaultCountries,
      ),
    );
  }
}
