import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ocs_auth/ocs_auth.dart';
import 'package:ocs_firebase/messaging.dart';
import 'package:ocs_firebase/ocs_firebase.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import 'package:webview_flutter/webview_flutter.dart' as webview;
import 'package:wefix4utoday/blocs/my_notification_count/my_notification_count_cubit.dart';
import 'package:wefix4utoday/repositories/partner_repo.dart';
import 'package:wefix4utoday/repositories/wallet_repo.dart';
import '/blocs/chat_request/chat_request_bloc.dart';
import '/blocs/service_request/service_request_bloc.dart';
import '/signalr.dart';
import '../widget.dart';
import '/screens/more/web_view.dart';
import '/globals.dart';
import '/modals/customer.dart';
import '/modals/partner.dart';
import '/screens/home/splash.dart';
import '/blocs/user/user_cubit.dart';
import 'account_setting.dart';
import 'changeLanguage/change_language.dart';
import 'policy_and_services.dart';

Widget buildUserInfo(
    {required String title,
    required Color color,
    required IconData icon,
    required Function onPress}) {
  return Parent(
    gesture: Gestures()
      ..onTap(() {
        onPress();
      }),
    style: ParentStyle()
      ..padding(horizontal: 10, vertical: 5, right: 15)
      ..background.color(Colors.white)
      ..ripple(true),
    child: Row(
      children: [
        Parent(
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
          style: ParentStyle()
            ..padding(all: 5)
            ..width(38)
            ..height(38)
            ..borderRadius(all: 40),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Txt(
            "${title}",
            style: TxtStyle()
              ..textColor(OCSColor.text.withOpacity(0.8))
              ..fontSize(Style.subTitleSize),
          ),
        ),
        Icon(
          Remix.arrow_right_s_line,
          color: OCSColor.text.withOpacity(0.5),
          size: 16,
        )
      ],
    ),
  );
}

Widget buildLogoImage({required String source, double? width, double? height}) {
  return Center(
    child: Image.asset(
      source,
      width: width ?? 80,
      height: width ?? 80,
    ),
  );
}

class BuildUserProfile extends StatefulWidget {
  const BuildUserProfile({Key? key}) : super(key: key);

  @override
  State<BuildUserProfile> createState() => _BuildUserProfileState();
}

class _BuildUserProfileState extends State<BuildUserProfile> {
  String lastName = '';

