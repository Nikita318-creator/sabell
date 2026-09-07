import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_sabel/features/settings/data/models/remote_config.dart';

abstract class ConfigApiClient {
  Future<RemoteConfig> fetchConfig();
}

class ConfigApiClientImpl implements ConfigApiClient {
  final Dio dio;
  ConfigApiClientImpl(this.dio);

  @override
  Future<RemoteConfig> fetchConfig() async {
    // 1. Генерируем уникальный timestamp под каждый запрос
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final url =
        'https://raw.githubusercontent.com/Nikita318-creator/sabell_server/main/custom_server.json?t=$timestamp';

    // 2. Явно передаем заголовки запрета кэширования
    final response = await dio.get(
      url,
      options: Options(
        headers: {
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0',
        },
      ),
    );

    print(response);
    print(response.data);
    final rawData = response.data;
    final Map<String, dynamic> jsonMap = rawData is String
        ? jsonDecode(rawData) as Map<String, dynamic>
        : rawData as Map<String, dynamic>;

    return RemoteConfig.fromJson(jsonMap);
  }
}
