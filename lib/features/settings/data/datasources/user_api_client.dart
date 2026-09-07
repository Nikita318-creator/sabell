import 'package:dio/dio.dart';

abstract class UserApiClient {
  Future<List<dynamic>> fetchUsers();
}

class UserApiClientImpl implements UserApiClient {
  final Dio dio;

  UserApiClientImpl(this.dio);

  @override
  Future<List<dynamic>> fetchUsers() async {
    final response = await dio.get(
      'https://jsonplaceholder.typicode.com/users',
    );
    return response.data as List<dynamic>;
  }
}
