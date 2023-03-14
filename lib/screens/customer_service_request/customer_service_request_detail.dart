import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ocs_auth/ocs_auth.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '/screens/customer_service_request/service_request_time_line.dart';
import '/screens/customer_service_request/widget.dart';
import '/modals/requestUpdateQuot.dart';
import '/repositories/request_update_invoice.dart';
import '../service_request_widget.dart';
import '../function_temp.dart';
import '/blocs/request_service_detail/request_service_detail_bloc.dart';
import '/screens/payment_screen/customer_close_service.dart';
import '/blocs/service_request/service_request_bloc.dart';
import '/modals/partner.dart';
import '/globals.dart';
import '/modals/customer_request_service.dart';
import '/repositories/customer_request_service.dart';
import '/screens/widget.dart';
import 'customer_request_all_info.dart';

class CustomerServiceRequestDetail extends StatefulWidget {
  final MRequestService? data;
  final bool? notNotif;
  final int? id;
  final bool showFeedback;

  const CustomerServiceRequestDetail(
      {Key? key, this.data, this.id, this.notNotif, this.showFeedback = false})
      : super(key: key);

  @override
  State<CustomerServiceRequestDetail> createState() =>
      _CustomerServiceRequestDetailState();
}

class _CustomerServiceRequestDetailState
    extends State<CustomerServiceRequestDetail> {
  late final _util = OCSUtil.of(context);
  var txtTitleStyle = TxtStyle()
    ..fontSize(14)
    ..width(100)
    ..textColor(
      OCSColor.text.withOpacity(0.7),
    );
  var subtitleStyle = TxtStyle()
    ..fontSize(14)
    ..textColor(OCSColor.text.withOpacity(0.9));
  ServiceRequestRepo _repo = ServiceRequestRepo();
  bool _loading = false;
  bool _approveLoading = false;
  MServiceRequestDetail _requestDetail = MServiceRequestDetail();

  Color _color = Colors.orange;
  bool _failed = false;
  MRequestService _header = MRequestService();
  String _status = '';
  bool _initLoading = false;
  RequestUpdateQuot _requestUpdateQuotRepo = RequestUpdateQuot();
  MRequestUpdateQuot? _updateQuotData;

  @override
  void initState() {
    super.initState();
    if (widget.notNotif ?? true) _header = widget.data!;
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_approveLoading) _util.navigator.pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: NavigatorBackButton(loading: _approveLoading),
          title: Txt(
            "${_util.language.key('service-request')}",
            style: TxtStyle()
              ..fontSize(Style.titleSize)
              ..textColor(Colors.white),
          ),
          actions: [
            if (!_failed) ...[
              IconButton(
                tooltip: "Request Timeline",
                onPressed: _loading || _initLoading || _approveLoading
                    ? null
                    : () {
                        _util.navigator.to(
                          ServiceRequestTimeLine(
                            code: _header.code ?? "",
                          ),
                          transition: OCSTransitions.LEFT,
                        );
                      },
                icon: Icon(
                  Remix.time_line,
                  size: 20,
                ),
              ),
              IconButton(
                tooltip: "View detail",
                onPressed: _loading || _initLoading || _approveLoading
                    ? null
                    : () {
                        _util.navigator.to(
                          CustomerServiceAllInfo(
                            data: widget.data,
                            requestDetail: _requestDetail,
                          ),
                          transition: OCSTransitions.LEFT,
                        );
                      },
                icon: Icon(
                  Remix.eye_line,
                  size: 20,
                ),
              ),
            ]
          ],
          backgroundColor: OCSColor.primary,
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () async {
        //     context.read<RequestServiceDetailBloc>()
        //       ..add(UpdateStatusDetail(
        //           id: _header.id, status: _header.status, getDetail: true));
        //   },
        // ),
        backgroundColor: Colors.white,
        body: _initLoading
            ? Center(
                child: CircularProgressIndicator.adaptive(),
              )
            : SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    Parent(
                      style: ParentStyle(),
                      child: BlocConsumer<RequestServiceDetailBloc,
                          RequestServiceDetailState>(
                        listener: (context, state) {
                          if (state is RequestDetailSuccess) {
                            _header = state.header!;
                            _requestDetail = state.detail!;

                            _checkStatus(state.header!);
                            _updateQuotData = _requestDetail.quotUpdateRequest;

                            // if ((_header.status?.toUpperCase() ==
                            //             RequestStatus.approved ||
                            //         _header.status?.toUpperCase() ==
                            //             RequestStatus.fixing ||
                            //         _header.status?.toUpperCase() ==
                            //             RequestStatus.heading) &&
                            //     _requestDetail.quotUpdateRequest == null) {
                            //   var data = _requestDetail.acceptedPartners
                            //       ?.where(
                            //           (e) => e.partnerId == _header.partnerId)
                            //       .toList();
                            //
                            //   if (data != null && data.isNotEmpty)
                            //     _getUpdateQuot(data[0].quotationId ?? 0);
                            // }

                            _failed = false;
                            _loading = false;
                            setState(() {});
                          }
                          if (state is RequestDetailLoading) {
                            _loading = true;
                            setState(() {});
                          }
                          if (state is RequestDetailFailure) {
                            _failed = true;
                            _loading = false;
                            setState(() {});
                          }
                        },
                        builder: (context, state) {
                          if (state is RequestDetailLoading) {
                            return Center(
                              child: CircularProgressIndicator.adaptive(),
                            );
                          }
                          if (state is RequestDetailFailure) {
                            return BuildErrorBloc(
                              message: state.message,
                              onRetry: _getDetail,
                            );
                          }
                          if (state is RequestDetailSuccess) {
                            return Stack(
                              children: [
                                CustomScrollView(
                                  slivers: [
                                    SliverToBoxAdapter(
                                      child: Parent(
                                        style: ParentStyle()
                                          ..padding(all: 15)
                                          ..minHeight(_util.query.height),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            buildTopContent(
                                              context,
                                              color: _color,
                                              status: _status,
                                              subtitleStyle: subtitleStyle,
                                              txtTitleStyle: txtTitleStyle,
                                              header: state.header,
                                            ),
                                            SizedBox(height: 10),
                                            if (state.header?.status
                                                        ?.toUpperCase() !=
                                                    RequestStatus.canceled &&
                                                state.header?.status
                                                        ?.toUpperCase() !=
                                                    RequestStatus.rejected)
                                              _buildPartnerSection(
                                                  state.header!, state.detail!),
                                            SizedBox(height: 70),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                _buildCloseBtn(
                                  header: state.header,
                                  detail: state.detail,
                                ),
                                _buildPendingBtn(
                                  header: state.header,
                                  detail: state.detail,
                                ),
                                if (_approveLoading)
                                  Positioned(
                                    child: Container(
                                      color: Colors.black.withOpacity(.3),
                                      child: const Center(
                                        child:
                                            CircularProgressIndicator.adaptive(
                                          valueColor: AlwaysStoppedAnimation(
                                              Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }

                          return SizedBox();
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _init() async {
    if (widget.notNotif != null && widget.notNotif == false) {
      setState(() {
        _initLoading = true;
      });
      var _res = await _repo
          .list(MServiceRequestFilter(id: widget.id, refId: Model.customer.id));

      if (!_res.error) {
        _header = _res.data[0];
      }

      setState(() {
        _initLoading = false;
      });
    }
    _getDetail();
  }

  Widget _buildPendingBtn(
      {MRequestService? header, MServiceRequestDetail? detail}) {
    if ((header?.status?.toUpperCase() == RequestStatus.pending ||
            header?.status?.toUpperCase() == RequestStatus.accepted) &&
        detail!.acceptedPartners!
            .every((e) => e.status?.toUpperCase() == RequestStatus.rejected))
      return Positioned(
        bottom: _util.query.bottom <= 0 ? 15 : _util.query.bottom,
        child: Parent(
          style: ParentStyle()
            ..alignment.center()
            ..padding(
              horizontal: 15,
            )
            ..width(_util.query.width),
          child: BuildButton(
            title: _util.language.key('cancel-request'),
            fontSize: 16,
            onPress: () {
              confirmCancelModel(context, onSubmit: _onCancelService);
            },
          ),
        ),
      );

    return SizedBox();
  }

  Widget _buildCloseBtn(
      {MRequestService? header, MServiceRequestDetail? detail}) {
    if ((header?.status?.toUpperCase() == RequestStatus.closed ||
            header?.status?.toUpperCase() == RequestStatus.waitingFeedback) &&
        _util.query.isKbPopup == false)
      return Positioned(
        bottom: _util.query.bottom <= 0 ? 15 : _util.query.bottom,
        child: Parent(
          style: ParentStyle()
            ..alignment.center()
            ..padding(
              horizontal: 16,
            )
            ..width(_util.query.width),
          child: BuildButton(
            title:
                header?.status?.toUpperCase() == RequestStatus.waitingFeedback
                    ? _util.language.key('feedback')
                    : _util.language.key('checkout-payment'),
            fontSize: 16,
            onPress:
                header?.status?.toUpperCase() == RequestStatus.waitingFeedback
                    ? () {
                        modelGiveFeedBack(context,
                            onFeedBack: _onFeedback, onSkip: _onSkip);
                      }
                    : () {
                        _toCheckOutPaymentPage(header, detail);
                      },
          ),
        ),
      );

    return SizedBox();
  }

  void _toCheckOutPaymentPage(
      MRequestService? header, MServiceRequestDetail? detail) {
    _util.navigator.to(
      CustomerCloseService(
        detail: detail,
        data: header,
      ),
      transition: OCSTransitions.LEFT,
    );
  }

  Future _onFeedback(double rate, String comment) async {
    _util.navigator.pop();
    setState(() {
      _approveLoading = true;
    });

    var _res = await _repo.feedbackRequest(
      requestId: _header.id ?? 0,
      comment: comment,
      rating: rate,
    );
    _onCallApiFeedBack(_res);

    setState(() {
      _approveLoading = false;
    });
  }

  Future _onSkip() async {
    _util.navigator.pop();
    setState(() {
      _approveLoading = true;
    });

    var _res = await _repo.feedbackRequest(
      requestId: _header.id ?? 0,
      comment: "",
      rating: 0,
    );
    _onCallApiFeedBack(_res);

    setState(() {
      _approveLoading = false;
    });
  }

  _onCallApiFeedBack(MResponse res) {
    if (!res.error) {
      _util.snackBar(
        message: _util.language.key('success'),
        status: SnackBarStatus.success,
      );
      var json = jsonDecode(res.data);
      MRequestService header = MRequestService.fromJson(json[0]);
      if (Globals.tabRequestStatusIndex == 0)
        context.read<ServiceRequestBloc>()
          ..add(UpdateServiceRequest(data: header));
      else if (Globals.tabRequestStatusIndex == 6) {
        context
            .read<ServiceRequestBloc>()
            .add(RemoveServiceRequest(data: header));
      }

      _util.pop();
    } else {
      _util.snackBar(message: res.message, status: SnackBarStatus.danger);
    }
  }

  void _checkStatus(MRequestService header) {
    checkCusRequestStatus(
        header: header,
        func: (status, color, subStatus) {
          _status = status;
          _color = color;
        });
  }

  Future _getDetail() async {
    await context.read<RequestServiceDetailBloc>()
      ..add(FetchRequestDetail(id: _header.id ?? 0, header: _header));
    if (widget.showFeedback) {
      await modelGiveFeedBack(context,
          onFeedBack: _onFeedback, onSkip: _onSkip);
    }
  }

  Future _onCancelService() async {
    _util.navigator.pop();
    setState(() {
      _approveLoading = true;
    });
    var _res = await _repo.cancelRequest(_header.id ?? 0);
    if (_res.error) {
      _util.snackBar(message: _res.message, status: SnackBarStatus.danger);
    } else {
      setState(() {
        _approveLoading = false;
      });
      var json = jsonDecode(_res.data);
      if (Globals.tabRequestStatusIndex == 0)
        context.read<ServiceRequestBloc>()
          ..add(UpdateServiceRequest(
              data: _header.copyWith(status: RequestStatus.canceled)));
      else if (Globals.tabRequestStatusIndex == 1) {
        context
            .read<ServiceRequestBloc>()
            .add(RemoveServiceRequest(data: _header));
      }
      _util.snackBar(
        message: _util.language.key('success'),
        status: SnackBarStatus.success,
      );
      _util.navigator.pop();
    }
    setState(() {
      _approveLoading = false;
    });
  }

  Widget _buildPartnerSection(
      MRequestService header, MServiceRequestDetail detail) {
    return (_header.partnerId ?? 0) > 0
        ? Parent(
            style: ParentStyle()..margin(top: 10),
            child: _buildApprovedPartner(header, detail),
          )
        : detail.acceptedPartners!.isEmpty
            ? buildNoAcceptPartner(_util.language.key('no-accept-partner'))
            : _buildAcceptPartner(header, detail);
  }

  Widget _buildAcceptPartner(
      MRequestService header, MServiceRequestDetail detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Txt(
          _util.language.key('accept-partners'),
          style: TxtStyle()
            ..fontSize(Style.subTitleSize)
            ..margin(top: 10)
            ..textColor(OCSColor.text),
        ),
        Parent(
          style: ParentStyle()
            ..width(_util.query.width)
            ..margin(top: 5)
            ..padding(bottom: 20),
          child: AlignedGridView.count(
            primary: true,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            itemCount: detail.acceptedPartners?.length,
            itemBuilder: (BuildContext context, int i) {
              return buildPartnerCard(
                context,
                header: header,
                detail: detail,
                data: detail.acceptedPartners![i],
              );
            },
            crossAxisCount: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildApprovedPartner(
      MRequestService header, MServiceRequestDetail detail) {
    MAcceptedPartner _approvePartner = detail.acceptedPartners![0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Txt(
          _util.language.key('approved-partner'),
          style: TxtStyle()
            ..fontSize(Style.subTitleSize)
            ..textColor(OCSColor.text),
        ),
        header.status?.toUpperCase() == RequestStatus.done
            ? buildDonePartnerCard(
                context,
                header: header,
                detail: detail,
                approvePartner: _approvePartner,
              )
            : buildPartnerCard(context,
                header: header, detail: detail, data: _approvePartner)
      ],
    );
  }

  Future _getUpdateQuot(
    int quotId,
  ) async {
    if (quotId == 0) return;
    setState(() {
      _initLoading = true;
    });
    MResponse res = await _requestUpdateQuotRepo.get(quotId);
    if (!res.error) {
      if (res.data.isNotEmpty) {
        _updateQuotData = res.data[0];
        context.read<RequestServiceDetailBloc>().add(
              UpdateRequestDetail(
                header: _header,
                detail: _requestDetail.copyWith(
                  quotUpdateRequest: _updateQuotData,
                ),
              ),
            );
      }
    } else {
      _util.snackBar(message: res.message, status: SnackBarStatus.danger);
    }
    setState(() {
      _initLoading = false;
    });
  }
}
