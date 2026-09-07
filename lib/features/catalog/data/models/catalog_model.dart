class RemoteProducts {
  final String id;
  final String title;
  final double price;
  final String imageUrl;
  final List<String> additionalImages; // 👈 Новое поле!
  final String description;
  final List<String> tags;
  final bool isShowOnHomeScreen;
  final int count;

  const RemoteProducts({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    this.additionalImages = const [],
    required this.description,
    required this.tags,
    this.isShowOnHomeScreen = false,
    required this.count,
  });

  /// Удобный геттер для получения всех картинок товара (главное фото + дополнительные)
  List<String> get allImages {
    final list = <String>[];
    if (imageUrl.isNotEmpty) list.add(imageUrl);
    list.addAll(additionalImages);
    return list.isNotEmpty ? list : [''];
  }

  factory RemoteProducts.fromJson(Map<String, dynamic> json, String docId) {
    // Парсинг тегов
    List<String> parsedTags = [];
    if (json['tags'] is List) {
      parsedTags = (json['tags'] as List).map((e) => e.toString()).toList();
    } else if (json['tags'] is String) {
      final tagsStr = json['tags'] as String;
      parsedTags = tagsStr.isNotEmpty
          ? tagsStr.split(',').map((e) => e.trim()).toList()
          : [];
    }

    // Парсинг дополнительных картинок (поддержка строки через запятую и List)
    List<String> parsedAdditionalImages = [];
    final rawImages = json['additionalImages'] ?? json['addidtionalImages'];
    if (rawImages is List) {
      parsedAdditionalImages = rawImages
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (rawImages is String && rawImages.isNotEmpty) {
      parsedAdditionalImages = rawImages
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return RemoteProducts(
      id: docId,
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String? ?? '',
      additionalImages: parsedAdditionalImages,
      description:
          json['desc'] as String? ?? json['description'] as String? ?? '',
      tags: parsedTags,
      isShowOnHomeScreen: json['isShowOnHomeScreen'] as bool? ?? false,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

// class CatalogProductModel {
//   final String id;
//   final String title;
//   final double price;
//   final String imageUrl;
//   final String description;
//   final List<String> tags;
//   final bool isShowOnHomeScreen;

//   const CatalogProductModel({
//     required this.id,
//     required this.title,
//     required this.price,
//     required this.imageUrl,
//     required this.description,
//     required this.tags,
//     this.isShowOnHomeScreen = false,
//   });

//   static final List<CatalogProductModel> mockProducts = [
//     const CatalogProductModel(
//       id: '1',
//       title: 'Шелковая блуза',
//       price: 189.00,
//       imageUrl:
//           'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&q=80&w=800',
//       description:
//           'Легкая шелковая блуза свободного кроя. Идеально сочетается с брюками с завышенной талией или базовой юбкой.',
//       tags: ['блуза', 'блузка', 'шелк', 'шелковая', 'топ', 'рубашка'],
//       isShowOnHomeScreen: true,
//     ),
//     const CatalogProductModel(
//       id: '2',
//       title: 'Платье миди с разрезом',
//       price: 245.50,
//       imageUrl:
//           'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&q=80&w=800',
//       description:
//           'Элегантное платье миди глубокого оттенка. Подчеркивает силуэт, оснащено аккуратным разрезом по бедру.',
//       tags: ['платье', 'миди', 'вечернее', 'одежда'],
//       isShowOnHomeScreen: true,
//     ),
//     const CatalogProductModel(
//       id: '3',
//       title: 'Юбка плиссе',
//       price: 135.00,
//       imageUrl:
//           'https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?auto=format&fit=crop&q=80&w=800',
//       description:
//           'Трендовая юбка плиссе из качественного плотного материала. Пояс на эластичной резинке.',
//       tags: ['юбка', 'плиссе', 'миди', 'одежда'],
//       isShowOnHomeScreen: false,
//     ),
//     const CatalogProductModel(
//       id: '4',
//       title: 'Оверсайз жакет',
//       price: 320.00,
//       imageUrl:
//           'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&q=80&w=800',
//       description:
//           'Двубортный оверсайз жакет из костюмной ткани. Держит форму, дополнен подкладкой и пуговицами.',
//       tags: ['жакет', 'пиджак', 'оверсайз', 'костюм', 'верхняя одежда'],
//       isShowOnHomeScreen: true,
//     ),
//     const CatalogProductModel(
//       id: '5',
//       title: 'Кашемировый свитер',
//       price: 290.00,
//       imageUrl:
//           'https://images.unsplash.com/photo-1576995853123-5a10305d93c0?auto=format&fit=crop&q=80&w=800',
//       description:
//           'Мягчайший свитер из 100% кашемира. Оптимальная длина и расслабленный силуэт.',
//       tags: ['свитер', 'джемпер', 'кашемир', 'кофта', 'шерсть'],
//       isShowOnHomeScreen: false,
//     ),
//     const CatalogProductModel(
//       id: '6',
//       title: 'Кожаные брюки',
//       price: 210.00,
//       imageUrl:
//           'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&q=80&w=800',
//       description: 'Брюки из мягкой эко-кожи прямого кроя на высокой посадке.',
//       tags: ['брюки', 'штаны', 'кожа', 'кожаные'],
//       isShowOnHomeScreen: true,
//     ),
//     const CatalogProductModel(
//       id: '7',
//       title: 'Тренч классический',
//       price: 410.00,
//       imageUrl:
//           'https://images.unsplash.com/photo-1544441893-675973e31985?auto=format&fit=crop&q=80&w=800',
//       description:
//           'Двубортный тренчкот с водоотталкивающей пропиткой. Классический крой и пояс с пряжкой.',
//       tags: ['тренч', 'плащ', 'пальто', 'верхняя одежда'],
//       isShowOnHomeScreen: false,
//     ),
//     const CatalogProductModel(
//       id: '8',
//       title: 'Шерстяное пальто',
//       price: 520.00,
//       imageUrl:
//           'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?auto=format&fit=crop&q=80&w=800',
//       description:
//           'Пальто прямого силуэта из натуральной шерсти. Надежно защищает от холода и ветра.',
//       tags: ['пальто', 'шерсть', 'зима', 'осень', 'верхняя одежда'],
//       isShowOnHomeScreen: true,
//     ),
//     const CatalogProductModel(
//       id: '9',
//       title: 'Базовая хлопковая футболка',
//       price: 65.00,
//       imageUrl:
//           'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?auto=format&fit=crop&q=80&w=800',
//       description:
//           'Плотная футболка из 100% органического хлопка. Держит форму после множества стирок.',
//       tags: ['футболка', 'футболки', 'верх', 'база', 'хлопок', 'майка'],
//       isShowOnHomeScreen: false,
//     ),
//     const CatalogProductModel(
//       id: '10',
//       title: 'Джинсы прямой крой',
//       price: 175.00,
//       imageUrl:
//           'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?auto=format&fit=crop&q=80&w=800',
//       description:
//           'Классические джинсы с высокой посадкой из плотного денима без добавления стрейча.',
//       tags: ['джинсы', 'деним', 'брюки', 'штаны'],
//       isShowOnHomeScreen: true,
//     ),
//     const CatalogProductModel(
//       id: '11',
//       title: 'Льняной топ',
//       price: 95.00,
//       imageUrl:
//           'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?auto=format&fit=crop&q=80&w=800',
//       description:
//           'Воздушный топ из натурального льна на тонких бретелях. Идеальный выбор для жарких дней.',
//       tags: ['топ', 'майка', 'лен', 'льняной', 'лето'],
//       isShowOnHomeScreen: false,
//     ),
//     const CatalogProductModel(
//       id: '12',
//       title: 'Шопер из кожи',
//       price: 280.00,
//       imageUrl:
//           'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&q=80&w=800',
//       description:
//           'Вместительная сумка-шопер из натуральной гладкой кожи с внутренним карманом на молнии.',
//       tags: ['сумка', 'шопер', 'аксессуары', 'кожа'],
//       isShowOnHomeScreen: true,
//     ),
//     const CatalogProductModel(
//       id: '13',
//       title: 'Укороченный худи',
//       price: 145.00,
//       imageUrl:
//           'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?auto=format&fit=crop&q=80&w=800',
//       description:
//           'Худи из мягкого петельчатого футера с капюшоном. Свободная посадка и сниженная линия плеч.',
//       tags: ['худи', 'толстовка', 'кофта', 'оверсайз', 'спорт'],
//       isShowOnHomeScreen: false,
//     ),
//     const CatalogProductModel(
//       id: '14',
//       title: 'Шорты бермуды',
//       price: 115.00,
//       imageUrl:
//           'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?auto=format&fit=crop&q=80&w=800',
//       description:
//           'Костюмные шорты-бермуды со стрелками и высокой посадкой. Элегантная альтернатива юбке.',
//       tags: ['шорты', 'бермуды', 'костюм', 'лето'],
//       isShowOnHomeScreen: false,
//     ),
//     const CatalogProductModel(
//       id: '15',
//       title: 'Атласная комбинация',
//       price: 225.00,
//       imageUrl:
//           'https://images.unsplash.com/photo-1496747611176-843222e1e57c?auto=format&fit=crop&q=80&w=800',
//       description:
//           'Шелковистое платье-комбинация на регулируемых бретелях. Изящный V-образный вырез.',
//       tags: ['платье', 'комбинация', 'атлас', 'шелк', 'вечернее'],
//       isShowOnHomeScreen: false,
//     ),
//   ];
// }
