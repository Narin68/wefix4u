import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '../../blocs/my_notification_count/my_notification_count_cubit.dart';
import '/blocs/user/user_cubit.dart';
import '../cus_invoice_receipt/cus_invoice_reciept_list.dart';
import '../function_temp.dart';
import '/blocs/service_request/service_request_bloc.dart';
import '/modals/customer_request_service.dart';
import '/screens/widget.dart';
import '/globals.dart';
import 'customer_service_request_detail.dart';

class CustomerServiceRequestList extends StatefulWidget {
  final bool? isInit;

  const CustomerServiceRequestList({Key? key, this.isInit}) : super(key: key);

  @override
  State<CustomerServiceRequestList> createState() =>
      _CustomerServiceRequestListState();
}

class _CustomerServiceRequestListState
    extends State<CustomerServiceRequestList> {
  late final _util = OCSUtil.of(context);

  ScrollController _scrollCtr = ScrollController();
  var _color;
  var _status = '';
  String _filterStatus = "";
  bool _isSearch = false;
  TextEditingController _searchCtrl = TextEditingController();
  FocusNode _fNode = FocusNode();

  @override
  void initState() {
    super.initState();
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
      length: 10,
      child: Scaffold(
        appBar: AppBar(
          // elevation: 0,
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
                  _filterStatus = "Accepted";
                  break;
                case 3:
                  _filterStatus = "Approved";
                  break;
                case 4:
                  _filterStatus = "Heading";
                  break;
                case 5:
                  _filterStatus = "Fixing";
                  break;
                case 6:
                  _filterStatus = "Closed";
                  break;
                case 7:
                  _filterStatus = "Done";
                  break;
                case 8:
                  _filterStatus = "Canceled";
                  break;
                case 9:
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
                text: _util.language.key('request-sent'),
              ),
              Tab(
                text: _util.language.key('accepted'),
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
                text: _util.language.key('canceled'),
              ),
              Tab(
                text: _util.language.key('rejected'),
              ),
            ],
          ),

          backgroundColor: OCSColor.primary,
          title: _isSearch
              ? TextField(
                  focusNode: _fNode,
                  controller: _searchCtrl,
                  decoration: InputDecoration(border: InputBorder.none),
                  cursorColor: Colors.white,
                  cursorHeight: 30,
                  style: TextStyle(fontSize: 14, color: Colors.white),
                  onSubmitted: (v) {
                    _reloadData();
                  },
                )
              : Txt(
                  _util.language.key('your-request'),
                  style: TxtStyle()
                    ..fontSize(16)
                    ..textColor(Colors.white),
                ),
          actions: [
            IconButton(
              onPressed: () {
                _util.navigator.to(CusInvoiceAndReceiptList(),
                    transition: OCSTransitions.UP);
              },
              icon: Icon(
                Icons.receipt,
                size: 22,
              ),
              tooltip: _util.language.key('invoice-and-receipt'),
            ),
            // SizedBox(width: 10),
          ],
        ),
        body: SafeArea(
          bottom: false,
          child: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              for (var i = 0; i < 10; i++) ...[
                _buildBody(),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Future _init() async {
    _scrollCtr.addListener(_onScrollItem);
    _filterStatus = Globals.requestFilterStatus;
    context.read<MyNotificationCountCubit>().resetServiceRequestCount();
    if (widget.isInit ?? false) {
      context.read<ServiceRequestBloc>()
        ..add(ReloadServiceRequest())
        ..add(
          FetchedServiceRequest(
            filter: MServiceRequestFilter(refId: Model.customer.id),
            isInit: true,
          ),
        );
    } else {
      context.read<ServiceRequestBloc>().add(
            FetchedServiceRequest(
              filter: MServiceRequestFilter(refId: Model.customer.id),
              isInit: true,
            ),
          );
    }
  }

  void _reloadData() {
    context.read<ServiceRequestBloc>()
      ..add(ReloadServiceRequest())
      ..add(
        FetchedServiceRequest(
          filter: MServiceRequestFilter(
            refId: Model.customer.id,
            status: _filterStatus.isEmpty ? null : [_filterStatus],
            search: _searchCtrl.text,
          ),
        ),
      );
  }

  Widget _buildBody() {
    return Parent(
      style: ParentStyle()..height(_util.query.height),
      child: BlocBuilder<ServiceRequestBloc, ServiceRequestState>(
        builder: (context, state) {
          if (state is ServiceRequestLoading) {
            return _buildLoadingState();
          }
          if (state is ServiceRequestFailure) {
            return BuildErrorBloc(
              message: state.message,
              onRetry: () {
                context.read<ServiceRequestBloc>()
                  ..add(ReloadServiceRequest())
                  ..add(FetchedServiceRequest(
                      filter: MServiceRequestFilter(refId: Model.customer.id)));
              },
            );
          }
          if (state is ServiceRequestSuccess) {
            if (state.data!.isEmpty) return Center(child: BuildNoDataScreen());
            return _buildList(
              onRefresh: () async {
                context
                    .read<MyNotificationCountCubit>()
                    .resetServiceRequestCount();
                _reloadData();
              },
              data: state.data,
              hasReach: state.hasReach ?? false,
            );
          }
          return SizedBox();
        },
      ),
    );
  }

  Widget _buildServiceBox(MRequestService data) {
    String date = OCSUtil.dateFormat(DateTime.parse('${data.createdDate}'),
        format: Format.dateTime, langCode: Globals.langCode);

    return Parent(
      gesture: Gestures()
        ..onTap(() {
          _util.navigator.to(
            CustomerServiceRequestDetail(data: data),
            transition: OCSTransitions.LEFT,
          );
        }),
      style: ParentStyle()
        ..background.color(Colors.white)
        ..width(_util.query.width)
        ..padding(
          all: 15,
        )
        ..margin(bottom: 10)
        ..borderRadius(all: 5)
        ..ripple(true),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Txt(
              _util.language.key(_status),
              style: TxtStyle()
                ..borderRadius(all: 2)
                ..fontWeight(FontWeight.w600)
                ..textColor(_color)
                ..fontSize(12)
                ..textAlign.right(),
            ),
          ),
          Parent(
            style: ParentStyle(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Txt(
                  "#${data.code ?? ""}",
                  style: TxtStyle()
                    ..fontSize(Style.subTitleSize)
                    ..textColor(OCSColor.text)
                    ..fontWeight(FontWeight.bold)
                    ..textAlign.right(),
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Remix.calendar_2_line,
                      size: 14,
                      color: OCSColor.text.withOpacity(1),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Txt(
                        "${date}",
                        style: TxtStyle()
                          ..fontSize(Style.subTextSize)
                          ..maxLines(1)
                          ..textOverflow(TextOverflow.ellipsis)
                          ..textColor(OCSColor.text.withOpacity(.7)),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Remix.map_pin_line,
                      size: 14,
                      color: OCSColor.text.withOpacity(1),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Txt(
                        "${data.targetLocation}",
                        style: TxtStyle()
                          ..fontSize(Style.subTextSize)
                          ..maxLines(1)
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

  void _checkStatus(MRequestService header) {
    checkCusRequestStatus(
      header: header,
      func: (status, color, subStatus) {
        _status = status;
        _color = color;
      },
    );
  }

  void _onScrollItem() {
    final _max = _scrollCtr.position.maxScrollExtent;
    final _currScroll = _scrollCtr.position.pixels;
    if (_currScroll >= _max) {
      context.read<ServiceRequestBloc>().add(
            FetchedServiceRequest(
              filter: MServiceRequestFilter(
                  refId: Model.customer.id,
                  status: _filterStatus.isEmpty ? null : [_filterStatus]),
            ),
          );
    }
    setState(() {});
  }

  Widget _buildList(
      {List<MRequestService>? data,
      bool hasReach = false,
      required Function onRefresh}) {
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollCtr,
        padding: EdgeInsets.all(15),
        itemCount: hasReach ? data?.length : data!.length + 1,
        itemBuilder: (_, i) {
          if (i < data!.length) _checkStatus(data[i]);
          return i >= data.length
              ? Parent(
                  style: ParentStyle()
                    ..width(_util.query.width)
                    ..padding(all: 15, horizontal: 20)
                    ..borderRadius(all: 10),
                  child: const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                )
              : _buildServiceBox(data[i]);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator.adaptive(),
    );
  }
}
