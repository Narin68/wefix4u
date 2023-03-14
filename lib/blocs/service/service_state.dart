part of 'service_bloc.dart';

@immutable
abstract class ServiceState {
  List<Object> get props => [];
}

class ServiceInitial extends ServiceState {
  @override
  List<Object> get props => [];
}

class ServiceLoading extends ServiceState {
  @override
  List<Object> get props => [];
}

class ServiceSuccess extends ServiceState {
  final List<MService>? data;

  final List<MService>? selectData;

  final bool? hasReach;

  ServiceSuccess({this.data, this.hasReach = false, this.selectData});

  copyWith({
    List<MService>? data,
    List<MService>? selectData,
    bool? hasReach,
  }) =>
      ServiceSuccess(
        data: data ?? this.data,
        hasReach: hasReach ?? this.hasReach,
        selectData: selectData ?? this.selectData,
      );

  @override
  List<Object> get props => [data!, hasReach!];
}

class ServiceFailure extends ServiceState {
  final String message;
  final int statusCode;

  ServiceFailure({required this.statusCode, required this.message});

  @override
  List<Object> get props => [message, statusCode];
}
