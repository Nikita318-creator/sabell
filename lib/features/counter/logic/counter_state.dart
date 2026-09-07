class CounterState {
  final int value;
  final String? errorMessage;

  const CounterState({required this.value, this.errorMessage});

  /// Начальное состояние
  factory CounterState.initial() => const CounterState(value: 0);

  /// Вспомогательный метод copyWith (аналог struct copy в Swift)
  CounterState copyWith({
    int? value,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CounterState(
      value: value ?? this.value,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
