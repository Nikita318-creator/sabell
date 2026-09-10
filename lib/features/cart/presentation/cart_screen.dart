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

  void _showContactBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetContext) {
        return _ContactFormBottomSheet(
          onSubmit: () {
            // Запускаем списывание товара и мок-сервис только после успешного заполнения и закрытия окна
            context.read<CartBloc>().add(const CheckoutCartEvent());
          },
        );
      },
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
                            'Оформляя заказ, вы ничего не платите. Мы свяжемся с вами по условиям вашего заказа — оплата только при получении.',
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.4,
                              color: Color(0xFF666666),
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: isCheckoutLoading
                                ? null
                                : () => _showContactBottomSheet(context),
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
                                      'Оформить Заказ',
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

class _ContactFormBottomSheet extends StatefulWidget {
  final VoidCallback onSubmit;

  const _ContactFormBottomSheet({required this.onSubmit});

  @override
  State<_ContactFormBottomSheet> createState() =>
      _ContactFormBottomSheetState();
}

class _ContactFormBottomSheetState extends State<_ContactFormBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telegramController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _viberController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();

  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _telegramController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
    _viberController.addListener(_validateForm);
    _instagramController.addListener(_validateForm);
    _whatsappController.addListener(_validateForm);
  }

  void _validateForm() {
    final hasName = _nameController.text.trim().isNotEmpty;
    final hasAtLeastOneContact =
        _emailController.text.trim().isNotEmpty ||
        _telegramController.text.trim().isNotEmpty ||
        _phoneController.text.trim().isNotEmpty ||
        _viberController.text.trim().isNotEmpty ||
        _instagramController.text.trim().isNotEmpty ||
        _whatsappController.text.trim().isNotEmpty;

    final isValid = hasName && hasAtLeastOneContact;

    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _telegramController.dispose();
    _phoneController.dispose();
    _viberController.dispose();
    _instagramController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: CupertinoTextField(
        controller: controller,
        placeholder: label,
        keyboardType: keyboardType,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E5E5)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: bottomInset + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Детали заказа и связь',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Наш менеджер свяжется с вами в ближайшее время по деталям заказа и обсудит условия самовывоза/доставки. Оплата происходит только при получении товара.',
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 16),
            _buildField('Ваше имя *', _nameController),
            const Text(
              'Укажите хотя бы один способ связи:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF888888),
              ),
            ),
            const SizedBox(height: 8),
            _buildField(
              'Email',
              _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            _buildField('Telegram ID', _telegramController),
            _buildField(
              'Номер телефона',
              _phoneController,
              keyboardType: TextInputType.phone,
            ),
            _buildField(
              'Viber',
              _viberController,
              keyboardType: TextInputType.phone,
            ),
            _buildField('Instagram', _instagramController),
            _buildField(
              'WhatsApp',
              _whatsappController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _isFormValid
                  ? () {
                      Navigator.of(context).pop();
                      widget.onSubmit();
                    }
                  : null,
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: _isFormValid ? Colors.black : const Color(0xFFCCCCCC),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'ПРОДОЛЖИТЬ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final RemoteProducts product;
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
