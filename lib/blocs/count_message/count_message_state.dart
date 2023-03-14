part of 'count_message_cubit.dart';

@immutable
abstract class CountMessageState {
  List<Object> get props => [];
}

class CountMessageInitial extends CountMessageState {
  @override
  List<Object> get props => [];
}

class CountMessageLoading extends CountMessageState {
  @override
  List<Object> get props => [];
}

class CountMessageSuccess extends CountMessageState {
  final int? data;
  final int? requestId;

  CountMessageSuccess({this.data, this.requestId});

  copyWith({
    int? data,
    int? requestId,
  }) =>
      CountMessageSuccess(
          data: data ?? this.data, requestId: requestId ?? this.requestId);

  @override
  List<Object> get props => [data!, requestId!];
}

class CountMessageFailure extends CountMessageState {
  final String message;
  final int statusCode;

  CountMessageFailure({required this.statusCode, required this.message});

  @override
  List<Object> get props => [message, statusCode];
}
