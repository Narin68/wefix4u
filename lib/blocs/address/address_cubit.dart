import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '/modals/address_filter.dart';
import '/repositories/address.dart';
import '/modals/address.dart';

part 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  AddressCubit() : super(AddressInitial());

  var _repo = AddressRepo();

  Future getData(int? id, int? refId) async {
    emit(AddressLoading());

    final result = await _repo.list(MAddressFilter(id: id, referenceId: refId));

    if (!result.error) {
      if (result.header.length > 0) emit(AddressSuccess(result.header));
    } else
      emit(AddressFailure(
          statusCode: result.statusCode, message: result.message));
  }
}
