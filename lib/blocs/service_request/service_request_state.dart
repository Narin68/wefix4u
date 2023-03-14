part of 'service_request_bloc.dart';

@immutable
abstract class ServiceRequestState {
  List<Object> get props => [];
}

class ServiceRequestInitial extends ServiceRequestState {
  final bool isLoading;

  ServiceRequestInitial({this.isLoading = true});

  @override
  List<Object> get props => [isLoading];
}

class ServiceRequestLoading extends ServiceRequestState {
  @override
  List<Object> get props => [];
}

class ServiceRequestSuccess extends ServiceRequestState {
  final List<MRequestService>? data;
  final bool? hasReach;

  ServiceRequestSuccess({
    this.data,
    this.hasReach,
  });

  ServiceRequestSuccess copyWith({
    List<MRequestService>? data,
    bool? hasReach,
  }) =>
      ServiceRequestSuccess(
        data: data ?? this.data,
        hasReach: hasReach ?? this.hasReach,
      );

  @override
  List<Object> get props => [data ?? [], hasReach ?? false];
}

class ServiceRequestFailure extends ServiceRequestState {
  final String message;
  final int statusCode;

  ServiceRequestFailure({required this.statusCode, required this.message});

  @override
  List<Object> get props => [message, statusCode];
}
