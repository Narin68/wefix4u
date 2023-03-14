part of 'service_category_bloc.dart';

@immutable
abstract class ServiceCategoryEvent {
  List<Object> get props => [];
}

class Init extends ServiceCategoryEvent {
  @override
  List<Object> get props => [];
}

class FetchServiceCate extends ServiceCategoryEvent {
  late final bool? isInit;
  final bool getNewData;

  FetchServiceCate({this.isInit, this.getNewData = false});

  @override
  List<Object> get props => [
        {this.isInit}
      ];
}

class ReloadServiceCate extends ServiceCategoryEvent {
  final String search;

  ReloadServiceCate({this.search = ''});

  @override
  List<Object> get props => [this.search];
}

class GetServiceCate extends ServiceCategoryEvent {
  final String search;

  GetServiceCate({this.search = ''});

  @override
  List<Object> get props => [this.search];
}
