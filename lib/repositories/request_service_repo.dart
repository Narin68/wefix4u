import 'dart:convert';
import 'dart:io';

import 'package:ocs_auth/ocs_auth.dart';
import '/modals/address.dart';
import '../modals/customer_request_service.dart';
import '../globals.dart';

class RequestServiceRepo {
  Future<MResponse> requestService(MServiceUsage model) async {
    try {
      model = model.copyWith(districtId: 0);
      var _res = await fetchedData('${ApisString.requestService}',
          withDb: true, data: model.toJson());
      if (_res.statusCode == 401) {
        return MResponse(
          error: true,
          statusCode: ResponseStatus.unAuthorize,
          message: MessageKey.unAuthorize,
        );
      }
      // print("New request service data => ${_res.body}");

      if (_res.statusCode != 200) {
        return MResponse(
          error: true,
          statusCode: 1,
          message: jsonDecode(_res.body)['Message'],
        );
      }

      if (_res.statusCode != 200) throw Exception(_res.body);
      var json = jsonDecode(_res.body);
      // invokeSignalR(method: () {
      //   sendSignalR(method: "requestService", detail: _res.body);
      // });

      List<MRequestService> data = [];
      json.forEach((x) => data.add(MRequestService.fromJson(x)));

      return MResponse(data: data);
    } on SocketException {
      return MResponse(
        error: true,
        statusCode: 2,
        message: MessageKey.noConnection,
      );
    } catch (e) {
      print("[Error request service] ${e}");
      return MResponse(error: true, message: MessageKey.errorOccurred);
    }
  }

  Future<MResponse> checkAvailability(
    List<int> services,
    String targetLocation,
  ) async {
    try {
      var result = await fetchedData('${ApisString.checkAvailabilityService}',
          withDb: true,
          data: {
            "ServiceIds": services,
            "TargetLocation": targetLocation,
          });
      if (result.statusCode == 400)
        return MResponse(
          error: true,
          statusCode: 400,
          message: jsonDecode(result.body)['Detail'],
        );
      if (result.statusCode != 200) {
        return MResponse(
          error: true,
          statusCode: 1,
          message: jsonDecode(result.body)['Message'],
        );
      }
      if (result.statusCode == 401) {
        return MResponse(
          error: true,
          statusCode: ResponseStatus.unAuthorize,
          message: MessageKey.unAuthorize,
        );
      }
      if (result.statusCode != 200) throw Exception(result.body);

      var json = result.body;

      if (json == false || json.toString() == "false") {
        return MResponse(
          error: true,
          statusCode: 01,
          message: 'Not available location',
        );
      }

      return MResponse(data: json);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      print("[Error Check Available] ${e}");
      return MResponse(error: true, message: MessageKey.errorOccurred);
    }
  }

  Future<MResponse> getProvinceId(
    String targetLocation,
  ) async {
    try {
      var result = await fetchedData(
          '${ApisString.getProvinceId + targetLocation}',
          withDb: true,
          method: Methods.get);
      if (result.statusCode == 400)
        return MResponse(
          error: true,
          statusCode: 400,
          message: jsonDecode(result.body)['Detail'],
        );
      if (result.statusCode != 200) {
        return MResponse(
          error: true,
          statusCode: 1,
          message: jsonDecode(result.body)['Message'],
        );
      }
      if (result.statusCode == 401) {
        return MResponse(
          error: true,
          statusCode: ResponseStatus.unAuthorize,
          message: MessageKey.unAuthorize,
        );
      }
      if (result.statusCode != 200) throw Exception(result.body);
      var json = jsonDecode(result.body);
      List<MAddress> data = [];
      json.forEach((x) => data.add(MAddress.fromJson(x)));
      return MResponse(data: data);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      print("[Error Check Available] ${e}");
      return MResponse(error: true, message: MessageKey.errorOccurred);
    }
  }
}
