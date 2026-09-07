import 'package:flutter/material.dart';

// --- РОДИТЕЛЬСКИЙ ВИДЖЕТ ---
class ParentScreen extends StatefulWidget {
  const ParentScreen({super.key});

  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  int _counter = 0;
  bool _isDark = false;

  @override
  Widget build(BuildContext context) {
    // Оборачиваем в Theme (InheritedWidget)
    return MaterialApp(
      theme: _isDark ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Меняем параметр СВЕРХУ (проп счетчика)
            UserCard(title: "Пользователь №$_counter"),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => setState(() => _counter++),
              child: const Text("Изменить проп от родителя"),
            ),
            ElevatedButton(
              onPressed: () => setState(() => _isDark = !_isDark),
              child: const Text("Сменить тему (InheritedWidget)"),
            ),
          ],
        ),
      ),
    );
  }
}

// --- ДОЧЕРНИЙ ВИДЖЕТ (Здесь вся магия ЖЦ) ---
class UserCard extends StatefulWidget {
  final String title; // Параметр СВЕРХУ

  const UserCard({super.key, required this.title});

  @override
  State<UserCard> createState() {
    print('1. createState() -> Актера позвали на роль');
    return _UserCardState();
  }
}

class _UserCardState extends State<UserCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    print('2. initState() -> Актер вышел на сцену (1 раз за жизнь!)');
    _controller = TextEditingController(text: "Начальное значение");
    // ПРИМЕЧАНИЕ: Написать Theme.of(context) ТУТ НЕЛЬЗЯ - дерево еще не собрано!
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print(
      '3. didChangeDependencies() -> Изменился InheritedWidget (Тема/Provider)!',
    );
    // ЗДЕСЬ УЖЕ МОЖНО:
    final isDark = Theme.of(context).brightness == Brightness.dark;
    print('   Текущая тема темная? $isDark');
  }

  @override
  void didUpdateWidget(covariant UserCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('4. didUpdateWidget() -> Родитель прислал НОВЫЙ Чертеж (Widget)!');
    print('   Старый заголовок: ${oldWidget.title}');
    print('   Новый заголовок: ${widget.title}');
  }

  @override
  Widget build(BuildContext context) {
    print('5. build() -> Рисуем кадр');
    // BuildContext context - это и есть сам ELEMENT!
    return Container(
      padding: const EdgeInsets.all(16),
      child: Text(widget.title),
    );
  }

  @override
  void deactivate() {
    print('6. deactivate() -> Актера временно убрали со сцены');
    super.deactivate();
  }

  @override
  void dispose() {
    print('7. dispose() -> Актер уволен, очищаем гримерку!');
    _controller.dispose(); // Убираем контроллер, чтобы не было утечки памяти
    super.dispose();
  }
}
