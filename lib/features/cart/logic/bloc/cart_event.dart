import 'package:flutter/foundation.dart';

@immutable
abstract class CartEvent {
  const CartEvent();
}

class LoadCartEvent extends CartEvent {
  const LoadCartEvent();
}

class AddToCartEvent extends CartEvent {
  final String productId;
  const AddToCartEvent(this.productId);
}

class RemoveFromCartEvent extends CartEvent {
  final String productId;
  const RemoveFromCartEvent(this.productId);
}

// 👈 Новый ивент оформления заказа
class CheckoutCartEvent extends CartEvent {
  const CheckoutCartEvent();
}
