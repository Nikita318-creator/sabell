import 'package:flutter/foundation.dart';

@immutable
abstract class CatalogEvent {
  const CatalogEvent();
}

class LoadCatalogDataEvent extends CatalogEvent {
  const LoadCatalogDataEvent();
}

class CatalogPullToRefreshEvent extends CatalogEvent {
  const CatalogPullToRefreshEvent();
}

class SelectGalleryImageEvent extends CatalogEvent {
  final int index;
  const SelectGalleryImageEvent(this.index);
}

class CatalogAppResumedEvent extends CatalogEvent {
  const CatalogAppResumedEvent();

  @override
  List<Object?> get props => [];
}
