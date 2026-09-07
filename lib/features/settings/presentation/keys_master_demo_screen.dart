import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_sabel/features/settings/logic/bloc/keys_demo_bloc.dart';
import 'package:flutter_sabel/features/settings/logic/bloc/keys_demo_event.dart';
import 'package:flutter_sabel/features/settings/logic/bloc/keys_demo_state.dart';

class KeysMasterDemoScreen extends StatefulWidget {
  const KeysMasterDemoScreen({super.key});

  @override
  State<KeysMasterDemoScreen> createState() => _KeysMasterDemoScreenState();
}

class _KeysMasterDemoScreenState extends State<KeysMasterDemoScreen> {
  // GlobalKeys создаются на уровне State
  GlobalKey<FormState>? _formKey = GlobalKey<FormState>();
  GlobalKey? _cardKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => KeysDemoBloc(),
      child: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('ALL KEYS MASTER DEMO'),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: SafeArea(
            child: BlocBuilder<KeysDemoBloc, KeysDemoState>(
              builder: (context, state) {
                // Если тумблер выключен, передаем null вместо GlobalKey
                final activeFormKey = state.useGlobalKey ? _formKey : null;
                final activeCardKey = state.useGlobalKey ? _cardKey : null;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Кнопка принудительного rebuild экрана
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[100],
                      ),
                      icon: const Icon(Icons.refresh, color: Colors.purple),
                      label: Text(
                        'Rebuild экрана из BLoC (Counter: ${state.blocCounter})',
                      ),
                      onPressed: () {
                        context.read<KeysDemoBloc>().add(
                          IncrementBlocCounterEvent(),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // ==========================================
                    // 1. VALUEKEY
                    // ==========================================
                    _buildHeader(
                      title: '1. VALUEKEY',
                      description: 'Привязать ввод в TextField к ID элемента.',
                      useKey: state.useValueKey,
                      onToggle: () => context.read<KeysDemoBloc>().add(
                        const ToggleKeyUsageEvent('valueKey'),
                      ),
                    ),
                    const Text(
                      '💡 Инструкция: Напиши заметку в поле "Беларусь" и нажми Сдвинуть. '
                      'БЕЗ ValueKey текст останется на 1-й позиции (улетит к России). С ValueKey — уйдет вместе с Беларусью.',
                      style: TextStyle(fontSize: 11, color: Colors.orange),
                    ),
                    const SizedBox(height: 8),

                    Column(
                      children: state.countries.map((item) {
                        return Container(
                          // ТУМБЛЕР КЛЮЧА
                          key: state.useValueKey
                              ? ValueKey<String>(item.id)
                              : null,
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(8),
                          color: item.color.withOpacity(0.2),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'ID: ${item.id} (${item.name})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Заметка для ${item.name}',
                                    isDense: true,
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    CupertinoButton.filled(
                      padding: EdgeInsets.zero,
                      child: const Text('Сдвинуть элементы (Swap List)'),
                      onPressed: () {
                        context.read<KeysDemoBloc>().add(SwapItemsEvent());
                      },
                    ),

                    _buildDivider(),

                    // ==========================================
                    // 2. OBJECTKEY
                    // ==========================================
                    _buildHeader(
                      title: '2. OBJECTKEY',
                      description:
                          'Ключ связывается с целым экземпляром класса CountryModel.',
                      useKey: state.useObjectKey,
                      onToggle: () => context.read<KeysDemoBloc>().add(
                        const ToggleKeyUsageEvent('objectKey'),
                      ),
                    ),
                    const Text(
                      '💡 Используем целый объект CountryModel в качестве ключа для первого элемента списка.',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),

                    Builder(
                      builder: (context) {
                        final firstCountry = state.countries.first;
                        return Container(
                          key: state.useObjectKey
                              ? ObjectKey(firstCountry)
                              : null,
                          padding: const EdgeInsets.all(12),
                          color: Colors.deepPurple[100],
                          child: Text(
                            'ObjectKey(firstCountry):\nПервая страна сейчас — ${firstCountry.name} (id: ${firstCountry.id})',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),

                    _buildDivider(),

                    // ==========================================
                    // 3. UNIQUEKEY
                    // ==========================================
                    _buildHeader(
                      title: '3. UNIQUEKEY',
                      description:
                          'Принудительный полный перезапуск элемента (initState).',
                      useKey: state.useUniqueKey,
                      onToggle: () => context.read<KeysDemoBloc>().add(
                        const ToggleKeyUsageEvent('uniqueKey'),
                      ),
                    ),
                    const Text(
                      '💡 Смотри на внутренний таймер/счетчик. Нажми "Сгенерировать новый UniqueKey". '
                      'С UniqueKey виджет уничтожится и заново запустит initState(). Без него — сохранится старый State.',
                      style: TextStyle(fontSize: 11, color: Colors.orange),
                    ),
                    const SizedBox(height: 8),

                    _StatefulInternalBox(
                      key: state.useUniqueKey ? state.uniqueKey : null,
                      keyHash: state.uniqueKey.hashCode.toString(),
                    ),

                    const SizedBox(height: 6),
                    CupertinoButton(
                      color: Colors.black,
                      child: const Text('Сгенерировать новый UniqueKey в BLoC'),
                      onPressed: () {
                        context.read<KeysDemoBloc>().add(
                          RegenerateUniqueKeyEvent(),
                        );
                      },
                    ),

                    _buildDivider(),

                    // ==========================================
                    // 4. PAGESTORAGEKEY
                    // ==========================================
                    _buildHeader(
                      title: '4. PAGESTORAGEKEY',
                      description:
                          'Сохранение скролла при пересборке (Rebuild).',
                      useKey: state.usePageStorageKey,
                      onToggle: () => context.read<KeysDemoBloc>().add(
                        const ToggleKeyUsageEvent('pageStorageKey'),
                      ),
                    ),
                    const Text(
                      '💡 Инструкция: Проскролль горизонтальный список вправо. '
                      'Затем нажми фиолетовую кнопку "Rebuild экрана из BLoC" в самом верху. '
                      'БЕЗ PageStorageKey скролл сбросится в ноль! С ключом — останется там, где ты его оставил.',
                      style: TextStyle(fontSize: 11, color: Colors.orange),
                    ),
                    const SizedBox(height: 8),

                    SizedBox(
                      height: 70,
                      child: ListView.builder(
                        key: state.usePageStorageKey
                            ? const PageStorageKey<String>('demo_horiz_list')
                            : null,
                        scrollDirection: Axis.horizontal,
                        itemCount: 20,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 90,
                            margin: const EdgeInsets.only(right: 8),
                            color: Colors.teal[(index % 8 + 2) * 100],
                            alignment: Alignment.center,
                            child: Text(
                              'Item $index',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    _buildDivider(),

                    // ==========================================
                    // 5. GLOBALKEY
                    // ==========================================
                    _buildHeader(
                      title: '5. GLOBALKEY',
                      description:
                          'Доступ к State формы и замер RenderBox в произвольный момент.',
                      useKey: state.useGlobalKey,
                      onToggle: () => context.read<KeysDemoBloc>().add(
                        const ToggleKeyUsageEvent('globalKey'),
                      ),
                    ),
                    const Text(
                      '💡 ЧТО БЕЗ НЕГО НЕЛЬЗЯ СДЕЛАТЬ: Валидировать форму из внешнего обработчика кнопки или узнать размер блока через RenderBox без пересборки.',
                      style: TextStyle(fontSize: 11, color: Colors.redAccent),
                    ),
                    const SizedBox(height: 8),

                    Form(
                      key: activeFormKey,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Введите данные',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => (val == null || val.isEmpty)
                            ? 'Поле не должно быть пустым!'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 6),

                    CupertinoButton(
                      color: Colors.grey[800],
                      onPressed: () {
                        if (activeFormKey == null) {
                          _showAlert(
                            context,
                            'Ошибка (Ключ выключен)',
                            'БЕЗ GlobalKey мы не можем вызвать _formKey.currentState!.validate() извне!',
                          );
                          return;
                        }

                        if (activeFormKey.currentState!.validate()) {
                          _showAlert(
                            context,
                            'Успех',
                            'Форма валидирована через GlobalKey<FormState>!',
                          );
                        }
                      },
                      child: const Text('Валидировать Форму извне'),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      key: activeCardKey,
                      padding: const EdgeInsets.all(12),
                      color: Colors.amber[200],
                      child: const Text(
                        'Размер этого контейнера меняется в зависимости от текста.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 6),

                    CupertinoButton(
                      color: Colors.amber[900],
                      onPressed: () {
                        if (activeCardKey == null) {
                          _showAlert(
                            context,
                            'Ошибка (Ключ выключен)',
                            'БЕЗ GlobalKey мы не можем вызвать findRenderObject() и узнать размеры элемента из контекста!',
                          );
                          return;
                        }

                        final renderBox =
                            activeCardKey.currentContext?.findRenderObject()
                                as RenderBox?;
                        if (renderBox != null) {
                          final size = renderBox.size;
                          _showAlert(
                            context,
                            'Размеры блока из RenderBox',
                            'Ширина: ${size.width.toStringAsFixed(1)}px\nВысота: ${size.height.toStringAsFixed(1)}px',
                          );
                        }
                      },
                      child: const Text('Снять геометрию RenderBox'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({
    required String title,
    required String description,
    required bool useKey,
    required VoidCallback onToggle,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Column(
          children: [
            Text(
              useKey ? 'KEY ON' : 'KEY OFF',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: useKey ? Colors.green : Colors.red,
              ),
            ),
            CupertinoSwitch(value: useKey, onChanged: (_) => onToggle()),
          ],
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const Column(
      children: [SizedBox(height: 12), Divider(), SizedBox(height: 8)],
    );
  }

  void _showAlert(BuildContext context, String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(dialogContext),
          ),
        ],
      ),
    );
  }
}

/// Вспомогательный класс для UniqueKey: считывает момент своей инициализации
class _StatefulInternalBox extends StatefulWidget {
  final String keyHash;
  const _StatefulInternalBox({super.key, required this.keyHash});

  @override
  State<_StatefulInternalBox> createState() => _StatefulInternalBoxState();
}

class _StatefulInternalBoxState extends State<_StatefulInternalBox> {
  late String _createdTime;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _createdTime = '${now.minute}:${now.second}:${now.millisecond}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.orange[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'UniqueKey Hash: ${widget.keyHash}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            'State создан (initState) в: $_createdTime',
            style: const TextStyle(color: Colors.deepOrange),
          ),
        ],
      ),
    );
  }
}
