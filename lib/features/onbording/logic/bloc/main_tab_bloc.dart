import 'package:flutter_bloc/flutter_bloc.dart';
import 'main_tab_event.dart';
import 'main_tab_state.dart';

class MainTabBloc extends Bloc<MainTabEvent, MainTabState> {
  MainTabBloc() : super(const MainTabState()) {
    on<ChangeTabEvent>(_onChangeTab);
  }

  void _onChangeTab(ChangeTabEvent event, Emitter<MainTabState> emit) {
    emit(MainTabState(currentTabIndex: event.index));
  }
}
