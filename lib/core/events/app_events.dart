import 'dart:async';

/// Простой EventBus на базе StreamController
class AppEventBus {
  static final AppEventBus _instance = AppEventBus._internal();
  factory AppEventBus() => _instance;
  AppEventBus._internal();

  final _controller = StreamController<AppEvent>.broadcast();

  Stream<AppEvent> get stream => _controller.stream;

  void fire(AppEvent event) {
    _controller.add(event);
  }
}

abstract class AppEvent {}

/// Событие, сигнализирующее о том, что профиль/заказы нужно обновить
class OrdersUpdatedEvent extends AppEvent {}
