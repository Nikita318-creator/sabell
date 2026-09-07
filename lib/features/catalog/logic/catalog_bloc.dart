import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sabel/features/catalog/data/repositories/server_product_repository.dart';
import 'catalog_event.dart';
import 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final ServerProductRepository repository;

  late final AppLifecycleListener _lifecycleListener;

  CatalogBloc({required this.repository}) : super(const CatalogInitialState()) {
    on<LoadCatalogDataEvent>(_onLoadCatalogData);
    on<CatalogPullToRefreshEvent>(_onCatalogPullToRefreshEvent);
    on<CatalogAppResumedEvent>(
      _onAppResumed,
    ); // 👈 Хэндлер возврата из фонового режима

    // Слушаем возврат приложения из бэкграунда
    _lifecycleListener = AppLifecycleListener(
      onResume: () => add(const CatalogAppResumedEvent()),
    );
  }

  @override
  Future<void> close() {
    _lifecycleListener.dispose();
    return super.close();
  }

  Future<void> _onLoadCatalogData(
    LoadCatalogDataEvent event,
    Emitter<CatalogState> emit,
  ) async {
    emit(const CatalogLoadingState());

    try {
      final products = await repository.getProducts();
      emit(CatalogLoadedState(products: products));
    } catch (e) {
      emit(CatalogErrorState(errorMessage: 'Не удалось загрузить каталог: $e'));
    }
  }

  // 👈 Полная перезагрузка при возврате в приложение с полноэкранным лоадером
  Future<void> _onAppResumed(
    CatalogAppResumedEvent event,
    Emitter<CatalogState> emit,
  ) async {
    emit(const CatalogLoadingState());

    try {
      final products = await repository.getProducts(forceRefresh: true);
      emit(CatalogLoadedState(products: products));
    } catch (e) {
      emit(CatalogErrorState(errorMessage: 'Не удалось обновить каталог: $e'));
    }
  }

  Future<void> _onCatalogPullToRefreshEvent(
    CatalogPullToRefreshEvent event,
    Emitter<CatalogState> emit,
  ) async {
    try {
      final products = await repository.getProducts(forceRefresh: true);
      emit(CatalogLoadedState(products: products));
    } catch (e) {
      emit(CatalogErrorState(errorMessage: 'Не удалось загрузить каталог: $e'));
    }
  }
}
