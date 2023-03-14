import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ocs_auth/ocs_auth.dart';
import 'package:ocs_util/ocs_util.dart';
import '/globals.dart';
import '/blocs/user/user_cubit.dart';
import '/screens/widget.dart';
import '/firebase_auth.dart';
import '../widget.dart';

class ConfirmSMS extends StatefulWidget {
  final String? phone;

  ConfirmSMS({required this.phone});

  @override
  _ConfirmSMSState createState() => _ConfirmSMSState();
}

class _ConfirmSMSState extends State<ConfirmSMS> {
  late var _util = OCSUtil.of(context);

  late var _auth = OCSAuth.instance;
  bool _loading = false;
  var verCode = TextEditingController();

  Timer? _timer;

  int _count = 0;
  var _waiting = true;
  String _phone = "";
  String _token = "";
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _phone = widget.phone!;
    _onSend();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_loading) _util.navigator.pop();

        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: OCSColor.primary,
          leading: NavigatorBackButton(loading: _loading),
          title: Txt(
            _util.language.key('confirm-code'),
            style: TxtStyle()
              ..fontSize(16)
              ..textColor(Colors.white),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: Parent(
            style: ParentStyle()
              ..width(_util.query.width)
              ..alignmentContent.center(),
            child: Stack(
              children: [
                Parent(
                  style: ParentStyle()
                    ..padding(horizontal: 20)
                    ..maxWidth(Globals.maxScreen),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: SizedBox()),
                      SizedBox(
                        child: Parent(
                          style: ParentStyle(),
                          child: buildLogoImage(
                              source: 'assets/images/mail-confirm.png',
                              width: _util.query.isKbPopup ? 60 : 80),
                        ),
                      ),
                      SizedBox(height: 20),
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
                        },
                        currentCode: verCode.text,
                        onCodeSubmitted: (v) {
                          if (v.length == 6) _onSubmit();
                        },
                      ),
                      SizedBox(height: 20),
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
                              ..fontSize(14)
                              ..textColor(Colors.black38),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Txt(
                        "${_util.language.key("your-code-has-sent-to")} ${_phone}",
                        style: TxtStyle()
                          ..fontSize(14)
                          ..textAlign.center()
                          ..textColor(Colors.black38),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      _waiting == false
                          ? Parent(
                              style: ParentStyle(),
                              child: BuildButton(
                                title: "${_util.language.key("resend-code")}",
                                height: 45,
                                width: 180,
                                fontSize: 16,
                                onPress: _resend,
                              ),
                            )
                          : Parent(
                              style: ParentStyle(),
                              child: BuildButton(
                                title: "${_util.language.key("verify")}",
                                width: 160,
                                fontSize: 15,
                                iconSize: 18,
                                height: 45,
                                onPress: () {
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
                                  } else
                                    _onSubmit();
                                },
                              ),
                            ),
                      Expanded(child: SizedBox()),
                      Expanded(child: SizedBox()),
                    ],
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
                  )
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

  Future _onSend() async {
    setState(() {
      _loading = true;
    });
    await MyFirebaseAuth.sendSms(_phone, onError: (e) async {
      print("[Error change phone] $e");
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
        var result = await _auth.changePhone(
            phone: _phone, confirmToken: user?.displayName ?? "");
        if (!result.error) {
          setState(() {
            _loading = true;
          });
          await context.read<MyUserCubit>().get();
          setState(() {
            _loading = false;
          });
          _util.pop();
          _util.navigator.replace(
            BuildSuccessScreen(
              successTitle: "${_util.language.key("success-change-phone")}",
            ),
          );
        } else {
          _util.snackBar(
              message: '${result.message}', status: SnackBarStatus.danger);
          setState(() {
            _loading = false;
          });
        }
      },
      onError: (e) {
        _util.snackBar(
            message: '${_util.language.key("invalid-code")}',
            status: SnackBarStatus.danger);
        setState(() {
          _loading = false;
        });
      },
    );
  }

  Future _resend() async {
    setState(() {
      _loading = true;
    });
    await MyFirebaseAuth.sendSms(
      _phone,
      onError: (e) async {
        _util.snackBar(
          message: '${_util.language.key("You-phone-have-problem")}',
          status: SnackBarStatus.danger,
        );
        setState(() => _loading = false);
      },
      onSuccess: (v) async {
        setState(() {
          _token = v;
          _loading = false;
        });
        _util.navigator.replace(ConfirmSMS(phone: _phone));
      },
    );
    setState(() {
      _loading = false;
    });
  }

  @override
  void dispose() {
    if (_timer != null) _timer?.cancel();
    super.dispose();
  }
}
