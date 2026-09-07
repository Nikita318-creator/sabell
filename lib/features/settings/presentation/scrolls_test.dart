import 'package:flutter/material.dart';

class ScrollsTestScreen extends StatefulWidget {
  const ScrollsTestScreen({super.key});

  @override
  State<ScrollsTestScreen> createState() => _ScrollsTestScreenState();
}

class _ScrollsTestScreenState extends State<ScrollsTestScreen> {
  // Хранилище текстов для каждого TextField в каждой карточке по ее индексу
  final Map<int, TextEditingController> _textControllers = {};

  TextEditingController _getController(int index) {
    return _textControllers.putIfAbsent(
      index,
      () => TextEditingController(text: 'Заметка для товара #$index'),
    );
  }

  @override
  void dispose() {
    // Чистим за собой все контроллеры при закрытии экрана
    for (var controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Избегаем прыжка UI при открытии клавиатуры
      resizeToAvoidBottomInset: true,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Оставляем красивый SliverAppBar для контекста
          SliverAppBar(
            expandedHeight: 150.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Карточки с Каруселями'),
              background: Image.network(
                'https://picsum.photos/800/400',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.grey[800]),
              ),
            ),
          ),

          // 2. Вертикальный список (SliverList) карточек товаров
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Создаем карточку товара для каждого индекса
                return ProductCardItem(
                  index: index,
                  controller: _getController(index),
                );
              },
              // Пусть будет 20 товаров
              childCount: 20,
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.only(
              // Берем системный нижний отступ (Safe Area) + фиксированный запас под таббар
              bottom: MediaQuery.of(context).padding.bottom + 60,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Одиночная карточка товара (Vertical Item) с внутренней каруселью (Horizontal Scroll)
// ---------------------------------------------------------------------------
class ProductCardItem extends StatefulWidget {
  final int index;
  final TextEditingController controller;

  const ProductCardItem({
    super.key,
    required this.index,
    required this.controller,
  });

  @override
  State<ProductCardItem> createState() => _ProductCardItemState();
}

// Снова используем AutomaticKeepAliveClientMixin, чтобы при скролле
// не сбрасывался PageView (текущая фотография) и состояние TextField
class _ProductCardItemState extends State<ProductCardItem>
    with AutomaticKeepAliveClientMixin {
  @override
  // ОБЯЗАТЕЛЬНО возвращаем true для сохранения состояния ячейки в памяти
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // ВАЖНО: Вызов super.build(context) обязателен при использовании KeepAlive
    super.build(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // Чтобы скруглить края вложенного PageView
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 3. ВНУТРЕННЯЯ ГОРИЗОНТАЛЬНАЯ КАРУСЕЛЬ ФОТОГРАФИЙ (Horizontal Scroll)
          SizedBox(
            height: 180, // Ограничиваем высоту карусели
            child: PageView.builder(
              itemCount: 4, // Допустим, 4 фото у каждого товара
              controller: PageController(
                viewportFraction: 0.9,
              ), // Немного видны соседние фото
              itemBuilder: (context, photoIndex) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://picsum.photos/seed/${widget.index}_$photoIndex/400/300',
                      fit: BoxFit.cover,
                      // Обработка ошибок загрузки
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: Colors.grey[400]),
                      // Показываем лоадер, пока качаем
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                          ? child
                          : const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                );
              },
            ),
          ),

          // 4. Тексты и TextField
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Название Товара #${widget.index}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Описание товара: короткий мок текст для примера. Это описание может быть разной длины.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // 5. ВЛОЖЕННЫЙ TEXTFIELD ВНУТРИ КАРТОЧКИ
                TextField(
                  controller: widget.controller,
                  decoration: InputDecoration(
                    isDense: true, // Уменьшаем высоту TextField
                    border: const OutlineInputBorder(),
                    labelText: 'Ввод данных для #${widget.index}',
                    hintText: 'Заметка...',
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
