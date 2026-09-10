import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_sabel/features/catalog/data/repositories/server_product_repository.dart';
import 'package:flutter_sabel/features/cart/data/cart_storage.dart';
import 'package:flutter_sabel/features/cart/logic/bloc/cart_event.dart';
import 'package:flutter_sabel/features/cart/logic/bloc/cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final ServerProductRepository repository;

  // 🤖 Telegram Bot API Credentials
  static const String _tgBotToken =
      '8737490032:AAGjMSyiuongZJ423hVjSo68Ca2evjvuong';
  static const String _tgChatId = '1059302098';

  CartBloc({required this.repository}) : super(const CartInitialState()) {
    on<LoadCartEvent>(_onLoadCart);
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<CheckoutCartEvent>(_onCheckout);
  }

  Future<void> _onLoadCart(LoadCartEvent event, Emitter<CartState> emit) async {
    emit(const CartLoadingState());
    try {
      final ids = await CartStorage.getCartItemIds();

      if (ids.isEmpty) {
        emit(const CartLoadedState(products: [], productIds: []));
        return;
      }

      final allProducts = await repository.getProducts(forceRefresh: true);
      final cartProducts = allProducts
          .where((p) => ids.contains(p.id))
          .toList();

      emit(CartLoadedState(products: cartProducts, productIds: ids));
    } catch (e) {
      emit(
        const CartErrorState('Не удалось загрузить корзину. Попробуйте позже.'),
      );
    }
  }

  Future<void> _onAddToCart(
    AddToCartEvent event,
    Emitter<CartState> emit,
  ) async {
    await CartStorage.addProduct(event.productId);
    add(const LoadCartEvent());
  }

  Future<void> _onRemoveFromCart(
    RemoveFromCartEvent event,
    Emitter<CartState> emit,
  ) async {
    await CartStorage.removeProduct(event.productId);
    add(const LoadCartEvent());
  }

  Future<void> _sendTelegramNotification({
    required OrderContactInfo contactInfo,
    required List products,
    required double totalPrice,
  }) async {
    try {
      final itemsText = products
          .map((p) => '• ${p.title} — ${p.price.toStringAsFixed(2)} BYN')
          .join('\n');

      final message =
          '''
🛍 *НОВЫЙ ЗАКАЗ!*

${contactInfo.toFormattedString()}
📦 *Товары:*
$itemsText

💰 *Итого:* ${totalPrice.toStringAsFixed(2)} BYN
''';

      final url = Uri.parse(
        'https://api.telegram.org/bot$_tgBotToken/sendMessage',
      );
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chat_id': _tgChatId,
          'text': message,
          'parse_mode': 'Markdown',
        }),
      );
    } catch (_) {
      // Игнорируем сетевые ошибки отправки в ТГ, чтобы списание товара в Firestore все равно завершилось
    }
  }

  Future<void> _onCheckout(
    CheckoutCartEvent event,
    Emitter<CartState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CartLoadedState || currentState.products.isEmpty) {
      return;
    }

    final products = currentState.products;
    final totalPrice = currentState.totalPrice;

    emit(const CartCheckoutInProgressState());

    try {
      final productIds = products.map((p) => p.id).toList();

      // 1. Атомарное списание товара в Firestore
      await repository.checkout(productIds);

      // 2. Отправка уведомления в Telegram бот
      await _sendTelegramNotification(
        contactInfo: event.contactInfo,
        products: products,
        totalPrice: totalPrice,
      );

      // 3. Очистка локальной корзины
      await CartStorage.clearCart();

      emit(const CartCheckoutSuccessState());
      add(const LoadCartEvent());
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(CartErrorState(errorMessage));

      add(const LoadCartEvent());
    }
  }
}
