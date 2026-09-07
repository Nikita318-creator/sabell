import 'package:flutter/foundation.dart';
import 'package:flutter_sabel/features/catalog/data/models/catalog_model.dart';

@immutable
abstract class SearchState {
  final String queryText;

  const SearchState({this.queryText = ''});
}

class SearchInitialState extends SearchState {
  const SearchInitialState({super.queryText});
}

class SearchLoadingState extends SearchState {
  const SearchLoadingState({super.queryText});
}

class SearchSuccessState extends SearchState {
  final List<RemoteProducts> products; // 👈 Заменили модель на RemoteProducts
  final String query;

  const SearchSuccessState({
    required this.products,
    required this.query,
    super.queryText,
  });
}

class SearchEmptyState extends SearchState {
  final String query;

  const SearchEmptyState({required this.query, super.queryText});
}

class SearchValidationErrorState extends SearchState {
  final String message;

  const SearchValidationErrorState(this.message, {super.queryText});
}
