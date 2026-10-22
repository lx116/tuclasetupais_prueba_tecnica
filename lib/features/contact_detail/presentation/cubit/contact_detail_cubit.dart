import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/contact_detail_unavailable_exception.dart';
import '../../domain/usecases/contact_not_found_exception.dart';
import '../../domain/usecases/get_contact_by_id.dart';
import 'contact_detail_state.dart';

const String _unavailableMessage =
    'La lista de contactos no se cargó. Vuelve a la lista e inténtalo de nuevo.';

class ContactDetailCubit extends Cubit<ContactDetailState> {
  ContactDetailCubit(this._getContactById)
    : super(const ContactDetailLoading());

  final GetContactById _getContactById;

  Future<void> load(int id) async {
    if (state is! ContactDetailLoading) emit(const ContactDetailLoading());

    final ContactDetailState next;
    try {
      next = ContactDetailData(await _getContactById(id));
    } on ContactNotFoundException {
      if (!isClosed) emit(const ContactDetailNotFound());
      return;
    } catch (error) {
      if (isClosed) return;
      emit(ContactDetailError(_describe(error)));
      return;
    }

    if (!isClosed) emit(next);
  }

  String _describe(Object error) => switch (error) {
    ContactDetailUnavailableException() => _unavailableMessage,
    _ => '$error',
  };
}
