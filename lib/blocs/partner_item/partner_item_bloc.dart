import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:ocs_util/ocs_util.dart';
import '/modals/partner_item.dart';
import '/repositories/partner_item_repo.dart';

part 'partner_item_event.dart';

part 'partner_item_state.dart';

class PartnerItemBloc extends Bloc<PartnerItemEvent, PartnerItemState> {
  PartnerItemRepo repo = PartnerItemRepo();

  PartnerItemBloc() : super(PartnerItemInitial()) {
    on(_init);
  }

  Future<void> _init(
      PartnerItemEvent event, Emitter<PartnerItemState> emit) async {
    var _currState = state;
    int _record = 15;

    if (event is ReloadItem) {
      emit(PartnerItemInitial());
    }
    if (event is FetchPartnerItem && !_hasReachedMax(_currState)) {
      if ((event.isInit ?? false) && _currState is PartnerItemSuccess) {
        return;
      }
      if (_currState is PartnerItemInitial) {
        emit(PartnerItemLoading());
        var _res = await repo.list(search: '', pages: 1, record: _record);

        if (!_res.error) {
          bool _hasMax = _res.data.length < _record;
          emit(PartnerItemSuccess(data: _res.data, hasMax: _hasMax));
        } else {
          emit(PartnerItemFailure(
              statusCode: _res.statusCode, message: _res.message));
        }
        return;
      }
      if (_currState is PartnerItemSuccess) {
        int _page = (_currState.data!.length / _record).ceil() + 1;
        var _result = await repo.list(pages: _page, record: _record);

        var _oldData = _currState.data;

        if (!_result.error) {
          bool _hasMax = _result.data.length < _record;
          emit(
            PartnerItemSuccess(
              data: _oldData! + _result.data,
              hasMax: _hasMax,
            ),
          );
        } else {
          emit(PartnerItemFailure(
              message: "${_result.message}", statusCode: _result.statusCode));
        }
        return;
      }
    }

    if (event is UpdateItem && _currState is PartnerItemSuccess) {
      List<MPartnerServiceItemData> _currData = _currState.data ?? [];
      int? index = _currData.indexWhere((e) => e.id == event.data.id);
      _currData[index] = event.data;
      emit(_currState.copyWith(data: _currData));
    }

    if (event is DeleteItem && _currState is PartnerItemSuccess) {
      List<MPartnerServiceItemData> _currData = _currState.data ?? [];
      _currData.removeWhere((e) => e.id == event.id);
      emit(_currState.copyWith(data: _currData));
    }
  }

  bool _hasReachedMax(PartnerItemState state) {
    return state is PartnerItemSuccess && (state.hasMax ?? false);
  }
}
