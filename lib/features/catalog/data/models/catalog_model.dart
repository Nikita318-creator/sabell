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
  final String articul;
  final String size;

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
    required this.articul,
    required this.size,
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
      articul: json['articul'] as String? ?? '',
      size: json['size'] as String? ?? '',
    );
  }
}
