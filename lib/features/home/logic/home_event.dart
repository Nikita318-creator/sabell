import 'package:flutter/foundation.dart';

@immutable
abstract class HomeEvent {
  const HomeEvent();
}

class LoadHomeDataEvent extends HomeEvent {
  const LoadHomeDataEvent();
}

class HomePullToRefreshEvent extends HomeEvent {
  const HomePullToRefreshEvent();
}

class HomeAppResumedEvent extends HomeEvent {
  const HomeAppResumedEvent();

  @override
  List<Object?> get props => [];
}
