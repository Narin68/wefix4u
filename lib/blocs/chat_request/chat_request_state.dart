part of 'chat_request_bloc.dart';

@immutable
abstract class ChatRequestState {
  List<Object> get props => [];
}

class ChatRequestInitial extends ChatRequestState {
  ChatRequestInitial();

  @override
  List<Object> get props => [];
}

class ChatRequestLoading extends ChatRequestState {
  @override
  List<Object> get props => [];
}

class ChatRequestSuccess extends ChatRequestState {
  final List<MRequestService>? data;
  final bool? hasReach;

  ChatRequestSuccess({
    this.data,
    this.hasReach,
  });

  ChatRequestSuccess copyWith({
    List<MRequestService>? data,
    bool? hasReach,
  }) =>
      ChatRequestSuccess(
        data: data ?? this.data,
        hasReach: hasReach ?? this.hasReach,
      );

  @override
  List<Object> get props => [data ?? [], hasReach ?? false];
}

class ChatRequestFailure extends ChatRequestState {
  final String message;
  final int statusCode;

  ChatRequestFailure({required this.statusCode, required this.message});

  @override
  List<Object> get props => [message, statusCode];
}
