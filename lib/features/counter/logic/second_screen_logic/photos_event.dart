sealed class PhotosEvent {
  const PhotosEvent();
}

/// Событие: пользователь зашел на экран / нажал "Обновить"
final class PhotosFetchRequested extends PhotosEvent {
  const PhotosFetchRequested();
}