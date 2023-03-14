part of 'message_bloc.dart';

@immutable
abstract class MessageEvent {
  List<Object> get props => [];
}

@immutable
class FetchMessage extends MessageEvent {
  final int? records;
  final int? requestId;
  final int? receiverId;
  final bool? isInit;

  FetchMessage({this.records, this.isInit, this.receiverId, this.requestId});

  @override
  List<Object> get props => [];
}

class ReloadMessage extends MessageEvent {
  @override
  List<Object> get props => [];
}

class UpdateMessage extends MessageEvent {
  final MMessageData data;

  UpdateMessage({required this.data});

  @override
  List<Object> get props => [data];
}

class UpdateLastMessage extends MessageEvent {
  final MMessageData data;

  UpdateLastMessage({required this.data});

  @override
  List<Object> get props => [data];
}

class UpdateSeenMessage extends MessageEvent {
  final List<int> ids;

  UpdateSeenMessage({required this.ids});

  @override
  List<Object> get props => [ids];
}

class DeleteMessage extends MessageEvent {
  final int id;

  DeleteMessage({required this.id});

  @override
  List<Object> get props => [id];
}

class AddMessage extends MessageEvent {
  final MMessageData data;

  AddMessage({required this.data});

  @override
  List<Object> get props => [data];
}
