part of 'wallet_cubit.dart';

@immutable
abstract class WalletState {
  List<Object> get props => [];
}

class WalletInitial extends WalletState {
  @override
  List<Object> get props => [];
}

class WalletLoading extends WalletState {
  @override
  List<Object> get props => [];
}

class WalletSuccess extends WalletState {
  final MWalletData? data;
  final String? withdrawStatus;

  WalletSuccess({this.data, this.withdrawStatus});

  WalletSuccess copyWith({
    MWalletData? WalletData,
    String? withdrawStatus,
  }) =>
      WalletSuccess(
        data: data ?? this.data,
        withdrawStatus: withdrawStatus ?? this.withdrawStatus,
      );

  @override
  List<Object> get props => [data!, withdrawStatus ?? ''];
}

class WalletFailure extends WalletState {
  final String message;
  final int statusCode;

  WalletFailure({required this.statusCode, required this.message});

  @override
  List<Object> get props => [message, statusCode];
}
