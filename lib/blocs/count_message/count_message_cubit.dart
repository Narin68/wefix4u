import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:ocs_auth/ocs_auth.dart';
import '/repositories/message_repo.dart';

part 'count_message_state.dart';

class CountMessageCubit extends Cubit<CountMessageState> {
  MessageRepo _repo = MessageRepo();

  CountMessageCubit() : super(CountMessageInitial());

  Future fetchCountMessage(requestId) async {
    MResponse _res = await _repo.getCountUnseen(requestId);

    if (!_res.error) {
      emit(CountMessageSuccess(data: _res.data, requestId: requestId));
    } else {
      emit(CountMessageFailure(
          statusCode: _res.statusCode, message: _res.message));
    }
  }

  Future setCountMessage(int count) async {
    var _curr = state;

    if (_curr is CountMessageSuccess) {
      emit(_curr.copyWith(data: count));
    }
  }
}
