import 'package:flutter/foundation.dart';

@immutable
class OrderContactInfo {
  final String name;
  final String? email;
  final String? telegram;
  final String? phone;
  final String? viber;
  final String? instagram;
  final String? whatsapp;

  const OrderContactInfo({
    required this.name,
    this.email,
    this.telegram,
    this.phone,
    this.viber,
    this.instagram,
    this.whatsapp,
  });

  String toFormattedString() {
    final buffer = StringBuffer();
    buffer.writeln('👤 *Имя:* $name');
    if (email != null && email!.isNotEmpty)
      buffer.writeln('📧 *Email:* $email');
    if (telegram != null && telegram!.isNotEmpty)
      buffer.writeln('✈️ *Telegram:* $telegram');
    if (phone != null && phone!.isNotEmpty)
      buffer.writeln('📞 *Телефон:* $phone');
    if (viber != null && viber!.isNotEmpty)
      buffer.writeln('🟣 *Viber:* $viber');
    if (instagram != null && instagram!.isNotEmpty)
      buffer.writeln('📸 *Instagram:* $instagram');
    if (whatsapp != null && whatsapp!.isNotEmpty)
      buffer.writeln('🟢 *WhatsApp:* $whatsapp');
    return buffer.toString();
  }
}

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

class CheckoutCartEvent extends CartEvent {
  final OrderContactInfo contactInfo;

  const CheckoutCartEvent(this.contactInfo);
}
