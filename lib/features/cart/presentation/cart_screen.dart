import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sabel/features/catalog/data/models/catalog_model.dart';
import 'package:flutter_sabel/features/cart/logic/bloc/cart_bloc.dart';
import 'package:flutter_sabel/features/cart/logic/bloc/cart_event.dart';
import 'package:flutter_sabel/features/cart/logic/bloc/cart_state.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void _showErrorDialog(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Не удалось оформить заказ'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(message),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ПОНЯТНО'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Успешно!'),
        content: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text('Ваш заказ успешно оформлен.'),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ОК'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: CupertinoPageScaffold(
        backgroundColor: Colors.white,
        navigationBar: const CupertinoNavigationBar(
          backgroundColor: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFE5E5E5), width: 0.5),
          ),
          middle: Text(
            'КОРЗИНА',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<CartBloc, CartState>(
            listener: (context, state) {
              if (state is CartErrorState) {
                _showErrorDialog(context, state.message);
              } else if (state is CartCheckoutSuccessState) {
                _showSuccessDialog(context);
              }
            },
            builder: (context, state) {
              if (state is CartLoadingState || state is CartInitialState) {
                return const Center(
                  child: CupertinoActivityIndicator(
                    radius: 12,
                    color: Colors.black,
                  ),
                );
              }

              final isCheckoutLoading = state is CartCheckoutInProgressState;

              if (state is CartLoadedState || isCheckoutLoading) {
                // Извлекаем список товаров если состояние CartLoadedState
                final products = state is CartLoadedState
                    ? state.products
                    : <RemoteProducts>[];
                final totalPrice = state is CartLoadedState
                    ? state.totalPrice
                    : 0.0;

                if (products.isEmpty && !isCheckoutLoading) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            CupertinoIcons.bag,
                            size: 40,
                            color: Color(0xFFCCCCCC),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'ВАША КОРЗИНА ПУСТА',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: Colors.black,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Вы пока не добавили ни одного товара.\nПерейдите в каталог, чтобы выбрать понравившиеся модели.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF777777),
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: products.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return _CartItemTile(
                            product: product,
                            onRemove: () {
                              context.read<CartBloc>().add(
                                RemoveFromCartEvent(product.id),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Color(0xFFE5E5E5), width: 0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'ИТОГО:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: Color(0xFF777777),
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              Text(
                                '${totalPrice.toStringAsFixed(2)} BYN',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Нажимая кнопку «Оплатить корзину», вы соглашаетесь с условиями пользовательского соглашения и возврата.',
                            style: TextStyle(
                              fontSize: 10,
                              height: 1.4,
                              color: Color(0xFF888888),
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: isCheckoutLoading
                                ? null
                                : () {
                                    context.read<CartBloc>().add(
                                      const CheckoutCartEvent(),
                                    );
                                  },
                            child: Container(
                              width: double.infinity,
                              height: 48,
                              color: isCheckoutLoading
                                  ? Colors.grey
                                  : Colors.black,
                              alignment: Alignment.center,
                              child: isCheckoutLoading
                                  ? const CupertinoActivityIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'ОПЛАТИТЬ КОРЗИНУ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final RemoteProducts product; // 👈 Заменили модель на RemoteProducts
  final VoidCallback onRemove;

  const _CartItemTile({required this.product, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          SizedBox(
            width: 70,
            height: 93,
            child: Container(
              color: const Color(0xFFF2F2F2),
              child: Image.network(product.imageUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${product.price.toStringAsFixed(2)} BYN',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.all(12),
            onPressed: onRemove,
            child: const Icon(
              CupertinoIcons.minus_circle,
              size: 20,
              color: Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutWebViewMockScreen extends StatelessWidget {
  const _CheckoutWebViewMockScreen();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: CupertinoPageScaffold(
        backgroundColor: Colors.white,
        navigationBar: const CupertinoNavigationBar(
          backgroundColor: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFE5E5E5), width: 0.5),
          ),
          middle: Text(
            'ЭКВАЙРИНГ (МОК)',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CupertinoActivityIndicator(radius: 14, color: Colors.black),
                SizedBox(height: 16),
                Text(
                  'ЗАГРУЗКА ПЛАТЕЖНОГО ШЛЮЗА...',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                    color: Color(0xFF777777),
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
