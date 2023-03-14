import 'dart:convert';
import 'dart:io';

import 'package:ocs_auth/ocs_auth.dart';

import '../globals.dart';
import '../modals/service.dart';

class ServiceRepo {
  Future<MResponse> list(
      {int? pages = 1, String? search = '', int serviceCateId = 0}) async {
    try {
      var _result = await fetchedData(
        ApisString.serviceList,
        withDb: true,
        data: {
          "Pages": "${pages}",
          "Records": "15",
          "OrderBy": "Id",
          "OrderDir": "DESC",
          "ServiceCateId": serviceCateId,
          "Search": search,
          "Status": "ENABLED",
        },
        isGlobal: true,
      );

      if (_result.statusCode == 401) {
        return MResponse(
          error: true,
          statusCode: ResponseStatus.unAuthorize,
          message: MessageKey.unAuthorize,
        );
      }
      if (_result.statusCode != 200) throw Exception();
      var jsonData = jsonDecode(_result.body);
      List<MService> data = [];
      jsonData.forEach((e) => data.add(MService.fromJson(e)));
      return MResponse(data: data);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }
}
