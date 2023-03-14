part of 'invoice_bloc.dart';

@immutable
abstract class InvoiceState {
  List<Object> get props => [];
}

class InvoiceInitial extends InvoiceState {
  InvoiceInitial();

  @override
  List<Object> get props => [];
}

class InvoiceSuccess extends InvoiceState {
  final List<MInvoiceData>? data;
  final bool? hasMax;

  InvoiceSuccess({this.data, this.hasMax});

  InvoiceSuccess copyWith({
    List<MInvoiceData>? data,
    bool? hasMax,
  }) =>
      InvoiceSuccess(data: data ?? this.data, hasMax: hasMax ?? this.hasMax);

  @override
  List<Object> get props => [this.data!, this.hasMax!];
}

class InvoiceLoading extends InvoiceState {
  @override
  List<Object> get props => [];
}

class InvoiceFailed extends InvoiceState {
  final int? statusCode;
  final String? message;

  InvoiceFailed({this.message, this.statusCode});

  @override
  List<Object> get props => [this.message!, this.statusCode!];
}
