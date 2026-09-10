import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_review/in_app_review.dart';

import 'package:flutter_sabel/features/settings/logic/bloc/settings_bloc.dart';
import 'package:flutter_sabel/features/settings/logic/bloc/settings_event.dart';
import 'package:flutter_sabel/features/settings/logic/bloc/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _requestReview() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    }
  }

  void _showCountryPicker(
    BuildContext screenContext,
    String currentCountry,
    List<String> countries,
  ) {
    int selectedIndex = countries.contains(currentCountry)
        ? countries.indexOf(currentCountry)
        : 0;

    showCupertinoModalPopup(
      context: screenContext,
      builder: (modalContext) => Container(
        height: 280,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              color: const Color(0xFFF8F8F8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Выберите страну',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text(
                      'Готово',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () {
                      final chosenCountry = countries[selectedIndex];
                      screenContext.read<SettingsBloc>().add(
                        UpdateCountryEvent(chosenCountry),
                      );
                      Navigator.of(modalContext).pop();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                  initialItem: selectedIndex,
                ),
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  selectedIndex = index;
                },
                children: countries
                    .map(
                      (c) => Center(
                        child: Text(
                          c,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc()..add(const LoadSettingsEvent()),
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
              'НАСТРОЙКИ',
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
            child: Column(
              children: [
                const SizedBox(height: 12),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Color(0xFFE5E5E5),
                  ),
                ),

                // Оценить приложение
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

                // Политика конфиденциальности
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
              ],
            ),
          ),
        ),
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
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'ПОЛИТИКА КОНФИДЕНЦИАЛЬНОСТИ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: Colors.black,
                    decoration: TextDecoration.none,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Мы уважаем ваше право на конфиденциальность и стремимся обеспечивать защиту ваших персональных данных. Настоящая политика объясняет, как мы собираем, используем и защищаем информацию во время использования нашего приложения.\n\n'
                  '1. Сбор информации\n'
                  'Мы не собираем личные данные пользователей без их явного согласия. Все данные о покупках и избранном хранятся локально на вашем устройстве.\n\n'
                  '2. Использование данных\n'
                  'Аналитическая информация используется исключительно для улучшения производительности приложения и оптимизации пользовательского опыта.\n\n'
                  '3. Безопасность\n'
                  'Мы принимаем все необходимые организационные и технические меры для защиты ваших данных от несанкционированного доступа.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF444444),
                    decoration: TextDecoration.none,
                  ),
                ),
                SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
