import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ocs_auth/ocs_auth.dart';
import 'package:ocs_util/ocs_util.dart';
import '/globals.dart';
import '/blocs/user/user_cubit.dart';
import '/screens/widget.dart';
import '../widget.dart';

class ConfirmChangeEmail extends StatefulWidget {
  final String? email;

  ConfirmChangeEmail({required this.email});

  @override
  _ConfirmChangeEmailState createState() => _ConfirmChangeEmailState();
}

class _ConfirmChangeEmailState extends State<ConfirmChangeEmail> {
  late var _util = OCSUtil.of(context);

  late var _auth = OCSAuth.instance;
  bool _loading = false;
  var verCode = TextEditingController();

  Timer? _timer;

  int _count = 0;
  var _waiting = true;
  String _email = "";
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _email = widget.email!;
    _setTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              // Parent(
              //   style: ParentStyle(),
              //   child: IconButton(
              //     tooltip: _util.language.key('back'),
              //     onPressed: () {
              //       _util.navigator.pop();
              //     },
              //     icon: Icon(
              //       Remix.arrow_left_line,
              //       size: 20,
              //       color: OCSColor.text,
              //     ),
              //   ),
              // ),
              Parent(
                style: ParentStyle()
                  ..padding(horizontal: 20)
                  ..maxWidth(Globals.maxScreen),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: SizedBox()),
                    Parent(
                      style: ParentStyle(),
                      child: buildLogoImage(
                          source: 'assets/images/mail-confirm.png',
                          width: _util.query.isKbPopup ? 60 : 80),
                    ),
                    SizedBox(height: 10),
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
                      "${_util.language.key("your-code-has-sent-to")} ${_email}",
                      style: TxtStyle()
                        ..fontSize(14)
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

  Future _onSubmit() async {
    setState(() {
      _loading = true;
    });

    var result = await _auth.changeEmail(
        email: widget.email!, validateToken: verCode.text);
    if (!result.error) {
      var response = await _auth.changeEmail(
        email: widget.email!,
        confirmToken: verCode.text,
        validateToken: verCode.text,
      );

      if (!response.error) {
        setState(() {
          _loading = true;
        });
        context.read<MyUserCubit>().get(getCustomer: false);
        setState(() {
          _loading = false;
        });
        _util.pop();
        _util.navigator.replace(BuildSuccessScreen(
          successTitle: _util.language.key("you-success-change-your-new-email"),
        ));
      } else {
        _util.snackBar(
            message: '${response.message}', status: SnackBarStatus.danger);
        setState(() {
          _loading = false;
        });
      }
    } else {
      _util.snackBar(
          message: '${result.message}', status: SnackBarStatus.danger);
      setState(() {
        _loading = false;
      });
    }
  }

  Future _resend() async {
    setState(() {
      _loading = true;
    });
    var result = await _auth.changeEmail(email: widget.email!);

    if (!result.error) {
      _util.navigator.to(ConfirmChangeEmail(
        email: widget.email,
      ));
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

  @override
  void dispose() {
    if (_timer != null) _timer?.cancel();
    super.dispose();
  }
}
