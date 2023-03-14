part of 'address_cubit.dart';

@immutable
abstract class AddressState {
  List<Object> get props => [];
}

class AddressInitial extends AddressState {
  List<Object> get props => [];
}

class AddressLoading extends AddressState {
  @override
  List<Object> get props => [];
}

class AddressSuccess extends AddressState {
  final List<MAddress> data;

  AddressSuccess(this.data);

  @override
  List<Object> get props => [data];
}

class AddressFailure extends AddressState {
  final String message;
  final int statusCode;

  AddressFailure({required this.statusCode, required this.message});

  @override
  List<Object> get props => [message, statusCode];
}
