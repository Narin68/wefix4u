part of 'request_service_detail_bloc.dart';

@immutable
abstract class RequestServiceDetailEvent {
  List<Object> get props => [];
}

class FetchRequestDetail extends RequestServiceDetailEvent {
  final int id;
  final MRequestService header;

  FetchRequestDetail({required this.id, required this.header});

  List<Object> get props => [id, header];
}

class UpdateRequestDetail extends RequestServiceDetailEvent {
  final MRequestService? header;
  final MServiceRequestDetail? detail;

  UpdateRequestDetail({this.detail, this.header});

  List<Object> get props => [detail!, header!];
}

class UpdateStatusDetail extends RequestServiceDetailEvent {
  final int? id;
  final String? status;
  final bool getDetail;

  UpdateStatusDetail({this.id, this.status, this.getDetail = false});

  List<Object> get props => [id!, status!];
}

class ReloadRequestDetail extends RequestServiceDetailEvent {
  List<Object> get props => [];
}

class GetRequestDetail extends RequestServiceDetailEvent {
  List<Object> get props => [];
}
