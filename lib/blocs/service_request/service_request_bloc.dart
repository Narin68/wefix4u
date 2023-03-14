import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '/repositories/customer_request_service.dart';
import '/modals/customer_request_service.dart';

part 'service_request_event.dart';

part 'service_request_state.dart';

class ServiceRequestBloc
    extends Bloc<ServiceRequestEvent, ServiceRequestState> {
  final ServiceRequestRepo repo;

  ServiceRequestBloc({required this.repo}) : super(ServiceRequestInitial()) {
    on(_onEvent);
  }

  Future<void> _onEvent(
      ServiceRequestEvent event, Emitter<ServiceRequestState> emit) async {
    var currState = state;
    var repo = ServiceRequestRepo();
    int _record = 10;

    if (event is ReloadServiceRequest) {
      emit(ServiceRequestInitial(isLoading: event.isLoading));
    }

    if (event is FetchedServiceRequest && !_hasReachedMax(currState)) {
      final filter = event.filter;

      if ((event.isInit ?? false) && currState is ServiceRequestSuccess) {
        return;
      }

      /// init data
      if (currState is ServiceRequestInitial ||
          currState is ServiceRequestFailure) {
        if (currState is ServiceRequestInitial && currState.isLoading)
          emit(ServiceRequestLoading());

        if (currState is ServiceRequestFailure) emit(ServiceRequestLoading());
        var _result = await repo.list(filter!.copyWith(
          pages: 1,
          records: _record,
        ));

        if (!_result.error) {
          bool _hasMax = _result.data.length < _record;
          emit(ServiceRequestSuccess(data: _result.data, hasReach: _hasMax));
        } else {
          emit(ServiceRequestFailure(
              message: "${_result.message}", statusCode: _result.statusCode));
        }
        return;
      }

      /// Get more data
      if (currState is ServiceRequestSuccess) {
        int _page = (currState.data!.length / _record).ceil() + 1;

        var _result = await repo.list(filter!.copyWith(
          pages: _page,
          records: _record,
        ));

        if (!_result.error) {
          List<MRequestService> data = _result.data;
          bool _hasMax = _result.data.length < _record;

          emit(data.isEmpty
              ? currState.copyWith(hasReach: true)
              : currState.copyWith(
                  data: (currState.data ?? []) + data,
                  hasReach: _hasMax,
                ));
        } else {
          emit(ServiceRequestFailure(
              message: "${_result.message}", statusCode: _result.statusCode));
        }

        return;
      }
    }

    if (event is UpdateServiceRequest && currState is ServiceRequestSuccess) {
      var oldData = currState.data;
      var newData = event.data;
      List<MRequestService> data =
          oldData?.where((e) => e.id == newData.id).toList() ?? [];

      if (data.isNotEmpty) {
        oldData = _changeData(oldData ?? [], newData);
      }

      emit(currState.copyWith(
        data: oldData?.toSet().toList(),
      ));
      return;
    }

    if (event is AddServiceRequest && currState is ServiceRequestSuccess) {
      var oldData = currState.data;
      var newData = event.data;
      emit(
        currState.copyWith(
          data: newData + (oldData ?? []),
        ),
      );
    }

    if (event is RemoveServiceRequest && currState is ServiceRequestSuccess) {
      currState.data?.removeWhere((e) => e.id == event.data.id);
      emit(currState.copyWith(data: currState.data ?? []));
    }
  }

  bool _hasReachedMax(ServiceRequestState state) =>
      state is ServiceRequestSuccess && (state.hasReach ?? false);

  List<MRequestService> _changeData(
      List<MRequestService> oldData, MRequestService newData) {
    for (var i = 0; i < oldData.length; i++) {
      if (newData.id == oldData[i].id) {
        oldData[i] = newData;
        break;
      }
    }

    return oldData;
  }
}
