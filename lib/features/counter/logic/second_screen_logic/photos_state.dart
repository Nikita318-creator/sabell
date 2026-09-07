import 'package:flutter_sabel/features/counter/data/models/photo_model.dart';

sealed class PhotosState {
  const PhotosState();
}

/// 1. Идет загрузка
final class PhotosLoading extends PhotosState {
  const PhotosLoading();
}

/// 2. Успешно загрузили список
final class PhotosSuccess extends PhotosState {
  final List<PhotoModel> photos;
  const PhotosSuccess(this.photos);
}

/// 3. Произошла ошибка сети
final class PhotosFailure extends PhotosState {
  final String errorMessage;
  const PhotosFailure(this.errorMessage);
}
