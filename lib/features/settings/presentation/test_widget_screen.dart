import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sabel/core/di/injection_container.dart';
import 'package:flutter_sabel/features/settings/data/repositories/user_repository.dart';
import 'package:flutter_sabel/features/settings/logic/bloc/bloc/test_widget_bloc.dart';
import 'package:flutter_sabel/features/settings/logic/bloc/bloc/test_widget_event.dart';
import 'package:flutter_sabel/features/settings/logic/bloc/bloc/test_widget_state.dart';

class TestWidgetScreen extends StatelessWidget {
  const TestWidgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TestWidgetBloc(userRepository: sl<UserRepository>())
            ..add(const LoadUsersEvent()),
      child: Scaffold(
        appBar: AppBar(title: const Text('BLoC Network Demo')),
        body: SafeArea(
          child: BlocBuilder<TestWidgetBloc, TestWidgetState>(
            builder: (context, state) {
              if (state is TestWidgetLoadingUsers) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is TestWidgetError) {
                return Center(child: Text('Ошибка: ${state.message}'));
              }

              if (state is TestWidgetSuccess) {
                final users = state.users;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      for (var user in users) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Левая часть: ID + Name из сети
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${user.id} + ${user.name}",
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    const Icon(Icons.person_outline),
                                  ],
                                ),
                              ),

                              // Правая часть: Кнопка с лоадером и вызовом шторки
                              BlocBuilder<TestWidgetBloc, TestWidgetState>(
                                builder: (context, state) {
                                  final bool isLoading =
                                      state is TestWidgetLoading &&
                                      state.loadingNumber == user.id;

                                  return ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(120, 45),
                                      padding: EdgeInsets.zero,
                                    ),
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            // 1. Отправляем ивент в BLoC
                                            context.read<TestWidgetBloc>().add(
                                              TappedTestWidgetEvent(user.id),
                                            );

                                            // 2. Открываем BottomSheet
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor:
                                                  Colors.transparent,
                                              builder: (_) => BlocProvider.value(
                                                value: context
                                                    .read<TestWidgetBloc>(),
                                                child:
                                                    const _ChildBottomSheet(),
                                              ),
                                            );
                                          },
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Opacity(
                                          opacity: isLoading ? 0.0 : 1.0,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Icon(Icons.touch_app),
                                              SizedBox(width: 8),
                                              Text("тап_ми"),
                                            ],
                                          ),
                                        ),
                                        if (isLoading)
                                          const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 20),
                      ],
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

class _ChildBottomSheet extends StatelessWidget {
  const _ChildBottomSheet();

  @override
  Widget build(BuildContext context) {
    // Используем DraggableScrollableSheet для плавного свайпа и 9/10 высоты
    return DraggableScrollableSheet(
      initialChildSize: 0.9, // 90% высоты экрана при открытии
      minChildSize: 0.3, // Минимальный размер при свайпе вниз
      maxChildSize: 0.9, // Максимальный размер (9/10)
      snap: true, // Привязка к краям при свайпе
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  // Полоска-индикатор для свайпа (UI-гайдлайн iOS/Android)
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Заголовок модалки
                  const Text(
                    "Лента новостей",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),

                  // Список из 50 моковых новостей
                  Expanded(
                    child: ListView.builder(
                      controller:
                          scrollController, // Обязательно привязываем controller!
                      itemCount: 50,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemBuilder: (context, index) {
                        final newsId = index + 1;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Заглушка под картинку
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent.withValues(
                                      alpha: 0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.newspaper,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Текст новости
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Новость №$newsId: Важное событие в IT",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Описание новости под номером $newsId. Здесь находится краткое содержание статьи для демонстрации работы ListView.builder.",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              // Кнопка крестика в левом верхнем углу
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Закрыть',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
