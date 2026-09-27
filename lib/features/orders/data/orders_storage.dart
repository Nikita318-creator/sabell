import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OrderItem {
  final String title;
  final String imageUrl;

  OrderItem({required this.title, required this.imageUrl});

  Map<String, dynamic> toJson() => {'title': title, 'imageUrl': imageUrl};

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

class SavedOrder {
  final String id;

  /// Дата и время добавления (с точностью до минут)
  final DateTime date;
  final double totalPrice;
  final List<OrderItem> items;

  SavedOrder({
    required this.id,
    required this.date,
    required this.totalPrice,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'totalPrice': totalPrice,
    'items': items.map((i) => i.toJson()).toList(),
  };

  factory SavedOrder.fromJson(Map<String, dynamic> json) {
    return SavedOrder(
      id: json['id'] ?? '',
      date: DateTime.parse(json['date']),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      items: (json['items'] as List)
          .map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}

class OrdersStorage {
  static const String _key = 'saved_orders_history';

  static DateTime _nowWithMinutePrecision() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour, now.minute);
  }

  /// Сохранение одного нового заказа
  static Future<void> saveOrder({
    required List<OrderItem> items,
    required double totalPrice,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existingOrders = await getOrders();

    final newOrder = SavedOrder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: _nowWithMinutePrecision(),
      totalPrice: totalPrice,
      items: items,
    );

    existingOrders.insert(0, newOrder);

    final jsonList = existingOrders.map((o) => o.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  /// Сохранение массива заказов (используется при обновлении/очистке устаревших)
  static Future<void> saveOrdersList(List<SavedOrder> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = orders.map((o) => o.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  /// Получение всех сохранённых заказов
  static Future<List<SavedOrder>> getOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => SavedOrder.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Ручная очистка всей истории
  static Future<void> clearOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
