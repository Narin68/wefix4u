import 'package:flutter/material.dart';
import 'package:ocs_auth/custom_context.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import 'package:wefix4utoday/screens/function_temp.dart';
import '../../blocs/my_notification_count/my_notification_count_cubit.dart';
import '../partner_service_request/partner_service_request_list.dart';
import '../partner_service_request/partner_service_request_detail.dart';
import '/modals/partner.dart';
import '/repositories/partner_repo.dart';
import '/blocs/wallet/wallet_cubit.dart';
import '../partner_quotation/quotation_list.dart';
import '../create_wallet.dart';
import '../partner_wallet/wallet.dart';
import '/screens/invoice/invoice_list.dart';
import '/blocs/service_request/service_request_bloc.dart';
import '/modals/customer_request_service.dart';
import '/globals.dart';
import '/screens/widget.dart';
import 'package:skeletons/skeletons.dart';
import '../partner_item/partner_item.dart';
import 'widget.dart';

class PartnerHomeScreen extends StatefulWidget {
  @override
  _PartnerHomeScreenState createState() => _PartnerHomeScreenState();
}

class _PartnerHomeScreenState extends State<PartnerHomeScreen> {
  late var _util = OCSUtil.of(context);
  List<String> imgList = [];
  List<String> listString = [];
  List<MRequestService> _requestServices = [];

  @override
  void initState() {
    super.initState();
    _init();
    context.notificationCount();
  }

  Future _init() async {
    if (Model.partner.id != null) {
      _getRequest();
      return;
    }

    MPartner? partner = await PartnerRepo.getPartnerFromPref();

    if (partner != null) {
      Model.partner = partner;
      _getRequest();
    } else {
      var res = await PartnerRepo().getPartner(Model.customer.id);
      if (!res.error) {
        var partner = res.data.length < 1 ? MPartner() : (res.data ?? []).first;
        Model.partner = partner;
        PartnerRepo.savePartnerToPref(partner);
        _getRequest();
      }
    }
  }

