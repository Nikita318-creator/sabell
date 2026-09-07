import 'package:flutter/foundation.dart';
import 'package:flutter_sabel/features/catalog/data/models/catalog_model.dart';

enum LocationStatus { initial, success, denied }

@immutable
abstract class HomeState {
  const HomeState();
}

class HomeInitialState extends HomeState {
  const HomeInitialState();
}

class HomeLoadingState extends HomeState {
  const HomeLoadingState();
}

class HomeLoadedState extends HomeState {
  final List<RemoteProducts> products; // 👈 Меняем тип на RemoteProducts
  final LocationStatus locationStatus;
  final String? country;

  const HomeLoadedState({
    required this.products,
    this.locationStatus = LocationStatus.initial,
    this.country,
  });

  HomeLoadedState copyWith({
    List<RemoteProducts>? products, // 👈 Меняем тип на RemoteProducts
    LocationStatus? locationStatus,
    String? country,
  }) {
    return HomeLoadedState(
      products: products ?? this.products,
      locationStatus: locationStatus ?? this.locationStatus,
      country: country ?? this.country,
    );
  }

  // Явный метод для сброса страны в null без костылей
  HomeLoadedState resetCountry({LocationStatus? locationStatus}) {
    return HomeLoadedState(
      products: products,
      locationStatus: locationStatus ?? this.locationStatus,
      country: null,
    );
  }
}

class HomeErrorState extends HomeState {
  final String errorMessage;

  const HomeErrorState({required this.errorMessage});
}