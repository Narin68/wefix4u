import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '/globals.dart';

import '../widget.dart';
import '/screens/auths/by_email_or_phone.dart';
import './widget.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  late var _util = OCSUtil.of(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Parent(
          style: ParentStyle()
            ..width(_util.query.width)
            ..height(_util.query.height),
          child: Column(
            children: [
              Parent(
                style: ParentStyle()
                  ..width(_util.query.width)
                  ..alignmentContent.centerLeft()
                  ..padding(horizontal: 10),
                child: NavigatorBackButton(iconColor: OCSColor.text),
              ),
              Expanded(child: SizedBox()),
              Parent(
                style: ParentStyle()
                  ..padding(horizontal: 50)
                  ..maxWidth(Globals.maxScreen),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Parent(
                      style: ParentStyle(),
                      child: Hero(
                        tag: "logo",
                        child: SizedBox(
                          child: BuildLogo(),
                          width: 45,
                          height: 45,
                        ),
                      ),
                    ),
                    if (!_util.query.isKbPopup)
                      SizedBox(
                        height: 10,
                      ),
                    if (!_util.query.isKbPopup)
                      Parent(
                        style: ParentStyle(),
                        child: Hero(
                          tag: 'logoText',
                          child: SizedBox(
                            height: 20,
                            child: BuildTextLogo(),
                          ),
                        ),
                      ),
                    SizedBox(
                      height: 20,
                    ),
                    BuildScreenTitle(
                        title: "${_util.language.key("forgot-password")}"),
                    SizedBox(
                      height: 40,
                    ),
                    Parent(
                      style: ParentStyle(),
                      child: BuildButton(
                        title: "${_util.language.key("by-phone")}",
                        width: 250,
                        height: 47,
                        fontSize: 15,
                        onPress: () {
                          _util.navigator.to(
                            ForgotByPhoneOrEmail(
                              isEmail: false,
                            ),
                          );
                        },
                        iconData: Remix.phone_line,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Parent(
                      style: ParentStyle()..width(250),
                      child: Row(
                        children: [
                          Expanded(
                            child: new Container(
                                margin: const EdgeInsets.only(right: 10.0),
                                child: Divider(
                                  color: OCSColor.border,
                                  height: 36,
                                )),
                          ),
                          Text("${_util.language.key("or")}"),
                          Expanded(
                            child: new Container(
                                margin: const EdgeInsets.only(left: 10.0),
                                child: Divider(
                                  color: OCSColor.border,
                                  height: 36,
                                )),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Parent(
                      style: ParentStyle(),
                      child: BuildSecondButton(
                        title: "${_util.language.key("by-email")}",
                        width: 250,
                        height: 47,
                        fontSize: 15,
                        iconData: Remix.mail_line,
                        onPress: () {
                          _util.navigator
                              .to(ForgotByPhoneOrEmail(isEmail: true));
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(flex: 3, child: SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
}
