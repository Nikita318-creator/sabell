import 'package:flutter/foundation.dart';

@immutable
abstract class CatalogDetailsEvent {
  const CatalogDetailsEvent();
}

class CatalogDetailsImageChangedEvent extends CatalogDetailsEvent {
  final int index;

  const CatalogDetailsImageChangedEvent(this.index);
}
