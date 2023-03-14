import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '/modals/customer_request_service.dart';
import '/repositories/customer_request_service.dart';

part 'chat_request_event.dart';

part 'chat_request_state.dart';

class ChatRequestBloc extends Bloc<ChatRequestEvent, ChatRequestState> {
  ChatRequestBloc() : super(ChatRequestInitial()) {
    on(_onEvent);
  }

  Future<void> _onEvent(
      ChatRequestEvent event, Emitter<ChatRequestState> emit) async {
    var currState = state;
    var repo = ServiceRequestRepo();
    int _record = 15;
    List<String> status = [
      "APPROVED",
      "ACCEPTED",
      "FIXING",
      "HEADING",
      "CLOSED",
      "QUOTE SUBMITTED"
    ];

    if (event is ReloadChatRequest) {
      emit(ChatRequestInitial());
    }

    if (event is FetchedChatRequest && !_hasReachedMax(currState)) {
      final filter = event.filter;

      if ((event.isInit ?? false) && currState is ChatRequestSuccess) {
        return;
      }

      /// init data
      if (currState is ChatRequestInitial || currState is ChatRequestFailure) {
        if (currState is ChatRequestInitial || currState is ChatRequestFailure)
          emit(ChatRequestLoading());

        var _result = await repo.list(
          filter!.copyWith(
            pages: 1,
            records: _record,
            status: status,
          ),
        );

        if (!_result.error) {
          List<MRequestService> data = _result.data;

          // data.forEach((element) {
          //   print(element.status);
          // });

          bool _hasMax = _result.data.length < _record;
          emit(ChatRequestSuccess(data: data, hasReach: _hasMax));
        } else {
          emit(ChatRequestFailure(
              message: "${_result.message}", statusCode: _result.statusCode));
        }
        return;
      }

      /// Get more data
      if (currState is ChatRequestSuccess) {
        int _page = (currState.data!.length / _record).ceil() + 1;

        var _result = await repo.list(filter!.copyWith(
          pages: _page,
          records: _record,
          status: status,
        ));

        if (!_result.error) {
          List<MRequestService> data = _result.data;
          bool _hasMax = (_result.data.length) < _record;
          emit(data.isEmpty
              ? currState.copyWith(hasReach: true)
              : currState.copyWith(
                  data: (currState.data ?? []) + data,
                  hasReach: _hasMax,
                ));
        } else {
          emit(ChatRequestFailure(
              message: "${_result.message}", statusCode: _result.statusCode));
        }

        return;
      }
    }
  }

  bool _hasReachedMax(ChatRequestState state) =>
      state is ChatRequestSuccess && (state.hasReach ?? false);
}
