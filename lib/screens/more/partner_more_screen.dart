import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '/blocs/chat_request/chat_request_bloc.dart';
import '/signalr.dart';
import '/blocs/service_request/service_request_bloc.dart';
import '/screens/home/splash.dart';
import '/globals.dart';
import 'business_info/business_information.dart';
import 'editProfile/edit_profile.dart';
import 'widget.dart';

class PartnerMoreScreen extends StatefulWidget {
  @override
  _PartnerMoreScreenState createState() => _PartnerMoreScreenState();
}

class _PartnerMoreScreenState extends State<PartnerMoreScreen> {
  late var _util = OCSUtil.of(context);
  String lastName = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _changeUserType(String v) async {
    if (v.toLowerCase() != Globals.userType.toLowerCase()) {
      var _pref = await SharedPreferences.getInstance();
      _pref.setString(Prefs.userType, '$v');
      _util.navigator.pop();
      _util.navigator.replace(SplashScreen(
        loading: true,
      ));
      context.read<ServiceRequestBloc>()..add(ReloadServiceRequest());
      context.read<ChatRequestBloc>()..add(ReloadChatRequest());
      disconnectSignalR();
      Globals.tabRequestStatusIndex = 0;
      Globals.requestFilterStatus = "";
    } else {
      _util.navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: OCSColor.primary,
        shadowColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.white,
                collapsedHeight: 120,
                elevation: 0,
                flexibleSpace: BuildUserProfile(),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Parent(
                      style: ParentStyle()..padding(horizontal: 0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Parent(
                              style: ParentStyle()
                                ..height(40)
                                ..padding(horizontal: 15),
                              child: Row(
                                children: [
                                  Txt(
                                    _util.language.key('account'),
                                    style: TxtStyle()
                                      ..textColor(OCSColor.text)
                                      ..fontSize(Style.titleSize),
                                  ),
                                  Expanded(child: SizedBox()),
                                ],
                              ),
                            ),
                            Parent(
                              style: ParentStyle()
                                ..background.color(Colors.white)
                                ..borderRadius(all: 0),
                              child: Column(
                                children: [
                                  buildUserInfo(
                                    onPress: () {
                                      _util.navigator.to(EditProfile(),
                                          transition: OCSTransitions.LEFT);
                                    },
                                    color: Colors.blueAccent,
                                    title: "${_util.language.key("user-info")}",
                                    icon: Remix.user_2_line,
                                  ),
                                  if (Globals.userType.toLowerCase() ==
                                          'partner' &&
                                      Model.userInfo.userType?.toLowerCase() ==
                                          'partner')
                                    buildUserInfo(
                                      onPress: () {
                                        _util.navigator.to(BusinessInfo(),
                                            transition: OCSTransitions.LEFT);
                                      },
                                      color: Colors.blueAccent,
                                      title:
                                          "${_util.language.key("business-info")}",
                                      icon: Remix.store_2_line,
                                    ),
                                  buildUserInfo(
                                    onPress: () async {
                                      setState(() {
                                        showDialog<String>(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                            contentPadding: EdgeInsets.only(
                                                left: 25,
                                                top: 15,
                                                bottom: 10,
                                                right: 15),
                                            title: Txt(
                                              _util.language
                                                  .key('switch-user-type'),
                                              style: TxtStyle()
                                                ..fontSize(Style.titleSize)
                                                ..textColor(OCSColor.text),
                                            ),
                                            content: Txt(
                                              _util.language.key(Globals
                                                          .userType
                                                          .toLowerCase() ==
                                                      "partner"
                                                  ? 'do-you-want-switch-customer'
                                                  : 'do-you-want-switch-partner'),
                                              style: TxtStyle()
                                                ..fontSize(14)
                                                ..textColor(OCSColor.text
                                                    .withOpacity(0.7)),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, 'Cancel'),
                                                child: Txt(
                                                  _util.language.key('no'),
                                                  style: TxtStyle()
                                                    ..textColor(OCSColor.text
                                                        .withOpacity(0.6)),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  _changeUserType(
                                                    Globals.userType
                                                                .toLowerCase() ==
                                                            UserType.partner
                                                        ? UserType.customer
                                                        : UserType.partner,
                                                  );
                                                },
                                                child: Txt(
                                                  _util.language.key('yes'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                        // showModalBottomSheet<void>(
                                        //   backgroundColor: Colors.transparent,
                                        //   context: context,
                                        //   constraints: BoxConstraints(
                                        //     maxWidth: Globals.maxScreen,
                                        //   ),
                                        //   builder: (BuildContext context) {
                                        //     return BuildSwitchUser(
                                        //       userType: Globals.userType
                                        //           .toLowerCase(),
                                        //       onSubmit: _changeUserType,
                                        //     );
                                        //   },
                                        // );
                                      });
                                    },
                                    color: Colors.green,
                                    title: _util.language.key(
                                        Globals.userType.toLowerCase() ==
                                                'partner'
                                            ? "switch-to-customer"
                                            : "switch-to-partner"),
                                    icon: Icons.switch_account,
                                  ),
                                ],
                              ),
                            ),
                            BuildBottomMore()
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          )),
    );
  }
}
