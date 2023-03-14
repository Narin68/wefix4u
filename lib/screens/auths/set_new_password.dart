import 'package:flutter/material.dart';
import 'package:ocs_auth/ocs_auth.dart';
import '../widget.dart';
import '/globals.dart';
import '/screens/auths/login.dart';
import './widget.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';

class SetNewPassword extends StatefulWidget {
  final MForgotHeader? header;

  final bool? isEmail;

  SetNewPassword({this.header, this.isEmail});

  @override
  _SetNewPasswordState createState() => _SetNewPasswordState();
}

class _SetNewPasswordState extends State<SetNewPassword> {
  late var _util = OCSUtil.of(context);
  var _newPasswordTxt = TextEditingController();
  var _confirmPassword = TextEditingController();
  var _form = GlobalKey<FormState>();
  var _auth = OCSAuth.instance;
  bool _loading = false;
  bool _showPass = true;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_loading) _util.navigator.pop();

        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          top: false,
          child: Parent(
            style: ParentStyle()..width(_util.query.width),
            child: Center(
              child: Stack(
                children: [
                  Column(
                    children: [
                      SizedBox(height: _util.query.top),
                      _util.query.isKbPopup == true
                          ? SizedBox(
                              height: 10,
                            )
                          : Parent(
                              style: ParentStyle()
                                ..width(_util.query.width)
                                ..alignmentContent.centerLeft()
                                ..padding(horizontal: 10),
                              child: NavigatorBackButton(
                                  loading: _loading, iconColor: OCSColor.text)),
                      Expanded(child: SizedBox()),
                      Parent(
                        style: ParentStyle()
                          ..padding(horizontal: 20)
                          ..maxWidth(Globals.maxScreen),
                        child: Form(
                          key: _form,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Parent(
                                style: ParentStyle(),
                                child: Hero(
                                  tag: "logo",
                                  child: SizedBox(
                                    child: BuildLogo(),
                                    width:
                                        _util.query.isKbPopup == true ? 35 : 40,
                                    height:
                                        _util.query.isKbPopup == true ? 35 : 40,
                                  ),
                                ),
                              ),
                              if (!_util.query.isKbPopup)
                                SizedBox(
                                  height: 15,
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
                                height: _util.query.isKbPopup ? 5 : 15,
                              ),
                              BuildScreenTitle(
                                  title:
                                      _util.language.key("set-new-password")),
                              SizedBox(
                                height: 20,
                              ),
                              Parent(
                                style: ParentStyle()
                                  ..padding(all: 15, horizontal: 15)
                                  ..borderRadius(all: 10)
                                  ..boxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blur: 5,
                                      offset: Offset(1, 1))
                                  // ..elevation(2, opacity: 0.1)
                                  ..background.color(Colors.white),
                                child: Column(
                                  children: [
                                    MyTextField(
                                      borderWidth: Style.borderWidth,
                                      textInputAction: TextInputAction.next,
                                      controller: _newPasswordTxt,
                                      label: _util.language.key("new-password"),
                                      labelTextSize: Style.subTitleSize,
                                      placeholder: _util.language
                                          .key("enter-new-password"),
                                      backgroundColor: Colors.white,
                                      textInputType:
                                          TextInputType.visiblePassword,
                                      obscureText: _showPass,
                                      validator: (v) {
                                        if (v == "") {
                                          return "${_util.language.key("this-field-is-required")}";
                                        }

                                        if (v!.length < 6) {
                                          return "${_util.language.key('invalid-password')}";
                                        }
                                        return null;
                                      },
                                      suffixOnPressed: (t) {
                                        if (!_loading) {
                                          setState(() {
                                            _showPass = !_showPass;
                                          });
                                        }
                                      },
                                      suffixIcon: _showPass
                                          ? Remix.eye_off_line
                                          : Remix.eye_line,
                                    ),
                                    MyTextField(
                                      borderWidth: Style.borderWidth,
                                      controller: _confirmPassword,
                                      label: _util.language
                                          .key("confirm-password"),
                                      labelTextSize: Style.subTitleSize,
                                      placeholder: _util.language
                                          .key("enter-confirm-password"),
                                      backgroundColor: Colors.white,
                                      textInputType:
                                          TextInputType.visiblePassword,
                                      obscureText: _showPass,
                                      validator: (v) {
                                        if (v == "") {
                                          return "${_util.language.key("this-field-is-required")}";
                                        }
                                        if (v != _newPasswordTxt.text) {
                                          return "${_util.language.key("confirm-password-does-not-match")}";
                                        }
                                        return null;
                                      },
                                      onSubmitted: (v) async {
                                        widget.isEmail == true
                                            ? await _onSubmitEmail()
                                            : await _onSubmit();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 25,
                              ),
                              Parent(
                                style: ParentStyle(),
                                child: BuildButton(
                                  title: _util.language.key("save"),
                                  height: 45,
                                  width: 180,
                                  fontSize: Style.titleSize,
                                  onPress: widget.isEmail == true
                                      ? _onSubmitEmail
                                      : _onSubmit,
                                  iconData: Remix.save_line,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(flex: 3, child: SizedBox()),
                    ],
                  ),
                  if (_loading)
                    Positioned(
                      child: Container(
                        color: Colors.black.withOpacity(.3),
                        child: const Center(
                            child: CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        )),
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
    if (!_form.currentState!.validate()) return;
    setState(() {
      _loading = true;
    });
    var phone = widget.header?.identity;
    if (phone?.indexOf("0") == 0) phone = phone?.replaceFirst('0', '+855');

    var result = await _auth.phoneForgot(widget.header!.copyWith(
      password: _newPasswordTxt.text.trim(),
      confirmPassword: _confirmPassword.text.trim(),
      identity: phone,
    ));

    if (!result.error) {
      _util.navigator.pop();
      _util.navigator.pop();
      _util.snackBar(
        message: _util.language.key("success"),
        status: SnackBarStatus.success,
      );
      _util.navigator.replace(Login(), isFade: true);
      return;
    } else {
      _util.snackBar(message: result.message, status: SnackBarStatus.danger);
    }

    setState(() {
      _loading = false;
    });
  }

  Future _onSubmitEmail() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _loading = true;
    });
    var result = await _auth.emailForgot(
      widget.header!.copyWith(
        password: _newPasswordTxt.text.trim(),
        confirmPassword: _confirmPassword.text.trim(),
      ),
    );

    if (!result.error) {
      _util.navigator.pop();
      _util.navigator.pop();
      _util.snackBar(
          message: _util.language.key("success"),
          status: SnackBarStatus.success);
      _util.navigator.replace(Login(), isFade: true);
      return;
    } else {
      _util.snackBar(message: result.message, status: SnackBarStatus.danger);
    }

    setState(() {
      _loading = false;
    });
  }
}
