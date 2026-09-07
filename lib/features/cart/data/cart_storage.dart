import 'package:shared_preferences/shared_preferences.dart';

class CartStorage {
  static const String _cartKey = 'persistent_cart_product_ids';

  // Получить список ID сохраненных товаров
  static Future<List<String>> getCartItemIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_cartKey) ?? [];
  }

  // Добавить товар по ID
  static Future<void> addProduct(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(_cartKey) ?? [];
    if (!items.contains(id)) {
      items.add(id);
      await prefs.setStringList(_cartKey, items);
    }
  }

  // Удалить товар по ID
  static Future<void> removeProduct(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(_cartKey) ?? [];
    if (items.contains(id)) {
      items.remove(id);
      await prefs.setStringList(_cartKey, items);
    }
  }

  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }

  // Проверить, находится ли товар в корзине
  static Future<bool> containsProduct(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(_cartKey) ?? [];
    return items.contains(id);
  }
}
