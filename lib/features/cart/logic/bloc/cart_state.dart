import 'package:flutter/foundation.dart';
import 'package:flutter_sabel/features/catalog/data/models/catalog_model.dart';

@immutable
abstract class CartState {
  const CartState();
}

class CartInitialState extends CartState {
  const CartInitialState();
}

class CartLoadingState extends CartState {
  const CartLoadingState();
}

class CartLoadedState extends CartState {
  final List<RemoteProducts> products;
  final List<String> productIds;

  const CartLoadedState({required this.products, required this.productIds});

  double get totalPrice => products.fold(0, (sum, item) => sum + item.price);
}

// 👈 Состояние процесса оплаты (для лоадера на кнопке)
class CartCheckoutInProgressState extends CartState {
  const CartCheckoutInProgressState();
}

// 👈 Успешная покупка
class CartCheckoutSuccessState extends CartState {
  const CartCheckoutSuccessState();
}

// 👈 Ошибка с понятным сообщением для юзера
class CartErrorState extends CartState {
  final String message;
  const CartErrorState(this.message);
}
