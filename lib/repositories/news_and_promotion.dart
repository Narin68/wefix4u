import 'dart:convert';
import 'dart:io';
import 'package:ocs_auth/ocs_auth.dart';

import '../globals.dart';
import '../modals/news_and_promotion.dart';

class NewsAndPromotionRepo {
  Future<MResponse> get(MNewsAndPromotionFilter filter) async {
    try {
      // var resp = await _auth.clientPostData(
      //   ApisString.newsAndPromotionList,
      //   body: filter.toJson(),
      //   withDb: true,
      // );
      var resp = await fetchedData(
        ApisString.newsAndPromotionList,
        withDb: true,
        data: filter.toJson(),
        isGlobal: true,
      );

      if (resp.statusCode != 200) {
        return MResponse(
          error: true,
          statusCode: 1,
          message: jsonDecode(resp.body)['Message'],
        );
      }
      if (resp.statusCode != 200) {
        if (resp.statusCode == 401) {
          print('[New and Promotion] Error un authorized');
          return MResponse(
              error: true, statusCode: 4, message: 'un-authorized');
        }

        throw '${resp.statusCode}, ${resp.body}';
      }

      var jsonData = jsonDecode(resp.body) as List;
      List<MNewsAndPromotion> list = [];
      jsonData.map((e) {
        MNewsAndPromotion data = MNewsAndPromotion.fromJson(e);

        if (data.image != null && data.image!.isNotEmpty)
          data = data.copyWith(image: '${AuthConfig.webServer}/${data.image}');

        list.add(data);
      }).toList();

      return MResponse(data: list);
    } on SocketException {
      print('[New and Promotion] Error no connection');
      return MResponse(error: true, statusCode: 2, message: 'no-connection');
    } catch (e) {
      print('[New and Promotion] Error $e');
      return MResponse(error: true, statusCode: 3, message: 'error-occurred');
    }
  }
}