  @override
  Widget build(BuildContext context) {
    return FlexibleSpaceBar(
      background: Stack(
        children: [
          Parent(
            style: ParentStyle()..borderRadius(all: 5),
            child: BlocBuilder<MyUserCubit, MyUserState>(
              builder: (context, state) {
                lastName = Model.userInfo.lastName!;
                if (Model.userInfo.lastName!.indexOf(".") == 0)
                  lastName = lastName.replaceFirst('.', '');
                String phone = Model.userInfo.phone ?? "";
                if (phone.contains('+855')) {
                  phone = phone.replaceAll('+855', '0');
                }
                String email = '';
                if (Model.userInfo.email == null) {
                  email = '';
                } else {
                  email = Model.userInfo.email!;
                }
                return Stack(
                  children: [
                    ClipPath(
                      child: Parent(
                        style: ParentStyle()
                          ..height(70)
                          ..background.color(OCSColor.primary),
                      ),
                      clipper: CustomClipPath(),
                    ),
                    Parent(
                      gesture: Gestures()..onTap(() {}),
                      style: ParentStyle()
                        ..ripple(false)
                        ..margin(all: 15)
                        ..padding(all: 10, horizontal: 15)
                        ..borderRadius(all: 5)
                        ..background.color(Colors.white)
                        ..boxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: Offset(0, 1),
                            blur: 5
                            // blur: 1,
                            ),
                      child: Row(
                        children: [
                          Center(
                            child: Parent(
                                style: ParentStyle()
                                  ..borderRadius(all: 50)
                                  ..background.color(Colors.white)
                                  ..elevation(1, opacity: .2)
                                  ..width(60)
                                  ..height(60)
                                  ..overflow.hidden(),
                                child: Model.userInfo.imagePath == null ||
                                        Model.userInfo.imagePath == ""
                                    ? Image.asset(
                                        Globals.userAvatarImage,
                                        fit: BoxFit.cover,
                                      )
                                    : MyCacheNetworkImage(
                                        url: Model.userInfo.imagePath ?? '',
                                        iconSize: 30,
                                        defaultAssetImage:
                                            Globals.userAvatarImage,
                                      )),
                          ),
                          SizedBox(width: 15),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Txt(
                                "${Model.userInfo.firstName} ${lastName}",
                                style: TxtStyle()
                                  ..textColor(OCSColor.text)
                                  ..fontSize(Style.subTitleSize),
                              ),
                              Txt(
                                "${phone}",
                                style: TxtStyle()
                                  ..textColor(OCSColor.text.withOpacity(0.7))
                                  ..fontSize(Style.subTextSize),
                              ),
                              if (email.isNotEmpty)
                                Txt(
                                  "${email}",
                                  style: TxtStyle()
                                    ..textColor(OCSColor.text.withOpacity(0.7))
                                    ..fontSize(Style.subTextSize),
                                ),
                            ],
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
                          Expanded(child: SizedBox()),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BuildBottomMore extends StatefulWidget {
  const BuildBottomMore({Key? key}) : super(key: key);

  @override
  State<BuildBottomMore> createState() => _BuildBottomMoreState();
}

class _BuildBottomMoreState extends State<BuildBottomMore> {
  late var _util = OCSUtil.of(context);
  late var _auth = OCSAuth.instance;
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
    return Column(
      children: [
        buildUserInfo(
          onPress: () {
            _util.navigator.to(AccountSetting(),
                isFade: true, transition: OCSTransitions.LEFT);
          },
          color: Color.fromRGBO(22, 160, 133, 1),
          title: "${_util.language.key("account-setting")}",
          icon: Remix.user_settings_line,
        ),
        // buildUserInfo(
        //   onPress: () {
        //     _util.navigator.to(ChangePhone(),
        //         isFade: true, transition: OCSTransitions.LEFT);
        //   },
        //   color: Colors.cyan,
        //   title: "${_util.language.key("change-phone")}",
        //   icon: Remix.phone_line,
        // ),
        // buildUserInfo(
        //   onPress: () {
        //     _util.navigator.to(ChangeEmail(), transition: OCSTransitions.LEFT);
        //   },
        //   color: Color.fromRGBO(155, 89, 182, 1),
        //   title: "${_util.language.key("change-email")}",
        //   icon: Remix.mail_line,
        // ),
        buildUserInfo(
          onPress: () {
            _util.navigator.to(ChangeLanguage(langCode: _langCode),
                transition: OCSTransitions.LEFT);
          },
          color: Color.fromRGBO(243, 156, 18, 1),
          title: "${_util.language.key("change-language")}",
          icon: Remix.translate,
        ),
        Parent(
          style: ParentStyle()
            ..height(40)
            ..padding(horizontal: 15),
          child: Row(
            children: [
              Txt(
                _util.language.key('other'),
                style: TxtStyle()
                  ..textColor(OCSColor.text)
                  ..fontSize(Style.titleSize),
              ),
              Expanded(child: SizedBox()),
            ],
          ),
        ),
        Parent(
          style: ParentStyle()..background.color(Colors.white),
          child: Column(
            children: [
              // if (Globals.userType.toLowerCase() == UserType.customer)
              // buildUserInfo(
              //   onPress: () async {
              //     _util.navigator.to(
              //       MessageDetail(requestId: 0, receiverName: "wefix4u"),
              //       transition: OCSTransitions.LEFT,
              //     );
              //   },
              //   color: Colors.blue,
              //   title: _util.language.key('message-to-company'),
              //   icon: Icons.message,
              // ),
              buildUserInfo(
                onPress: () async {
                  _util.navigator.to(
                    PolicyAndService(),
                    transition: OCSTransitions.LEFT,
                  );
                },
                color: Colors.blue,
                title: _util.language.key("privacy-and-service"),
                icon: Remix.file_user_line,
              ),
              buildUserInfo(
                onPress: () async {
                  _util.navigator.to(
                      MyWebView(
                        title: "${_util.language.key("support")}",
                        url: "${ApisString.webServer}/privacyandpolicy/support",
                      ),
                      transition: OCSTransitions.LEFT);
                },
                color: Colors.blue,
                title: "${_util.language.key("support")}",
                icon: Remix.customer_service_2_line,
              ),
              buildUserInfo(
                onPress: () async {
                  _util.navigator.to(AccountDeletionScreen(onSuccess: _logout),
                      transition: OCSTransitions.LEFT);
                },
                color: Colors.red,
                title:
                    "${_util.language.by(km: "លុបគណនី", en: "Delete account")}",
                icon: Remix.user_unfollow_line,
              ),
              buildUserInfo(
                onPress: () {
                  showModalBottomSheet(
                    isDismissible: true,
                    enableDrag: false,
                    backgroundColor: Colors.transparent,
                    context: context,
                    constraints: BoxConstraints(
                      maxWidth: Globals.maxScreen,
                    ),
                    builder: (BuildContext context) {
                      return _buildLogout();
                    },
                  );
                },
                color: Colors.red,
                title: "${_util.language.key("log-out")}",
                icon: Remix.logout_box_line,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Future _logout() async {
    var result = await _auth.logout();
    if (result) {
      context.read<ServiceRequestBloc>()..add(ReloadServiceRequest());
      context.read<ChatRequestBloc>()..add(ReloadChatRequest());
      await _resetData();
      disconnectSignalR();
      _util.navigator.pop();
      _util.navigator.replace(SplashScreen(loading: true), isFade: true);
      // await _saveFirebaseToken();
    }
  }

  Future _resetData() async {
    var _pref = await SharedPreferences.getInstance();
    _pref.setString(Prefs.userType, '');
    Globals.userType = '';
    Globals.navIndex = -1;
    Model.userInfo = MUserInfo();
    Model.partner = MPartner();
    Model.customer = MMyCustomer();
    Model.userWallet = null;
    Model.settlementRule = null;
    OCSMessaging.instance.deleteToken();
    Globals.tabRequestStatusIndex = 0;
    Globals.requestFilterStatus = "";
    context.read<MyNotificationCountCubit>()
      ..resetServiceRequestCount()
      ..resetNewsCount();
    await PartnerRepo.removePartnerPref();
    await WalletRepo.removeWalletPref();
  }

  Widget _buildLogout() {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Parent(
            style: ParentStyle()
              ..height(155)
              ..borderRadius(all: 5)
              ..margin(all: 20 + _util.query.bottom, horizontal: 20)
              ..background.color(Colors.white),
            child: Parent(
              style: ParentStyle()
                ..padding(
                  vertical: 10,
                  horizontal: 15,
                ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Parent(
                        style: ParentStyle(),
                        child: Icon(
                          Remix.logout_box_line,
                          size: 18,
                          color: OCSColor.text,
                        ),
                      ),
                      SizedBox(width: 5),
                      Txt(
                        "${_util.language.key("log-out")}",
                        style: TxtStyle()
                          ..fontSize(Style.titleSize)
                          ..textColor(OCSColor.text),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Txt(
                    "${_util.language.key("are-you-sure-want-to-log-out")}",
                    style: TxtStyle()
                      ..textColor(OCSColor.text.withOpacity(0.7))
                      ..fontSize(Style.subTitleSize),
                  ),
                  Expanded(child: SizedBox()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Parent(
                        gesture: Gestures()
                          ..onTap(() {
                            _util.navigator.pop();
                          }),
                        style: ParentStyle()
                          ..width(100)
                          ..height(40)
                          ..background.color(OCSColor.primary)
                          ..borderRadius(all: 5)
                          ..alignmentContent.center()
                          ..ripple(true),
                        child: Txt(
                          "${_util.language.key("cancel")}",
                          style: TxtStyle()
                            ..textColor(Colors.white)
                            ..textAlign.center()
                            ..fontSize(13)
                            ..width(100),
                        ),
                      ),
                      SizedBox(width: 10),
                      Parent(
                        gesture: Gestures()..onTap(_logout),
                        style: ParentStyle()
                          ..width(100)
                          ..height(40)
                          ..ripple(true)
                          ..background.color(OCSColor.primary.withOpacity(0.2))
                          ..borderRadius(all: 5)
                          ..alignmentContent.center(),
                        child: Txt(
                          "${_util.language.key("log-out")}",
                          style: TxtStyle()
                            ..textColor(OCSColor.primary)
                            ..fontSize(13),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BuildSwitchUser extends StatefulWidget {
  final String? userType;
  final Function()? onChange;
  final Function(String v)? onSubmit;

  const BuildSwitchUser({Key? key, this.userType, this.onChange, this.onSubmit})
      : super(key: key);

  @override
  State<BuildSwitchUser> createState() => _BuildSwitchUserState();
}

class _BuildSwitchUserState extends State<BuildSwitchUser> {
  String _userType = '';
  late var _util = OCSUtil.of(context);

  @override
  void initState() {
    super.initState();
    _userType = widget.userType ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Parent(
            style: ParentStyle()
              ..padding(all: 10, horizontal: 20)
              ..margin(bottom: 10 + _util.query.bottom)
              ..background.color(Colors.transparent),
            child: Parent(
              style: ParentStyle()
                ..borderRadius(all: 5)
                ..padding(all: 15, bottom: 0, left: 5, top: 10)
                ..background.color(Colors.white),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Remix.user_shared_2_line,
                        color: OCSColor.text,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Txt(
                        _util.language.key(
                          'switch-user-type',
                        ),
                        style: TxtStyle()
                          ..fontSize(Style.titleSize)
                          ..textColor(
                            OCSColor.text,
                          ),
                      ),
                    ],
                  ),
                  Parent(
                    style: ParentStyle()..height(40),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Radio(
                          value: 'partner',
                          groupValue: _userType,
                          onChanged: (String? value) {
                            setState(() {
                              _userType = value!;
                            });
                          },
                        ),
                        Txt(
                          _util.language.key('partner'),
                          style: TxtStyle()
                            ..textColor(OCSColor.text)
                            ..fontSize(Style.subTitleSize),
                          gesture: Gestures()
                            ..onTap(() {
                              setState(() {
                                _userType = 'partner';
                              });
                            }),
                        )
                      ],
                    ),
                  ),
                  Parent(
                    style: ParentStyle()..height(40),
                    child: Row(
                      children: [
                        Radio(
                          value: 'customer',
                          groupValue: _userType,
                          onChanged: (String? value) {
                            setState(() {
                              _userType = value!;
                            });
                          },
                        ),
                        SizedBox(height: 10),
                        Txt(
                          _util.language.key('customer'),
                          style: TxtStyle()
                            ..textColor(OCSColor.text)
                            ..fontSize(Style.subTitleSize),
                          gesture: Gestures()
                            ..onTap(() {
                              setState(() {
                                _userType = 'customer';
                              });
                            }),
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Parent(
                        gesture: Gestures()
                          ..onTap(() {
                            _util.navigator.pop();
                          }),
                        style: ParentStyle()
                          ..width(100)
                          ..height(40)
                          ..background.color(OCSColor.primary)
                          ..borderRadius(all: 5)
                          ..alignmentContent.center()
                          ..ripple(true),
                        child: Txt(
                          "${_util.language.key("close")}",
                          style: TxtStyle()
                            ..textColor(Colors.white)
                            ..textAlign.center()
                            ..fontSize(Style.subTitleSize)
                            ..width(100),
                        ),
                      ),
                      SizedBox(width: 10),
                      Parent(
                        gesture: Gestures()
                          ..onTap(() {
                            if (widget.onSubmit != null)
                              widget.onSubmit!(_userType);
                          }),
                        style: ParentStyle()
                          ..width(100)
                          ..height(40)
                          ..ripple(true)
                          ..background.color(OCSColor.primary.withOpacity(0.2))
                          ..borderRadius(all: 5)
                          ..alignmentContent.center(),
                        child: Txt(
                          "${_util.language.key("change")}",
                          style: TxtStyle()
                            ..textColor(OCSColor.primary)
                            ..fontSize(Style.subTitleSize),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomClipPath extends CustomClipper<Path> {
  var radius = 10.0;

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(
        size.width / 4, size.height - 40, size.width / 2, size.height - 20);
    path.quadraticBezierTo(
        3 / 4 * size.width, size.height, size.width, size.height - 30);
    path.lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
