import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ocs_auth/ocs_auth.dart';
import '/modals/business.dart';

import '../signalr.dart';
import '/modals/partner.dart';
import '../globals.dart';
import '../modals/apply_partner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PartnerRepo {
  Future<MResponse> applyPartner(MApplyPartner model) async {
    try {
      var _res = await fetchedData(ApisString.applyPartner,
          withDb: true, data: model.toJson());

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

      invokeSignalR(
        method: () {
          MySignalR.partnership(_res.body);
        },
        retrySignalR: 0,
      );
      var jsonData = jsonDecode(_res.body);
      MPartner data = MPartner.fromJson(jsonData);
      return MResponse(data: data);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future<MResponse> getPartnerRequest(int? cusId) async {
    try {
      var _res = await fetchedData(
        ApisString.partnerRequest,
        withDb: true,
        data: {
          "Records": 10,
          "Pages": 1,
          "CustomerId": cusId,
          "FromDate": "",
          "ToDate": "",
          "Status": ""
        },
      );
      if (_res.statusCode == 401) {
        return MResponse(
          error: true,
          statusCode: ResponseStatus.unAuthorize,
          message: MessageKey.unAuthorize,
        );
      }
      if (_res.statusCode != 200) throw Exception(_res.body);
      List<MPartnerRequest> data = [];
      var jsonData = jsonDecode(_res.body);

      jsonData.forEach((e) => data.add(MPartnerRequest.fromJson(e)));
      return MResponse(data: data);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future<MResponse> getRequestPartnerDetail(int? id) async {
    try {
      var _res = await fetchedData(
        ApisString.partnerRequestDetail + "?id=$id",
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
      if (_res.statusCode != 200) throw Exception(_res.body);
      var json = jsonDecode(_res.body);
      MPartnerRequestDetail data = MPartnerRequestDetail.fromJson(json);

      return MResponse(data: data);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      print("[Error detail] ${e}");
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future<MResponse> getPartnerDetail(int? id) async {
    try {
      var _res = await fetchedData(
        ApisString.partnerRead + "?id=$id",
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
      if (_res.statusCode != 200) throw Exception(_res.body);
      var json = jsonDecode(_res.body);

      MPartnerRequestDetail data = MPartnerRequestDetail.fromJson(json);
      return MResponse(data: data);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      print("[Error detail] ${e}");
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future<MResponse> getPartner(int? id, {String? username}) async {
    try {
      var _res = await fetchedData(
        ApisString.partnerList,
        withDb: true,
        data: {
          "Code": "",
          "Id": 0,
          "CustomerId": id,
          "CoverageId": 0,
          "ServiceId": 0,
          "Records": 10,
          "Search": "",
          "Pages": 1,
          "OrderBy": "",
          "OrderDir": "",
          "Database": "",
          "Username": username,
        },
      );

      if (_res.statusCode == 401) {
        return MResponse(
          error: true,
          statusCode: ResponseStatus.unAuthorize,
          message: MessageKey.unAuthorize,
        );
      }

      if (_res.statusCode != 200) throw Exception(_res.body);
      var json = jsonDecode(_res.body);
      List<MPartner> data = [];
      json.forEach((e) => data.add(MPartner.fromJson(e)));
      return MResponse(data: data);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      print("[Error] ${e}");
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future<MResponse> update(
      {required String name,
      required String nameEnglish,
      required String phone1,
      required String phone2,
      required String email,
      required int experience,
      required String latlong,
      required String address,
      Uint8List? placeImage,
      required}) async {
    try {
      var _res = await fetchedData(
        ApisString.updatePartner,
        withDb: true,
        data: {
          "UpdateCoverage": false,
          "UpdateService": false,
          "BusinessName": name,
          "BusinessNameEnglish": nameEnglish,
          "BusinessPhone1": phone1,
          "BusinessPhone2": phone2,
          "BusinessEmail": email,
          "BusinessAddress": address,
          "BusinessAddressEnglish": address,
          "LatLong": latlong,
          "RefId": "",
          "RefCode": Model.userInfo.loginName,
          "Status": "APPROVE",
          "Code": "",
          "ForUpdate": true,
          "Id": Model.partner.id,
          "PlaceImage": placeImage ?? [],
          "WorkExperience": experience,
        },
      );

      if (_res.statusCode == 401) {
        return MResponse(
          error: true,
          statusCode: ResponseStatus.unAuthorize,
          message: MessageKey.unAuthorize,
        );
      }

      if (_res.statusCode != 200) throw Exception(_res.body);
      var json = jsonDecode(_res.body);
      return MResponse(data: json);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      print("[Error] ${e}");
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future updateCovAndServ({
    List<int>? addedServices,
    List<int>? addedCoverages,
    List<int>? removedServices,
    List<int>? removedCoverages,
  }) async {
    try {
      var _res = await fetchedData(
        ApisString.updateCovAndServ,
        withDb: true,
        data: {
          "AddedServices": addedServices ?? [],
          "RemovedServices": removedServices ?? [],
          "AddedCoverages": addedCoverages ?? [],
          "RemovedCoverages": removedCoverages ?? [],
          "Partner": Model.partner.id,
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
      invokeSignalR(method: () {
        MySignalR.updateSvAndCv(jsonEncode(jsonDecode(_res.body)["Detail"]));
      });
      return MResponse(data: []);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      print("[Error] ${e}");
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future updateCovAndServList(
      {required int refId, int pages = 1, records = 15}) async {
    try {
      var _res = await fetchedData(
        ApisString.updateCovAndServList,
        withDb: true,
        data: {
          "RefId": refId,
          "Pages": pages,
          "Records": records,
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
      List<MBusinessRequestList> data = [];

      json.forEach((e) => data.add(MBusinessRequestList.fromJson(e)));

      return MResponse(data: data);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      print("[Error] ${e}");
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future<MResponse> updateCovAndServDetail(int id) async {
    try {
      var _res = await fetchedData(
        ApisString.updateCovAndServDetail + "?id=$id",
        withDb: true,
      );

      if (_res.statusCode != 200) {
        return MResponse(
            error: true,
            statusCode: _res.statusCode,
            message: jsonDecode(_res.body)['Message']);
      }
      var json = jsonDecode(_res.body);

      MBusinessRequestDetail data = MBusinessRequestDetail.fromMap(json);

      return MResponse(data: data);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      print("[Error Detail] ${e}");
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  static Future savePartnerToPref(MPartner partner) async {
    print("Save partner to pref => ${partner.toJson()}");
    final pref = await SharedPreferences.getInstance();
    pref.setString(Prefs.partnerInfo, jsonEncode(partner.toJson()));
  }

  static Future removePartnerPref() async {
    final pref = await SharedPreferences.getInstance();
    print('Remove partner pref');
    pref.remove(Prefs.partnerInfo);
  }

  static Future<MPartner?> getPartnerFromPref() async {
    final pref = await SharedPreferences.getInstance();

    final prefPartner = pref.getString(Prefs.partnerInfo);

    if (prefPartner == null) return null;

    Map<String, dynamic> map = jsonDecode(prefPartner);
    MPartner partner = MPartner.fromJson(map);
    print("get partner from pref => ${partner.toJson()}");

    return partner;
  }
}
