import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '/modals/service.dart';
import '/repositories/service_repo.dart';

part 'service_event.dart';

part 'service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceRepo? repo;

  ServiceBloc({this.repo}) : super(ServiceInitial()) {
    on(_onEvent);
  }

  Future<void> _onEvent(ServiceEvent event, Emitter<ServiceState> emit) async {
    var currState = state;
    int _record = 15;

    if (event is InitService) {
      emit(ServiceLoading());

      var _result =
          await repo?.list(pages: 1, serviceCateId: event.serviceCateId);
      if (!_result!.error) {
        bool _hasMax = _result.data.length <= _record;
        emit(ServiceSuccess(
            data: _result.data, hasReach: _hasMax, selectData: []));
      } else {
        emit(ServiceFailure(
            message: "${_result.message}", statusCode: _result.statusCode));
      }
    }

    if (event is ReloadData && currState is ServiceSuccess) {
      emit(ServiceLoading());
      var _result = await repo?.list(
          pages: 1, search: event.search, serviceCateId: event.serviceCateId);

      if (!_result!.error) {
        bool _hasMax = _result.data.length <= _record;
        emit(ServiceSuccess(
            data: _result.data,
            hasReach: _hasMax,
            selectData: currState.selectData));
      } else {
        emit(ServiceFailure(
            message: "${_result.message}", statusCode: _result.statusCode));
      }
    }

    if (event is GetData && currState is ServiceSuccess) {
      int _page = (currState.data!.length / _record).ceil() + 1;
      var _result =
          await repo?.list(pages: _page, serviceCateId: event.serviceCateId);

      var _oldData = currState.data;

      if (!_result!.error) {
        bool _hasMax = _result.data.length < _record;
        emit(ServiceSuccess(
          data: (_oldData ?? []) + _result.data,
          hasReach: _hasMax,
          selectData: currState.selectData,
        ));
      } else {
        emit(ServiceFailure(
            message: "${_result.message}", statusCode: _result.statusCode));
      }
    }
    if (event is SelectService && currState is ServiceSuccess) {
      var currSelectData = currState.selectData ?? [];
      var hasData = currSelectData.where((e) => e.id == event.data?.id);
      if (hasData.isNotEmpty) {
        currSelectData.removeWhere((e) => e.id == event.data?.id);
      } else {
        currSelectData.add(event.data!);
      }
      emit(currState.copyWith(selectData: currSelectData));
    }

    if (event is MultiSelect && currState is ServiceSuccess) {
      List<MService> select = [];
      var data = currState.data;
      select = select + event.data!;
      emit(ServiceSuccess(data: data, selectData: select, hasReach: true));
    }
  }
}
