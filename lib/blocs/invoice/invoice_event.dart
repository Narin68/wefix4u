part of 'invoice_bloc.dart';

@immutable
abstract class InvoiceEvent {
  List<Object> get props => [];
}

class FetchInvoice extends InvoiceEvent {
  final int? partnerId;
  final String? status;
  final int? cusId;
  final bool? isInit;

  FetchInvoice({this.partnerId, this.isInit, this.cusId, this.status});

  List<Object> get props =>
      [this.partnerId!, this.isInit!, this.cusId!, this.status!];
}

class ReloadInvoice extends InvoiceEvent {
  List<Object> get props => [];
}
