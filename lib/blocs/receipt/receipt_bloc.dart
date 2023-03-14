import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '/modals/invoice.dart';
import '/repositories/invoice_repo.dart';

part 'receipt_event.dart';

part 'receipt_state.dart';

class ReceiptBloc extends Bloc<ReceiptEvent, ReceiptState> {
  final InvoiceRepo repo;

  ReceiptBloc({required this.repo}) : super(ReceiptInitial()) {
    on(_init);
  }

  Future<void> _init(ReceiptEvent event, Emitter<ReceiptState> emit) async {
    var _currState = state;
    int records = 10;

    if (event is ReloadReceipt) {
      emit(ReceiptInitial());
    }

    if (event is FetchReceipt && !_hasReachedMax(_currState)) {
      if ((event.isInit ?? false) && _currState is ReceiptSuccess) {
        return;
      }

      if (_currState is ReceiptInitial) {
        emit(ReceiptLoading());
        var _res = await repo.list(
            partner: event.partnerId ?? 0,
            customerId: event.cusId ?? 0,
            status: event.status ?? "");
        if (!_res.error) {
          bool _reach = _res.data.length < records;
          emit(ReceiptSuccess(data: _res.data, hasMax: _reach));
        } else {
          emit(ReceiptFailed(
              message: _res.message, statusCode: _res.statusCode));
        }

        return;
      }

      if (_currState is ReceiptSuccess) {
        int _pages = ((_currState.data?.length)! / records).ceil() + 1;
        var _res = await repo.list(
            partner: event.partnerId ?? 0,
            pages: _pages,
            customerId: event.cusId ?? 0,
            status: event.status ?? "");
        if (!_res.error) {
          bool _reach = _res.data.length < records;
          List<MInvoiceData> data = _res.data;
          emit(data.isEmpty
              ? _currState.copyWith(hasMax: true)
              : _currState.copyWith(
                  hasMax: _reach, data: (_currState.data ?? []) + _res.data));
        } else {
          emit(ReceiptFailed(
              message: _res.message, statusCode: _res.statusCode));
        }
      }
    }
  }

  bool _hasReachedMax(ReceiptState state) =>
      state is ReceiptSuccess && (state.hasMax ?? false);
}
