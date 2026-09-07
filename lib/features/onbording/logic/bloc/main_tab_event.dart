import 'package:flutter/foundation.dart';

@immutable
abstract class MainTabEvent {
  const MainTabEvent();
}

class ChangeTabEvent extends MainTabEvent {
  final int index;

  const ChangeTabEvent(this.index);
}
