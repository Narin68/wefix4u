import 'dart:convert';
import 'dart:io';

import 'package:ocs_auth/ocs_auth.dart';
import '/globals.dart';
import '/modals/partner_item.dart';

class PartnerItemRepo {
  Future<MResponse> list(
      {int? pages = 1, String? search = '', int record = 15}) async {
    try {
      var _result = await fetchedData(
        ApisString.listPartnerItem,
        withDb: true,
        data: {
          "Pages": "${pages}",
          "Records": "${record}",
          "OrderBy": "Id",
          "OrderDir": "DESC",
          "PartnerId": Model.partner.id,
          "Search": search,
          "FromPrice": -1,
          "ToPrice": -1,
        },
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
      if (_result.statusCode != 200) throw Exception();
      var jsonData = jsonDecode(_result.body);
      List<MPartnerServiceItemData> data = [];
      jsonData.forEach((e) => data.add(MPartnerServiceItemData.fromJson(e)));
      return MResponse(data: data);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future<MResponse> add(MPartnerServiceItem data) async {
    try {
      var _result = await fetchedData(
        ApisString.createPartnerItem,
        withDb: true,
        data: data.toJson(),
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
      if (_result.statusCode != 200) throw Exception();
      var jsonData = jsonDecode(_result.body);
      MPartnerServiceItemData dataResponse =
          MPartnerServiceItemData.fromJson(jsonData);
      return MResponse(data: dataResponse);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future<MResponse> update(MPartnerServiceItem model) async {
    try {
      var _result = await fetchedData(
        ApisString.updatePartnerItem,
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
      if (_result.statusCode != 200) throw Exception();
      var jsonData = jsonDecode(_result.body);
      MPartnerServiceItemData dataResponse =
          MPartnerServiceItemData.fromJson(jsonData);
      return MResponse(data: dataResponse);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future<MResponse> delete({int? id}) async {
    try {
      var _result = await fetchedData(
        ApisString.deletePartnerItem + '?id=$id',
        withDb: true,
        method: Methods.get,
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
      if (_result.statusCode != 200) throw Exception();
      return MResponse(data: []);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }
}
