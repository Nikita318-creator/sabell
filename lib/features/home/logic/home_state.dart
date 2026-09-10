import 'package:flutter/foundation.dart';
import 'package:flutter_sabel/features/catalog/data/models/catalog_model.dart';

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
  final String? country;

  const HomeLoadedState({required this.products, this.country});

  HomeLoadedState copyWith({
    List<RemoteProducts>? products, // 👈 Меняем тип на RemoteProducts
    String? country,
  }) {
    return HomeLoadedState(
      products: products ?? this.products,
      country: country ?? this.country,
    );
  }

  // Явный метод для сброса страны в null без костылей
  HomeLoadedState resetCountry() {
    return HomeLoadedState(products: products, country: null);
  }
}

class HomeErrorState extends HomeState {
  final String errorMessage;

  const HomeErrorState({required this.errorMessage});
}
