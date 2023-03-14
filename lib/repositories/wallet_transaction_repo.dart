import 'dart:convert';
import 'dart:io';
import 'package:ocs_auth/ocs_auth.dart';
import '../signalr.dart';
import '/modals/wallet_transaction.dart';
import '../globals.dart';

class WalletTransactionRepo {
  Future<MResponse> walletTransactionList(int walletId,
      {int records = 10, int pages = 1}) async {
    List<MWalletTransactionData> data = [];
    if (walletId == 0)
      return MResponse(
        error: false,
        data: data,
      );
    try {
      var _res = await fetchedData(ApisString.walletTransactionList,
          withDb: true,
          data: {
            "Owner": Model.userInfo.loginName,
            "RefId": "",
            "WalletId": walletId,
            "TransactionType": "",
            "Pages": pages,
            "Records": records,
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
      json.forEach((e) => data.add(MWalletTransactionData.fromJson(e)));
      return MResponse(data: data, error: false);
    } on SocketException {
      return MResponse(
        error: true,
        statusCode: 2,
        message: MessageKey.noConnection,
      );
    } catch (e) {
      print("[Error walletTransactionList] $e");
      return MResponse(error: true, message: "Error occurred");
    }
  }
}
