import 'package:flutter/foundation.dart';

@immutable
class CatalogDetailsState {
  final int selectedImageIndex;

  const CatalogDetailsState({this.selectedImageIndex = 0});

  CatalogDetailsState copyWith({int? selectedImageIndex}) {
    return CatalogDetailsState(
      selectedImageIndex: selectedImageIndex ?? this.selectedImageIndex,
    );
  }
}
