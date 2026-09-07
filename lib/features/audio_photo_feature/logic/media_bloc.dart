import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sabel/features/audio_photo_feature/models/media_item_model.dart';
import 'package:flutter_sabel/features/audio_photo_feature/repositories/media_repository.dart';

// EVENTS
abstract class MediaEvent {}

class LoadMediaEvent extends MediaEvent {}

class AddMediaEvent extends MediaEvent {
  final File file;
  final MediaType type;
  AddMediaEvent(this.file, this.type);
}

// STATES
abstract class MediaState {}

class MediaInitialState extends MediaState {}

class MediaLoadingState extends MediaState {}

class MediaLoadedState extends MediaState {
  final List<MediaItemModel> items;
  MediaLoadedState(this.items);
}

// BLOC
class MediaBloc extends Bloc<MediaEvent, MediaState> {
  final MediaRepository repository;

  MediaBloc(this.repository) : super(MediaInitialState()) {
    on<LoadMediaEvent>((event, emit) async {
      emit(MediaLoadingState());
      final items = await repository.getMediaFiles();
      emit(MediaLoadedState(items));
    });

    on<AddMediaEvent>((event, emit) async {
      await repository.saveMedia(tempFile: event.file, type: event.type);
      add(LoadMediaEvent());
    });
  }
}
