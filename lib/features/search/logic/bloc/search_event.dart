import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
abstract class SearchEvent {
  const SearchEvent();
}

class SearchTextChangedEvent extends SearchEvent {
  final String text;
  const SearchTextChangedEvent(this.text);
}

class SearchQuerySubmittedEvent extends SearchEvent {
  final String query;
  const SearchQuerySubmittedEvent(this.query);
}

class SearchResetEvent extends SearchEvent {
  const SearchResetEvent();
}

// 🟢 Ивент изменения жизненного цикла приложения
class SearchAppLifecycleChangedEvent extends SearchEvent {
  final AppLifecycleState state;
  const SearchAppLifecycleChangedEvent(this.state);
}
