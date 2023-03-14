import 'dart:convert';
import 'dart:io';
import 'package:ocs_auth/ocs_auth.dart';
import '/globals.dart';
import '/modals/file.dart';
import 'dart:async';

class FileRepo {
  Future<MResponse> uploadFile(MFile file) async {
    try {
      var _res = await fetchedData(
        ApisString.uploadFile,
        withDb: true,
        data: file.toJson(),
      );
      if (_res.statusCode == 401) {
        return MResponse(
          error: true,
          statusCode: ResponseStatus.unAuthorize,
          message: MessageKey.unAuthorize,
        );
      }
      if (_res.statusCode != 200) {
        print("[Error upload file] ${_res.body}");
        return MResponse(
          error: true,
          statusCode: 1,
          message: jsonDecode(_res.body)['Message'],
        );
      }
      if (_res.statusCode != 200) throw Exception(_res.body);
      MFileUpload data = MFileUpload.fromJson(jsonDecode(_res.body)['File']);
      return MResponse(data: data);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future<MResponse> saveFileToDb(MSaveFileToDb file) async {
    try {
      var _res = await fetchedData(
        ApisString.saveFileToDb,
        withDb: true,
        data: file.toJson(),
      );
      if (_res.statusCode == 401) {
        return MResponse(
          error: true,
          statusCode: ResponseStatus.unAuthorize,
          message: MessageKey.unAuthorize,
        );
      }
      if (_res.statusCode != 200) {
        print("[Error save file to db] ${_res.body}");
        return MResponse(
          error: true,
          statusCode: 1,
          message: jsonDecode(_res.body)['Message'],
        );
      }
      if (_res.statusCode != 200) throw Exception(_res.body);
      return MResponse(data: []);
    } on SocketException {
      return MResponse(
        error: true,
        statusCode: 2,
        message: MessageKey.noConnection,
      );
    } catch (e) {
      return MResponse(
        error: true,
        statusCode: 3,
        message: MessageKey.errorOccurred,
      );
    }
  }

  Future<MResponse> uploadVideo({
    required String url,
    int? refId,
    String extension = 'mp4',
    String refType = "USE_SERVICE_REQ",
    String? name = '',
  }) async {
    try {
      var _res = await fetchedData(
        ApisString.uploadVideo,
        withDb: true,
        data: {
          "FileType": "Video",
          "Extension": "$extension",
          "RefId": refId,
          "Name": "$name",
          "RefType": "$refType",
          "Url": "$url",
        },
      );

      if (_res.statusCode != 200) throw Exception(_res.body);

      return MResponse(data: []);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      print("Error => $e");
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Map<String, String> requestHeader({String? token}) => {
        'Content-Type': 'application/json',
        'Authorization': token ?? AuthConfig.externalToken,
        'oc_device_id': AuthConfig.deviceId,
        'oc_database': AuthConfig.database,
      };
}
