import 'package:flutter/foundation.dart';

@immutable
abstract class TestWidgetEvent {
  const TestWidgetEvent();
}

class LoadUsersEvent extends TestWidgetEvent {
  const LoadUsersEvent();
}

class TappedTestWidgetEvent extends TestWidgetEvent {
  final int tappedNumber;

  const TappedTestWidgetEvent(this.tappedNumber);
}

class ChiledTappedTestWidgetEvent extends TestWidgetEvent {
  const ChiledTappedTestWidgetEvent();
}
