import 'package:flutter_bloc/flutter_bloc.dart';
import 'catalog_details_event.dart';
import 'catalog_details_state.dart';

class CatalogDetailsBloc
    extends Bloc<CatalogDetailsEvent, CatalogDetailsState> {
  CatalogDetailsBloc() : super(const CatalogDetailsState()) {
    on<CatalogDetailsImageChangedEvent>((event, emit) {
      emit(state.copyWith(selectedImageIndex: event.index));
    });
  }
}
