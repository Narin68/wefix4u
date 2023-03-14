import 'dart:convert';
import 'dart:io';
import 'package:ocs_auth/ocs_auth.dart';
import '/modals/quotation.dart';
import '../globals.dart';
import '../modals/customer_request_service.dart';
import '../modals/request_log_list.dart';
import '../signalr.dart';

class ServiceRequestRepo {
  int _retrySignalR = 0;

  Future _invokeSignalR({required Function method}) async {
    if (await MySignalR.connected()) {
      _retrySignalR = 0;
      method();
    } else {
      _retrySignalR++;
      if (_retrySignalR == 3) return;
      return _invokeSignalR(method: method);
    }
  }

  Future<MResponse> list(MServiceRequestFilter filter) async {
    final newFilter = filter.copyWith(
      orderDir: "DESC",
      orderBy: "Id",
    );
    try {
      var _result = await fetchedData(
        ApisString.serviceRequestList,
        withDb: true,
        data: newFilter.toJson(),
      );

      // print("List => ${_result.body}");
      // print("List => ${_result.statusCode}");

      if (_result.statusCode == 401) {
        return MResponse(
          error: true,
          statusCode: ResponseStatus.unAuthorize,
          message: MessageKey.unAuthorize,
        );
      }
      if (_result.statusCode != 200) throw Exception();
      var jsonData = jsonDecode(_result.body);
      List<MRequestService> data = [];
      jsonData.forEach((e) {
        if (e != null) data.add(MRequestService.fromJson(e));
      });
      return MResponse(data: data);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      print("[Error Request List]  => $e");

      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future<MResponse> getDetail(int id) async {
    try {
      var _result = await fetchedData(
        ApisString.serviceRequestDetail + "?id=${id}",
        withDb: true,
        method: Methods.get,
      );

      // print(_result.body);

      // print(ApisString.serviceRequestDetail +
      //     "?id=${id}&type=${Globals.userType}");

      if (_result.statusCode != 200) {
        return MResponse(
          error: true,
          statusCode: 1,
          message: jsonDecode(_result.body)['Message'],
        );
      }
      if (_result.statusCode == 401) {
        return MResponse(
          error: true,
          statusCode: ResponseStatus.unAuthorize,
          message: MessageKey.unAuthorize,
        );
      }
      // print(_result.body);
      if (_result.statusCode != 200) throw Exception();
      var jsonData = jsonDecode(_result.body);

      // print(jsonEncode(jsonData["Partners"]));

      var data = MServiceRequestDetail.fromJson(jsonData);
      return MResponse(data: data);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      print("Error == $e");
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future<MResponse> giveUp(int requestId) async {
    try {
      var _result = await fetchedData(
        ApisString.giveUpCustomerRequest + "?RequestId=$requestId",
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
        print("Error get detail == ${_result.body}");

        return MResponse(
          error: true,
          statusCode: 1,
          message: jsonDecode(_result.body)['Message'],
        );
      }
      if (_result.statusCode != 200) throw Exception();
      return MResponse(data: _result.body);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future<MResponse> heading(
    int requestId,
    String? arrivalTime, {
    String? lateReason,
  }) async {
    try {
      // print({
      //   "Id": requestId,
      //   "ArrivalTime": arrivalTime,
      //   "LateReason": lateReason,
      // });
      var _result =
          await fetchedData(ApisString.headingService, withDb: true, data: {
        "Id": requestId,
        "ArrivalTime": arrivalTime,
        "LateReason": lateReason,
      });

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
      return MResponse(data: _result.body);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future<MResponse> fixing(int requestId) async {
    try {
      var _result = await fetchedData(
        ApisString.fixingService + "?RequestId=$requestId",
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
      return MResponse(data: _result.body);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future<MResponse> closeService(int requestId) async {
    try {
      var _result = await fetchedData(
        ApisString.closeService + "?RequestId=$requestId",
        withDb: true,
        method: Methods.get,
      );
      print(_result.body);
      if (_result.statusCode == 401) {
        return MResponse(
          error: true,
          statusCode: ResponseStatus.unAuthorize,
          message: MessageKey.unAuthorize,
        );
      }
      if (_result.statusCode != 200) {
        print("[Error Accept] ${_result.body}");
        return MResponse(
          error: true,
          statusCode: 1,
          message: jsonDecode(_result.body)['Message'],
        );
      }
      if (_result.statusCode != 200) throw Exception();
      _invokeSignalR(method: () {
        sendSignalR(method: "close", detail: _result.body);
      });
      return MResponse(data: _result.body);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future<MResponse> feedbackRequest(
      {int? requestId, double? rating, String? comment}) async {
    try {
      var _result = await fetchedData(
        ApisString.feedbackRequest,
        data: {
          "RequestId": "$requestId",
          "Rating": "$rating",
          "Comment": "$comment",
        },
        withDb: true,
      );

      print(_result.body);

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
      _invokeSignalR(method: () {
        sendSignalR(method: "feedback", detail: _result.body);
      });
      return MResponse(data: _result.body);
    } on SocketException {
      return MResponse(
        error: true,
        statusCode: 2,
        message: MessageKey.noConnection,
      );
    } catch (e) {
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future<MResponse> SubmitQuot(MSubmitQuotData model) async {
    try {
      // print(jsonEncode(model.toJson()));
      var _result = await fetchedData(ApisString.createQuotation,
          data: model.toJson(), withDb: true);
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
      // _invokeSignalR(method: () {
      //   sendSignalR(method: "submitQuotation", detail: _result.body);
      // });
      return MResponse(data: _result.body);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      print("[Error Accept] $e");
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future<MResponse> partnerAccept(int requestId) async {
    try {
      var _result = await fetchedData(
        ApisString.acceptCustomerRequest + "?requestId=$requestId",
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
        print("[Error Accept] ${_result.body}");

        return MResponse(
          error: true,
          statusCode: 1,
          message: jsonDecode(_result.body)['Message'],
        );
      }
      if (_result.statusCode != 200) throw Exception();
      // _invokeSignalR(method: () {
      //   sendSignalR(method: "accept", detail: _result.body);
      // });

      return MResponse(data: _result.body);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      print("[Error Accept] $e");
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future<MResponse> cancelRequest(int requestId) async {
    try {
      var _result = await fetchedData(
        ApisString.cancelServiceRequest + "?requestId=$requestId",
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
      return MResponse(data: _result.body);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      print("[Error Accept] $e");
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future<MResponse> log(String code) async {
    try {
      var _result = await fetchedData(
        ApisString.requestLogList + "?code=$code",
        withDb: true,
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
      List<MRequestLogList> data = [];
      jsonData.forEach((e) => data.add(MRequestLogList.fromJson(e)));

      return MResponse(data: data);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      print("[Error] $e");
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }
}
