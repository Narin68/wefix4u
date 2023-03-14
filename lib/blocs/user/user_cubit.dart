import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ocs_auth/models/user.dart';
import 'package:ocs_auth/ocs_auth.dart' as auth;
import 'package:ocs_auth/repos/user.dart';
import '/globals.dart';
import '/modals/customer.dart';
import '/repositories/customer.dart';

part 'user_state.dart';

class MyUserCubit extends Cubit<MyUserState> {
  MyUserCubit() : super(MyUserInitial());

  final _auth = auth.OCSAuth();
  var _repo = CustomerRepo();

  Future get({
    bool getCustomer = true,
    bool loadingWidget = true,
    MUserInfo? info,
  }) async {
    emit(MyUserLoading(isLoad: loadingWidget));
    if (info != null) {
      await Future.delayed(Duration(milliseconds: 100));
      emit(MyUserSuccess(user: info, customer: Model.customer));
      return;
    }
    final result = await _auth.userInfo();

    if (!result.error) {
      Model.userInfo = result.data!;
      if (result.data != null) UserInfoRepo.saveToPref(result.data!);
      if (getCustomer) {
        var cusResp =
            await _repo.list(MMyCustomerFilter(code: Model.userInfo.loginName));
        if (!cusResp.error) {
          Model.customer = cusResp.data.length < 1
              ? MMyCustomer()
              : (cusResp.data ?? []).first;
          CustomerRepo.saveCusToPref(Model.customer);
        }
      }
      emit(MyUserSuccess(user: Model.userInfo, customer: Model.customer));
    } else {
      if (Model.userInfo.loginName != null && Model.customer.id != null) {
        emit(MyUserSuccess(user: Model.userInfo, customer: Model.customer));
        return;
      }
      emit(MyUserFailure(
          message: result.message, statusCode: result.statusCode));
    }
  }

  Future update({MUserInfo? user, MMyCustomer? customer}) async {
    var currState = state;
    if (currState is MyUserSuccess) {
      if (user != null) UserInfoRepo.saveToPref(user);
      if (customer != null) CustomerRepo.saveCusToPref(customer);
      emit(currState.copyWith(user: user, customer: customer));
    }
  }
}
