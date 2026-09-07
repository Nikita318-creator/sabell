import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sabel/features/counter/data/models/photo_model.dart';
import 'photos_event.dart';
import 'photos_state.dart';

class PhotosBloc extends Bloc<PhotosEvent, PhotosState> {
  final Dio _dio = Dio();

  PhotosBloc() : super(const PhotosLoading()) {
    on<PhotosFetchRequested>(_onFetchRequested);
  }

  Future<void> _onFetchRequested(
    PhotosFetchRequested event,
    Emitter<PhotosState> emit,
  ) async {
    emit(const PhotosLoading());

    try {
      final response = await _dio.get(
        'https://jsonplaceholder.typicode.com/photos',
      );

      final list = response.data as List<dynamic>;

      // Маппим JSON и сразу подменяем картинки на твои с GitHub!
      final photos = list.take(30).map((item) {
        final json = item as Map<String, dynamic>;
        final id = json['id'] as int;

        return PhotoModel(
          id: id,
          title: json['title'] as String,
          // Берем ID и подставляем в URL с GitHub: test1.jpg, test2.jpg...
          url:
              'https://raw.githubusercontent.com/uvarovn771-blip/GF_photos/main/test$id.jpg',
        );
      }).toList();

      emit(PhotosSuccess(photos));
    } catch (e) {
      emit(PhotosFailure('Ошибка загрузки данных: $e'));
    }
  }
}
