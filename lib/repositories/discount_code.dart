import 'dart:convert';
import 'dart:io';
import 'package:ocs_auth/ocs_auth.dart';
import '../globals.dart';
import '../modals/discount.dart';

class DiscountRepo {
  Future create({double? discount = 10, String? discountBy = "P"}) async {
    try {
      var _result = await fetchedData(
        ApisString.createDiscountCode,
        withDb: true,
        data: {
          "Discount": discount,
          "DiscountBy": discountBy,
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
      var jsonData = jsonDecode(_result.body);
      print(jsonData);

      return MResponse(data: {});
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      print("[Error Create discount code] $e");
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future list(String code) async {
    try {
      var _result = await fetchedData(
        ApisString.getDiscountCode,
        withDb: true,
        data: {
          "Code": code,
          "Status": "T",
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
      var jsonData = jsonDecode(_result.body);
      List<MDiscountCode> data = [];
      jsonData.forEach((v) => data.add(MDiscountCode.fromJson(v)));

      return MResponse(data: data);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      print("[Error get discount code] $e");
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future update(MDiscountCode data) async {
    try {
      var _result = await fetchedData(
        ApisString.updateDiscountCode,
        withDb: true,
        data: {
          "Id": data.id,
          "RefId": data.refId,
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
        print("Success Discount code ${jsonDecode(_result.body)['Message']}");
        return MResponse(
          error: true,
          statusCode: 1,
          message: jsonDecode(_result.body)['Message'],
        );
      }

      print("Success Discount code ${_result.body}");

      return MResponse(data: []);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      print("[Error get discount code] $e");
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }
}
