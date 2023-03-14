import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:ocs_auth/models/response.dart';
import '/modals/business.dart';
import '/repositories/partner_repo.dart';

part 'business_event.dart';

part 'business_state.dart';

class BusinessBloc extends Bloc<BusinessEvent, BusinessState> {
  final PartnerRepo repo;

  BusinessBloc({required this.repo}) : super(BusinessInitial()) {
    on(_init);
  }

  Future<void> _init(BusinessEvent event, Emitter<BusinessState> emit) async {
    var currState = state;
    int _record = 10;

    if (event is ReloadBusinessRequest) {
      emit(BusinessInitial());
    }

    if (event is FetchedBusinessRequest && !_hasReachedMax(currState)) {
      if ((event.isInit ?? false) && currState is BusinessSuccess) {
        return;
      }
      if (currState is BusinessInitial) {
        if (event.refId == null) {
          emit(BusinessFailure(statusCode: 00, message: "error-occurred"));
          return;
        }

        emit(BusinessLoading());
        MResponse _res = await repo.updateCovAndServList(
          refId: event.refId!,
        );

        if (!_res.error) {
          bool _hasMax = _res.data.length < _record;
          emit(BusinessSuccess(data: _res.data, hasReach: _hasMax));
        } else {
          emit(BusinessFailure(
              statusCode: _res.statusCode, message: _res.message));
        }
      }

      if (currState is BusinessSuccess) {
        if (event.refId == null) {
          emit(BusinessFailure(statusCode: 00, message: "error-occurred"));
          return;
        }
        int _page = (currState.data!.length / _record).ceil() + 1;

        MResponse _res = await repo.updateCovAndServList(
            refId: event.refId ?? 0, pages: _page, records: _record);
        if (!_res.error) {
          List<MBusinessRequestList> data = _res.data;
          bool _hasMax = _res.data.length < _record;

          emit(
            data.isEmpty
                ? currState.copyWith(hasReach: true)
                : currState.copyWith(
                    data: (currState.data ?? []) + data,
                    hasReach: _hasMax,
                  ),
          );
        } else {
          emit(BusinessFailure(
            statusCode: _res.statusCode,
            message: _res.message,
          ));
        }
      }
    }

    if (event is AddNewBusinessRequest && currState is BusinessSuccess) {
      emit(currState.copyWith(data: [event.data] + (currState.data ?? [])));
    }
    if (event is UpdateBusinessRequest && currState is BusinessSuccess) {
      List<MBusinessRequestList> dataFound =
          currState.data?.where((e) => e.id == event.data.id).toList() ?? [];
      if (dataFound.isNotEmpty) {
        int? index = currState.data?.indexWhere((e) => e.id == event.data.id);
        currState.data?[index!] = event.data;
        emit(currState.copyWith(data: (currState.data ?? [])));
      }
    }
  }

  bool _hasReachedMax(BusinessState state) =>
      state is BusinessSuccess && (state.hasReach ?? false);
}
