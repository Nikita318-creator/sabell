import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/catalog_model.dart';

abstract class ServerProductApiClient {
  Future<List<RemoteProducts>> fetchProducts();
  Future<void> checkoutProducts(List<String> productIds);
  Future<void> seedMockProducts(List<Map<String, dynamic>> mockList);
}

class ServerProductApiClientImpl implements ServerProductApiClient {
  final FirebaseFirestore firestore;

  ServerProductApiClientImpl({required this.firestore});

  // test111 заливаем на бек товары!
  ///////// ======== /////////

  // В ServerProductApiClientImpl:
  Future<void> seedMockProducts(List<Map<String, dynamic>> mockList) async {
    final batch = firestore.batch();
    final collection = firestore.collection('products');

    for (final data in mockList) {
      // Генерим ссылку на новый документ с авто-ID
      final docRef = collection.doc();
      batch.set(docRef, data);
    }

    // Отправляем все 10 документов одним атомарным запросом
    await batch.commit();
  }

  ///////// ======== /////////

  @override
  Future<List<RemoteProducts>> fetchProducts() async {
    final snapshot = await firestore
        .collection('products')
        .where('count', isGreaterThan: 0)
        .get(const GetOptions(source: Source.server));

    return snapshot.docs
        .map((doc) => RemoteProducts.fromJson(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> checkoutProducts(List<String> productIds) async {
    // Используем транзакцию для атомарного обновления и избежания race conditions
    await firestore.runTransaction((transaction) async {
      final docsToUpdate = <DocumentReference, int>{};

      for (final id in productIds) {
        final docRef = firestore.collection('products').doc(id);
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception('Товар с ID $id не найден');
        }

        final currentCount = (snapshot.data()?['count'] as num?)?.toInt() ?? 0;
        final title = snapshot.data()?['title'] as String? ?? 'Товар';

        // Проверка коллизии: кто-то опередил и забрал последний товар
        if (currentCount < 1) {
          throw Exception('К сожалению, "$title" уже раскупили!');
        }

        docsToUpdate[docRef] = currentCount - 1;
      }

      // Все проверки пройдены — атомарно записываем изменения
      docsToUpdate.forEach((docRef, newCount) {
        transaction.update(docRef, {'count': newCount});
      });
    });
  }
}
