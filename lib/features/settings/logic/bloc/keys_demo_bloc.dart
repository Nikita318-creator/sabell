import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'keys_demo_event.dart';
import 'keys_demo_state.dart';

class KeysDemoBloc extends Bloc<KeysDemoEvent, KeysDemoState> {
  KeysDemoBloc()
    : super(
        KeysDemoState(
          countries: const [
            CountryModel(id: '1', name: 'Беларусь', color: Colors.blueAccent),
            CountryModel(id: '2', name: 'Россия', color: Colors.redAccent),
            CountryModel(id: '3', name: 'Казахстан', color: Colors.teal),
          ],
          uniqueKey: UniqueKey(),
        ),
      ) {
    on<SwapItemsEvent>(_onSwapItems);
    on<RegenerateUniqueKeyEvent>(_onRegenerateUniqueKey);
    on<ToggleKeyUsageEvent>(_onToggleKeyUsage);
    on<IncrementBlocCounterEvent>(_onIncrementBlocCounter);
  }

  void _onSwapItems(SwapItemsEvent event, Emitter<KeysDemoState> emit) {
    final list = List<CountryModel>.from(state.countries);
    final item = list.removeAt(0);
    list.add(item);
    emit(state.copyWith(countries: list));
  }

  void _onRegenerateUniqueKey(
    RegenerateUniqueKeyEvent event,
    Emitter<KeysDemoState> emit,
  ) {
    emit(state.copyWith(uniqueKey: UniqueKey()));
  }

  void _onToggleKeyUsage(
    ToggleKeyUsageEvent event,
    Emitter<KeysDemoState> emit,
  ) {
    switch (event.keyType) {
      case 'valueKey':
        emit(state.copyWith(useValueKey: !state.useValueKey));
        break;
      case 'objectKey':
        emit(state.copyWith(useObjectKey: !state.useObjectKey));
        break;
      case 'uniqueKey':
        emit(state.copyWith(useUniqueKey: !state.useUniqueKey));
        break;
      case 'pageStorageKey':
        emit(state.copyWith(usePageStorageKey: !state.usePageStorageKey));
        break;
      case 'globalKey':
        emit(state.copyWith(useGlobalKey: !state.useGlobalKey));
        break;
    }
  }

  void _onIncrementBlocCounter(
    IncrementBlocCounterEvent event,
    Emitter<KeysDemoState> emit,
  ) {
    emit(state.copyWith(blocCounter: state.blocCounter + 1));
  }
}
