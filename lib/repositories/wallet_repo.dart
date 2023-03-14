import 'dart:convert';
import 'dart:io';
import 'package:ocs_auth/ocs_auth.dart';
import 'package:wefix4utoday/modals/wallet_transaction.dart';
import '../signalr.dart';
import '/modals/wallet.dart';
import '../globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletRepo {
  Future<MResponse> getWallet() async {
    try {
      var _res = await fetchedData(ApisString.walletList, withDb: true, data: {
        "Owner": Model.userInfo.loginName,
        "OwnerType":
            Globals.userType.toLowerCase() == UserType.partner ? "P" : "C",
        "ToBalance": -1,
        "FromBalance": -1,
        "FromEarning": -1,
        "ToEarning": -1,
      });

      if (_res.statusCode == 401) {
        return MResponse(
          error: true,
          statusCode: ResponseStatus.unAuthorize,
          message: MessageKey.unAuthorize,
        );
      }

      if (_res.statusCode != 200) {
        String messageCode = jsonDecode(_res.body)["MessageCode"];
        return MResponse(
          message: jsonDecode(_res.body)["Message"],
          error: true,
          statusCode: int.parse(messageCode),
        );
      }
      var json = jsonDecode(_res.body);
      List<MWalletData> data = [];
      json.forEach((e) => data.add(MWalletData.fromJson(e)));
      return MResponse(data: data, error: false);
    } on SocketException {
      return MResponse(
        error: true,
        statusCode: 2,
        message: MessageKey.noConnection,
      );
    } catch (e) {
      print("[Error getWallet] $e");
      return MResponse(error: true, message: "Error occurred");
    }
  }

  Future<MResponse> createWallet(
      {String bankAccount = '',
      String bankName = '',
      String accountName = ''}) async {
    try {
      var _res =
          await fetchedData(ApisString.createWallet, withDb: true, data: {
        "Owner": Model.userInfo.loginName,
        "OwnerType":
            Globals.userType.toLowerCase() == UserType.partner ? "P" : "C",
        "BankAccount": bankAccount,
        "BankName": bankName,
        "BankAccountName": accountName,
        "Status": bankAccount.isNotEmpty ? "V" : "U",
        "OwnerId": Model.partner.id,
        "Balance": 0,
        "Earning": 0,
      });
      if (_res.statusCode == 401) {
        return MResponse(
          error: true,
          statusCode: ResponseStatus.unAuthorize,
          message: MessageKey.unAuthorize,
        );
      }

      if (_res.statusCode != 200) {
        String messageCode = jsonDecode(_res.body)["MessageCode"];
        return MResponse(
          message: jsonDecode(_res.body)["Message"],
          error: true,
          statusCode: int.parse(messageCode),
        );
      }
      var json = jsonDecode(_res.body);
      var data = MWalletData.fromJson(json);
      return MResponse(data: data, error: false);
    } on SocketException {
      return MResponse(
        error: true,
        statusCode: 2,
        message: MessageKey.noConnection,
      );
    } catch (e) {
      print("[Error createWallet] $e");
      return MResponse(error: true, message: "Error occurred");
    }
  }

  Future<MResponse> updateWallet(int id,
      {String bankAccount = '',
      String bankName = '',
      String accountName = ''}) async {
    try {
      var _res =
          await fetchedData(ApisString.updateWallet, withDb: true, data: {
        "Owner": Model.userInfo.loginName,
        "Id": id,
        "OwnerType":
            Globals.userType.toLowerCase() == UserType.partner ? "P" : "C",
        "BankAccount": bankAccount,
        "BankName": bankName,
        "BankAccountName": accountName,
        "Status": "V",
        "Balance": Model.userWallet?.balance,
        "Earning": Model.userWallet?.earning,
      });
      if (_res.statusCode == 401) {
        return MResponse(
          error: true,
          statusCode: ResponseStatus.unAuthorize,
          message: MessageKey.unAuthorize,
        );
      }

      if (_res.statusCode != 200) {
        String messageCode = jsonDecode(_res.body)["MessageCode"];
        return MResponse(
          message: jsonDecode(_res.body)["Message"],
          error: true,
          statusCode: int.parse(messageCode),
        );
      }
      var json = jsonDecode(_res.body);
      var data = MWalletData.fromJson(json);
      return MResponse(data: data, error: false);
    } on SocketException {
      return MResponse(
        error: true,
        statusCode: 2,
        message: MessageKey.noConnection,
      );
    } catch (e) {
      print("[Error updateWallet] $e");
      return MResponse(error: true, message: "Error occurred");
    }
  }

  Future<MResponse> getUserWallet() async {
    try {
      var _res = await fetchedData(
        ApisString.getUserWallet +
            "?ownerType=${Globals.userType.toLowerCase() == UserType.partner ? "P" : "C"}",
        withDb: true,
        method: Methods.get,
      );
      if (_res.statusCode == 401) {
        return MResponse(
          error: true,
          statusCode: ResponseStatus.unAuthorize,
          message: MessageKey.unAuthorize,
        );
      }
      if (_res.statusCode != 200) {
        String messageCode = jsonDecode(_res.body)["MessageCode"];
        return MResponse(
          message: jsonDecode(_res.body)["Message"],
          error: true,
          statusCode: int.parse(messageCode),
        );
      }
      var json = jsonDecode(_res.body);
      var data = MWalletData.fromJson(json);
      return MResponse(data: data, error: false);
    } on SocketException {
      return MResponse(
        error: true,
        statusCode: 2,
        message: MessageKey.noConnection,
      );
    } catch (e) {
      print("[Error getUserWallet] $e");
      return MResponse(error: true, message: "Error occurred");
    }
  }

  Future withdrawalRequest(
      {required double amount, required int walletId, String? desc}) async {
    try {
      var _res =
          await fetchedData(ApisString.withdrawalRequest, withDb: true, data: {
        "Amount": amount,
        "WalletId": walletId,
        "Description": desc,
      });

      print(_res.body);
      if (_res.statusCode == 401) {
        return MResponse(
          error: true,
          statusCode: ResponseStatus.unAuthorize,
          message: MessageKey.unAuthorize,
        );
      }
      if (_res.statusCode != 200) {
        String messageCode = jsonDecode(_res.body)["MessageCode"];
        return MResponse(
          message: jsonDecode(_res.body)["Message"],
          error: true,
          statusCode: int.parse(messageCode),
        );
      }
      var json = jsonDecode(_res.body);
      var data = MWalletTransactionData.fromJson(json[0]);
      return MResponse(data: data, error: false);
    } on SocketException {
      return MResponse(
        error: true,
        statusCode: 2,
        message: MessageKey.noConnection,
      );
    } catch (e) {
      print("[Error withdrawalRequest] $e");
      return MResponse(error: true, message: "Error occurred");
    }
  }

  Future withdrawalRequestList() async {
    if (Model.userWallet?.id == null)
      return MResponse(
        error: false,
        data: false,
      );

    try {
      var _res = await fetchedData(ApisString.withdrawalRequestList,
          withDb: true,
          data: {
            "WalletId": Model.userWallet?.id ?? 0,
            "Records": 1,
          });
      if (_res.statusCode == 401) {
        return MResponse(
          error: true,
          statusCode: ResponseStatus.unAuthorize,
          message: MessageKey.unAuthorize,
        );
      }
      if (_res.statusCode != 200) {
        String messageCode = jsonDecode(_res.body)["MessageCode"];
        return MResponse(
          message: jsonDecode(_res.body)["Message"],
          error: true,
          statusCode: int.parse(messageCode),
        );
      }
      var json = jsonDecode(_res.body);
      if (json.isEmpty) {
        return MResponse(
          error: false,
          data: "",
        );
      }
      var status = json[0]["Status"].toString();
      return MResponse(data: status, error: false);
    } on SocketException {
      return MResponse(
        error: true,
        statusCode: 2,
        message: MessageKey.noConnection,
      );
    } catch (e) {
      print("[Error withdrawalRequestList] $e");
      return MResponse(error: true, message: "Error occurred");
    }
  }

  static Future saveWalletToPref(MWalletData wallet) async {
    print("Save wallet to pref => ${wallet.toJson()}");
    final pref = await SharedPreferences.getInstance();
    pref.setString(Prefs.walletInfo, jsonEncode(wallet.toJson()));
  }

  static Future removeWalletPref() async {
    final pref = await SharedPreferences.getInstance();
    print('Remove wallet pref');
    pref.remove(Prefs.walletInfo);
  }

  static Future<MWalletData?> getWalletFromPref() async {
    final pref = await SharedPreferences.getInstance();

    final prefWallet = pref.getString(Prefs.walletInfo);

    if (prefWallet == null) return null;

    Map<String, dynamic> map = jsonDecode(prefWallet);
    MWalletData wallet = MWalletData.fromJson(map);
    print("get wallet from pref => ${wallet.toJson()}");

    return wallet;
  }
}
