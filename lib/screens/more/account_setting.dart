import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '../widget.dart';
import '/screens/more/widget.dart';

import 'changeEmail/change_email.dart';
import 'changePassword/change_password.dart';
import 'changePhone/change_phone.dart';

class AccountSetting extends StatefulWidget {
  const AccountSetting({Key? key}) : super(key: key);

  @override
  State<AccountSetting> createState() => _AccountSettingState();
}

class _AccountSettingState extends State<AccountSetting> {
  late var _util = OCSUtil.of(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Txt(
          "Account setting",
          style: TxtStyle()
            ..fontSize(16)
            ..textColor(Colors.white),
        ),
        leading: NavigatorBackButton(),
      ),
      body: Column(
        children: [
          buildUserInfo(
            onPress: () {
              _util.navigator.to(ChangePassword(),
                  isFade: true, transition: OCSTransitions.LEFT);
            },
            color: Colors.blue,
            title: "${_util.language.key("change-password")}",
            icon: Remix.lock_2_line,
          ),
          buildUserInfo(
            onPress: () {
              _util.navigator.to(ChangePhone(),
                  isFade: true, transition: OCSTransitions.LEFT);
            },
            color: Colors.blue,
            title: "${_util.language.key("change-phone")}",
            icon: Remix.phone_line,
          ),
          buildUserInfo(
            onPress: () {
              _util.navigator
                  .to(ChangeEmail(), transition: OCSTransitions.LEFT);
            },
            color: Colors.blue,
            title: "${_util.language.key("change-email")}",
            icon: Remix.mail_line,
          ),
        ],
      ),
    );
  }
}
