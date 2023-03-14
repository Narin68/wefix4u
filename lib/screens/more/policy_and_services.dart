import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '../widget.dart';
import '/screens/more/web_view.dart';
import '/screens/more/widget.dart';

import '/globals.dart';

class PolicyAndService extends StatefulWidget {
  const PolicyAndService({Key? key}) : super(key: key);

  @override
  State<PolicyAndService> createState() => _PolicyAndServiceState();
}

class _PolicyAndServiceState extends State<PolicyAndService> {
  late var _util = OCSUtil.of(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Txt(
          _util.language.key("privacy-and-service"),
          style: TxtStyle()
            ..fontSize(16)
            ..textColor(Colors.white),
        ),
        leading: NavigatorBackButton(),
      ),
      body: Column(
        children: [
          buildUserInfo(
            onPress: () async {
              _util.navigator.to(
                MyWebView(
                  title: _util.language.key("privacy-policy"),
                  url: "${ApisString.webServer}/privacyandpolicy",
                ),
                transition: OCSTransitions.LEFT,
              );
            },
            color: Colors.blue,
            title: _util.language.key("privacy-policy"),
            icon: Remix.file_user_line,
          ),
          buildUserInfo(
            onPress: () async {
              _util.navigator.to(
                MyWebView(
                  title: "${_util.language.key("term-and-services")}",
                  url:
                      "${ApisString.webServer}/privacyandpolicy/termandservice",
                ),
                transition: OCSTransitions.LEFT,
              );
            },
            color: Colors.blue,
            title: "${_util.language.key("term-and-services")}",
            icon: Remix.article_line,
          ),
        ],
      ),
    );
  }
}
