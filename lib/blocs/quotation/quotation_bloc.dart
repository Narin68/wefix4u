import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '/modals/quotation.dart';
import '/repositories/quotation_repo.dart';

part 'quotation_event.dart';

part 'quotation_state.dart';

class QuotationBloc extends Bloc<QuotationEvent, QuotationState> {
  final QuotRepo repo;

  QuotationBloc({required this.repo}) : super(QuotationInitial()) {
    on(_init);
  }

  Future _init(QuotationEvent event, Emitter emit) async {
    var _currState = state;
    int _record = 10;
    if (event is ReloadQuot) {
      emit(QuotationInitial());
    }

    if (event is FetchQuot && !_hasReachedMax(_currState)) {
      if ((event.isInit ?? false) && _currState is QuotationSuccess) {
        return;
      }
      if (_currState is QuotationInitial) {
        var _res = await repo.list(
            partner: event.partnerId ?? 0, pages: 1, records: _record);
        if (!_res.error) {
          bool _hasMax = _res.data.length < _record;
          emit(QuotationSuccess(hasMax: _hasMax, data: _res.data));
        } else {
          emit(QuotationFailed(
              statusCode: _res.statusCode, message: _res.message));
        }

        return;
      }

      if (_currState is QuotationSuccess) {
        int _pages = ((_currState.data?.length ?? 0) / _record).ceil() + 1;
        var _res = await repo.list(
            partner: event.partnerId ?? 0, pages: _pages, records: _record);
        if (!_res.error) {
          bool _hasMax = _res.data.length < _record;
          List<MQuotationData> data = _res.data;
          emit(data.isEmpty
              ? _currState.copyWith(hasMax: true)
              : _currState.copyWith(
                  hasMax: _hasMax, data: (_currState.data ?? []) + _res.data));
        } else {
          emit(QuotationFailed(
              statusCode: _res.statusCode, message: _res.message));
        }
        return;
      }
    }
  }

  bool _hasReachedMax(QuotationState state) =>
      state is QuotationSuccess && (state.hasMax ?? false);
}
