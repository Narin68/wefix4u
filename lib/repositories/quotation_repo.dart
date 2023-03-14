import 'dart:convert';
import 'dart:io';

import 'package:ocs_auth/ocs_auth.dart';

import '../globals.dart';
import '../modals/customer_request_service.dart';
import '../modals/quotation.dart';

class QuotRepo {
  Future<MResponse> list({
    int partner = 0,
    int pages = 1,
    int records = 10,
    int customerId = 0,
    String status = '',
    int id = 0,
  }) async {
    try {
      var _res =
          await fetchedData(ApisString.quotationList, withDb: true, data: {
        // "PartnerId": partner,
        "Pages": pages,
        "Records": records,
        // "RequestId": 10197,
        // "FromCost": -1,
        // "ToCost": -1,
        // "Id": id,
        "OrderBy": "Id",
        "OrderDir": "DESC",
        // "CustomerId": customerId,
        "Status": status,
        "IsWithDetail": true,
      });

      if (_res.statusCode == 401) {
        return MResponse(
          error: true,
          statusCode: ResponseStatus.unAuthorize,
          message: MessageKey.unAuthorize,
        );
      }

      if (_res.statusCode != 200) {
        return MResponse(
          error: true,
          statusCode: 1,
          message: jsonDecode(_res.body)['Message'],
        );
      }

      if (_res.statusCode != 200) throw Exception(_res.body);
      // print(_res.body);

      var json = jsonDecode(_res.body);
      List<MQuotationData> data = [];
      json.forEach((e) => data.add(MQuotationData.fromJson(e)));
      return MResponse(data: data);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      print("[Error] List ${e}");
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future<MResponse> updateQuot(MSubmitQuotData model) async {
    try {
      var _result = await fetchedData(
        ApisString.updateQuot,
        withDb: true,
        data: model.toJson(),
      );

      if (_result.statusCode == 401) {
        return MResponse(
          error: true,
          statusCode: ResponseStatus.unAuthorize,
          message: MessageKey.unAuthorize,
        );
      }
      if (_result.statusCode != 200) {
        return MResponse(
          error: true,
          statusCode: 1,
          message: jsonDecode(_result.body)['Message'],
        );
      }
      var json = jsonDecode(_result.body);
      var data = MQuotationData.fromJson(json);
      return MResponse(data: data);
    } on SocketException {
      return MResponse(
        error: true,
        statusCode: 2,
        message: MessageKey.noConnection,
      );
    } catch (e) {
      print("[Error Accept] $e");
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future<MResponse> detail({
    required int id,
  }) async {
    try {
      var _res = await fetchedData(
        ApisString.quotationRead + "?id=$id&withdetail=${true}",
        withDb: true,
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
          error: true,
          statusCode: 1,
          message: jsonDecode(_res.body)['Message'],
        );
      }

      if (_res.statusCode != 200) throw Exception(_res.body);
      var json = jsonDecode(_res.body);
      // json.forEach((e) => data.add(MItemQuotation.fromJson(e)));
      MQuotationData data = MQuotationData.fromJson(json);
      return MResponse(data: data);
    } on SocketException {
      return MResponse(
        error: true,
        statusCode: 2,
        message: MessageKey.noConnection,
      );
    } catch (e) {
      print("[Error] List ${e}");
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future<MResponse> reject({
    required int id,
  }) async {
    try {
      var _res = await fetchedData(
        ApisString.rejectQuot + "?quoteid=$id",
        withDb: true,
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
          error: true,
          statusCode: 1,
          message: jsonDecode(_res.body)['Message'],
        );
      }

      if (_res.statusCode != 200) throw Exception(_res.body);
      var json = jsonDecode(_res.body);
      List<MItemQuotation> data = [];
      json.forEach((e) => data.add(MItemQuotation.fromJson(e)));
      return MResponse(data: data);
    } on SocketException {
      return MResponse(
        error: true,
        statusCode: 2,
        message: MessageKey.noConnection,
      );
    } catch (e) {
      print("[Error] List ${e}");
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future<MResponse> approve({
    required int id,
  }) async {
    try {
      var _res = await fetchedData(
        ApisString.approveQuot + "?quoteid=$id",
        withDb: true,
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
          error: true,
          statusCode: 1,
          message: jsonDecode(_res.body)['Message'],
        );
      }

      if (_res.statusCode != 200) throw Exception(_res.body);
      var json = jsonDecode(_res.body);
      return MResponse(data: json);
    } on SocketException {
      return MResponse(
        error: true,
        statusCode: 2,
        message: MessageKey.noConnection,
      );
    } catch (e) {
      print("[Error] List ${e}");
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }
}
