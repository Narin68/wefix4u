part of 'wallet_transaction_bloc.dart';

@immutable
abstract class WalletTransactionEvent {
  List<Object> get props => [];
}

class FetchWalletTransaction extends WalletTransactionEvent {
  final int? walletId;
  final bool? isInit;

  FetchWalletTransaction({this.walletId, this.isInit});

  List<Object> get props => [this.walletId!, this.isInit!];
}

class ReloadWalletTransaction extends WalletTransactionEvent {
  List<Object> get props => [];
}

class AddWalletTransaction extends WalletTransactionEvent {
  final MWalletTransactionData data;

  AddWalletTransaction({required this.data});

  List<Object> get props => [];
}

class UpdateWalletTransaction extends WalletTransactionEvent {
  final MWalletTransactionData data;

  UpdateWalletTransaction({required this.data});

  List<Object> get props => [];
}
