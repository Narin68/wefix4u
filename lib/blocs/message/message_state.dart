part of 'message_bloc.dart';

@immutable
abstract class MessageState {
  List<Object> get props => [];
}

class MessageInitial extends MessageState {
  @override
  List<Object> get props => [];
}

class MessageLoading extends MessageState {
  @override
  List<Object> get props => [];
}

class MessageSuccess extends MessageState {
  final List<MMessageData>? data;
  final bool? hasMax;

  MessageSuccess({this.data, this.hasMax});

  copyWith({
    List<MMessageData>? data,
    bool? hasMax,
  }) =>
      MessageSuccess(
        data: data ?? this.data,
        hasMax: hasMax ?? this.hasMax,
      );

  @override
  List<Object> get props => [data!, hasMax!];
}

class MessageFailure extends MessageState {
  final String message;
  final int statusCode;

  MessageFailure({required this.statusCode, required this.message});

  @override
  List<Object> get props => [message, statusCode];
}
