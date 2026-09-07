import 'package:bloc/bloc.dart';
import 'package:flutter_sabel/features/settings/data/models/test_user_model.dart';
import 'package:flutter_sabel/features/settings/data/repositories/user_repository.dart';
import 'test_widget_event.dart';
import 'test_widget_state.dart';

class TestWidgetBloc extends Bloc<TestWidgetEvent, TestWidgetState> {
  final UserRepository userRepository;

  TestWidgetBloc({required this.userRepository})
    : super(const TestWidgetInitial()) {
    on<LoadUsersEvent>(_onLoadUsersEvent);
    on<TappedTestWidgetEvent>(_onTappedTestWidgetEvent);
    on<ChiledTappedTestWidgetEvent>(_onChiledTappedTestWidgetEvent);
  }

  Future<void> _onLoadUsersEvent(
    LoadUsersEvent event,
    Emitter<TestWidgetState> emit,
  ) async {
    emit(const TestWidgetLoadingUsers());
    try {
      final users = await userRepository.getUsers();
      emit(TestWidgetSuccess(users));
    } catch (e) {
      emit(TestWidgetError(e.toString()));
    }
  }

  Future<void> _onTappedTestWidgetEvent(
    TappedTestWidgetEvent event,
    Emitter<TestWidgetState> emit,
  ) async {
    // Хэндлер для тапа по конкретному юзеру
  }

  void _onChiledTappedTestWidgetEvent(
    ChiledTappedTestWidgetEvent event,
    Emitter<TestWidgetState> emit,
  ) {
    emit(const TestWidgetInitial());
  }
}
