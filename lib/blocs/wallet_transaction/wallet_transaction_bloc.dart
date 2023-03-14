import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '/modals/wallet_transaction.dart';
import '/repositories/wallet_transaction_repo.dart';

part 'wallet_transaction_event.dart';

part 'wallet_transaction_state.dart';

class WalletTransactionBloc
    extends Bloc<WalletTransactionEvent, WalletTransactionState> {
  final repo = WalletTransactionRepo();

  WalletTransactionBloc() : super(WalletTransactionInitial()) {
    on(_init);
  }

  Future<void> _init(WalletTransactionEvent event,
      Emitter<WalletTransactionState> emit) async {
    var _currState = state;
    int _records = 10;

    if (event is ReloadWalletTransaction) {
      emit(WalletTransactionInitial());
    }

    if (event is FetchWalletTransaction && !_hasReachedMax(_currState)) {
      if ((event.isInit ?? false) && _currState is WalletTransactionSuccess) {
        return;
      }

      if (_currState is WalletTransactionInitial) {
        emit(WalletTransactionLoading());
        var _res = await repo.walletTransactionList(
          event.walletId ?? 0,
          records: _records,
          pages: 1,
        );
        if (!_res.error) {
          bool _reach = _res.data.length < _records;
          emit(WalletTransactionSuccess(data: _res.data ?? [], hasMax: _reach));
        } else {
          emit(WalletTransactionFailed(
              message: _res.message, statusCode: _res.statusCode));
        }
        return;
      }

      if (_currState is WalletTransactionSuccess) {
        int _pages = ((_currState.data?.length)! / _records).ceil() + 1;
        var _res = await repo.walletTransactionList(event.walletId ?? 0,
            pages: _pages, records: _records);
        if (!_res.error) {
          bool _reach = _res.data.length < _records;
          List<MWalletTransactionData> data = _res.data;
          emit(data.isEmpty
              ? _currState.copyWith(hasMax: true)
              : _currState.copyWith(
                  hasMax: _reach, data: (_currState.data ?? []) + _res.data));
        } else {
          emit(WalletTransactionFailed(
              message: _res.message, statusCode: _res.statusCode));
        }
        return;
      }
    }
    if (_currState is WalletTransactionSuccess &&
        event is AddWalletTransaction) {
      emit(_currState.copyWith(data: ([event.data]) + _currState.data!));
      return;
    }
    if (_currState is WalletTransactionSuccess &&
        event is UpdateWalletTransaction) {
      int? index = _currState.data?.indexWhere((e) => e.id == event.data.id);

      if (index != null && index >= 0) {
        _currState.data?[index] = event.data;
      }

      emit(_currState.copyWith(data: _currState.data));

      return;
    }
  }

  bool _hasReachedMax(WalletTransactionState state) =>
      state is WalletTransactionSuccess && (state.hasMax ?? false);
}
