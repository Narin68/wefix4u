part of 'business_bloc.dart';

@immutable
abstract class BusinessState {
  List<Object> get props => [];
}

class BusinessInitial extends BusinessState {
  BusinessInitial();

  @override
  List<Object> get props => [];
}

class BusinessLoading extends BusinessState {
  @override
  List<Object> get props => [];
}

class BusinessSuccess extends BusinessState {
  final List<MBusinessRequestList>? data;
  final bool? hasReach;

  BusinessSuccess({this.data, this.hasReach});

  BusinessSuccess copyWith({
    List<MBusinessRequestList>? data,
    bool? hasReach,
  }) =>
      BusinessSuccess(
        data: data ?? this.data,
        hasReach: hasReach ?? this.hasReach,
      );

  @override
  List<Object> get props => [data ?? [], hasReach ?? false];
}

class BusinessFailure extends BusinessState {
  final String message;
  final int statusCode;

  BusinessFailure({required this.statusCode, required this.message});

  @override
  List<Object> get props => [message, statusCode];
}
