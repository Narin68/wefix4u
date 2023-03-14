import 'dart:convert';
import 'dart:io';
import 'package:ocs_auth/ocs_auth.dart';
import '/modals/invoice.dart';
import '../globals.dart';

class InvoiceRepo {
  Future<MResponse> list({
    int partner = 0,
    int pages = 1,
    int records = 10,
    int customerId = 0,
    String status = '',
    bool withDetail = false,
    int requestId = 0,
  }) async {
    try {
      var _res = await fetchedData(
        ApisString.invoiceList,
        withDb: true,
        data: {
          "PartnerId": partner,
          "Pages": pages,
          "Records": records,
          "OrderBy": "Id",
          "OrderDir": "DESC",
          "CustomerId": customerId,
          "RequestId": requestId,
          "Status": status,
          "IsWithDetail": withDetail,
        },
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
      List<MInvoiceData> data = [];
      json.forEach((e) {
        data.add(MInvoiceData.fromJson(e));
      });
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

  Future<MResponse> detail({
    required int id,
  }) async {
    try {
      var _res = await fetchedData(
        ApisString.invoiceDetail + "?id=$id",
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
        return MResponse(
          error: true,
          statusCode: 1,
          message: jsonDecode(_res.body)['Message'],
        );
      }

      if (_res.statusCode != 200) throw Exception(_res.body);
      var json = jsonDecode(_res.body);
      MInvoiceData data = MInvoiceData.fromJson(json);
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
}
