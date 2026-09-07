import 'package:flutter_bloc/flutter_bloc.dart';
import 'counter_event.dart';
import 'counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterState.initial()) {
    // Регистрируем обработчики событий
    on<CounterIncremented>(_onIncremented);
    on<CounterDecremented>(_onDecremented);
    on<CounterReset>(_onReset);
  }

  void _onIncremented(CounterIncremented event, Emitter<CounterState> emit) {
    emit(state.copyWith(value: state.value + 1, clearError: true));
  }

  void _onDecremented(CounterDecremented event, Emitter<CounterState> emit) {
    if (state.value > 0) {
      emit(state.copyWith(value: state.value - 1, clearError: true));
    } else {
      emit(state.copyWith(errorMessage: 'Счетчик не может быть меньше нуля!'));
    }
  }

  void _onReset(CounterReset event, Emitter<CounterState> emit) {
    emit(CounterState.initial());
  }
}
