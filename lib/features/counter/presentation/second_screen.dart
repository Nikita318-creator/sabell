import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/photo_model.dart';
import '../logic/second_screen_logic/photos_bloc.dart';
import '../logic/second_screen_logic/photos_event.dart';
import '../logic/second_screen_logic/photos_state.dart';

class SecondScreen extends StatelessWidget {
  final int counterValue;

  const SecondScreen({super.key, required this.counterValue});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PhotosBloc()..add(const PhotosFetchRequested()),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Taps Count: $counterValue'),
        ),
        body: const _SecondScreenBody(),
      ),
    );
  }
}

/// 1. Тело экрана (обработка состояний BLoC)
class _SecondScreenBody extends StatelessWidget {
  const _SecondScreenBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PhotosBloc, PhotosState>(
      builder: (context, state) {
        return switch (state) {
          PhotosLoading() => const Center(child: CircularProgressIndicator()),
          PhotosFailure(:final errorMessage) => _ErrorView(
            message: errorMessage,
          ),
          PhotosSuccess(:final photos) => _PhotosListView(photos: photos),
        };
      },
    );
  }
}

/// 2. Виджет таблицы
class _PhotosListView extends StatelessWidget {
  final List<PhotoModel> photos;

  const _PhotosListView({required this.photos});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return _PhotoTile(photo: photos[index]);
      },
    );
  }
}

/// 3. ЕДИНЫЙ виджет ячейки (картинка + текст целиком)
class _PhotoTile extends StatelessWidget {
  final PhotoModel photo;

  const _PhotoTile({required this.photo});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Картинка с асинхронной загрузкой и плейсхолдером прямо внутри ячейки
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                photo.url,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.broken_image),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),

            // Текст ячейки
            Expanded(
              child: Text(
                photo.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 4. Вьюшка ошибки
class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                context.read<PhotosBloc>().add(const PhotosFetchRequested()),
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }
}
