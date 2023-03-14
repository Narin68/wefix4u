part of 'receipt_bloc.dart';

@immutable
abstract class ReceiptEvent {
  List<Object> get props => [];
}

class FetchReceipt extends ReceiptEvent {
  final int? partnerId;
  final String? status;
  final int? cusId;
  final bool? isInit;

  FetchReceipt({this.partnerId, this.isInit, this.cusId, this.status});

  List<Object> get props =>
      [this.partnerId!, this.isInit!, this.cusId!, this.status!];
}

class ReloadReceipt extends ReceiptEvent {
  List<Object> get props => [];
}
