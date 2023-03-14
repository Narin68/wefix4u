import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '/blocs/service_request/service_request_bloc.dart';
import '/signalr.dart';
import '../home/splash.dart';
import '/globals.dart';
import '../request_partner_info/request_partner_info.dart';
import '../select_services.dart';
import '/blocs/partner/partner_cubit.dart';
import 'editProfile/edit_profile.dart';
import 'widget.dart';

class CustomerMoreScreen extends StatefulWidget {
  @override
  _CustomerMoreScreenState createState() => _CustomerMoreScreenState();
}

class _CustomerMoreScreenState extends State<CustomerMoreScreen> {
  late var _util = OCSUtil.of(context);

  String lastName = '';

  @override
  void initState() {
    super.initState();
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
                                  BlocBuilder<PartnerCubit, PartnerState>(
                                    builder: (context, state) {
                                      if (state is PartnerSuccess) {
                                        if (state.data == null ||
                                            state.data!.isEmpty ||
                                            state.data![0].status
                                                    ?.toLowerCase() ==
                                                "rejected") {
                                          return buildUserInfo(
                                            onPress: () async {
                                              _util.navigator.to(
                                                SelectServices(
                                                  actionType: 'request-partner',
                                                ),
                                                transition: OCSTransitions.LEFT,
                                              );
                                            },
                                            color: Colors.green,
                                            title: _util.language
                                                .key("to-be-our-partner"),
                                            icon: Remix.team_line,
                                          );
                                        } else if (state.data != null &&
                                            state.data?[0].status
                                                    ?.toLowerCase() ==
                                                "approved") {
                                          return _buildSwitchUser();
                                        }
                                      }
                                      return SizedBox();
                                    },
                                  ),
                                  BlocBuilder<PartnerCubit, PartnerState>(
                                    builder: (context, state) {
                                      if (state is PartnerLoading) {
                                        return buildUserInfo(
                                          onPress: () async {},
                                          color: Colors.indigoAccent,
                                          title: _util.language
                                              .key("request-partner-info"),
                                          icon: Remix.file_3_line,
                                        );
                                      }
                                      if (state is PartnerFailure) {
                                        return SizedBox();
                                      }
                                      if (state is PartnerSuccess) {
                                        if (state.data != null &&
                                            (state.data?.length ?? 0) > 0 &&
                                            (state.data?[0].status
                                                        ?.toLowerCase() ==
                                                    "pending" ||
                                                state.data?[0].status
                                                        ?.toLowerCase() ==
                                                    "rejected")) {
                                          return buildUserInfo(
                                            onPress: () async {
                                              _util.navigator.to(
                                                RequestPartnerInfo(
                                                    partnerRequest:
                                                        state.data![0]),
                                                transition: OCSTransitions.LEFT,
                                              );
                                            },
                                            color: Colors.indigoAccent,
                                            title: _util.language
                                                .key("request-partner-info"),
                                            icon: Remix.file_3_line,
                                          );
                                        }
                                      }
                                      return SizedBox();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            BuildBottomMore(),
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

  void onSwitchUser(String v) async {
    if (v.toLowerCase() != Globals.userType.toLowerCase()) {
      var _pref = await SharedPreferences.getInstance();
      _pref.setString(Prefs.userType, '$v');
      _util.navigator.pop();
      _util.navigator.replace(SplashScreen(
        loading: true,
      ));
      context.read<ServiceRequestBloc>()..add(ReloadServiceRequest());
      disconnectSignalR();
      Globals.tabRequestStatusIndex = 0;
      Globals.requestFilterStatus = "";
    } else {
      _util.navigator.pop();
    }
  }

  Widget _buildSwitchUser() {
    return buildUserInfo(
      onPress: () async {
        setState(() {
          showModalBottomSheet<void>(
            backgroundColor: Colors.transparent,
            context: context,
            constraints: BoxConstraints(
              maxWidth: Globals.maxScreen,
            ),
            builder: (BuildContext context) {
              return BuildSwitchUser(
                userType: Globals.userType.toLowerCase(),
                onSubmit: onSwitchUser,
              );
            },
          );
        });
      },
      color: Colors.green,
      title: _util.language.key("switch-user-type"),
      icon: Icons.switch_account,
    );
  }
}
