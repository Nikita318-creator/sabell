import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitialState extends SettingsState {
  const SettingsInitialState();
}

class SettingsLoadedState extends SettingsState {
  final String selectedCountry;
  final List<String> availableCountries;

  const SettingsLoadedState({
    required this.selectedCountry,
    required this.availableCountries,
  });

  @override
  List<Object?> get props => [selectedCountry, availableCountries];
}
