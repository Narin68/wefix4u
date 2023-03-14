import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ocs_auth/ocs_auth.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '../access_denied.dart';
import '../function_temp.dart';
import '/signalr.dart';
import '/functions.dart';
import '../widget.dart';
import '/blocs/partner/partner_cubit.dart';
import '/blocs/user/user_cubit.dart';
import '/screens/request_service/request_form.dart';
import '/globals.dart';

import '/screens/auths/forgot_password.dart';
import '/screens/auths/register.dart';
import './widget.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late var util = OCSUtil.of(context);
  bool _showPass = false;
  bool _loading = false;
  var _username = TextEditingController();
  var _password = TextEditingController();
  var _form = GlobalKey<FormState>();

  late var _auth = OCSAuth.instance;
  FocusNode f1 = FocusNode();
  FocusNode f2 = FocusNode();

  @override
  void initState() {
    super.initState();
    // _username.text = "011111115";
    // _password.text = "abc123";
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        // iphone
        statusBarBrightness: Brightness.light,
      ),
      child: WillPopScope(
        onWillPop: () async {
          if (_loading) return false;
          return true;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            top: false,
            bottom: false,
            child: Parent(
              style: ParentStyle()
                ..width(util.query.width)
                ..background.color(Colors.white),
              child: Stack(
                children: [
                  Center(
                    child: SingleChildScrollView(
                      child: Parent(
                        style: ParentStyle()
                          ..padding(horizontal: 16)
                          ..maxWidth(Globals.maxScreen)
                          // ..background.color(Colors.white)
                          ..height(util.query.isKbPopup
                              ? util.query.height - 250 + util.query.top
                              : util.query.height),
                        child: Form(
                          key: _form,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (util.query.isKbPopup) SizedBox(height: 20),
                              // if (!util.query.isKbPopup)
                              Expanded(child: SizedBox()),
                              Parent(
                                style: ParentStyle(),
                                child: SizedBox(
                                  child: Hero(
                                    child: BuildLogo(),
                                    tag: "logo",
                                  ),
                                  width: util.query.isKbPopup == true ? 30 : 45,
                                  height:
                                      util.query.isKbPopup == true ? 30 : 45,
                                ),
                              ),
                              SizedBox(height: 15),
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
                                height: 5,
                              ),
                              BuildScreenTitle(
                                title: "${util.language.key("login")}",
                                fontSize: 18,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Parent(
                                style: ParentStyle()
                                  ..padding(all: 15, horizontal: 15)
                                  ..border(bottom: 1, color: OCSColor.primary)
                                  ..boxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blur: 2,
                                      offset: Offset(1, 1))
                                  ..background.color(Colors.white),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    MyTextField(
                                      iconSize: 20,
                                      borderWidth: Style.borderWidth,
                                      autoFocus: true,
                                      textInputAction: TextInputAction.next,
                                      icon: Remix.user_line,
                                      focusIcon: Remix.user_fill,
                                      focusColor: OCSColor.primary,
                                      focusNode: f1,
                                      labelTextSize: Style.subTitleSize,
                                      label: util.language.key("username"),
                                      controller: _username,
                                      readOnly: _loading,
                                      placeholder:
                                          "${util.language.key("enter-username")}",
                                      backgroundColor: Colors.white,
                                      autoValidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      validator: (v) {
                                        if (v == "") {
                                          return "${util.language.key("this-field-is-required")}";
                                        }
                                        return null;
                                      },
                                    ),
                                    MyTextField(
                                      borderWidth: Style.borderWidth,
                                      height: 50,
                                      iconSize: 20,
                                      icon: Remix.lock_line,
                                      focusIcon: Remix.lock_fill,
                                      focusColor: OCSColor.primary,
                                      focusNode: f2,
                                      labelTextSize: Style.subTitleSize,
                                      label: "${util.language.key("password")}",
                                      controller: _password,
                                      readOnly: _loading,
                                      placeholder:
                                          "${util.language.key("enter-password")}",
                                      suffixIcon: _showPass == true
                                          ? Remix.eye_line
                                          : Remix.eye_off_line,
                                      textInputType:
                                          TextInputType.visiblePassword,
                                      obscureText: !_showPass,
                                      backgroundColor: Colors.white,
                                      suffixOnPressed: (t) async {
                                        setState(() {
                                          _showPass = !_showPass;
                                        });
                                      },
                                      validator: (v) {
                                        if (v == "") {
                                          return "${util.language.key("this-field-is-required")}";
                                        }
                                        return null;
                                      },
                                      onSubmitted: (v) async {
                                        _onSubmit();
                                      },
                                    ),
                                    Parent(
                                      style: ParentStyle()
                                        ..alignment.centerRight(),
                                      child: Txt(
                                        "${util.language.key("forgot-password")}",
                                        style: TxtStyle()
                                          ..textColor(OCSColor.text)
                                          ..fontSize(Style.subTitleSize),
                                        gesture: Gestures()
                                          ..onTap(() {
                                            util.navigator.to(ForgotPassword());
                                          }),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    BuildButton(
                                      title: "${util.language.key("login")}",
                                      width: 220,
                                      height: 45,
                                      fontSize: Style.titleSize,
                                      onPress: _onSubmit,
                                      iconData: Remix.login_box_line,
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Txt(
                                          "${util.language.key("don't-have-an-account")}",
                                          style: TxtStyle()
                                            ..textColor(OCSColor.text)
                                            ..fontSize(Style.subTitleSize),
                                        ),
                                        SizedBox(width: 10),
                                        Txt(
                                          "${util.language.key("register")}",
                                          style: TxtStyle()
                                            ..fontWeight(FontWeight.bold)
                                            ..fontSize(Style.titleSize)
                                            ..margin(bottom: 2)
                                            ..textColor(
                                              OCSColor.primary,
                                            ),
                                          gesture: Gestures()
                                            ..onTap(() {
                                              if (!Globals.isRequestService) {
                                                Globals.isFromLogin = true;
                                              }
                                              util.navigator.replace(SignUp());
                                            }),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              Expanded(child: SizedBox()),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (!util.query.isKbPopup)
                    Positioned(
                      top: util.query.top,
                      left: 0,
                      child: Parent(
                        style: ParentStyle()
                          ..width(util.query.width)
                          ..alignmentContent.centerLeft()
                          ..padding(horizontal: 10),
                        child: NavigatorBackButton(iconColor: OCSColor.text),
                      ),
                    ),
                  if (_loading)
                    Positioned(
                      child: Container(
                        color: Colors.black.withOpacity(.3),
                        child: const Center(
                          child: CircularProgressIndicator.adaptive(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _onSubmit() async {
    if (_form.currentState!.validate()) {
      setState(() {
        _loading = true;
      });
      var result = await _auth.login(
        grantType: GrantType.password,
        password: _password.text.trim(),
        userName: _username.text.trim(),
      );
      if (!result.error) {
        await setUsedAccess();
        if (!Globals.isRequestService) {
          Globals.navIndex = 4;
        }
        await context.read<MyUserCubit>().get();
        if (Model.userInfo.userType?.toLowerCase() == "admin" ||
            Model.userInfo.userType?.toLowerCase() == "sysadmin") {
          await whenUserCompany();
        } else {
          Globals.hasAuth = true;
          await _setUserType();
          // await _getCustomer();

          if (Globals.userType.toLowerCase() == 'partner') {
            checkWallet(context);
          } else {
            context.read<PartnerCubit>().getPartnerRequest(Model.customer.id);
          }
          reConnectSignalR();
          await saveFirebaseToken();
          _checkNavigatorPage();
        }
      } else {
        util.snackBar(
          message: util.language.key(result.message),
          status: SnackBarStatus.danger,
        );
      }
      setState(() {
        _loading = false;
      });
    }
  }

  Future whenUserCompany() async {
    await _auth.logout();
    _password.text = "";
    _username.text = "";
    Model.userInfo = MUserInfo();
    util.navigator.to(AccessDenied(), transition: OCSTransitions.LEFT);
  }

  void _checkNavigatorPage() async {
    if (Globals.isRequestService) {
      Globals.isRequestService = false;
      util.navigator.replace(RequestForm());
    } else {
      util.navigator.pop();
      // util.navigator.replace(HomeMenus());
    }
  }

  Future _setUserType() async {
    var _pref = await SharedPreferences.getInstance();
    if (Globals.isRequestService) {
      Globals.navIndex = 4;
      Globals.userType = 'customer';
      _pref.setString(Prefs.userType, 'customer');
    } else {
      Globals.userType = (Model.userInfo.userType?.toLowerCase()) ?? "";
      _pref.setString(Prefs.userType, '${Globals.userType}');
    }
  }
}
