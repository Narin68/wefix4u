import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '/modals/customer_request_service.dart';
import '/repositories/customer_request_service.dart';

part 'request_service_detail_event.dart';

part 'request_service_detail_state.dart';

class RequestServiceDetailBloc
    extends Bloc<RequestServiceDetailEvent, RequestServiceDetailState> {
  final ServiceRequestRepo repo;

  RequestServiceDetailBloc({required this.repo})
      : super(RequestServiceDetailInitial()) {
    on(_init);
  }

  Future _init(RequestServiceDetailEvent event,
      Emitter<RequestServiceDetailState> emit) async {
    var _currState = state;

    if (event is FetchRequestDetail) {
      emit(RequestDetailLoading());

      var _res = await repo.getDetail(event.id);

      if (!_res.error) {
        emit(RequestDetailSuccess(detail: _res.data, header: event.header));
      } else {
        emit(RequestDetailFailure(
            statusCode: _res.statusCode, message: _res.message));
      }
    }

    if (event is ReloadRequestDetail) {
      emit(RequestServiceDetailInitial());
    }

    if (event is GetRequestDetail && _currState is RequestDetailSuccess) {
      emit(RequestDetailSuccess(
          detail: _currState.detail, header: _currState.header));
    }

    if (event is UpdateRequestDetail && _currState is RequestDetailSuccess) {
      if (event.header?.id == _currState.header?.id) {
        emit(
          _currState.copyWith(
            detail: event.detail ?? _currState.detail,
            data: event.header ?? _currState.header,
          ),
        );
      }
    }

    if (event is UpdateStatusDetail && _currState is RequestDetailSuccess) {
      if (event.id == _currState.header?.id) {
        emit(
          _currState.copyWith(
            data: _currState.header?.copyWith(status: event.status),
          ),
        );
        if (event.getDetail) {
          emit(RequestDetailLoading());

          var _res = await repo.getDetail(_currState.header?.id ?? 0);

          if (!_res.error) {
            emit(_currState.copyWith(
              detail: _res.data,
            ));
          } else {
            emit(RequestDetailFailure(
                statusCode: _res.statusCode, message: _res.message));
          }
        }
      }
    }
  }
}
