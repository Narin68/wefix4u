import 'package:bloc/bloc.dart';

part 'my_notification_count_state.dart';

class MyNotificationCountCubit extends Cubit<MyNotificationCountState> {
  MyNotificationCountCubit() : super(MyNotificationCountInitial());

  Future init() async {
    emit(MyNotificationCountSuccess(serviceRequestCount: 0, newsCount: 0));
  }

  Future setServiceRequestCount(int count) async {
    var currState = state;
    if (currState is MyNotificationCountSuccess) {
      emit(currState.copyWith(
          serviceRequestCount: (currState.serviceRequestCount ?? 0) + count));
    }
  }

  Future decreaseRequest() async {
    var currState = state;
    if (currState is MyNotificationCountSuccess) {
      emit(currState.copyWith(
          serviceRequestCount: (currState.serviceRequestCount ?? 0) - 1));
    }
  }

  Future setNewsCount(int count) async {
    var currState = state;
    if (currState is MyNotificationCountSuccess) {
      emit(currState.copyWith(newsCount: (currState.newsCount ?? 0) + count));
    }
  }

  Future resetServiceRequestCount() async {
    var currState = state;
    if (currState is MyNotificationCountSuccess) {
      emit(currState.copyWith(serviceRequestCount: 0));
    }
  }

  Future resetNewsCount() async {
    var currState = state;
    if (currState is MyNotificationCountSuccess) {
      emit(currState.copyWith(newsCount: 0));
    }
  }
}
