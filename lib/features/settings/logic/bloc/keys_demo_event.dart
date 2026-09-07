import 'package:equatable/equatable.dart';

abstract class KeysDemoEvent extends Equatable {
  const KeysDemoEvent();

  @override
  List<Object?> get props => [];
}

class SwapItemsEvent extends KeysDemoEvent {}

class RegenerateUniqueKeyEvent extends KeysDemoEvent {}

class ToggleKeyUsageEvent extends KeysDemoEvent {
  final String
  keyType; // 'valueKey', 'objectKey', 'uniqueKey', 'pageStorageKey', 'globalKey'
  const ToggleKeyUsageEvent(this.keyType);

  @override
  List<Object?> get props => [keyType];
}

class IncrementBlocCounterEvent extends KeysDemoEvent {}
