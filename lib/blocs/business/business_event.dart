part of 'business_bloc.dart';

@immutable
abstract class BusinessEvent {
  List<Object> get props => [];
}

class FetchedBusinessRequest extends BusinessEvent {
  final int? refId;

  final bool? isInit;

  FetchedBusinessRequest({this.refId, this.isInit});

  List<Object> get props => [refId!, isInit!];
}

class ReloadBusinessRequest extends BusinessEvent {
  final int? refId;
  final bool isLoading;

  ReloadBusinessRequest({this.refId, this.isLoading = true});

  List<Object> get props => [refId!, isLoading];
}

class AddNewBusinessRequest extends BusinessEvent {
  final MBusinessRequestList data;

  AddNewBusinessRequest({required this.data});

  List<Object> get props => [data];
}

class UpdateBusinessRequest extends BusinessEvent {
  final MBusinessRequestList data;

  UpdateBusinessRequest({required this.data});

  List<Object> get props => [data];
}