  void _getRequest() {
    context.read<ServiceRequestBloc>()
      ..add(
        FetchedServiceRequest(
          filter: MServiceRequestFilter(partnerId: Model.partner.id),
          isInit: true,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     context.read<MyNotificationCountCubit>().setServiceRequestCount(1);
      //   },
      // ),
      resizeToAvoidBottomInset: false,
      backgroundColor: OCSColor.background,
      appBar: AppBar(
        leading: null,
        actions: [
          notificationBellBuilder(context),
        ],
        backgroundColor: OCSColor.primary,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Parent(
              style: ParentStyle()..alignmentContent.center(),
              child: Row(
                children: [
                  Image.asset(
                    'assets/logo/logo-white.png',
                    height: 25,
                  ),
                  SizedBox(width: 10),
                  Parent(
                    style: ParentStyle(),
                    child: Image.asset(
                      'assets/logo/wf4u-text.png',
                      height: 15,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        leadingWidth: 0,
      ),
      body: SafeArea(
        bottom: true,
        child: Parent(
          style: ParentStyle()
            ..width(_util.query.width)
            ..height(_util.query.height),
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<ServiceRequestBloc>()
                ..add(ReloadServiceRequest())
                ..add(FetchedServiceRequest(
                    filter:
                        MServiceRequestFilter(partnerId: Model.partner.id)));
              checkWallet(context);
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Parent(
                    style: ParentStyle(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BuildSlider(),
                        SizedBox(height: 10),
                        _requestServiceSection(),
                        SizedBox(height: 5),
                        _buildNavigatorContent(),
                        SizedBox(height: 20),
                      ],
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

  Widget _requestServiceSection() {
    return Column(
      children: [
        Parent(
          style: ParentStyle()
            ..padding(horizontal: 15)
            ..margin(bottom: 5),
          child: Row(
            children: [
              Txt(
                _util.language.key(
                  'request-list',
                ),
                style: TxtStyle()
                  ..fontSize(Style.titleSize)
                  ..fontWeight(FontWeight.bold)
                  ..textColor(OCSColor.text),
              ),
              Expanded(child: SizedBox()),
              Txt(
                _util.language.key(
                  'show-all',
                ),
                style: TxtStyle()
                  ..fontSize(Style.subTitleSize)
                  ..textColor(OCSColor.primary)
                  ..textAlign.right()
                  ..borderRadius(all: 2),
                gesture: Gestures()
                  ..onTap(() {
                    Globals.tabRequestStatusIndex = 0;
                    _util.navigator.to(
                        PartnerServiceRequestList(
                          isInit: true,
                        ),
                        transition: OCSTransitions.UP);
                  }),
              ),
            ],
          ),
        ),
        Parent(
          style: ParentStyle()..padding(horizontal: 10),
          child: BlocConsumer<ServiceRequestBloc, ServiceRequestState>(
            listener: (context, state) {},
            builder: (context, state) {
              if (state is ServiceRequestLoading) {
                return _customerServiceLoading();
              }
              if (state is ServiceRequestFailure) {
                return SizedBox();
              }
              if (state is ServiceRequestSuccess) {
                if (state.data?.isEmpty ?? false)
                  return Parent(
                    style: ParentStyle()
                      ..background.color(OCSColor.primary.withOpacity(0.1))
                      ..width(_util.query.width)
                      ..padding(
                        all: 10,
                      )
                      ..margin(horizontal: 5, bottom: 10)
                      ..borderRadius(all: 3)
                      ..height(55)
                      ..alignmentContent.center()
                      ..border(
                        all: 1,
                        color: OCSColor.primary.withOpacity(0.5),
                      ),
                    child: Txt(
                      _util.language.key('no-request'),
                      style: TxtStyle()
                        ..fontSize(14)
                        ..textColor(OCSColor.text),
                    ),
                  );
                return ListView.builder(
                  primary: true,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: state.data!.length < 3 ? state.data!.length : 2,
                  itemBuilder: (_, i) {
                    return _serviceRequest(state.data![i]);
                  },
                );
              }
              if (_requestServices.isEmpty) return _customerServiceLoading();
              return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount:
                    _requestServices.length < 3 ? _requestServices.length : 2,
                itemBuilder: (_, i) {
                  return _serviceRequest(_requestServices[i]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _serviceRequest(MRequestService data) {
    String date = OCSUtil.dateFormat(DateTime.parse(data.createdDate ?? ""),
        format: Format.date);

    return Parent(
      gesture: Gestures()
        ..onTap(() {
          _util.navigator.to(
              PartnerServiceRequestDetail(
                data: data,
              ),
              transition: OCSTransitions.UP);
        }),
      style: ParentStyle()
        ..background.color(Colors.white)
        ..width(_util.query.width)
        ..padding(all: 10)
        ..margin(bottom: 5, horizontal: 2.5)
        ..borderRadius(all: 5)
        ..ripple(true)
        ..boxShadow(color: Colors.black.withOpacity(0.02), blur: 20),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Txt(
              date,
              style: TxtStyle()
                ..fontSize(Style.subTextSize)
                ..textColor(OCSColor.text.withOpacity(0.7))
                ..textAlign.right(),
            ),
          ),
          Parent(
            style: ParentStyle(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Txt(
                  "#${data.code}",
                  style: TxtStyle()
                    ..fontWeight(FontWeight.bold)
                    ..fontSize(Style.subTitleSize)
                    ..width(_util.query.width / 2)
                    ..textOverflow(TextOverflow.ellipsis)
                    ..textColor(OCSColor.text),
                ),
                SizedBox(height: 3),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Remix.map_pin_line,
                      size: 14,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: Txt(
                        "${data.targetLocation}",
                        style: TxtStyle()
                          ..fontSize(Style.subTextSize)
                          ..maxLines(1)
                          // ..width(_util.query.width / 2)
                          ..textOverflow(TextOverflow.ellipsis)
                          ..textColor(OCSColor.text.withOpacity(0.7)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _customerServiceLoading() {
    return Parent(
      style: ParentStyle(),
      child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          itemCount: 2,
          shrinkWrap: true,
          itemBuilder: (_, i) {
            return Parent(
              style: ParentStyle()
                ..margin(
                  bottom: 5,
                  horizontal: 5,
                ),
              child: SkeletonLine(
                style: SkeletonLineStyle(
                  height: 70,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
    );
  }

  Widget _buildNavigatorContent() {
    return Parent(
      style: ParentStyle()
        ..padding(horizontal: 13)
        ..width(_util.query.width),
      child: StaggeredGrid.count(
        crossAxisCount: 2,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        children: [
          _buildMenuBox(
            title: _util.language.key('product-and-service'),
            image: 'assets/images/check-list.png',
            onPress: () {
              _util.navigator.to(PartnerItem(), transition: OCSTransitions.UP);
            },
          ),
          BlocBuilder<WalletCubit, WalletState>(
            builder: (context, state) {
              if (state is WalletSuccess) {
                return _buildMenuBox(
                  enable: Model.userWallet == null ? false : true,
                  title: _util.language.key('wallet'),
                  image: 'assets/images/wallet.png',
                  onPress: () {
                    Model.userWallet == null
                        ? showDialog(
                            context: context,
                            builder: (_) => VerifyBankAccount(onSuccess: (v) {
                              context.read<WalletCubit>().updateWallet(v);
                              setState(() {});
                            }),
                            barrierDismissible: false,
                          )
                        : _util.navigator
                            .to(PartnerWallet(), transition: OCSTransitions.UP);
                  },
                );
              }
              return _buildMenuBox(
                enable: Model.userWallet == null ? false : true,
                title: _util.language.key('wallet'),
                image: 'assets/images/wallet.png',
                onPress: () {
                  Model.userWallet == null
                      ? showDialog(
                          context: context,
                          builder: (_) => VerifyBankAccount(onSuccess: (v) {
                            context.read<WalletCubit>().updateWallet(v);
                            setState(() {});
                          }),
                          barrierDismissible: false,
                        )
                      : _util.navigator
                          .to(PartnerWallet(), transition: OCSTransitions.UP);
                },
              );
            },
          ),
          _buildMenuBox(
            title: _util.language.key('invoice-list'),
            image: 'assets/images/invoice.png',
            onPress: () {
              _util.navigator.to(InvoiceList(), transition: OCSTransitions.UP);
            },
          ),
          _buildMenuBox(
            title: _util.language.key('quotation-list'),
            image: 'assets/images/quotation.png',
            onPress: () {
              _util.navigator
                  .to(QuotationList(), transition: OCSTransitions.UP);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuBox({
    required String title,
    Function? onPress,
    String? image,
    bool enable = true,
  }) {
    return Parent(
      gesture: Gestures()
        ..onTap(() {
          if (onPress != null) onPress();
        }),
      style: ParentStyle()
        ..background.color(Colors.white)
        ..elevation(2, opacity: 0.05)
        ..ripple(enable)
        ..opacity(enable ? 1 : 0.3)
        ..padding(all: 15, horizontal: 10, top: 5, bottom: 0)
        ..borderRadius(all: 3)
        ..boxShadow(color: Colors.black.withOpacity(0.02), blur: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Txt(
            title,
            style: TxtStyle()
              ..fontSize(Style.subTitleSize)
              ..textAlign.center()
              ..maxLines(2)
              ..textOverflow(TextOverflow.ellipsis)
              ..textColor(OCSColor.text),
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset(
                '${image}',
                width: 30,
                height: 30,
              ),
            ],
          ),
          SizedBox(height: 10)
        ],
      ),
    );
  }
}
