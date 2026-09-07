import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_sabel/features/settings/data/datasources/user_api_client.dart';
import 'package:flutter_sabel/features/settings/data/datasources/config_api_client.dart';
import 'package:flutter_sabel/features/settings/data/datasources/local_user_data_source.dart';
import 'package:flutter_sabel/features/settings/data/repositories/user_repository.dart';
import 'package:flutter_sabel/features/catalog/data/repositories/server_product_repository.dart';
import 'package:flutter_sabel/features/catalog/data/datasources/server_product_api_client.dart';
import 'package:flutter_sabel/features/cart/logic/bloc/cart_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> initDependencies() async {
  // External
  sl.registerLazySingleton<Dio>(() => Dio());

  // Data Sources
  sl.registerLazySingleton<UserApiClient>(() => UserApiClientImpl(sl<Dio>()));
  sl.registerLazySingleton<ConfigApiClient>(
    () => ConfigApiClientImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<LocalUserDataSource>(
    () => LocalUserDataSourceImpl(),
  );
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<ServerProductApiClient>(
    () => ServerProductApiClientImpl(firestore: sl<FirebaseFirestore>()),
  );

  // Repositories
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      apiClient: sl<UserApiClient>(),
      configClient: sl<ConfigApiClient>(),
      localDataSource: sl<LocalUserDataSource>(),
    ),
  );

  sl.registerLazySingleton<ServerProductRepository>(
    () => ServerProductRepositoryImpl(apiClient: sl<ServerProductApiClient>()),
  );
}
