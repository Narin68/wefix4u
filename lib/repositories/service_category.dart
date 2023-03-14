import 'dart:convert';
import 'dart:io';

import 'package:ocs_auth/ocs_auth.dart';
import '/modals/service_category.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../globals.dart';

class ServiceCateRepo {
  Future<MResponse> list(
      {String search = '', int pages = 1, int record = 100}) async {
    try {
      var _res = await fetchedData(
        ApisString.serviceCateList,
        withDb: true,
        data: {
          "Pages": "$pages",
          "Records": 100,
          "Search": "$search",
          "Status": "ENABLED",
        },
        isGlobal: true,
      );

      if (_res.statusCode == 401) {
        return MResponse(
          error: true,
          statusCode: ResponseStatus.unAuthorize,
          message: MessageKey.unAuthorize,
        );
      }
      if (_res.statusCode != 200) throw Exception(_res.body);
      var _json = jsonDecode(_res.body);
      List<MServiceCate>? data = [];
      _json.forEach((e) => data.add(MServiceCate.fromJson(e)));
      return MResponse(data: data);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      print("[Error Service cate] $e");
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future saveCatToPref(List<MServiceCate> list) async {
    var pref = await SharedPreferences.getInstance();
    final String data = MServiceCate.encode(list);
    pref.setString(Prefs.ServiceCatList, data);
  }

  Future<List<MServiceCate>> getCatToPref() async {
    var pref = await SharedPreferences.getInstance();
    final String? prefData = await pref.getString(Prefs.ServiceCatList);
    List<MServiceCate> data = [];
    if (prefData != null) {
      data = MServiceCate.decode(prefData);
    }

    return data;
  }
}
