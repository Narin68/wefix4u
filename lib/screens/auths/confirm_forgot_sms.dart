import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ocs_auth/ocs_auth.dart';
import '../widget.dart';
import '/globals.dart';
import '/firebase_auth.dart';
import '/screens/auths/set_new_password.dart';
import 'package:ocs_util/ocs_util.dart';

import './widget.dart';

class ConfirmForgotCode extends StatefulWidget {
  final String? phone;

  final String? email;

  final bool isEmail;

  ConfirmForgotCode({this.phone, this.email, this.isEmail = false});

  @override
  _ConfirmForgotCodeState createState() => _ConfirmForgotCodeState();
}

class _ConfirmForgotCodeState extends State<ConfirmForgotCode> {
  late var _util = OCSUtil.of(context);
  var verCode = TextEditingController();

  Timer? _timer;

  int _count = 0;
  var _loading = false, _waiting = true;

  late var _auth = OCSAuth.instance;
  var _token = '';
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    if (widget.isEmail == false) {
      _onSendPhone();
    } else {
      _setTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Parent(
          style: ParentStyle()..width(_util.query.width),
          child: Center(
            child: Stack(
              children: [
                Column(
                  children: [
                    SizedBox(height: _util.query.top),
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
                        ..padding(horizontal: 30)
                        ..maxWidth(Globals.maxScreen),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Parent(
                            style: ParentStyle(),
                            child: Hero(
                              tag: "logo",
                              child: SizedBox(
                                child: BuildLogo(),
                                width: _util.query.isKbPopup == true ? 35 : 45,
                                height: _util.query.isKbPopup == true ? 35 : 45,
                              ),
                            ),
                          ),
                          if (!_util.query.isKbPopup) SizedBox(height: 15),
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
                              title:
                                  "${_util.language.key("verification-code")}"),
                          SizedBox(
                            height: 10,
                          ),
                          PinFieldAutoFill(
                            focusNode: focusNode,
                            decoration: UnderlineDecoration(
                              colorBuilder: PinListenColorBuilder(
                                OCSColor.primary,
                                Colors.black12,
                              ),
                              gapSpace: 10,
                            ),
                            codeLength: 6,
                            onCodeChanged: (v) {
                              verCode.text = v!;
                              if (v.length == 6) {
                                if (widget.isEmail == false) {
                                  _onSubmit();
                                } else {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  _onSubmitEmail();
                                }
                              }
                            },
                            currentCode: verCode.text,
                            onCodeSubmitted: (v) {
                              if (v.length == 6) _onSubmit();
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.black38,
                              ),
                              SizedBox(width: 5),
                              Txt(
                                "${_count}s",
                                style: TxtStyle()
                                  ..fontSize(Style.subTitleSize)
                                  ..textColor(OCSColor.text.withOpacity(0.7)),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Txt(
                            "${_util.language.key("your-code-has-sent-to")} ${!widget.isEmail ? widget.phone : widget.email}",
                            style: TxtStyle()
                              ..fontSize(Style.subTitleSize)
                              ..textColor(OCSColor.text.withOpacity(0.7))
                              ..textAlign.center(),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          _waiting == false
                              ? Parent(
                                  style: ParentStyle(),
                                  child: BuildButton(
                                    title:
                                        "${_util.language.key("resend-code")}",
                                    height: 45,
                                    width: 180,
                                    fontSize: Style.titleSize,
                                    onPress: widget.isEmail == false
                                        ? _reSend
                                        : _resendEmail,
                                  ),
                                )
                              : Parent(
                                  style: ParentStyle(),
                                  child: BuildButton(
                                    title: "${_util.language.key("verify")}",
                                    height: 45,
                                    width: 180,
                                    fontSize: Style.titleSize,
                                    onPress: () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      if (verCode.text == "") {
                                        _util.snackBar(
                                          message:
                                              '${_util.language.key("please-input-code")}',
                                          status: SnackBarStatus.danger,
                                        );
                                      } else if (verCode.text.length < 6) {
                                        _util.snackBar(
                                          message:
                                              '${_util.language.key("code-must-be-6-digit")}',
                                          status: SnackBarStatus.danger,
                                        );
                                      } else if (widget.isEmail == false) {
                                        _onSubmit();
                                      } else {
                                        _onSubmitEmail();
                                      }
                                    },
                                  ),
                                ),
                          SizedBox(
                            height: 15,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: SizedBox()),
                    Expanded(child: SizedBox()),
                  ],
                ),
                if (_loading)
                  Positioned(
                    child: Container(
                      color: Colors.black.withOpacity(.3),
                      child: const Center(
                          child: CircularProgressIndicator.adaptive()),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _setTimer() async {
    _count = 120;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_count == 0) {
        _timer?.cancel();
        _waiting = false;
      } else {
        _count--;
        _waiting = true;
      }
      setState(() {});
    });
  }

  Future _onSubmitEmail() async {
    setState(() {
      _loading = true;
    });

    var result = await _auth.emailForgot(
      MForgotHeader(identity: widget.email!, confirmToken: verCode.text),
    );
    if (!result.error) {
      _util.navigator.pop();
      _util.navigator.replace(
        SetNewPassword(
          header: MForgotHeader(
              confirmToken: verCode.text, identity: widget.email!),
          isEmail: true,
        ),
      );
    } else {
      _util.snackBar(
          message: '${result.message}', status: SnackBarStatus.danger);
    }

    setState(() {
      _loading = false;
    });
  }

  Future _onSendPhone() async {
    setState(() {
      _loading = true;
    });
    String phone = widget.phone!;
    if (phone.indexOf("0") == 0) phone = phone.replaceFirst('0', '');
    await MyFirebaseAuth.sendSms("+855" + phone, onError: (e) async {
      _util.snackBar(
        message: '${_util.language.key("You-phone-have-problem")}',
        status: SnackBarStatus.danger,
      );
      setState(() {
        _loading = false;
      });
      _util.navigator.pop();
    }, onSuccess: (v) async {
      await _setTimer();
      focusNode.requestFocus();
      setState(() {
        _token = v;
        _loading = false;
      });
    }, onCompleted: (e) {
      setState(() {
        _loading = false;
      });
    });
  }

  Future _onSubmit() async {
    setState(() {
      _loading = true;
    });
    await MyFirebaseAuth.confirmSms(
      code: verCode.text,
      token: _token,
      onSuccess: (user) async {
        _util.navigator.pop();
        _util.navigator.replace(
          SetNewPassword(
            header: MForgotHeader(
              identity: widget.phone ?? "",
              confirmToken: user?.displayName ?? "",
            ),
            isEmail: false,
          ),
          isFade: true,
          transition: OCSTransitions.LEFT,
        );
      },
      onError: (e) {
        print(e);
        _util.snackBar(
            message: '${_util.language.key("invalid-code")}',
            status: SnackBarStatus.danger);
      },
    );
    setState(() {
      _loading = false;
    });
  }

  Future _resendEmail() async {
    setState(() {
      _loading = true;
    });
    var result = await _auth.changeEmail(email: widget.email!);

    if (!result.error) {
      _util.navigator.replace(
          ConfirmForgotCode(
            email: widget.email,
            isEmail: true,
          ),
          isFade: true);
      setState(() {
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
      _util.snackBar(
        message: result.message,
        status: SnackBarStatus.danger,
      );
    }
    setState(() {
      _loading = false;
    });
  }

  Future _reSend() async {
    setState(() {
      _loading = true;
    });

    var result =
        await _auth.phoneForgot(MForgotHeader(identity: widget.phone!));

    if (!result.error) {
      _util.navigator
          .replace(ConfirmForgotCode(phone: widget.phone), isFade: true);
    } else {
      _util.snackBar(message: result.message, status: SnackBarStatus.danger);
    }
  }

  @override
  void dispose() {
    if (_timer != null) _timer?.cancel();
    super.dispose();
    if (!mounted) {
      return;
    }
  }
}
