import 'dart:convert';
import 'dart:io';

import 'package:ocs_auth/ocs_auth.dart';

import '../globals.dart';
import '../modals/customer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerRepo {
  Future<MResponse> list(MMyCustomerFilter filter) async {
    try {
      var _result = await fetchedData(ApisString.customerList,
          withDb: true, data: filter.toJson());

      if (_result.statusCode == 401) {
        return MResponse(
          error: true,
          statusCode: ResponseStatus.unAuthorize,
          message: MessageKey.unAuthorize,
        );
      }
      var jsonData = jsonDecode(_result.body);
      List<MMyCustomer> data = [];
      jsonData.forEach((e) => data.add(MMyCustomer.fromJson(e)));

      return MResponse(data: data);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  Future<MResponse> updateUserMoreInfo(MMyCustomer model) async {
    try {
      var _result = await fetchedData(ApisString.updateCustomer,
          data: model.toJson(), withDb: true);
      if (_result.statusCode == 401) {
        return MResponse(
          error: true,
          statusCode: ResponseStatus.unAuthorize,
          message: MessageKey.unAuthorize,
        );
      }
      var jsonData = jsonDecode(_result.body);
      return MResponse(data: jsonData);
    } on SocketException {
      return MResponse(
          error: true, statusCode: 2, message: MessageKey.noConnection);
    } catch (e) {
      return MResponse(
          error: true, statusCode: 3, message: MessageKey.errorOccurred);
    }
  }

  static Future saveCusToPref(MMyCustomer customer) async {
    final pref = await SharedPreferences.getInstance();
    pref.setString(Prefs.customerInfo, jsonEncode(customer.toJson()));
  }

  static Future<MMyCustomer?> getCusFromPref() async {
    final pref = await SharedPreferences.getInstance();
    final prefUser = pref.getString(Prefs.customerInfo);

    if (prefUser == null) return null;

    Map<String, dynamic> user = jsonDecode(prefUser);

    return MMyCustomer.fromJson(user);
  }
}
