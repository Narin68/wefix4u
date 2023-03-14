part of 'language_cubit.dart';

@immutable
abstract class LanguageState {
  List<Object> get props => [];

}

class LanguageInitial extends LanguageState {}

class LanguageLoading extends LanguageState {
  @override
  List<Object> get props => [];
}

class LanguageSuccess extends LanguageState {
  final String data;

  LanguageSuccess(this.data);

  @override
  List<Object> get props => [data];
}

class LanguageFailure extends LanguageState {
  final String message;
  final int statusCode;

  LanguageFailure({required this.statusCode, required this.message});

  @override
  List<Object> get props => [message, statusCode];
}
