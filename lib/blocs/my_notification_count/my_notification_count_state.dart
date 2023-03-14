part of 'my_notification_count_cubit.dart';

abstract class MyNotificationCountState {
  List<Object> get props => [];
}

class MyNotificationCountInitial extends MyNotificationCountState {
  @override
  List<Object> get props => [];
}

class MyNotificationCountSuccess extends MyNotificationCountState {
  final int? serviceRequestCount;
  final int? newsCount;

  MyNotificationCountSuccess({this.newsCount, this.serviceRequestCount});

  MyNotificationCountSuccess copyWith(
          {int? serviceRequestCount, int? newsCount}) =>
      MyNotificationCountSuccess(
        newsCount: newsCount ?? this.newsCount,
        serviceRequestCount: serviceRequestCount ?? this.serviceRequestCount,
      );

  @override
  List<Object> get props => [];
}
