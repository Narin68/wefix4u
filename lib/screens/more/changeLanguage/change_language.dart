import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '/functions.dart';
import '/globals.dart';
import '/screens/widget.dart';

class ChangeLanguage extends StatefulWidget {
  final String? langCode;

  ChangeLanguage({this.langCode});

  @override
  _ChangeLanguageState createState() => _ChangeLanguageState();
}

class _ChangeLanguageState extends State<ChangeLanguage> {
  late var _util = OCSUtil.of(context);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(width: 5),
            Txt(
              _util.language.key("change-language"),
              style: TxtStyle()
                ..textColor(Colors.white)
                ..fontSize(Style.titleSize),
            ),
          ],
        ),
        backgroundColor: OCSColor.primary,
        leading: NavigatorBackButton(),
      ),
      body: SafeArea(
        child: Parent(
          style: ParentStyle()..padding(horizontal: 20, vertical: 0),
          child: LanguageBuilder(
            builder: (_, c) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Parent(
                    gesture: Gestures()
                      ..onTap(() {
                        _onChangeLang("km");
                      }),
                    style: ParentStyle()
                      ..border(
                          bottom: 1, color: Colors.black12.withOpacity(0.06))
                      ..padding(vertical: 5),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/km.png',
                          width: 40,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 10),
                        Txt(
                          "ភាសាខ្មែរ",
                          style: TxtStyle()
                            ..fontSize(14)
                            ..textColor(OCSColor.text),
                        ),
                        Expanded(child: SizedBox()),
                        if (c == "km")
                          Parent(
                            style: ParentStyle(),
                            child: Icon(
                              Remix.checkbox_circle_fill,
                              color: OCSColor.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Parent(
                    gesture: Gestures()
                      ..onTap(() {
                        _onChangeLang("en");
                      }),
                    style: ParentStyle()
                      ..border(
                          bottom: 1, color: Colors.black12.withOpacity(0.06))
                      ..padding(vertical: 5),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/en.png',
                          width: 40,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 10),
                        Txt(
                          "English",
                          style: TxtStyle()
                            ..fontSize(14)
                            ..textColor(OCSColor.text),
                        ),
                        Expanded(child: SizedBox()),
                        if (c == "en")
                          Parent(
                            style: ParentStyle(),
                            child: Icon(
                              Remix.checkbox_circle_fill,
                              color: OCSColor.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future _onChangeLang(String code) async {
    context.changeLang(code);
    Globals.langCode = code;
    saveToken(Globals.fbToken);
    setState(() {});
  }
}
