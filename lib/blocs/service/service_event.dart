part of 'service_bloc.dart';

@immutable
abstract class ServiceEvent {
  List<Object> get props => [];
}

class GetData extends ServiceEvent {
  final int serviceCateId;
  final String search;

  GetData({this.serviceCateId = 0, this.search = ''});

  @override
  List<Object> get props => [];
}

class InitService extends ServiceEvent {
  final int serviceCateId;

  InitService({this.serviceCateId = 0});

  @override
  List<Object> get props => [];
}

class SelectService extends ServiceEvent {
  final MService? data;

  SelectService({this.data});

  @override
  List<Object> get props => [data!];
}

class MultiSelect extends ServiceEvent {
  final List<MService>? data;

  MultiSelect({this.data});

  @override
  List<Object> get props => [data!];
}

class ReloadData extends ServiceEvent {
  final int serviceCateId;
  final String search;

  ReloadData({this.serviceCateId = 0, this.search = ''});

  @override
  List<Object> get props => [];
}
