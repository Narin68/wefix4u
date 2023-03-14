import 'package:flutter/material.dart';
import 'package:ocs_auth/ocs_auth.dart';
import 'package:ocs_util/ocs_util.dart';
import '/screens/widget.dart';
import '/globals.dart';

import './widget.dart';
import 'confirm_forgot_sms.dart';

class ForgotByPhoneOrEmail extends StatefulWidget {
  final bool? isEmail;


  ForgotByPhoneOrEmail({Key? key,this.isEmail})  : super(key: key);

  @override
  _ForgotByPhoneOrEmailState createState() => _ForgotByPhoneOrEmailState();
}

class _ForgotByPhoneOrEmailState extends State<ForgotByPhoneOrEmail> {
  late var _util = OCSUtil.of(context);

  late var _auth = OCSAuth.instance;
  var _form = GlobalKey<FormState>();
  bool _loading = false;
  var _textController = TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.requestFocus();
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
            child: Form(
              key: _form,
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
                          ..padding(horizontal: 20)
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
                                  width:
                                      _util.query.isKbPopup == true ? 35 : 45,
                                  height:
                                      _util.query.isKbPopup == true ? 35 : 45,
                                ),
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
                              height: _util.query.isKbPopup ? 10 : 15,
                            ),
                            BuildScreenTitle(
                              title: _util.language.key(
                                  "${widget.isEmail == true ? "confirm-by-email" : "confirm-by-phone"}"),
                              fontSize: 18,
                            ),
                            SizedBox(
                              height: _util.query.isKbPopup ? 10 : 20,
                            ),
                            MyTextField(
                              borderWidth: Style.borderWidth,
                              leading: widget.isEmail == true
                                  ? SizedBox()
                                  : Parent(
                                      style: ParentStyle()..margin(left: 10),
                                      child: Txt("+855",
                                          style: TxtStyle()
                                            ..textColor(Colors.black54)),
                                    ),
                              focusNode: focusNode,
                              controller: _textController,
                              readOnly: _loading,
                              label: _util.language.key(
                                  "${widget.isEmail == true ? "email" : "phone-number"}"),
                              labelTextSize: Style.subTitleSize,
                              placeholder:
                                  "${widget.isEmail == true ? _util.language.key("enter-email") : "12345678"}",
                              backgroundColor: Colors.white,
                              textInputType: widget.isEmail == true
                                  ? TextInputType.emailAddress
                                  : TextInputType.numberWithOptions(
                                      decimal: false, signed: false),
                              validator: (v) {
                                if (v == "")
                                  return "${_util.language.key("this-field-is-required")}";
                                if (widget.isEmail!) {
                                  final regExp = RegExp(AuthPattern.email);
                                  if (!regExp.hasMatch(v!)) {
                                    return "${_util.language.key("invalid-email")}";
                                  }
                                } else {
                                  final regExp = RegExp(AuthPattern.allPhone);
                                  if (!regExp.hasMatch(v!)) {
                                    return "${_util.language.key("invalid-phone-number")}";
                                  }
                                }
                                return null;
                              },
                              onSubmitted: (v) async {
                                widget.isEmail == false
                                    ? await _onConfirmPhone()
                                    : await _onConfirmEmail();
                              },
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Parent(
                              style: ParentStyle(),
                              child: BuildButton(
                                iconData: Icons.send,
                                title: "${_util.language.key("send")}",
                                height: 45,
                                width: 180,
                                fontSize: Style.titleSize,
                                onPress: () {
                                  widget.isEmail == false
                                      ? _onConfirmPhone()
                                      : _onConfirmEmail();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(flex: 2, child: SizedBox()),
                    ],
                  ),
                  if (_loading)
                    Positioned(
                        child: Container(
                      color: Colors.black.withOpacity(.3),
                      child: const Center(
                          child: CircularProgressIndicator.adaptive()),
                    )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _onConfirmEmail() async {
    if (_form.currentState!.validate() == false) return;
    setState(() {
      _loading = true;
    });
    var result = await _auth.emailForgot(
      MForgotHeader(identity: _textController.text),
    );

    if (!result.error) {
      _util.navigator.to(
        ConfirmForgotCode(email: _textController.text, isEmail: true),
      );
    } else {
      _util.snackBar(message: result.message, status: SnackBarStatus.danger);
    }
    setState(() {
      _loading = false;
    });
  }

  Future _onConfirmPhone() async {
    var result;
    String phone = '';
    if (_form.currentState!.validate() == false) return;
    if (_textController.text.trim().contains('0')) {
      if (_textController.text.trim().indexOf('0') == 0)
        phone = _textController.text.trim();
      else
        phone = '0' + _textController.text.trim();
    } else
      phone = '0' + _textController.text.trim();
    setState(() {
      _loading = true;
    });
    result = await _auth.phoneForgot(MForgotHeader(identity: phone));
    if (!result.error) {
      _util.navigator.to(
        ConfirmForgotCode(
          phone: phone,
        ),
      );
    } else {
      _util.snackBar(message: result.message, status: SnackBarStatus.danger);
    }
    setState(() {
      _loading = false;
    });
  }
}
