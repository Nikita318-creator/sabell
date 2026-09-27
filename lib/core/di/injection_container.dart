import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_sabel/features/catalog/data/repositories/server_product_repository.dart';
import 'package:flutter_sabel/features/catalog/data/datasources/server_product_api_client.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> initDependencies() async {
  // External
  sl.registerLazySingleton<Dio>(() => Dio());

  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<ServerProductApiClient>(
    () => ServerProductApiClientImpl(firestore: sl<FirebaseFirestore>()),
  );

  sl.registerLazySingleton<ServerProductRepository>(
    () => ServerProductRepositoryImpl(apiClient: sl<ServerProductApiClient>()),
  );
}
