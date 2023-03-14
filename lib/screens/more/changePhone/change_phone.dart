import 'package:flutter/material.dart';
import 'package:ocs_auth/ocs_auth.dart';
import 'package:ocs_util/ocs_util.dart';
import '/screens/widget.dart';
import '/globals.dart';
import '../widget.dart';
import 'confirm_sms.dart';

class ChangePhone extends StatefulWidget {
  @override
  _ChangePhoneState createState() => _ChangePhoneState();
}

class _ChangePhoneState extends State<ChangePhone> {
  late var _util = OCSUtil.of(context);

  late var _auth = OCSAuth.instance;
  bool _loading = false;
  var _phoneTxt = TextEditingController();
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
            _util.language.key('change-phone'),
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
                    ..padding(all: 15)
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
                                  source: 'assets/images/phone-call-1.png',
                                  width: _util.query.isKbPopup ? 60 : 80)),
                        ),
                        SizedBox(height: 20),
                        MyTextField(
                          borderWidth: Style.borderWidth,
                          leading: Parent(
                            style: ParentStyle()..margin(left: 10),
                            child: Txt("+855",
                                style: TxtStyle()..textColor(Colors.black54)),
                          ),
                          focusNode: focusNode,
                          controller: _phoneTxt,
                          label: "${_util.language.key("phone-number")}",
                          labelTextSize: 14,
                          placeholder: "12345678",
                          textInputType: TextInputType.numberWithOptions(
                              signed: false, decimal: false),
                          validator: (v) {
                            if (v == "") {
                              return "${_util.language.key("this-field-is-required")}";
                            }
                            final regExp = RegExp(AuthPattern.allPhone);
                            if (!regExp.hasMatch(v!)) {
                              return "${_util.language.key("invalid-phone-number")}";
                            }
                            return null;
                          },
                          onSubmitted: (v) {
                            _onSubmit();
                          },
                        ),
                        SizedBox(height: 10),
                        Parent(
                          style: ParentStyle()
                            ..alignmentContent.center()
                            ..padding(horizontal: 16),
                          child: BuildButton(
                            iconData: Icons.send,
                            title: "${_util.language.key("send")}",
                            width: 160,
                            fontSize: 15,
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
    setState(() {
      _loading = false;
    });
    if (!_form.currentState!.validate()) return;
    setState(() {
      _loading = true;
    });
    var phone = _phoneTxt.text.trim();
    if (phone.indexOf("0") == 0) phone = phone.replaceFirst('0', '');
    phone = "+855$phone";

    var result = await _auth.changePhone(phone: phone);

    if (!result.error) {
      _util.navigator.to(ConfirmSMS(phone: phone));
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
