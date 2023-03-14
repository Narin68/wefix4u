import 'package:flutter/material.dart';
import 'package:ocs_auth/ocs_auth.dart';
import 'package:ocs_firebase/env.dart';
import 'package:ocs_firebase/remote_config.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '../../blocs/my_notification_count/my_notification_count_cubit.dart';
import '../customer_service_request/customer_service_request_list.dart';
import '../partner_service_request/partner_service_request_list.dart';
import '/screens/message/chat_request.dart';
import '../function_temp.dart';
import '/modals/customer.dart';
import '/signalr.dart';
import '/blocs/user/user_cubit.dart';
import '/screens/more/no_auth_more_screen.dart';
import '/functions.dart';
import '../more/customer_more_screen.dart';
import '../more/partner_more_screen.dart';
import '../news_and_promotion/news_and_promotion.dart';
import '/globals.dart';
import '/blocs/partner/partner_cubit.dart';
import 'customer_home_screen.dart';
import 'package:ocs_firebase/messaging.dart';

import 'partner_home_screen.dart';

class HomeMenus extends StatefulWidget {
  @override
  _HomeMenusState createState() => _HomeMenusState();
}

class _HomeMenusState extends State<HomeMenus> with WidgetsBindingObserver {
  late var _util = OCSUtil.of(context);
  List<Widget> _screens = [];
  int _currIndex = 0;
  bool _isMaintenance = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    CustomConnectivity.init(context);
    checkVersion(context);
    requestLocationPermission(context);
    _initData();
    initSignalR(context);
    _initMessage();
  }

  void dispose() {
    super.dispose();
    CustomConnectivity.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  void _initMessage() {
    OCSMessaging.onMessaging(
      onGetToken: onGetToken,
      onMessage: (message) => onBackground(context, message),
      onOpen: (message) => onOpen(context, message),
      onError: (e) {
        print('Firebase Messaging Error: $e');
      },
    );
    if (!Globals.hasAuth) OCSMessaging.instance.deleteToken();
  }

  @override
  Future didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      _isMaintenance = await OCSFbConfig.getIsMaintenance();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isMaintenance
        ? MaintenanceScreen('wefix4u')
        : WillPopScope(
            onWillPop: _onWillPop,
            child: Stack(
              children: [
                BlocConsumer<MyUserCubit, MyUserState>(
                  listener: (context, state) async {
                    if (state is MyUserFailure) {
                      _noAuthFunc();
                    }
                    if (state is MyUserSuccess) {
                      if (state.user?.loginName == null) {
                        _noAuthFunc();
                      } else {
                        _hasAuth(state.user!, state.customer!);
                      }
                    }
                    if (state is MyUserLoading) {
                      if (!(state.isLoad ?? false))
                        _hasAuth(Model.userInfo, Model.customer);
                    }
                  },
                  builder: (context, state) {
                    if (state is MyUserSuccess) {
                      return _hasAuthWidget(state.user?.userType ?? "");
                    }

                    if (state is MyUserFailure) {
                      return _noAuthWidget();
                    }
                    if (state is MyUserLoading) {
                      if (!(state.isLoad ?? false))
                        return _hasAuthWidget(Globals.userType);

                      return _loading();
                    }
                    return SizedBox();
                  },
                ),
              ],
            ),
          );
  }

  Future<bool> _onWillPop() async {
    if (_currIndex != 0) {
      setState(() {
        _currIndex = 0;
      });
    } else {
      await minimizeApp();
    }
    return Future.value(false);
  }

  Future _initData() async {
    context.read<MyUserCubit>().get(info: Model.userInfo);
    if (Globals.userType.toLowerCase() == UserType.customer) {
      if (Globals.hasAuth)
        context.read<PartnerCubit>().getPartnerRequest(Model.customer.id);
    }
    if (Globals.userType.toLowerCase() == UserType.partner) {
      checkWallet(context);
    }
  }

  Future _noAuthFunc() async {
    _screens = [];
    Globals.userType = '';
    var _pref = await SharedPreferences.getInstance();
    _pref.setString(Prefs.userType, UserType.customer);
    Globals.hasAuth = false;
    _noAuthScreen();
    setState(() {});
  }

  Future _hasAuth(MUserInfo user, MMyCustomer customer) async {
    _screens = [];
    Model.userInfo = user;
    Model.customer = customer;
    var _pref = await SharedPreferences.getInstance();
    var userType = _pref.getString(Prefs.userType);
    if (Globals.userType.isEmpty)
      Globals.userType = userType ?? UserType.customer;
    if (Globals.navIndex == 4) _currIndex = 0;
    Globals.navIndex = -1;
    _hasAuthScreen(user.userType ?? UserType.customer);
    setState(() {});
  }

  void _noAuthScreen() {
    _screens.add(CustomerHomeScreen());
    _screens.add(NewsAndPromotionsScreen());
    _screens.add(NoAuthMoreScreen());
  }

  Future _hasAuthScreen(String userType) async {
    if (Globals.userType.toLowerCase() == UserType.customer) {
      _screens.add(CustomerHomeScreen());
      _screens.add(NewsAndPromotionsScreen());
      _screens.add(ChatRequest());
      _screens.add(CustomerServiceRequestList());
      userType.toLowerCase() == UserType.customer
          ? _screens.add(CustomerMoreScreen())
          : _screens.add(PartnerMoreScreen());
    } else {
      _screens.add(PartnerHomeScreen());
      _screens.add(NewsAndPromotionsScreen());
      _screens.add(ChatRequest());
      _screens.add(PartnerServiceRequestList(
        isInit: false,
      ));
      _screens.add(PartnerMoreScreen());
    }
  }

  Widget _hasAuthWidget(String userType) {
    return BlocBuilder<MyNotificationCountCubit, MyNotificationCountState>(
      builder: (context, state) {
        if (state is MyNotificationCountSuccess) {
          return Column(
            children: [
              Expanded(child: _screens[_currIndex]),
              OCSBottomNavBar(
                buttons: [
                  OCSButtonNavBar(
                    icon: Remix.home_3_line,
                    activeIcon: Remix.home_3_fill,
                    label: '${_util.language.key("home")}',
                  ),
                  OCSButtonNavBar(
                    notifCount: state.newsCount,
                    icon: Icons.campaign_outlined,
                    activeIcon: Icons.campaign,
                    label: '${_util.language.key("news-and-promotions")}',
                  ),

                  if (Globals.hasAuth)
                    OCSButtonNavBar(
                      icon: Icons.chat_outlined,
                      activeIcon: Icons.chat_rounded,
                      label: '${_util.language.key("chat")}',
                    ),

                  /// User type customer
                  if (userType.toLowerCase() == 'customer')
                    OCSButtonNavBar(
                      notifCount: state.serviceRequestCount,
                      icon: Remix.tools_line,
                      activeIcon: Remix.tools_line,
                      label: '${_util.language.key("request-list")}',
                    ),

                  /// User type partner
                  if (userType.toLowerCase() == 'partner')
                    OCSButtonNavBar(
                      notifCount: state.serviceRequestCount,
                      icon: Remix.tools_line,
                      activeIcon: Remix.tools_line,
                      label: '${_util.language.key("request-list")}',
                    ),
                  OCSButtonNavBar(
                    icon: Remix.more_line,
                    activeIcon: Remix.more_fill,
                    label: '${_util.language.key("more")}',
                  ),
                ],
                maxWidth: _util.query.width,
                onChange: (i) {
                  setState(() {
                    _currIndex = i;
                  });
                },
                currentIndex: _currIndex,
              ),
              SizedBox(height: _util.query.bottom),
            ],
          );
        }

        return SizedBox();
      },
    );
  }

  Widget _noAuthWidget() {
    return Column(
      children: [
        Expanded(child: _screens[_currIndex]),
        OCSBottomNavBar(
          buttons: [
            OCSButtonNavBar(
              icon: Remix.home_2_line,
              activeIcon: Remix.home_2_fill,
              label: '${_util.language.key("home")}',
            ),
            OCSButtonNavBar(
              icon: Icons.campaign_outlined,
              activeIcon: Icons.campaign,
              label: '${_util.language.key("news-and-promotions")}',
            ),
            OCSButtonNavBar(
              icon: Remix.more_line,
              activeIcon: Remix.more_fill,
              label: '${_util.language.key("more")}',
            ),
          ],
          maxWidth: _util.query.width,
          onChange: (i) {
            setState(() {
              _currIndex = i;
            });
          },
          currentIndex: _currIndex,
        ),
        SizedBox(height: _util.query.bottom),
      ],
    );
  }

  Widget _loading() {
    return Splash(
      logoSize: 100,
      onSplash: (BuildContext context) {},
      logo: "assets/logo/logo-white.png",
      bottom: Center(
        child: RichText(
          text: const TextSpan(
            text: 'Developed by',
            style: TextStyle(fontSize: 12),
            children: [
              TextSpan(text: ' . '),
              TextSpan(
                  text: 'wefix4u',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))
            ],
          ),
        ),
      ),
      appTitle: 'wefix4u',
      isMaintenance: FBEnv.isMaintenance,
    );
  }
}
