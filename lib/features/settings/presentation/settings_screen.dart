import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_review/in_app_review.dart';

import 'package:flutter_sabel/core/events/app_events.dart';
import 'package:flutter_sabel/features/orders/data/orders_storage.dart';
import 'package:flutter_sabel/features/settings/presentation/settings_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsBloc _settingsBloc;
  StreamSubscription<AppEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _settingsBloc = SettingsBloc()..add(const LoadSettingsEvent());

    // Слушаем глобальную шину событий
    _eventSubscription = AppEventBus().stream.listen((event) {
      if (event is OrdersUpdatedEvent) {
        if (mounted) {
          _settingsBloc.add(const LoadSettingsEvent());
        }
      }
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _settingsBloc.close();
    super.dispose();
  }

  Future<void> _requestReview() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    }
  }

  /// Ручной Pull-to-Refresh
  Future<void> _onRefresh() async {
    // Запоминаем текущий state или создаем Completer
    final completer = Completer<void>();

    late final StreamSubscription sub;
    sub = _settingsBloc.stream.listen((state) {
      if (state is SettingsLoadedState && !completer.isCompleted) {
        completer.complete();
        sub.cancel();
      }
    });

    _settingsBloc.add(const LoadSettingsEvent());

    // На случай если state заэмитился сразу же или застрял
    await completer.future.timeout(
      const Duration(seconds: 2),
      onTimeout: () => sub.cancel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _settingsBloc,
      child: Material(
        color: Colors.white,
        child: CupertinoPageScaffold(
          backgroundColor: Colors.white,
          navigationBar: const CupertinoNavigationBar(
            backgroundColor: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFE5E5E5), width: 0.5),
            ),
            middle: Text(
              'ПРОФИЛЬ',
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
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                CupertinoSliverRefreshControl(onRefresh: _onRefresh),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      const Icon(
                        CupertinoIcons.person_crop_circle_fill,
                        size: 80,
                        color: Color(0xFFCCCCCC),
                      ),
                      const SizedBox(height: 12),
                      BlocBuilder<SettingsBloc, SettingsState>(
                        builder: (context, state) {
                          final userId = state is SettingsLoadedState
                              ? state.userId
                              : '------';
                          return Text(
                            'Ваш User ID: $userId',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              decoration: TextDecoration.none,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'ВАШИ ЗАКАЗЫ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: Colors.black,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      BlocBuilder<SettingsBloc, SettingsState>(
                        builder: (context, state) {
                          if (state is SettingsLoadedState &&
                              state.activeOrders.isNotEmpty) {
                            return _OrdersListWidget(
                              orders: state.activeOrders,
                            );
                          }
                          return const _EmptyOrdersWidget();
                        },
                      ),
                      const SizedBox(height: 32),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Color(0xFFE5E5E5),
                        ),
                      ),
                      _SettingsTile(
                        title: 'ОЦЕНИТЬ ПРИЛОЖЕНИЕ',
                        onTap: _requestReview,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Color(0xFFE5E5E5),
                        ),
                      ),
                      _SettingsTile(
                        title: 'ПОЛИТИКА КОНФИДЕНЦИАЛЬНОСТИ',
                        onTap: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (_) => const PrivacyPolicyScreen(),
                            ),
                          );
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Color(0xFFE5E5E5),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
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

class _EmptyOrdersWidget extends StatelessWidget {
  const _EmptyOrdersWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'У вас пока нет активных заказов',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              decoration: TextDecoration.none,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Тут вы можете отслеживать статус ваших активных заказов',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF666666),
              height: 1.3,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersListWidget extends StatelessWidget {
  final List<SavedOrder> orders;

  const _OrdersListWidget({required this.orders});

  @override
  Widget build(BuildContext context) {
    final allItems = orders.expand((order) => order.items).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E5E5), width: 0.5),
            ),
            child: const Text(
              'Тут вы можете отслеживать статус ваших заказов!',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
                decoration: TextDecoration.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = allItems[index];
              return _OrderItemCard(item: item);
            },
          ),
        ],
      ),
    );
  }
}

class _OrderItemCard extends StatelessWidget {
  final OrderItem item;

  const _OrderItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              item.imageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 56,
                  height: 56,
                  color: const Color(0xFFEEEEEE),
                  child: const Icon(
                    CupertinoIcons.photo,
                    size: 24,
                    color: Color(0xFFAAAAAA),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 8),
                // ЖЁЛТЫЙ СТАТУС
                Row(
                  children: const [
                    Icon(
                      CupertinoIcons.time_solid,
                      size: 14,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'ОФОРМЛЕН',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: Colors.orange,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // ПОЯСНЕНИЕ ПОД СТАТУСОМ
                const Text(
                  'Менеджер свяжется с вами для подтверждения',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF666666),
                    height: 1.2,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String? value;
  final VoidCallback onTap;

  const _SettingsTile({required this.title, this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
            Row(
              children: [
                if (value != null) ...[
                  Text(
                    value!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                const Icon(
                  CupertinoIcons.chevron_right,
                  size: 14,
                  color: Color(0xFF888888),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
            'PRIVACY POLICY',
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'ПОЛИТИКА КОНФИДЕНЦИАЛЬНОСТИ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Colors.black,
                    decoration: TextDecoration.none,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Дата последнего обновления: 27 сентября 2026 г.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8E8E93),
                    decoration: TextDecoration.none,
                  ),
                ),
                SizedBox(height: 20),
                _PolicySection(
                  title: '1. Общие положения',
                  text:
                      'Настоящая Политика определяет порядок обработки и защиты данных пользователей приложения Sabell.\n\n'
                      'Наше приложение является витриной каталога товаров. Приложение НЕ совершает безналичные платежи и не принимает карты внутри интерфейса. Оплата производится исключительно при получении товара курьеру или менеджеру.',
                ),
                _PolicySection(
                  title: '2. Собираемая информация',
                  text:
                      'При оформлении заказа мы собираем минимальный набор данных для связи:\n'
                      '• Ваше имя (для обращения);\n'
                      '• Контактные данные (email, Telegram-юзернейм, номер телефона);\n'
                      '• Состав и параметры заказа.\n\n'
                      'Данные о корзине и избранном хранятся локально на вашем устройстве.',
                ),
                _PolicySection(
                  title: '3. Цели обработки данных',
                  text:
                      'Данные используются исключительно для передачи информации по заказу нашему менеджеру, чтобы он мог связаться с вами, подтвердить детали заказа, наличие и согласовать удобный способ доставки и оплаты.',
                ),
                _PolicySection(
                  title: '4. Передача и защита данных',
                  text:
                      'Мы не передаем ваши личные данные третьим лицам для рекламных или коммерческих рассылок. Передача происходит только внутри сервиса менеджеру, выполняющему обработку вашей заявки.',
                ),
                _PolicySection(
                  title: '5. Права пользователя',
                  text:
                      'Вы имеете право запросить удаление вашей истории заказов и персональных данных из базы сервиса в любой момент, обратившись в службу поддержки.',
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String text;

  const _PolicySection({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w400,
              color: Color(0xFF444444),
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
