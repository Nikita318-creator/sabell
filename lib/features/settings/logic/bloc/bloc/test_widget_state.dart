import 'package:flutter/foundation.dart';
import 'package:flutter_sabel/features/settings/data/models/test_user_model.dart';

@immutable
abstract class TestWidgetState {
  const TestWidgetState();
}

class TestWidgetInitial extends TestWidgetState {
  const TestWidgetInitial();
}

class TestWidgetLoadingUsers extends TestWidgetState {
  const TestWidgetLoadingUsers();
}

class TestWidgetSuccess extends TestWidgetState {
  final List<User> users;

  const TestWidgetSuccess(this.users);
}

class TestWidgetError extends TestWidgetState {
  final String message;

  const TestWidgetError(this.message);
}

class TestWidgetLoading extends TestWidgetState {
  final int loadingNumber;

  const TestWidgetLoading(this.loadingNumber);
}
