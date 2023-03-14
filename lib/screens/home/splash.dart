import 'package:flutter/material.dart';
import 'package:ocs_auth/ocs_auth.dart';
import 'package:ocs_auth/repos/user.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '/functions.dart';
import '../auths/login.dart';
import '../function_temp.dart';
import '/repositories/partner_repo.dart';
import '/globals.dart';
import '/modals/customer.dart';
import '/modals/partner.dart';
import '/repositories/customer.dart';
import 'home_menus.dart';

class SplashScreen extends StatefulWidget {
  final bool? loading;
  final bool? reload;

  SplashScreen({this.loading = false, this.reload});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late var _util = OCSUtil.of(context);

  late var _auth = OCSAuth.instance;
  bool _isRetry = false;
  int _onRetryCount = 0;
  MMyCustomer _customer = MMyCustomer();
  PartnerRepo _partnerRepo = PartnerRepo();

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _init() async {
    await _checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OCSColor.primary,
      body: SafeArea(
        bottom: false,
        child: Parent(
          style: ParentStyle()..width(_util.query.width),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: _isRetry
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Remix.error_warning_line,
                                    color: Colors.black38, size: 50),
                                SizedBox(
                                  height: 10,
                                ),
                                Txt('Something when wrong please try again',
                                    style: TxtStyle()
                                      ..textColor(Colors.black38)
                                      ..margin(bottom: 20)),
                                Txt(
                                  'Retry $_onRetryCount',
                                  gesture: Gestures()
                                    ..onTap(() {
                                      _onRetryCount++;
                                      if (_onRetryCount > 5) _auth.logout();
                                      _checkAuth();
                                      setState(() {});
                                    }),
                                  style: TxtStyle()
                                    ..border(all: 1, color: Colors.black38)
                                    ..textColor(Colors.black38)
                                    ..fontWeight(FontWeight.w600)
                                    ..fontSize(14)
                                    ..ripple(true)
                                    ..padding(horizontal: 20, vertical: 10)
                                    ..borderRadius(all: 5)
                                    ..background.color(Colors.transparent),
                                ),
                              ],
                            ),
                          )
                        : Center(
                            child: !(widget.loading ?? false)
                                ? SizedBox(
                                    child: Center(
                                      child: Image.asset(
                                          "assets/logo/logo-white.png"),
                                    ),
                                    height: 70,
                                  )
                                : const CircularProgressIndicator.adaptive(
                                    backgroundColor: Colors.white,
                                  ),
                          ),
                  ),
                  Parent(
                    style: ParentStyle()
                      ..margin(
                          bottom: _util.query.bottom <= 0
                              ? 15
                              : _util.query.bottom),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Txt(
                          "Developed by . ",
                          style: TxtStyle()
                            ..fontSize(Style.subTitleSize)
                            ..textColor(Colors.white),
                        ),
                        SizedBox(width: 5),
                        Txt(
                          "wefix4u",
                          style: TxtStyle()
                            ..fontSize(Style.subTitleSize)
                            ..fontWeight(FontWeight.bold)
                            ..textColor(Colors.white),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              if (widget.reload != null && widget.reload == true)
                Positioned(
                  child: Parent(
                    style: ParentStyle()..background.color(Colors.white),
                    child: const Center(
                      child: CircularProgressIndicator.adaptive(
                        valueColor: AlwaysStoppedAnimation(Colors.blue),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future _noCustomer() async {
    var currentCus = await CustomerRepo.getCusFromPref();
    if (currentCus != null) {
      Model.customer = currentCus;
    } else {
      CustomerRepo _customerRepo = CustomerRepo();
      var cusResp = await _customerRepo
          .list(MMyCustomerFilter(code: Model.userInfo.loginName));
      if (!cusResp.error) {
        Model.customer = cusResp.data.length < 1
            ? MMyCustomer()
            : (cusResp.data ?? []).first;
      }
    }

    if (Globals.userType.toLowerCase() == UserType.customer) {
      Model.customer = _customer;
      _util.navigator.replace(HomeMenus(), isFade: true);
    } else if (Globals.userType.toLowerCase() == UserType.partner) {
      await _checkPartnerData();
    }
  }

  Future _hasCustomer() async {
    if (Globals.userType.toLowerCase() == UserType.customer) {
      _util.navigator.replace(HomeMenus(), isFade: true);
    } else if (Globals.userType.toLowerCase() == UserType.partner) {
      await _checkPartnerData();
    }
  }

  Future _checkPartnerData() async {
    MPartner? partner = await PartnerRepo.getPartnerFromPref();

    if (partner != null) {
      Model.partner = partner;
      _util.navigator.replace(HomeMenus(), isFade: true);
    } else {
      var res = await PartnerRepo().getPartner(Model.customer.id);
      if (!res.error) {
        var partner = res.data.length < 1 ? MPartner() : (res.data ?? []).first;
        Model.partner = partner;
        PartnerRepo.savePartnerToPref(partner);
        _util.navigator.replace(HomeMenus(), isFade: true);
      }
    }

    if (Globals.userType.toLowerCase() == UserType.partner)
      checkWallet(context);
  }

  Future _checkAuth() async {
    setState(() {
      _isRetry = false;
    });
    bool isAuth = await isAuthenticated();
    var _pref = await SharedPreferences.getInstance();
    var _userType = _pref.getString(Prefs.userType);
    if (isAuth) {
      Globals.hasAuth = true;
      var currUser = await UserInfoRepo.getFromPref();
      Model.userInfo = currUser!;
      if (_userType == '' || _userType == null)
        Globals.userType =
            (Model.userInfo.userType?.toLowerCase()) ?? UserType.customer;
      else
        Globals.userType = _userType;

      if (Model.customer.id == null)
        await _noCustomer();
      else
        await _hasCustomer();
    } else {
      await noAuth();
    }
  }

  Future noAuth() async {
    bool _access = await getUsedAccess();
    Globals.userType = UserType.customer;
    if (_access) {
      _util.navigator.replace(HomeMenus(), isFade: true);
      _util.navigator.to(Login(), isFade: true);
    } else {
      _util.navigator.replace(HomeMenus(), isFade: true);
    }
    Globals.hasAuth = false;
  }
}
