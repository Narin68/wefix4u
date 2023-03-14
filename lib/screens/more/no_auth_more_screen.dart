import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import 'package:webview_flutter/webview_flutter.dart' as webview;
import '../auths/login.dart';
import '../auths/register.dart';
import '/globals.dart';
import '/screens/more/changeLanguage/change_language.dart';
import '/screens/more/web_view.dart';
import '/screens/more/widget.dart';

class NoAuthMoreScreen extends StatefulWidget {
  const NoAuthMoreScreen({Key? key}) : super(key: key);

  @override
  State<NoAuthMoreScreen> createState() => _NoAuthMoreScreenState();
}

class _NoAuthMoreScreenState extends State<NoAuthMoreScreen> {
  late var _util = OCSUtil.of(context);
  String? _langCode;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      webview.WebView.platform = webview.SurfaceAndroidWebView();
    }
    _getLanguageCode();
  }

  Future _getLanguageCode() async {
    var pref = await SharedPreferences.getInstance();
    _langCode = pref.getString(Prefs.langCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: OCSColor.primary,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Parent(
              style: ParentStyle()..alignmentContent.center(),
              child: Row(
                children: [
                  Image.asset(
                    'assets/logo/logo-white.png',
                    height: 25,
                  ),
                  SizedBox(width: 10),
                  Parent(
                    style: ParentStyle(),
                    child: Image.asset(
                      'assets/logo/wf4u-text.png',
                      height: 15,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            buildUserInfo(
              onPress: () {
                _util.navigator.to(ChangeLanguage(langCode: _langCode),
                    transition: OCSTransitions.LEFT);
              },
              color: Colors.blue,
              title: "${_util.language.key("change-language")}",
              icon: Remix.translate,
            ),
            Parent(
              style: ParentStyle()..background.color(Colors.white),
              child: Column(
                children: [
                  buildUserInfo(
                    onPress: () async {
                      _util.navigator.to(
                          MyWebView(
                            title: "${_util.language.key("privacy-policy")}",
                            url: "${ApisString.webServer}/privacyandpolicy",
                          ),
                          transition: OCSTransitions.LEFT);
                    },
                    color: Colors.blue,
                    title: "${_util.language.key("privacy-policy")}",
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
                  buildUserInfo(
                    onPress: () async {
                      _util.navigator.to(
                        MyWebView(
                          title: "${_util.language.key("support")}",
                          url:
                              "${ApisString.webServer}/privacyandpolicy/support",
                        ),
                        transition: OCSTransitions.LEFT,
                      );
                    },
                    color: Colors.blue,
                    title: "${_util.language.key("support")}",
                    icon: Remix.customer_service_2_line,
                  ),
                  _authMenu(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _authMenu() {
    return Parent(
      style: ParentStyle()..padding(all: 15),
      child: Row(
        children: [
          Expanded(
            child: Parent(
              gesture: Gestures()
                ..onTap(() {
                  Globals.isRequestService = false;
                  _util.navigator.to(Login());
                }),
              style: ParentStyle()
                ..padding(all: 7, horizontal: 10)
                ..borderRadius(all: 7)
                ..ripple(true)
                ..elevation(1, opacity: 0.2)
                ..background.color(Color.fromRGBO(206, 229, 236, 1)),
              child: Row(
                children: [
                  Image.asset('assets/images/log-in.png', width: 30),
                  SizedBox(
                    width: 10,
                  ),
                  Txt(
                    _util.language.key('login'),
                    style: TxtStyle()..textColor(OCSColor.text),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 15,
          ),
          Expanded(
            child: Parent(
              gesture: Gestures()
                ..onTap(() {
                  Globals.isRequestService = false;
                  _util.navigator.to(SignUp());
                }),
              style: ParentStyle()
                ..padding(all: 7, horizontal: 10)
                ..borderRadius(all: 7)
                ..ripple(true)
                ..elevation(1, opacity: 0.2)
                ..background.color(Color.fromRGBO(206, 229, 236, 1)),
              child: Row(
                children: [
                  Image.asset('assets/images/register.png', width: 30),
                  SizedBox(
                    width: 10,
                  ),
                  Txt(
                    _util.language.key('register'),
                    style: TxtStyle()..textColor(OCSColor.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
