sealed class CounterEvent {
  const CounterEvent();
}

/// Пользователь нажал кнопку "+"
final class CounterIncremented extends CounterEvent {
  const CounterIncremented();
}

/// Пользователь нажал кнопку "-"
final class CounterDecremented extends CounterEvent {
  const CounterDecremented();
}

/// Пользователь нажал сброс
final class CounterReset extends CounterEvent {
  const CounterReset();
}
