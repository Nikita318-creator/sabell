import 'package:flutter/foundation.dart';
import 'package:flutter_sabel/features/catalog/data/models/catalog_model.dart';

@immutable
abstract class CatalogState {
  const CatalogState();
}

class CatalogInitialState extends CatalogState {
  const CatalogInitialState();
}

class CatalogLoadingState extends CatalogState {
  const CatalogLoadingState();
}

class CatalogLoadedState extends CatalogState {
  final List<RemoteProducts> products; // 👈 Заменили тип на RemoteProduct

  const CatalogLoadedState({required this.products});
}

class CatalogErrorState extends CatalogState {
  final String errorMessage;

  const CatalogErrorState({required this.errorMessage});
}
