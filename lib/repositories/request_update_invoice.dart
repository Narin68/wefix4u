import 'dart:convert';
import 'dart:io';
import 'package:ocs_auth/ocs_auth.dart';
import '../globals.dart';
import '../modals/requestUpdateQuot.dart';

class RequestUpdateQuot {
  Future request(int quotId) async {
    try {
      var _result = await fetchedData(
        ApisString.requestUpdateInvoice,
        withDb: true,
        data: {
          "QuotationId": quotId,
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
        print("Request update error ${jsonDecode(_result.body)}");
        return MResponse(
          error: true,
          statusCode: 1,
          message: jsonDecode(_result.body)['Message'],
        );
      }
      var jsonData = jsonDecode(_result.body);

      var data = MRequestUpdateQuot.fromJson(jsonData);

      return MResponse(data: data);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      print("[Error request update invoice] $e");
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future get(int quotId) async {
    try {
      var _result = await fetchedData(
        ApisString.getInvoiceUpdateRequest,
        withDb: true,
        data: {
          "QuotationId": quotId,
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
      List<MRequestUpdateQuot> data = [];
      jsonData.forEach((x) => data.add(MRequestUpdateQuot.fromJson(x)));

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

  Future reject(int id) async {
    try {
      var _result = await fetchedData(
        ApisString.rejectQuotUpdate + "?Id=$id",
        withDb: true,
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
      var data = MRequestUpdateQuot.fromJson(jsonData);

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

  Future allow(int id) async {
    try {
      var _result = await fetchedData(
        ApisString.allowQuotUpdate + "?Id=$id",
        withDb: true,
      );

      if (_result.statusCode == 401) {
        return MResponse(
          error: true,
          statusCode: ResponseStatus.unAuthorize,
          message: MessageKey.unAuthorize,
        );
      }
      if (_result.statusCode != 200) {
        print("Error Allow ${_result.body}");
        return MResponse(
          error: true,
          statusCode: 1,
          message: jsonDecode(_result.body)['Message'],
        );
      }

      var jsonData = jsonDecode(_result.body);
      var data = MRequestUpdateQuot.fromJson(jsonData);

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

  Future approve(int id) async {
    try {
      var _result = await fetchedData(
        ApisString.approveQuotUpdate + "?Id=$id",
        withDb: true,
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
      var data = MRequestUpdateQuot.fromJson(jsonData);
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

  Future update(MSubmitUpdateQuot model) async {
    try {
      var _result = await fetchedData(
        ApisString.updateInvoice,
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
        print("Success Discount code ${jsonDecode(_result.body)}");
        return MResponse(
          error: true,
          statusCode: 1,
          message: jsonDecode(_result.body)['Message'],
        );
      }

      var jsonData = jsonDecode(_result.body);
      var data = MRequestUpdateQuot.fromJson(jsonData);
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
}
