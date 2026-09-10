import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sabel/features/catalog/data/models/catalog_model.dart';
import 'package:flutter_sabel/features/catalog/data/repositories/server_product_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

// Добавь HomeAppResumedEvent в home_event.dart, если его там нет:
// class HomeAppResumedEvent extends HomeEvent { const HomeAppResumedEvent(); }

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ServerProductRepository _repository;
  static const String _countryKey = 'user_selected_country';

  late final AppLifecycleListener _lifecycleListener;

  HomeBloc({required ServerProductRepository repository})
    : _repository = repository,
      super(const HomeInitialState()) {
    on<LoadHomeDataEvent>(_onLoadHomeData);
    on<HomeAppResumedEvent>(
      _onAppResumed,
    ); // 👈 Новый обработчик для полного перезапуска
    on<CheckLocationEvent>(_onCheckLocation);
    on<SelectManualCountryEvent>(_onSelectManualCountry);
    on<HomePullToRefreshEvent>(_onHomePullToRefresh);

    // При возврате из бэкграунда вызываем полный сброс и перезагрузку
    _lifecycleListener = AppLifecycleListener(
      onResume: () => add(const HomeAppResumedEvent()),
    );
  }

  @override
  Future<void> close() {
    _lifecycleListener.dispose();
    return super.close();
  }

  Future<void> _onLoadHomeData(
    LoadHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoadingState());

    try {
      final allProducts = await _repository.getProducts();
      final products = allProducts
          .where((product) => product.isShowOnHomeScreen)
          .toList();

      final prefs = await SharedPreferences.getInstance();
      final savedCountry = prefs.getString(_countryKey);

      if (savedCountry != null && savedCountry.isNotEmpty) {
        emit(HomeLoadedState(products: products, country: savedCountry));
      } else {
        emit(HomeLoadedState(products: products));
        add(const CheckLocationEvent());
      }
    } catch (e) {
      emit(HomeErrorState(errorMessage: 'Не удалось загрузить каталог: $e'));
    }
  }

  Future<void> _onAppResumed(
    HomeAppResumedEvent event,
    Emitter<HomeState> emit,
  ) async {
    // 1. Показываем лоадер для полной перезагрузки
    emit(const HomeLoadingState());

    try {
      // 2. Принудительно качаем свежий каталог с сервера
      final allProducts = await _repository.getProducts(forceRefresh: true);
      final products = allProducts
          .where((product) => product.isShowOnHomeScreen)
          .toList();

      final prefs = await SharedPreferences.getInstance();
      final savedCountry = prefs.getString(_countryKey);

      // 3. Выставляем LocationStatus.initial, чтобы BlocListener НЕ триггерил алерт
      emit(HomeLoadedState(products: products, country: savedCountry));

      // 4. Если страны ещё НЕТ в кэше (самый первый вход) — запускаем чекер
      if (savedCountry == null || savedCountry.isEmpty) {
        add(const CheckLocationEvent());
      }
    } catch (e) {
      emit(HomeErrorState(errorMessage: 'Не удалось обновить каталог: $e'));
    }
  }

  Future<void> _onHomePullToRefresh(
    HomePullToRefreshEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final allProducts = await _repository.getProducts(forceRefresh: true);
      final products = allProducts
          .where((product) => product.isShowOnHomeScreen)
          .toList();

      if (state is HomeLoadedState) {
        final currentState = state as HomeLoadedState;
        emit(currentState.copyWith(products: products));
      } else {
        emit(HomeLoadedState(products: products));
      }
    } catch (e) {
      emit(HomeErrorState(errorMessage: 'Не удалось обновить каталог: $e'));
    }
  }

  Future<void> _onCheckLocation(
    CheckLocationEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoadedState) return;
    final currentState = state as HomeLoadedState;
  }

  Future<void> _onSelectManualCountry(
    SelectManualCountryEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoadedState) return;
    final currentState = state as HomeLoadedState;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_countryKey, event.country);
  }
}
