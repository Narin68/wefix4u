import 'dart:convert';
import 'dart:io';
import 'package:ocs_auth/ocs_auth.dart';
import '/globals.dart';
import '../modals/settlement_rule.dart';

class SettlementRuleRepo {
  Future<MResponse> getList(MSettlementFilter filter) async {
    filter = filter.copyWith(
      refId: 0,
      fromPercentage: -1,
      toPercentage: -1,
      fromWalletDuration: -1,
      toWalletDuration: -1,
      fromFee: -1,
      toFee: -1,
      ruleType: "c",
      refType: "p",
    );
    try {
      var _res = await fetchedData(
        ApisString.settlementList,
        withDb: true,
        data: filter.toJson(),
      );

      if (_res.statusCode == 401) {
        return MResponse(
          error: true,
          statusCode: ResponseStatus.unAuthorize,
          message: MessageKey.unAuthorize,
        );
      }

      if (_res.statusCode != 200) {
        return MResponse(
          message: jsonDecode(_res.body)["Message"],
          error: true,
          statusCode: jsonDecode(_res.body)["MessageCode"],
        );
      }

      var json = jsonDecode(_res.body);
      List<MSettlementData> _data = [];
      json.forEach((x) => _data.add(MSettlementData.fromJson(x)));
      return MResponse(data: _data);
    } on SocketException {
      return MResponse(
        error: true,
        statusCode: 2,
        message: MessageKey.noConnection,
      );
    } catch (e) {
      return MResponse(error: true, message: "Error occurred");
    }
  }

  Future<MResponse> getByRefId({required int refId, String? refType}) async {
    try {
      String type = refType ?? Globals.userType;

      var _res = await fetchedData(
        "${ApisString.readSettlementRefId}?refId=$refId&refType=${type.toLowerCase() == UserType.partner ? "P" : "C"}",
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
      List<MSettlementData> _list = [];

      json.forEach((x) => _list.add(MSettlementData.fromJson(x)));
      _list = _list.where((e) => e.ruleType?.toLowerCase() == "c").toList();
      if (_list.isEmpty)
        return MResponse(
          message: "Data not found!",
          error: true,
          statusCode: 50503,
        );

      return MResponse(data: _list.first, error: false);
    } on SocketException {
      return MResponse(
        error: true,
        statusCode: 2,
        message: MessageKey.noConnection,
      );
    } catch (e) {
      print("[Error getByRefId] $e");
      return MResponse(error: true, message: "Error occurred");
    }
  }
}
