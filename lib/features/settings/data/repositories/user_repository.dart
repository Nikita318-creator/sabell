import 'package:flutter_sabel/features/settings/data/datasources/local_user_data_source.dart';
import 'package:flutter_sabel/features/settings/data/datasources/config_api_client.dart';
import 'package:flutter_sabel/features/settings/data/models/test_user_model.dart';
import 'package:flutter_sabel/features/settings/data/datasources/user_api_client.dart';

abstract class UserRepository {
  Future<List<User>> getUsers();
}

class UserRepositoryImpl implements UserRepository {
  final UserApiClient apiClient;
  final ConfigApiClient configClient;
  final LocalUserDataSource localDataSource;

  UserRepositoryImpl({
    required this.apiClient,
    required this.configClient,
    required this.localDataSource,
  });

  @override
  Future<List<User>> getUsers() async {
    // 1. Тянем конфиг с GitHub
    final config = await configClient.fetchConfig();

    // 2. Если стоял флаг сброса — очищаем кэш/БД
    if (config.needResetData) {
      await localDataSource.clearCache();
    }

    // 3. Проверяем кэш
    final cachedUsers = await localDataSource.getUsersFromCache();
    if (cachedUsers.isNotEmpty) {
      print("--- ДАННЫЕ ВЗЯТЫ ИЗ КЭША / ЛОКАЛЬНОЙ БД ---");
      return cachedUsers;
    }

    // 4. Если кэша нет — определяем источник (Сеть или Мок)
    List<User> resultUsers = [];

    if (config.needLoadFromRemote) {
      print("--- ДАННЫЕ ТЯНЕМ С СЕТИ (jsonplaceholder) ---");
      final rawData = await apiClient.fetchUsers();
      resultUsers = rawData
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      print("--- ДАННЫЕ ВЗЯТЫ ИЗ ЛОКАЛЬНОГО МОКА ---");
      resultUsers = _getMockUsers();
    }

    // 5. Кэшируем полученные данные в БД
    await localDataSource.saveUsersToCache(resultUsers);

    return resultUsers;
  }

  // Генератор локального мока
  List<User> _getMockUsers() {
    return const [
      User(id: 999, name: "Локальный Мок (Никита)"),
      User(id: 888, name: "Локальный Мок (Вика)"),
      User(id: 777, name: "Локальный Мок (Flutter Dev)"),
      User(id: 9, name: "Локальный Мок (Никита)"),
      User(id: 8, name: "Локальный Мок (Вика)"),
      User(id: 7, name: "Локальный Мок (Flutter Dev)"),
      User(id: 99, name: "Локальный Мок (Никита)"),
      User(id: 88, name: "Локальный Мок (Вика)"),
      User(id: 77, name: "Локальный Мок (Flutter Dev)"),
    ];
  }
}
