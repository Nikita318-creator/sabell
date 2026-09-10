import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_sabel/features/catalog/data/models/catalog_model.dart';
import 'package:flutter_sabel/features/cart/logic/bloc/cart_bloc.dart';
import 'package:flutter_sabel/features/cart/logic/bloc/cart_event.dart';
import 'package:flutter_sabel/features/cart/logic/bloc/cart_state.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _launchEmailSupport() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'nsun60359@gmail.com',
      queryParameters: {'subject': 'Вопрос по оформлению заказа'},
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Не удалось оформить заказ'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black,
                height: 1.35,
              ),
              children: [
                const TextSpan(
                  text:
                      'Не удалось оформить ваш заказ. Пожалуйста, проверьте правильность введенных данных и попробуйте еще раз. Если возникнут вопросы, вы можете обратиться в поддержку напрямую: ',
                ),
                TextSpan(
                  text: 'nsun60359@gmail.com',
                  style: const TextStyle(
                    color: CupertinoColors.activeBlue,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.of(ctx).pop();
                      _launchEmailSupport();
                    },
                ),
              ],
            ),
          ),
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
          child: Text(
            'Ваш заказ успешно оформлен. Наш менеджер скоро свяжется с вами.',
          ),
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
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetContext) {
        return _ContactFormBottomSheet(
          onSubmit: (contactInfo) {
            context.read<CartBloc>().add(CheckoutCartEvent(contactInfo));
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
                _showErrorDialog(context, state.errorMessage);
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
  final ValueChanged<OrderContactInfo> onSubmit;

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
    _loadSavedForm();

    _nameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _telegramController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _viberController.addListener(_onFieldChanged);
    _instagramController.addListener(_onFieldChanged);
    _whatsappController.addListener(_onFieldChanged);
  }

  Future<void> _loadSavedForm() async {
    final prefs = await SharedPreferences.getInstance();
    _nameController.text = prefs.getString('checkout_name') ?? '';
    _emailController.text = prefs.getString('checkout_email') ?? '';
    _telegramController.text = prefs.getString('checkout_telegram') ?? '';
    _phoneController.text = prefs.getString('checkout_phone') ?? '';
    _viberController.text = prefs.getString('checkout_viber') ?? '';
    _instagramController.text = prefs.getString('checkout_instagram') ?? '';
    _whatsappController.text = prefs.getString('checkout_whatsapp') ?? '';
    _validateForm();
  }

  Future<void> _saveFormToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('checkout_name', _nameController.text.trim());
    await prefs.setString('checkout_email', _emailController.text.trim());
    await prefs.setString('checkout_telegram', _telegramController.text.trim());
    await prefs.setString('checkout_phone', _phoneController.text.trim());
    await prefs.setString('checkout_viber', _viberController.text.trim());
    await prefs.setString(
      'checkout_instagram',
      _instagramController.text.trim(),
    );
    await prefs.setString('checkout_whatsapp', _whatsappController.text.trim());
  }

  void _onFieldChanged() {
    _validateForm();
    _saveFormToPrefs();
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
    _saveFormToPrefs();
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
      padding: const EdgeInsets.only(bottom: 10.0),
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

    return SafeArea(
      bottom: true,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: bottomInset > 0 ? bottomInset + 12 : 16,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDDDDD),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Детали заказа и связь',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Наш менеджер свяжется с вами в ближайшее время по деталям заказа и обсудит условия самовывоза/доставки. Оплата происходит только при получении товара.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: Color(0xFF666666),
                  decoration: TextDecoration.none,
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
                  decoration: TextDecoration.none,
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
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _isFormValid
                    ? () async {
                        await _saveFormToPrefs();
                        final contactInfo = OrderContactInfo(
                          name: _nameController.text.trim(),
                          email: _emailController.text.trim(),
                          telegram: _telegramController.text.trim(),
                          phone: _phoneController.text.trim(),
                          viber: _viberController.text.trim(),
                          instagram: _instagramController.text.trim(),
                          whatsapp: _whatsappController.text.trim(),
                        );
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          widget.onSubmit(contactInfo);
                        }
                      }
                    : null,
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _isFormValid
                        ? Colors.black
                        : const Color(0xFFCCCCCC),
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
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
                  '${product.title} (${product.size})',
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
