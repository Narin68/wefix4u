import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '../../blocs/my_notification_count/my_notification_count_cubit.dart';
import '/blocs/user/user_cubit.dart';
import '../function_temp.dart';
import '/blocs/service_request/service_request_bloc.dart';
import '/modals/customer_request_service.dart';
import '/modals/quotation.dart';
import '/screens/widget.dart';
import '/globals.dart';
import 'partner_service_request_detail.dart';

class PartnerServiceRequestList extends StatefulWidget {
  final bool isInit;

  const PartnerServiceRequestList({Key? key, this.isInit = false})
      : super(key: key);

  @override
  State<PartnerServiceRequestList> createState() =>
      _PartnerServiceRequestListState();
}

class _PartnerServiceRequestListState extends State<PartnerServiceRequestList> {
  late final _util = OCSUtil.of(context);

  ScrollController _scrollCtr = ScrollController();
  var _color;
  var _status = '';
  int index = 0;
  String _filterStatus = "";

  @override
  void initState() {
    super.initState();
    _scrollCtr.addListener(_onScrollItem);
    _init();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollCtr.removeListener(_onScrollItem);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: Globals.tabRequestStatusIndex,
      length: 8,
      child: Scaffold(
        appBar: AppBar(
          // elevation: 0,
          backgroundColor: OCSColor.primary,
          title: Txt(
            _util.language.key('request-list'),
            style: TxtStyle()
              ..fontSize(16)
              ..textColor(Colors.white),
          ),
          bottom: TabBar(
            onTap: (int i) {
              if (i == Globals.tabRequestStatusIndex) return;
              switch (i) {
                case 0:
                  _filterStatus = "";
                  break;
                case 1:
                  _filterStatus = "Pending";
                  break;
                case 2:
                  _filterStatus = "Approved";
                  break;
                case 3:
                  _filterStatus = "Heading";
                  break;
                case 4:
                  _filterStatus = "Fixing";
                  break;
                case 5:
                  _filterStatus = "Closed";
                  break;
                case 6:
                  _filterStatus = "Done";
                  break;
                case 7:
                  _filterStatus = "Rejected";
                  break;
              }
              _reloadData();

              Globals.tabRequestStatusIndex = i;
              Globals.requestFilterStatus = _filterStatus;
              setState(() {});
            },
            // padding: EdgeInsets.all(10),
            indicatorColor: Colors.white,
            physics: AlwaysScrollableScrollPhysics(),
            isScrollable: true,
            tabs: [
              Tab(
                text: _util.language.key('all'),
              ),
              Tab(
                text: _util.language.key('enquiring'),
              ),
              Tab(
                text: _util.language.key('confirmed'),
              ),
              Tab(
                text: _util.language.key('heading'),
              ),
              Tab(
                text: _util.language.key('fixing'),
              ),
              Tab(
                text: _util.language.key('closed'),
              ),
              Tab(
                text: _util.language.key('done'),
              ),
              Tab(
                text: _util.language.key('reject'),
              ),
            ],
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              for (var i = 0; i < 8; i++) ...[
                _buildBody(),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Future _reloadData() async {
    await context.read<ServiceRequestBloc>()
      ..add(ReloadServiceRequest())
      ..add(
        FetchedServiceRequest(
          filter: MServiceRequestFilter(
            partnerId: Model.partner.id,
            status: _filterStatus.isEmpty ? null : [_filterStatus],
          ),
          isInit: true,
        ),
      );
  }

  void _init() {
    context.read<MyNotificationCountCubit>().resetServiceRequestCount();
    if (widget.isInit) {
      context.read<ServiceRequestBloc>()
        ..add(ReloadServiceRequest())
        ..add(
          FetchedServiceRequest(
            filter: MServiceRequestFilter(partnerId: Model.partner.id),
            isInit: true,
          ),
        );
    } else {
      context.read<ServiceRequestBloc>().add(
            FetchedServiceRequest(
              filter: MServiceRequestFilter(partnerId: Model.partner.id),
              isInit: true,
            ),
          );
    }
  }

  Widget _buildBody() {
    return Parent(
      style: ParentStyle()..height(_util.query.height),
      child: Column(
        children: [
          Expanded(
            child: BlocBuilder<ServiceRequestBloc, ServiceRequestState>(
              builder: (context, state) {
                if (state is ServiceRequestLoading) {
                  return Center(child: CircularProgressIndicator.adaptive());
                }
                if (state is ServiceRequestFailure) {
                  return BuildErrorBloc(
                    message: state.message,
                    onRetry: _reloadData,
                  );
                }
                if (state is ServiceRequestSuccess) {
                  if (state.data!.isEmpty) return BuildNoDataScreen();
                  return RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<MyNotificationCountCubit>()
                          .resetServiceRequestCount();
                      _reloadData();
                    },
                    child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        controller: _scrollCtr,
                        padding: const EdgeInsets.all(15),
                        itemCount: state.hasReach!
                            ? state.data?.length
                            : state.data!.length + 1,
                        itemBuilder: (_, i) {
                          return i >= state.data!.length
                              ? Parent(
                                  style: ParentStyle()
                                    ..width(_util.query.width)
                                    ..padding(all: 15, horizontal: 20)
                                    ..borderRadius(all: 10),
                                  child: const Center(
                                    child: CircularProgressIndicator.adaptive(),
                                  ),
                                )
                              : _buildServiceList(state.data![i]);
                        }),
                  );
                }

                return SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceList(MRequestService data) {
    String phone = data.customerPhone!;
    String date = OCSUtil.dateFormat(DateTime.parse('${data.createdDate}'),
        format: Format.dateTime, langCode: Globals.langCode);

    if (phone.contains('+855')) {
      phone = phone.replaceAll('+855', '0');
    }

    _checkStatus(data);
    return Parent(
      gesture: Gestures()
        ..onTap(() {
          Model.quotationDetail = MSubmitQuotData();
          Model.quotationDetail = Model.quotationDetail!.copyWith(items: []);
          Model.partnerItems = [];
          _util.navigator.to(
            PartnerServiceRequestDetail(
              data: data,
            ),
            transition: OCSTransitions.LEFT,
          );
        }),
      style: ParentStyle()
        ..background.color(Colors.white)
        ..width(_util.query.width)
        ..padding(all: 15, horizontal: 15, bottom: 10, top: 10)
        ..margin(
          bottom: 10,
        )
        ..borderRadius(all: 5)
        ..ripple(true),
      child: Stack(
        children: [
          Positioned(
            top: 5,
            right: 0,
            child: Txt(
              _util.language.key(_status),
              style: TxtStyle()
                ..borderRadius(all: 2)
                ..fontWeight(FontWeight.w600)
                ..fontSize(Style.subTextSize)
                ..textColor(_color)
                ..textAlign.right(),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Txt(
              date,
              style: TxtStyle()
                ..fontSize(Style.subTextSize - 1)
                ..textColor(OCSColor.text.withOpacity(0.7))
                ..textAlign.right(),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Parent(
                style: ParentStyle(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Txt(
                      "#${data.code}",
                      style: TxtStyle()
                        ..fontSize(Style.subTitleSize)
                        ..width(200)
                        ..fontWeight(FontWeight.bold)
                        ..textOverflow(TextOverflow.ellipsis)
                        ..textColor(OCSColor.text),
                    ),
                    SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Remix.user_2_line,
                          size: 14,
                          color: OCSColor.text.withOpacity(0.7),
                        ),
                        SizedBox(width: 5),
                        Txt(
                          "${_util.language.by(km: data.customerName, en: data.customerNameEnglish, autoFill: true).replaceAll('.', '')}",
                          style: TxtStyle()
                            ..fontSize(12)
                            // ..width(200)
                            ..textOverflow(TextOverflow.ellipsis)
                            ..textColor(OCSColor.text.withOpacity(0.7)),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Remix.map_pin_line,
                          size: 14,
                          color: OCSColor.text.withOpacity(0.7),
                        ),
                        SizedBox(width: 5),
                        Txt(
                          "${data.targetLocation}",
                          style: TxtStyle()
                            ..fontSize(12)
                            ..width((_util.query.width / 2) - 40)
                            ..textOverflow(TextOverflow.ellipsis)
                            ..textColor(OCSColor.text.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _checkStatus(MRequestService header) {
    checkRequestStatus(
        header: header,
        func: (status, color, btnName) {
          _status = status;
          _color = color;
        });
  }

  void _onScrollItem() {
    final _max = _scrollCtr.position.maxScrollExtent;
    final _currScroll = _scrollCtr.position.pixels;

    if (_currScroll >= _max) {
      context.read<ServiceRequestBloc>().add(
            FetchedServiceRequest(
              filter: MServiceRequestFilter(
                partnerId: Model.partner.id,
                status: _filterStatus.isEmpty ? null : [_filterStatus],
              ),
            ),
          );
    }
    setState(() {});
  }
}
