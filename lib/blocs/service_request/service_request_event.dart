part of 'service_request_bloc.dart';

@immutable
abstract class ServiceRequestEvent {
  List<Object> get props => [];
}

class FetchedServiceRequest extends ServiceRequestEvent {
  final MServiceRequestFilter? filter;
  final bool? isInit;

  FetchedServiceRequest({this.filter, this.isInit});

  List<Object> get props => [filter!, isInit!];
}

class ReloadServiceRequest extends ServiceRequestEvent {
  final MServiceRequestFilter? filter;
  final bool isLoading;

  ReloadServiceRequest({this.filter, this.isLoading = true});

  List<Object> get props => [filter!, isLoading];
}

class UpdateServiceRequest extends ServiceRequestEvent {
  final MRequestService data;
  final MServiceRequestDetail? detail;

  UpdateServiceRequest({required this.data, this.detail});

  List<Object> get props => [data, detail!];
}

class AddServiceRequest extends ServiceRequestEvent {
  final List<MRequestService> data;

  AddServiceRequest({required this.data});

  List<Object> get props => [data];
}

class ClearRequestService extends ServiceRequestEvent {
  List<Object> get props => [];
}

class RemoveServiceRequest extends ServiceRequestEvent {
  final MRequestService data;
  RemoveServiceRequest({required this.data});
  List<Object> get props => [data];
}
