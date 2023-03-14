part of 'receipt_bloc.dart';

@immutable
abstract class ReceiptState {
  List<Object> get props => [];
}

class ReceiptInitial extends ReceiptState {
  ReceiptInitial();

  @override
  List<Object> get props => [];
}

class ReceiptSuccess extends ReceiptState {
  final List<MInvoiceData>? data;
  final bool? hasMax;

  ReceiptSuccess({this.data, this.hasMax});

  ReceiptSuccess copyWith({
    List<MInvoiceData>? data,
    bool? hasMax,
  }) =>
      ReceiptSuccess(data: data ?? this.data, hasMax: hasMax ?? this.hasMax);

  @override
  List<Object> get props => [this.data!, this.hasMax!];
}

class ReceiptLoading extends ReceiptState {
  @override
  List<Object> get props => [];
}

class ReceiptFailed extends ReceiptState {
  final int? statusCode;
  final String? message;

  ReceiptFailed({this.message, this.statusCode});

  @override
  List<Object> get props => [this.message!, this.statusCode!];
}
