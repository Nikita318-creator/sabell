import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sabel/features/catalog/data/repositories/server_product_repository.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ServerProductRepository repository; // 👈 Добавили репозиторий
  late final AppLifecycleListener _lifecycleListener;

  SearchBloc({required this.repository}) : super(const SearchInitialState()) {
    on<SearchTextChangedEvent>(_onTextChanged);
    on<SearchQuerySubmittedEvent>(_onQuerySubmitted);
    on<SearchResetEvent>(_onReset);
    on<SearchAppLifecycleChangedEvent>(_onLifecycleChanged);

    // Подписываем BLoC на события системного цикла
    _lifecycleListener = AppLifecycleListener(
      onStateChange: (state) {
        add(SearchAppLifecycleChangedEvent(state));
      },
    );
  }

  @override
  Future<void> close() {
    // Чистим за собой подписку при уничтожении БЛоКа
    _lifecycleListener.dispose();
    return super.close();
  }

  void _onLifecycleChanged(
    SearchAppLifecycleChangedEvent event,
    Emitter<SearchState> emit,
  ) {
    switch (event.state) {
      case AppLifecycleState.resumed:
        debugPrint('⚡️ [BLOC] App RESUMED — Приложение в фокусе');
        break;
      case AppLifecycleState.inactive:
        debugPrint(
          '⚠️ [BLOC] App INACTIVE — Переходное состояние (шторка/звонок)',
        );
        break;
      case AppLifecycleState.paused:
        debugPrint('💤 [BLOC] App PAUSED — Приложение свернуто в бэкграунд');
        break;
      case AppLifecycleState.detached:
        debugPrint('❌ [BLOC] App DETACHED — Движок отключается');
        break;
      case AppLifecycleState.hidden:
        debugPrint('👁️‍🗨️ [BLOC] App HIDDEN — Окно полностью скрыто');
        break;
    }
  }

  void _onTextChanged(SearchTextChangedEvent event, Emitter<SearchState> emit) {
    emit(SearchInitialState(queryText: event.text));
  }

  void _onReset(SearchResetEvent event, Emitter<SearchState> emit) {
    emit(const SearchInitialState(queryText: ''));
  }

  Future<void> _onQuerySubmitted(
    SearchQuerySubmittedEvent event,
    Emitter<SearchState> emit,
  ) async {
    final cleanQuery = event.query.trim().toLowerCase();

    if (cleanQuery.length < 3) {
      emit(
        SearchValidationErrorState(
          'Пожалуйста, введите не менее 3 символов для поиска',
          queryText: event.query,
        ),
      );
      return;
    }

    emit(SearchLoadingState(queryText: event.query));

    try {
      // 👈 Загружаем свежие RemoteProducts вместо моков
      final allProducts = await repository.getProducts();

      final results = allProducts.where((product) {
        final titleMatch = product.title.toLowerCase().contains(cleanQuery);
        final tagMatch = product.tags.any(
          (tag) => tag.toLowerCase().contains(cleanQuery),
        );

        return titleMatch || tagMatch;
      }).toList();

      if (results.isEmpty) {
        emit(SearchEmptyState(query: cleanQuery, queryText: event.query));
      } else {
        emit(
          SearchSuccessState(
            products: results,
            query: cleanQuery,
            queryText: event.query,
          ),
        );
      }
    } catch (e) {
      emit(
        SearchValidationErrorState(
          'Ошибка при поиске: $e',
          queryText: event.query,
        ),
      );
    }
  }
}
