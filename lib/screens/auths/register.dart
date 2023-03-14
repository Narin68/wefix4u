import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ocs_auth/ocs_auth.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '../widget.dart';
import '/globals.dart';
import '/screens/auths/verification_code.dart';

import '/screens/auths/login.dart';
import './widget.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late var _util = OCSUtil.of(context);

  FocusNode? f1 = FocusNode();

  final _form = GlobalKey<FormState>();

  MRegisterHeader? header;

  final _firstNameTxt = TextEditingController(),
      _lastNameTxt = TextEditingController(),
      _passwordTxt = TextEditingController(),
      _phoneTxt = TextEditingController(),
      _confirmPasswordTxt = TextEditingController();

  bool _loading = false;
  bool _showPass = false;
  double _labelSize = Style.subTitleSize;

  late var _ocsAuth = OCSAuth.instance;

  void initState() {
    super.initState();
    f1!.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: WillPopScope(
        onWillPop: () async {
          if (!_loading) _util.navigator.pop();
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            top: false,
            bottom: false,
            child: Stack(
              children: [
                Parent(
                  style: ParentStyle()..width(_util.query.width),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _form,
                      child: Column(
                        children: [
                          SizedBox(
                            height: _util.query.top,
                          ),
                          Parent(
                            style: ParentStyle()
                              ..width(_util.query.width)
                              ..alignmentContent.centerLeft()
                              ..padding(horizontal: 10),
                            child: NavigatorBackButton(
                                loading: _loading, iconColor: OCSColor.text),
                          ),
                          Center(
                            child: Parent(
                              style: ParentStyle()
                                ..padding(horizontal: 20)
                                ..maxWidth(Globals.maxScreen),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Parent(
                                    style: ParentStyle()
                                      ..margin(
                                        top: _util.query.isKbPopup ? 0 : 20,
                                      ),
                                    child: SizedBox(
                                      child: Hero(
                                        child: BuildLogo(),
                                        tag: "logo",
                                      ),
                                      width: _util.query.isKbPopup ? 30 : 40,
                                      height: _util.query.isKbPopup ? 30 : 40,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  // if (!_util.query.isKbPopup)
                                  Parent(
                                    style: ParentStyle(),
                                    child: Hero(
                                      tag: 'logoText',
                                      child: SizedBox(
                                        height: _util.query.isKbPopup ? 15 : 20,
                                        child: BuildTextLogo(),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  BuildScreenTitle(
                                    title: "${_util.language.key("registers")}",
                                    fontSize: 18,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Parent(
                                    style: ParentStyle()
                                      ..padding(all: 15, horizontal: 15)
                                      ..borderRadius(all: 5)
                                      ..boxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blur: 5,
                                          offset: Offset(1, 1))
                                      // ..elevation(2, opacity: 0.1)
                                      ..background.color(Colors.white),
                                    child: Column(
                                      children: [
                                        Parent(
                                          style: ParentStyle(),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: MyTextField(
                                                  borderWidth:
                                                      Style.borderWidth,
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  readOnly: _loading,
                                                  controller: _firstNameTxt,
                                                  label:
                                                      "${_util.language.key("first-name")}",
                                                  labelTextSize: _labelSize,
                                                  placeholder:
                                                      "${_util.language.key("enter-first-name")}",
                                                  backgroundColor: Colors.white,
                                                  focusNode: f1,
                                                  autoValidateMode:
                                                      AutovalidateMode
                                                          .onUserInteraction,
                                                  validator: (v) {
                                                    if (v == "") {
                                                      return "${_util.language.key("this-field-is-required")}";
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                              SizedBox(width: 15),
                                              Expanded(
                                                child: MyTextField(
                                                  borderWidth:
                                                      Style.borderWidth,
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  readOnly: _loading,
                                                  controller: _lastNameTxt,
                                                  label:
                                                      "${_util.language.key("last-name")}",
                                                  labelTextSize: _labelSize,
                                                  placeholder:
                                                      "${_util.language.key("enter-last-name")}",
                                                  backgroundColor: Colors.white,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        MyTextField(
                                          borderWidth: Style.borderWidth,
                                          textInputAction: TextInputAction.next,
                                          leading: Parent(
                                            style: ParentStyle()
                                              ..margin(left: 10),
                                            child: Txt("+855",
                                                style: TxtStyle()
                                                  ..textColor(Colors.black54)),
                                          ),
                                          readOnly: _loading,
                                          controller: _phoneTxt,
                                          label:
                                              "${_util.language.key("phone-number")}",
                                          labelTextSize: _labelSize,
                                          placeholder: "12345678",
                                          textInputType:
                                              TextInputType.numberWithOptions(
                                                  decimal: false,
                                                  signed: false),
                                          backgroundColor: Colors.white,
                                          autoValidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          validator: (v) {
                                            if (v == "") {
                                              return "${_util.language.key("this-field-is-required")}";
                                            }
                                            final regExp =
                                                RegExp(AuthPattern.allPhone);
                                            if (!regExp.hasMatch(v!)) {
                                              return "${_util.language.key("invalid-phone-number")}";
                                            }
                                            return null;
                                          },
                                        ),
                                        MyTextField(
                                          borderWidth: Style.borderWidth,
                                          textInputAction: TextInputAction.next,
                                          readOnly: _loading,
                                          controller: _passwordTxt,
                                          label:
                                              "${_util.language.key("password")}",
                                          labelTextSize: _labelSize,
                                          placeholder:
                                              "${_util.language.key("enter-password")}",
                                          textInputType:
                                              TextInputType.visiblePassword,
                                          obscureText: !_showPass,
                                          backgroundColor: Colors.white,
                                          autoValidateMode: AutovalidateMode
                                              .onUserInteraction,
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
                                          suffixIcon: _showPass == true
                                              ? Remix.eye_line
                                              : Remix.eye_off_line,
                                          onChanged: (v) {
                                            // _password = v!;
                                          },
                                        ),
                                        MyTextField(
                                          borderWidth: Style.borderWidth,
                                          onSubmitted: (v) {
                                            _onSubmit();
                                          },
                                          readOnly: _loading,
                                          controller: _confirmPasswordTxt,
                                          label:
                                              "${_util.language.key("confirm-password")}",
                                          labelTextSize: _labelSize,
                                          placeholder:
                                              "${_util.language.key("enter-confirm-password")}",
                                          textInputType:
                                              TextInputType.visiblePassword,
                                          obscureText: !_showPass,
                                          backgroundColor: Colors.white,
                                          autoValidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          validator: (v) {
                                            if (v == "") {
                                              return "${_util.language.key("this-field-is-required")}";
                                            }
                                            if (v != _passwordTxt.text) {
                                              return "${_util.language.key("confirm-password-does-not-match")}";
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Parent(
                                    style: ParentStyle(),
                                    child: BuildButton(
                                      title:
                                          "${_util.language.key("register")}",
                                      width: 220,
                                      height: 45,
                                      fontSize: Style.titleSize,
                                      onPress: _onSubmit,
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Txt(
                                        "${_util.language.key("already-have-an-account")}",
                                        style: TxtStyle()
                                          ..textColor(OCSColor.text)
                                          ..fontSize(Style.subTitleSize),
                                      ),
                                      SizedBox(width: 10),
                                      Txt(
                                        "${_util.language.key("login")}",
                                        style: TxtStyle()
                                          ..textColor(OCSColor.text)
                                          ..fontSize(Style.titleSize)
                                          ..fontWeight(FontWeight.bold)
                                          ..margin(bottom: 2)
                                          ..textColor(
                                            OCSColor.primary,
                                          ),
                                        gesture: Gestures()
                                          ..onTap(() {
                                            if (!_loading)
                                              _util.navigator.replace(Login());
                                          }),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
    );
  }

  void _onSubmit() async {
    setState(() => _loading = true);
    var isValid = _form.currentState!.validate();

    if (!isValid) {
      setState(() => _loading = false);
      return;
    }
    var phone = _phoneTxt.text.trim();
    if (phone.indexOf("0") == 0) phone = phone.replaceFirst('0', '');
    phone = "+855$phone";

    var header = MRegisterHeader(
      firstName: _firstNameTxt.text.trim(),
      lastName: _lastNameTxt.text.trim().isNotEmpty
          ? _lastNameTxt.text.trim()
          : _firstNameTxt.text.trim(),
      password: _passwordTxt.text.trim(),
      confirmPassword: _confirmPasswordTxt.text.trim(),
      phone: phone,
      isPhoneOrEmailConfirm: 1,
      loginName: "auto_number",
      userType: "CUSTOMER",
    );
    var result = await _ocsAuth.register(header);
    if (!result.error) {
      _util.navigator.replace(VerificationCode(header: header),
          transition: OCSTransitions.LEFT);
    } else {
      _util.snackBar(
        message: _util.language.key(result.message),
        status: SnackBarStatus.danger,
      );
    }
    setState(() {
      _loading = false;
    });
  }
}
