import 'package:flutter/foundation.dart';

@immutable
class MainTabState {
  final int currentTabIndex;

  const MainTabState({this.currentTabIndex = 0});
}
