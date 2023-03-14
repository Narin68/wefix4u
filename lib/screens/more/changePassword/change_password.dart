import 'package:flutter/material.dart';
import 'package:ocs_auth/ocs_auth.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '/globals.dart';
import '/screens/widget.dart';
import '../widget.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  late var _util = OCSUtil.of(context);

  late var _auth = OCSAuth.instance;
  bool _loading = false;
  bool _hideOldPass = true;
  bool _hideNewPass = true;
  var _oldPasswordTxt = TextEditingController();
  var _newPasswordTxt = TextEditingController();
  var _confirmPasswordTxt = TextEditingController();
  var _form = GlobalKey<FormState>();
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_loading) _util.navigator.pop();

        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: OCSColor.primary,
          leading: NavigatorBackButton(loading: _loading),
          title: Txt(
            _util.language.key('change-password'),
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
                Column(
                  children: [
                    AnimatedContainer(
                      height: _util.query.isKbPopup ? 20 : 80,
                      curve: Curves.bounceIn,
                      duration: Duration(milliseconds: 100),
                    ),
                    Parent(
                      style: ParentStyle()
                        ..maxWidth(Globals.maxScreen)
                        ..padding(all: 15, vertical: 0),
                      child: Form(
                        key: _form,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              width: _util.query.isKbPopup ? 60 : 80,
                              curve: Curves.easeInOut,
                              duration: Duration(milliseconds: 150),
                              child: buildLogoImage(
                                source: 'assets/images/password.png',
                              ),
                            ),
                            if (!_util.query.isKbPopup) SizedBox(height: 20),
                            MyTextField(
                              borderWidth: Style.borderWidth,
                              textInputAction: TextInputAction.next,
                              focusNode: focusNode,
                              controller: _oldPasswordTxt,
                              label: "${_util.language.key("old-password")}",
                              labelTextSize: 14,
                              placeholder:
                                  "${_util.language.key("enter-old-password")}",
                              textInputType: TextInputType.visiblePassword,
                              obscureText: _hideNewPass,
                              suffixIcon: _hideNewPass
                                  ? Remix.eye_off_line
                                  : Remix.eye_line,
                              suffixOnPressed: (v) {
                                setState(() {
                                  _hideNewPass = !_hideNewPass;
                                });
                              },
                              validator: (v) {
                                if (v == "") {
                                  return "${_util.language.key("this-field-is-required")}";
                                }
                                return null;
                              },
                            ),
                            MyTextField(
                              borderWidth: Style.borderWidth,
                              textInputAction: TextInputAction.next,
                              controller: _newPasswordTxt,
                              label: "${_util.language.key("new-password")}",
                              labelTextSize: 14,
                              placeholder:
                                  "${_util.language.key("enter-new-password")}",
                              textInputType: TextInputType.visiblePassword,
                              obscureText: _hideOldPass,
                              suffixIcon: _hideOldPass
                                  ? Remix.eye_off_line
                                  : Remix.eye_line,
                              suffixOnPressed: (v) {
                                setState(() {
                                  _hideOldPass = !_hideOldPass;
                                });
                              },
                              validator: (v) {
                                if (v == "") {
                                  return "${_util.language.key("this-field-is-required")}";
                                }
                                if (v!.length < 6) {
                                  return "${_util.language.key('invalid-password')}";
                                }
                                return null;
                              },
                            ),
                            MyTextField(
                              borderWidth: Style.borderWidth,
                              controller: _confirmPasswordTxt,
                              label:
                                  "${_util.language.key("confirm-password")}",
                              labelTextSize: 14,
                              placeholder:
                                  "${_util.language.key("confirm-password")}",
                              textInputType: TextInputType.visiblePassword,
                              obscureText: _hideOldPass,
                              autoValidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (v) {
                                if (v == "") {
                                  return "${_util.language.key("this-field-is-required")}";
                                }
                                if (v != _newPasswordTxt.text) {
                                  return "${_util.language.key("confirm-password-does-not-match")}";
                                }
                                return null;
                              },
                              onSubmitted: (v) {
                                _onChangePass();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    if (!_util.query.isKbPopup) SizedBox(),
                    Parent(
                      style: ParentStyle()
                        ..alignmentContent.center()
                        ..padding(horizontal: 16),
                      child: BuildButton(
                        title: "${_util.language.key("update")}",
                        width: 160,
                        fontSize: 15,
                        iconSize: 18,
                        height: 45,
                        onPress: _onChangePass,
                      ),
                    ),
                    Expanded(
                      child: SizedBox(),
                      flex: 2,
                    ),
                  ],
                ),
                if (_loading)
                  Positioned(
                    child: Container(
                      color: Colors.black.withOpacity(.3),
                      child: const Center(
                        child: CircularProgressIndicator.adaptive(),
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

  Future _onChangePass() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _loading = true;
    });
    var result = await _auth.changePassword(
      oldPassword: _oldPasswordTxt.text,
      password: _newPasswordTxt.text,
      confirmPassword: _confirmPasswordTxt.text,
    );

    if (!result.error) {
      _util.navigator.replace(
          BuildSuccessScreen(
            successTitle:
                "${_util.language.key("you-success-change-your-new-password")}",
          ),
          transition: OCSTransitions.LEFT);
    } else {
      _util.snackBar(
        message: result.message,
        status: SnackBarStatus.danger,
      );
    }
    setState(() {
      _loading = false;
    });
  }
}
