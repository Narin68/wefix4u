part of 'service_category_bloc.dart';

@immutable
abstract class ServiceCategoryState {
  List<Object> get props => [];
}

class ServiceCategoryInitial extends ServiceCategoryState {
  @override
  List<Object> get props => [];
}

class ServiceCategoryLoading extends ServiceCategoryState {
  @override
  List<Object> get props => [];
}

class ServiceCategorySuccess extends ServiceCategoryState {
  final List<MServiceCate>? data;
  final bool? hasMax;

  ServiceCategorySuccess({this.data, this.hasMax});

  @override
  List<Object> get props => [data!, hasMax!];

  ServiceCategorySuccess copyWith({
    List<MServiceCate>? data,
    bool? hasReach,
  }) =>
      ServiceCategorySuccess(
        data: data ?? this.data,
        hasMax: hasReach ?? this.hasMax,
      );
}

class ServiceCategoryFailure extends ServiceCategoryState {
  final String message;
  final int statusCode;

  ServiceCategoryFailure({required this.statusCode, required this.message});

  @override
  List<Object> get props => [message, statusCode];
}
