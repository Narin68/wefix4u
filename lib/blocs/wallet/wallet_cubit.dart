import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:ocs_auth/models/response.dart';
import '/globals.dart';
import '/modals/wallet.dart';
import '/repositories/wallet_repo.dart';

part 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  WalletCubit() : super(WalletInitial());

  var _repo = WalletRepo();

  Future createWallet({String? bankAccount, String? bankName}) async {
    emit(WalletLoading());
    var _res = await _repo.createWallet(
        bankName: bankName ?? "", bankAccount: bankAccount ?? "");
    if (!_res.error) {
      Model.userWallet = _res.data;
      await WalletRepo.saveWalletToPref(_res.data);
      emit(WalletSuccess(data: _res.data));
    } else
      emit(WalletFailure(statusCode: _res.statusCode, message: _res.message));
  }

  Future updateWallet(MWalletData data, {String? status}) async {
    Model.userWallet = data;
    await WalletRepo.saveWalletToPref(data);
    emit(WalletSuccess(data: data, withdrawStatus: status ?? ""));
  }

  Future updateBalanceAndEarning(
      {double? earning, double? balance, String? status}) async {
    var s = state;
    if (s is WalletSuccess) {
      var data = s.data?.copyWith(earning: earning, balance: balance);
      Model.userWallet = data;
      if (Model.userWallet != null)
        await WalletRepo.saveWalletToPref(Model.userWallet!);
      emit(WalletSuccess(data: data, withdrawStatus: status ?? ""));
    }
  }

  Future addWallet(MWalletData data) async {
    await WalletRepo.saveWalletToPref(data);
    emit(WalletSuccess(data: data));
  }

  Future getByRef({bool init = false}) async {
    emit(WalletLoading());

    if (!init) {
      MWalletData? wallet = await WalletRepo.getWalletFromPref();

      if (wallet != null) {
        Model.userWallet = wallet;
        emit(WalletSuccess(data: wallet));
        return;
      }
    }

    var _res = await _repo.getUserWallet();
    if (!_res.error) {
      Model.userWallet = _res.data;
      MResponse _result = await _repo.withdrawalRequestList();
      if (!_result.error) {
        await WalletRepo.saveWalletToPref(_res.data);
        emit(WalletSuccess(data: _res.data, withdrawStatus: _result.data));
        return;
      }

      emit(WalletSuccess(data: _res.data));
    } else
      emit(WalletFailure(statusCode: _res.statusCode, message: _res.message));
  }
}
