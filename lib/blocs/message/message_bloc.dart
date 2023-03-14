import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:ocs_auth/models/response.dart';
import '/globals.dart';
import '/modals/message.dart';
import '/repositories/message_repo.dart';

part 'message_event.dart';

part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  var _repo = MessageRepo();

  MessageBloc() : super(MessageInitial()) {
    on(_init);
  }

  Future _init(MessageEvent event, Emitter<MessageState> emit) async {
    var _currState = state;
    int _records = 30;

    if (event is ReloadMessage) {
      emit(MessageInitial());
    }

    if (event is FetchMessage && !_hasMax(state)) {
      if ((event.isInit ?? false) && _currState is MessageSuccess) {
        return;
      }

      if (_currState is MessageInitial) {
        emit(MessageLoading());
        MResponse _res = await _repo.getListMessage(
          requestId: event.requestId,
          receiverId: event.receiverId,
          page: 1,
          records: _records,
        );

        if (!_res.error) {
          var _hasMax = _res.data.length < _records;
          emit(MessageSuccess(data: _res.data, hasMax: _hasMax));
        } else {
          emit(MessageFailure(
              statusCode: _res.statusCode, message: _res.message));
        }
        return;
      }

      if (_currState is MessageSuccess) {
        int _page = ((_currState.data?.length ?? 0) / _records).ceil() + 1;
        MResponse _res = await _repo.getListMessage(
          requestId: event.requestId,
          receiverId: event.receiverId,
          page: _page,
          records: _records,
        );

        if (!_res.error) {
          var _hasMax = _res.data.length < _records;

          emit(MessageSuccess(
              data: (_currState.data ?? []) + _res.data, hasMax: _hasMax));
        } else {
          emit(MessageFailure(
              statusCode: _res.statusCode, message: _res.message));
        }
        return;
      }
    }

    if (event is AddMessage && _currState is MessageSuccess) {
      if (event.data.sender != Model.userInfo.loginName &&
          event.data.id != null &&
          (_currState.data?.isNotEmpty ?? false) &&
          _currState.data?[0].requestId == event.data.requestId)
        await _repo.seenMessage(event.data.id ?? 0);

      emit(_currState.copyWith(data: ((_currState.data ?? []) + [event.data])));
    }

    if (event is UpdateMessage && _currState is MessageSuccess) {
      var oldData = _currState.data;
      var newData = event.data;
      oldData = _changeData(oldData ?? [], newData);

      emit(_currState.copyWith(
        data: oldData.toSet().toList(),
      ));
      return;
    }

    if (event is UpdateSeenMessage && _currState is MessageSuccess) {
      var oldData = _currState.data;

      for (var i = 0; i < oldData!.length; i++) {
        event.ids.forEach((e) {
          if (oldData[i].id == e) oldData[i] = oldData[i].copyWith(status: "S");
        });
      }

      emit(_currState.copyWith(
        data: oldData.toSet().toList(),
      ));
      return;
    }

    if (event is UpdateLastMessage && _currState is MessageSuccess) {
      var oldData = _currState.data;
      var newData = event.data;
      oldData?[(oldData.length > 1 ? oldData.length : 1) - 1] = newData;

      emit(_currState.copyWith(
        data: oldData?.toSet().toList(),
      ));
      return;
    }

    if (event is DeleteMessage && _currState is MessageSuccess) {
      _currState.data?.removeWhere((e) => e.id == event.id);
      _currState.copyWith(data: _currState.data);
    }
  }

  List<MMessageData> _changeData(
      List<MMessageData> oldData, MMessageData newData) {
    if (oldData.isEmpty) return [];

    for (var i = 0; i < oldData.length; i++) {
      if (newData.id == oldData[i].id) {
        oldData[i] = newData;
        break;
      }
    }

    return oldData;
  }

  bool _hasMax(MessageState state) {
    return (state is MessageSuccess && (state.hasMax ?? false));
  }
}
