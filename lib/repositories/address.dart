import 'dart:convert';
import 'dart:io';

import 'package:ocs_auth/ocs_auth.dart';
import '/modals/address.dart';
import '/modals/address_filter.dart';
import '../globals.dart';

class AddressRepo {
  Future list(MAddressFilter filter) async {
    try {
      var _result = await fetchedData(ApisString.addressList,
          withDb: true, data: filter.toJson());
      if (_result.statusCode == 401) {
        return MResponse(
          error: true,
          statusCode: ResponseStatus.unAuthorize,
          message: MessageKey.unAuthorize,
        );
      }
      var jsonData = jsonDecode(_result.body);
      List<MAddress> data = [];
      jsonData.forEach((e) => data.add(MAddress.fromJson(e)));

      return MResponse(data: data);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future getCoverage() async {
    try {
      var _result = await fetchedData(ApisString.coverageList,
          withDb: true, method: Methods.get);
      if (_result.statusCode == 401) {
        return MResponse(
          error: true,
          statusCode: ResponseStatus.unAuthorize,
          message: MessageKey.unAuthorize,
        );
      }
      var jsonData = jsonDecode(_result.body);
      List<MAddress> data = [];
      jsonData.forEach((e) => data.add(MAddress.fromJson(e)));
      data = data.where((e) => e.status?.toLowerCase() == "enabled").toList();
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
