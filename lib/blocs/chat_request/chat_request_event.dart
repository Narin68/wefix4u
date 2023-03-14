part of 'chat_request_bloc.dart';

@immutable
abstract class ChatRequestEvent {
  List<Object> get props => [];
}

class FetchedChatRequest extends ChatRequestEvent {
  final MServiceRequestFilter? filter;
  final bool? isInit;

  FetchedChatRequest({this.filter, this.isInit});

  List<Object> get props => [filter!, isInit!];
}

class ReloadChatRequest extends ChatRequestEvent {
  final MServiceRequestFilter? filter;
  final bool isLoading;

  ReloadChatRequest({this.filter, this.isLoading = true});

  List<Object> get props => [filter!, isLoading];
}
