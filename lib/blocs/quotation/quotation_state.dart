part of 'quotation_bloc.dart';

@immutable
abstract class QuotationState {
  List<Object> get props => [];
}

class QuotationInitial extends QuotationState {
  @override
  List<Object> get props => [];
}

class QuotationSuccess extends QuotationState {
  final bool? hasMax;
  final List<MQuotationData>? data;

  QuotationSuccess({this.hasMax, this.data});

  QuotationSuccess copyWith({
    bool? hasMax,
    List<MQuotationData>? data,
  }) =>
      QuotationSuccess(
        data: data ?? this.data,
        hasMax: hasMax ?? this.hasMax,
      );

  @override
  List<Object> get props => [this.hasMax!, this.data ?? []];
}

class QuotationLoading extends QuotationState {
  @override
  List<Object> get props => [];
}

class QuotationFailed extends QuotationState {
  final String? message;
  final int? statusCode;

  QuotationFailed({this.message, this.statusCode});

  @override
  List<Object> get props => [this.message!, this.statusCode!];
}
