part of 'request_service_detail_bloc.dart';

@immutable
abstract class RequestServiceDetailState {
  List<Object> get props => [];
}

class RequestServiceDetailInitial extends RequestServiceDetailState {
  @override
  List<Object> get props => [];
}

class RequestDetailLoading extends RequestServiceDetailState {
  @override
  List<Object> get props => [];
}

class RequestDetailSuccess extends RequestServiceDetailState {
  final MRequestService? header;
  final MServiceRequestDetail? detail;

  RequestDetailSuccess({this.header, this.detail});

  RequestDetailSuccess copyWith({
    MRequestService? data,
    MServiceRequestDetail? detail,
  }) =>
      RequestDetailSuccess(
        header: data ?? this.header,
        detail: detail ?? this.detail,
      );

  @override
  List<Object> get props => [header ?? [], this.detail!];
}

class RequestDetailFailure extends RequestServiceDetailState {
  final String message;
  final int statusCode;

  RequestDetailFailure({required this.statusCode, required this.message});

  @override
  List<Object> get props => [message, statusCode];
}
