part of 'quotation_bloc.dart';

@immutable
abstract class QuotationEvent {
  List<Object> get props => [];
}

class FetchQuot extends QuotationEvent {
  final int? partnerId;
  final bool? isInit;

  FetchQuot({this.partnerId, this.isInit});

  @override
  List<Object> get props => [this.partnerId!, this.isInit!];
}

class ReloadQuot extends QuotationEvent {
  @override
  List<Object> get props => [];
}
