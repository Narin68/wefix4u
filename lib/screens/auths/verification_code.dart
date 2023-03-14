import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ocs_auth/ocs_auth.dart';
import '/blocs/partner/partner_cubit.dart';
import '/signalr.dart';
import '/blocs/service_request/service_request_bloc.dart';
import '/functions.dart';
import '/blocs/user/user_cubit.dart';
import '/screens/request_service/request_form.dart';
import '/globals.dart';
import '/firebase_auth.dart';
import 'package:ocs_util/ocs_util.dart';
import '../widget.dart';
import './widget.dart';

class VerificationCode extends StatefulWidget {
  final MRegisterHeader? header;

  VerificationCode({this.header});

  @override
  _VerificationCodeState createState() => _VerificationCodeState();
}

class _VerificationCodeState extends State<VerificationCode> {
  late var _util = OCSUtil.of(context);
  var verCode = TextEditingController();

  Timer? _timer;

  int _count = 0;
  var _loading = false, _waiting = true;

  late var _auth = OCSAuth.instance;
  var _token = '';
  GlobalKey _scaffold = GlobalKey();

  @override
  void initState() {
    super.initState();
    _onSend();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
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
                                width: _util.query.isKbPopup == true ? 70 : 90,
                                height: _util.query.isKbPopup == true ? 70 : 90,
                              ),
                            ),
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
                            height: 10,
                          ),
                          BuildScreenTitle(
                            title: "${_util.language.key("verification-code")}",
                            fontSize: 18,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          PinFieldAutoFill(
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
                              if (v.length == 6) _onSubmit();
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
                            "${_util.language.key("your-code-has-sent-to")} ${widget.header!.phone}",
                            style: TxtStyle()
                              ..fontSize(Style.subTitleSize)
                              ..textAlign.center()
                              ..textColor(OCSColor.text.withOpacity(0.7)),
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
                                    onPress: () {
                                      _reSend();
                                    },
                                  ),
                                )
                              : Parent(
                                  style: ParentStyle(),
                                  child: BuildButton(
                                    title: "${_util.language.key("verify")}",
                                    height: 45,
                                    width: 180,
                                    fontSize: Style.titleSize,
                                    onPress: () async {
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
                                      } else if (verCode.text.length == 6) {
                                        await _onSubmit();
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
                    Expanded(flex: 2, child: SizedBox()),
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
                  )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _setTimer() {
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
    await MyFirebaseAuth.confirmSms(
      code: verCode.text,
      token: _token,
      onSuccess: (user) async {
        var result = await _auth.register(MRegisterHeader(
          phone: widget.header?.phone,
          confirmToken: user?.displayName ?? '',
          isPhoneOrEmailConfirm: 1,
        ));
        if (!result.error) {
          if (!Globals.isRequestService) {
            Globals.navIndex = 4;
          }
          await _login();
        } else {
          _util.snackBar(
              message: '${_util.language.key("error-confirm")}',
              status: SnackBarStatus.danger);
        }
      },
      onError: (e) {
        _util.snackBar(
            message: '${_util.language.key("invalid-code")}',
            status: SnackBarStatus.danger);
      },
    );
    setState(() {
      _loading = false;
    });
  }

  Future _onSend() async {
    setState(() {
      _loading = true;
    });

    await MyFirebaseAuth.sendSms(
      '${widget.header!.phone}',
      onError: (e) async {
        setState(() {
          _loading = false;
        });
        print('Error when send sms to phone number $e');
        _util.snackBar(
          message: '${_util.language.key("You-phone-have-problem")}',
          status: SnackBarStatus.danger,
        );
        _util.navigator.pop();
      },
      onSuccess: (token) async {
        _setTimer();
        setState(() {
          _token = token;
          _loading = false;
        });
      },
    );
  }

  Future _reSend() async {
    setState(() {
      _loading = true;
    });

    var result =
        await _auth.register(widget.header!.copyWith(isPhoneOrEmailConfirm: 2));

    if (!result.error) {
      _util.navigator
          .replace(VerificationCode(header: widget.header), isFade: true);
    } else {
      _util.snackBar(message: result.message, status: SnackBarStatus.danger);
    }
    setState(() {
      _loading = false;
    });
  }

  Future _login() async {
    var result = await _auth.login(
      grantType: GrantType.password,
      password: widget.header?.password ?? "",
      userName: widget.header?.phone,
    );
    if (!result.error) {
      await setUsedAccess();
      Globals.hasAuth = true;
      await context.read<ServiceRequestBloc>()
        ..add(ReloadServiceRequest());
      if (!Globals.isRequestService) {
        Globals.navIndex = 4;
      }
      await context.read<MyUserCubit>().get();
      await context.read<PartnerCubit>().getPartnerRequest(Model.customer.id);
      if (Globals.isRequestService) {
        Globals.isRequestService = false;
        Globals.userType = 'customer';
        _util.navigator.replace(RequestForm());
        _util.navigator.to(
          BuildSuccessScreen(
            successTitle: _util.language.key('success'),
          ),
        );
      } else {
        Globals.navIndex = 4;
        Globals.isFromLogin = false;
        _util.navigator.replace(
          BuildSuccessScreen(
            successTitle: _util.language.key('success'),
          ),
        );
      }
      reConnectSignalR();
      saveFirebaseToken();
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

  @override
  void dispose() {
    if (_timer != null) _timer?.cancel();
    super.dispose();
  }
}
