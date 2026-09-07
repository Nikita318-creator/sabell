import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {
  const LoadSettingsEvent();
}

class UpdateCountryEvent extends SettingsEvent {
  final String country;

  const UpdateCountryEvent(this.country);

  @override
  List<Object?> get props => [country];
}
