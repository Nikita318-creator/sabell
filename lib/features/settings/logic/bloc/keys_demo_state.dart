import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class CountryModel extends Equatable {
  final String id;
  final String name;
  final Color color;

  const CountryModel({
    required this.id,
    required this.name,
    required this.color,
  });

  @override
  List<Object?> get props => [id, name, color];
}

class KeysDemoState extends Equatable {
  final List<CountryModel> countries;
  final UniqueKey uniqueKey;

  // Флаги включения/выключения ключей для демонстрации
  final bool useValueKey;
  final bool useObjectKey;
  final bool useUniqueKey;
  final bool usePageStorageKey;
  final bool useGlobalKey;

  final int blocCounter; // Счётчик для вызова Rebuild всего экрана

  const KeysDemoState({
    required this.countries,
    required this.uniqueKey,
    this.useValueKey = true,
    this.useObjectKey = true,
    this.useUniqueKey = true,
    this.usePageStorageKey = true,
    this.useGlobalKey = true,
    this.blocCounter = 0,
  });

  KeysDemoState copyWith({
    List<CountryModel>? countries,
    UniqueKey? uniqueKey,
    bool? useValueKey,
    bool? useObjectKey,
    bool? useUniqueKey,
    bool? usePageStorageKey,
    bool? useGlobalKey,
    int? blocCounter,
  }) {
    return KeysDemoState(
      countries: countries ?? this.countries,
      uniqueKey: uniqueKey ?? this.uniqueKey,
      useValueKey: useValueKey ?? this.useValueKey,
      useObjectKey: useObjectKey ?? this.useObjectKey,
      useUniqueKey: useUniqueKey ?? this.useUniqueKey,
      usePageStorageKey: usePageStorageKey ?? this.usePageStorageKey,
      useGlobalKey: useGlobalKey ?? this.useGlobalKey,
      blocCounter: blocCounter ?? this.blocCounter,
    );
  }

  @override
  List<Object?> get props => [
    countries,
    uniqueKey,
    useValueKey,
    useObjectKey,
    useUniqueKey,
    usePageStorageKey,
    useGlobalKey,
    blocCounter,
  ];
}
