import 'package:flutter_sabel/features/catalog/data/models/catalog_model.dart';
import 'package:flutter_sabel/features/catalog/data/datasources/server_product_api_client.dart';

abstract class ServerProductRepository {
  Future<List<RemoteProducts>> getProducts({bool forceRefresh = false});
  Future<void> checkout(List<String> productIds); // 👈 Добавляем
  void clearCache();
}

class ServerProductRepositoryImpl implements ServerProductRepository {
  final ServerProductApiClient apiClient;
  List<RemoteProducts>? _cachedProducts;

  ServerProductRepositoryImpl({required this.apiClient});

  @override
  Future<List<RemoteProducts>> getProducts({bool forceRefresh = false}) async {
    if (_cachedProducts != null && !forceRefresh) {
      return _cachedProducts!;
    }
    final products = await apiClient.fetchProducts();
    _cachedProducts = products;
    return products;
  }

  @override
  Future<void> checkout(List<String> productIds) async {
    await apiClient.checkoutProducts(productIds);
    clearCache(); // Очищаем кэш, так как количество товаров изменилось
  }

  @override
  void clearCache() {
    _cachedProducts = null;
  }
}
