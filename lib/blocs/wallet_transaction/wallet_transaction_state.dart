part of 'wallet_transaction_bloc.dart';

@immutable
abstract class WalletTransactionState {
  List<Object> get props => [];
}

class WalletTransactionInitial extends WalletTransactionState {
  @override
  List<Object> get props => [];
}

class WalletTransactionSuccess extends WalletTransactionState {
  final List<MWalletTransactionData>? data;
  final bool? hasMax;

  WalletTransactionSuccess({this.data, this.hasMax});

  WalletTransactionSuccess copyWith({
    List<MWalletTransactionData>? data,
    bool? hasMax,
  }) =>
      WalletTransactionSuccess(
          data: data ?? this.data, hasMax: hasMax ?? this.hasMax);

  @override
  List<Object> get props => [this.data!, this.hasMax!];
}

class WalletTransactionLoading extends WalletTransactionState {
  @override
  List<Object> get props => [];
}

class WalletTransactionFailed extends WalletTransactionState {
  final int? statusCode;
  final String? message;

  WalletTransactionFailed({this.message, this.statusCode});

  @override
  List<Object> get props => [this.message!, this.statusCode!];
}
