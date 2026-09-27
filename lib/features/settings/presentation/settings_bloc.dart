import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sabel/features/orders/data/orders_storage.dart';

// EVENTS
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {
  const LoadSettingsEvent();
}

class UpdateCountryEvent extends SettingsEvent {
  final String country;

  const UpdateCountryEvent(this.country);

  @override
  List<Object?> get props => [country];
}

// STATES
abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitialState extends SettingsState {
  const SettingsInitialState();
}

class SettingsLoadedState extends SettingsState {
  final String userId;
  final List<SavedOrder> activeOrders;

  const SettingsLoadedState({required this.userId, required this.activeOrders});

  @override
  List<Object?> get props => [userId, activeOrders];
}

// BLOC
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  static const String _userIdKey = 'user_unique_id';

  SettingsBloc() : super(const SettingsInitialState()) {
    on<LoadSettingsEvent>(_onLoadSettings);
  }

  Future<void> _onLoadSettings(
    LoadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    // 1. Загрузка / генерация User ID
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString(_userIdKey);

    if (userId == null) {
      final random = Random();
      userId = (100000 + random.nextInt(900000)).toString();
      await prefs.setString(_userIdKey, userId);
    }

    // 2. Получение и фильтрация заказов из хранилища
    final allOrders = await OrdersStorage.getOrders();
    final now = DateTime.now();

    final List<SavedOrder> validOrders = [];
    bool hasExpiredOrders = false;

    for (final order in allOrders) {
      final difference = now.difference(order.date);
      if (difference.inHours >= 24) {
        // Заказ старше 24 часов - помечаем для удаления
        hasExpiredOrders = true;
      } else {
        // Заказ новее 24 часов - оставляем
        validOrders.add(order);
      }
    }

    // Если были заказы старше 24 часов, перезаписываем БД актуальным списком
    if (hasExpiredOrders) {
      await OrdersStorage.saveOrdersList(validOrders);
    }

    emit(SettingsLoadedState(userId: userId, activeOrders: validOrders));
  }
}
