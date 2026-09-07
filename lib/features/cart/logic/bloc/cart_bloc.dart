import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sabel/features/catalog/data/repositories/server_product_repository.dart';
import 'package:flutter_sabel/features/cart/data/cart_storage.dart';
import 'package:flutter_sabel/features/cart/logic/bloc/cart_event.dart';
import 'package:flutter_sabel/features/cart/logic/bloc/cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final ServerProductRepository repository;

  CartBloc({required this.repository}) : super(const CartInitialState()) {
    on<LoadCartEvent>(_onLoadCart);
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<CheckoutCartEvent>(_onCheckout); // 👈 Регистрируем
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
      emit(CartErrorState('Не удалось загрузить корзину. Попробуйте позже.'));
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

  Future<void> _onCheckout(
    CheckoutCartEvent event,
    Emitter<CartState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CartLoadedState || currentState.products.isEmpty)
      return;

    emit(const CartCheckoutInProgressState());

    try {
      final productIds = currentState.products.map((p) => p.id).toList();

      // 1. Делаем атомарный списание в Firestore
      await repository.checkout(productIds);

      // 2. Очищаем локальное хранилище корзины после успешной оплаты
      await CartStorage.clearCart();

      emit(const CartCheckoutSuccessState());
      add(const LoadCartEvent());
    } catch (e) {
      // Извлекаем кастомное понятное сообщение или даем дефолтное
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(CartErrorState(errorMessage));

      // Перезагружаем корзину, чтобы обновить актуальные остатки
      add(const LoadCartEvent());
    }
  }
}
