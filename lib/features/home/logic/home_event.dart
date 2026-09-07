import 'package:flutter/foundation.dart';

@immutable
abstract class HomeEvent {
  const HomeEvent();
}

class LoadHomeDataEvent extends HomeEvent {
  const LoadHomeDataEvent();
}

class CheckLocationEvent extends HomeEvent {
  const CheckLocationEvent();
}

class SelectManualCountryEvent extends HomeEvent {
  final String country;

  const SelectManualCountryEvent({required this.country});
}

class HomePullToRefreshEvent extends HomeEvent {
  const HomePullToRefreshEvent();
}

class HomeAppResumedEvent extends HomeEvent {
  const HomeAppResumedEvent();

  @override
  List<Object?> get props => [];
}
