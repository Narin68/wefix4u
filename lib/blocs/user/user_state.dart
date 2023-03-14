part of 'user_cubit.dart';

abstract class MyUserState extends Equatable {
  const MyUserState();
}

class MyUserInitial extends MyUserState {
  @override
  List<Object> get props => [];
}

class MyUserLoading extends MyUserState {
  final bool? isLoad;

  MyUserLoading({this.isLoad});

  @override
  List<Object> get props => [isLoad!];
}

class MyUserSuccess extends MyUserState {
  final MUserInfo? user;

  final MMyCustomer? customer;

  const MyUserSuccess({this.user, this.customer});

  MyUserSuccess copyWith({
    MUserInfo? user,
    MMyCustomer? customer,
  }) =>
      MyUserSuccess(
        user: user ?? this.user,
        customer: customer ?? this.customer,
      );

  @override
  List<Object> get props => [user!, customer!];
}

class MyUserFailure extends MyUserState {
  final String message;
  final int statusCode;

  const MyUserFailure({required this.statusCode, required this.message});

  @override
  List<Object> get props => [message, statusCode];
}
