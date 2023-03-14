import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '/modals/invoice.dart';
import '/repositories/invoice_repo.dart';

part 'invoice_event.dart';

part 'invoice_state.dart';

class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final InvoiceRepo repo;

  InvoiceBloc({required this.repo}) : super(InvoiceInitial()) {
    on(_init);
  }

  Future<void> _init(InvoiceEvent event, Emitter<InvoiceState> emit) async {
    var _currState = state;
    int records = 10;

    if (event is ReloadInvoice) {
      emit(InvoiceInitial());
    }

    if (event is FetchInvoice && !_hasReachedMax(_currState)) {
      if ((event.isInit ?? false) && _currState is InvoiceSuccess) {
        return;
      }

      if (_currState is InvoiceInitial) {
        emit(InvoiceLoading());
        var _res = await repo.list(
          partner: event.partnerId ?? 0,
          customerId: event.cusId ?? 0,
          status: event.status ?? "",
        );
        if (!_res.error) {
          bool _reach = _res.data.length < records;
          emit(InvoiceSuccess(data: _res.data, hasMax: _reach));
        } else {
          emit(InvoiceFailed(
              message: _res.message, statusCode: _res.statusCode));
        }

        return;
      }

      if (_currState is InvoiceSuccess) {
        int _pages = ((_currState.data?.length ?? 0) / records).ceil() + 1;
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
          emit(InvoiceFailed(
              message: _res.message, statusCode: _res.statusCode));
        }
      }
    }
  }

  bool _hasReachedMax(InvoiceState state) =>
      state is InvoiceSuccess && (state.hasMax ?? false);
}
