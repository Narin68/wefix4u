import 'package:flutter/material.dart';
import 'package:ocs_auth/ocs_auth.dart';
import 'package:ocs_util/ocs_util.dart';
import '/globals.dart';
import '/screens/widget.dart';
import '../widget.dart';
import 'confirm_sms_change_email.dart';

class ChangeEmail extends StatefulWidget {
  @override
  _ChangeEmailState createState() => _ChangeEmailState();
}

class _ChangeEmailState extends State<ChangeEmail> {
  late var _util = OCSUtil.of(context);

  late var _auth = OCSAuth.instance;
  bool _loading = false;
  var _emailTxt = TextEditingController();
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: OCSColor.primary,
          leading: NavigatorBackButton(loading: _loading),
          title: Txt(
            _util.language.key('change-email'),
            style: TxtStyle()
              ..fontSize(16)
              ..textColor(Colors.white),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: Parent(
            gesture: Gestures()..onTap(() {}),
            style: ParentStyle()
              ..width(_util.query.width)
              ..alignmentContent.center(),
            child: Stack(
              children: [
                Parent(
                  style: ParentStyle()
                    ..padding(all: 16)
                    ..maxWidth(Globals.maxScreen),
                  child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (_util.query.isKbPopup) SizedBox(height: 10),
                        Expanded(child: SizedBox()),
                        SizedBox(
                          child: Parent(
                            style: ParentStyle(),
                            child: buildLogoImage(
                                source: 'assets/images/mail-sent.png',
                                width: _util.query.isKbPopup ? 60 : 80),
                          ),
                        ),
                        SizedBox(height: 10),
                        MyTextField(
                          borderWidth: Style.borderWidth,
                          focusNode: focusNode,
                          controller: _emailTxt,
                          label: _util.language.key("email"),
                          labelTextSize: 14,
                          placeholder: 'Example@mail.com',
                          textInputType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == "") {
                              return "${_util.language.key("this-field-is-required")}";
                            }
                            final regExp = RegExp(AuthPattern.email);
                            if (!regExp.hasMatch(v!)) {
                              return "${_util.language.key("invalid-email")}";
                            }
                            return null;
                          },
                          onSubmitted: (v) {
                            _onSubmit();
                          },
                        ),
                        SizedBox(height: 15),
                        Parent(
                          style: ParentStyle()
                            ..alignmentContent.center()
                            ..padding(horizontal: 16),
                          child: BuildButton(
                            iconData: Icons.send,
                            title: _util.language.key("send"),
                            width: 160,
                            fontSize: 16,
                            iconSize: 18,
                            height: 45,
                            onPress: _onSubmit,
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
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

  Future _onSubmit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _loading = true;
    });
    var result = await _auth.changeEmail(email: _emailTxt.text);

    if (!result.error) {
      _util.navigator.to(
        ConfirmChangeEmail(
          email: _emailTxt.text,
        ),
        transition: OCSTransitions.LEFT,
      );
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
  }
}
