import 'dart:convert';
import 'dart:io';
import 'package:ocs_auth/ocs_auth.dart';
import '../signalr.dart';
import '/globals.dart';
import '/modals/message.dart';

class MessageRepo {
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

  Future getCountUnseen(int requestId) async {
    try {
      var _res = await fetchedData(
        ApisString.countMessage + "?requestId=${requestId}",
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
      int unseen = json;
      return MResponse(data: unseen);
    } on SocketException {
      return MResponse(
        error: true,
        statusCode: 2,
        message: MessageKey.noConnection,
      );
    } catch (e) {
      print("[Error] List ${e}");
      return MResponse(
        error: true,
        statusCode: 3,
        message: MessageKey.errorOccurred,
      );
    }
  }

  Future getListMessage(
      {int? requestId, int? receiverId, int? page, int? records}) async {
    try {
      var _res = await fetchedData(
        ApisString.listMessage,
        withDb: true,
        data: {
          "ForUser": Model.userInfo.loginName, // Username
          "WithId": receiverId ?? -1, // Receiver partner  or customer id
          "RequestId": requestId ?? 0,
          "Records": records ?? 15,
          "Pages": page ?? 1,
          "ExceptDeleteType": "A",
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
      List<int> ids = [];
      List<MMessageData> data = [];
      json.forEach((x) => data.add(MMessageData.fromJson(x)));
      data.forEach((e) {
        if (e.status == "U" && Model.userInfo.loginName != e.sender)
          ids.add(e.id ?? 0);
      });

      data = data.reversed.toList();

      if (ids.isNotEmpty) await multiSeenMessage(ids);

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

  Future sendMessage(MSendMessage model) async {
    try {
      var _res = await fetchedData(
        ApisString.sendMessage,
        withDb: true,
        data: model.toJson(),
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
      var data = MMessageData.fromJson(json);
      _invokeSignalR(method: () {
        if (data.receivers?.isEmpty ?? false) {
          data = data.copyWith(receivers: ["COMPANY"]);
          var j = jsonEncode(data.toJson());
          sendSignalR(method: "chat", detail: j);
        } else {
          sendSignalR(method: "chat", detail: _res.body);
        }
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
        error: true,
        statusCode: 3,
        message: MessageKey.errorOccurred,
      );
    }
  }

  Future updateMessage(MSendMessage model) async {
    try {
      var _res = await fetchedData(
        ApisString.updateMessage,
        withDb: true,
        data: model.toJson(),
      );
      if (_res.statusCode == 401) {
        return MResponse(
          error: true,
          statusCode: ResponseStatus.unAuthorize,
          message: MessageKey.unAuthorize,
        );
      }

      // print("[Update Message] => ${_res.body}");

      if (_res.statusCode != 200) {
        return MResponse(
          error: true,
          statusCode: 1,
          message: jsonDecode(_res.body)['Message'],
        );
      }
      if (_res.statusCode != 200) throw Exception(_res.body);
      _invokeSignalR(method: () {
        sendSignalR(method: "updatechat", detail: _res.body);
      });
      var json = jsonDecode(_res.body);
      var data = MMessageData.fromJson(json);
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
        error: true,
        statusCode: 3,
        message: MessageKey.errorOccurred,
      );
    }
  }

  Future multiSeenMessage(List<int> ids) async {
    try {
      var _res = await fetchedData(
        ApisString.multiSeenMessage,
        withDb: true,
        data: {"Ids": ids},
      );
      if (_res.statusCode == 401) {
        return MResponse(
          error: true,
          statusCode: ResponseStatus.unAuthorize,
          message: MessageKey.unAuthorize,
        );
      }

      // print("[Multi Seen Message] => ${_res.body}");

      if (_res.statusCode != 200) {
        return MResponse(
          error: true,
          statusCode: 1,
          message: jsonDecode(_res.body)['Message'],
        );
      }
      if (_res.statusCode != 200) throw Exception(_res.body);
      _invokeSignalR(method: () {
        sendSignalR(method: "multipleseen", detail: _res.body);
      });
      var json = jsonDecode(_res.body);
      List<MMessageData> data = [];
      json["Data"].forEach((x) => data.add(MMessageData.fromJson(x)));
      return MResponse(data: data);
    } on SocketException {
      return MResponse(
        error: true,
        statusCode: 2,
        message: MessageKey.noConnection,
      );
    } catch (e) {
      print("[Error] Multi seen ${e}");
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future seenMessage(int id) async {
    try {
      var _res = await fetchedData(
        ApisString.seenMessage + "?msgId=${id}",
        withDb: true,
      );
      if (_res.statusCode == 401) {
        return MResponse(
          error: true,
          statusCode: ResponseStatus.unAuthorize,
          message: MessageKey.unAuthorize,
        );
      }

      // print("[Seen Message] => ${_res.body}");

      if (_res.statusCode != 200) {
        return MResponse(
          error: true,
          statusCode: 1,
          message: jsonDecode(_res.body)['Message'],
        );
      }
      if (_res.statusCode != 200) throw Exception(_res.body);
      _invokeSignalR(method: () {
        sendSignalR(method: "seen", detail: _res.body);
      });
      var json = jsonDecode(_res.body);
      MMessageData data = MMessageData.fromJson(json);
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

  Future deleteMessage(int id, String status) async {
    try {
      var _res = await fetchedData(
        ApisString.deleteMessage + "?msgId=${id}&delType=${status}",
        withDb: true,
      );
      if (_res.statusCode == 401) {
        return MResponse(
          error: true,
          statusCode: ResponseStatus.unAuthorize,
          message: MessageKey.unAuthorize,
        );
      }

      // print("[Delete Message] => ${_res.body}");

      if (_res.statusCode != 200) {
        return MResponse(
          error: true,
          statusCode: 1,
          message: jsonDecode(_res.body)['Message'],
        );
      }
      if (_res.statusCode != 200) throw Exception(_res.body);
      if (status == "A") {
        _invokeSignalR(method: () {
          sendSignalR(method: "updateChat", detail: _res.body);
        });
      }
      var json = jsonDecode(_res.body);
      MMessageData data = MMessageData.fromJson(json);
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

  Future getSender(int id, String username) async {
    try {
      var _res = await fetchedData(
        ApisString.getSender + "?msgId=${id}&username=${username}",
        withDb: true,
      );
      if (_res.statusCode == 401) {
        return MResponse(
          error: true,
          statusCode: ResponseStatus.unAuthorize,
          message: MessageKey.unAuthorize,
        );
      }

      // print("[Get Sender Message] => ${_res.body}");

      if (_res.statusCode != 200) {
        return MResponse(
          error: true,
          statusCode: 1,
          message: jsonDecode(_res.body)['Message'],
        );
      }
      if (_res.statusCode != 200) throw Exception(_res.body);
      var json = jsonDecode(_res.body);
      MReceiver data = MReceiver.fromJson(json);
      return MResponse(data: data);
    } on SocketException {
      return MResponse(
        error: true,
        statusCode: 2,
        message: MessageKey.noConnection,
      );
    } catch (e) {
      print("[Error] Get Sender ${e}");
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

// Future getReceiver(int id, String username) async {
//   try {
//     var _res = await _auth.postData(
//       ApisString.getReceiver + "?msgId=${id}&username=${username}",
//       withDb: true,
//     );
//     if (_res.statusCode == 401) {
//       return MResponse(
//         error: true,
//         statusCode: ResponseStatus.unAuthorize,
//         message: MessageKey.unAuthorize,
//       );
//     }
//
//     print("[Get Receiver Message] => ${_res.body}");
//
//     if (_res.statusCode != 200) {
//       return MResponse(
//         error: true,
//         statusCode: 1,
//         message: jsonDecode(_res.body)['Message'],
//       );
//     }
//     if (_res.statusCode != 200) throw Exception(_res.body);
//     var json = jsonDecode(_res.body);
//     MReceiver data = MReceiver.fromJson(json);
//     return MResponse(data: data);
//   } on SocketException {
//     return MResponse(
//       error: true,
//       statusCode: 2,
//       message: MessageKey.noConnection,
//     );
//   } catch (e) {
//     print("[Error] Get Receiver ${e}");
//     return MResponse(
//         error: true, statusCode: 3, message: MessageKey.errorOccurred);
//   }
// }
}
