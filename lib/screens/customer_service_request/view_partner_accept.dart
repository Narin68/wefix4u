import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ocs_auth/models/response.dart';
import 'package:ocs_util/ocs_util.dart';
import '../../repositories/quotation_repo.dart';
import '../view_quote.dart';
import '/blocs/request_service_detail/request_service_detail_bloc.dart';
import '/modals/requestUpdateQuot.dart';
import '/repositories/request_update_invoice.dart';
import '../message/message_widget.dart';
import '/modals/quotation.dart';
import '/blocs/service_request/service_request_bloc.dart';
import '/modals/customer_request_service.dart';
import '../service_request_widget.dart';
import '/globals.dart';
import '/repositories/customer_request_service.dart';
import '/modals/partner.dart';
import '../widget.dart';

class PartnerAccept extends StatefulWidget {
  final MAcceptedPartner? data;
  final MRequestService? service;
  final MServiceRequestDetail? detail;
  final bool? isNot;
  final int? refId;
  final int? quotId;

  const PartnerAccept({
    Key? key,
    this.service,
    this.detail,
    this.isNot,
    this.refId,
    this.data,
    this.quotId,
  }) : super(key: key);

  @override
  State<PartnerAccept> createState() => _PartnerAcceptState();
}

class _PartnerAcceptState extends State<PartnerAccept> {
  MAcceptedPartner _approvePartner = MAcceptedPartner();
  late var _util = OCSUtil.of(context);
  bool _loading = false;
  bool _initLoading = false;
  ServiceRequestRepo _repo = ServiceRequestRepo();
  QuotRepo _quotRepo = QuotRepo();
  MRequestService _header = MRequestService();
  var txtTitleStyle = TxtStyle()
    ..fontSize(Style.subTitleSize)
    ..textColor(
      OCSColor.text.withOpacity(0.8),
    )
    ..width(80)
    ..textColor(OCSColor.text);
  var subtitleStyle = TxtStyle()
    ..fontSize(Style.subTextSize)
    ..textColor(OCSColor.text.withOpacity(0.8));
  MServiceRequestDetail _requestDetail = MServiceRequestDetail();
  RequestUpdateQuot _requestUpdateQuotRepo = RequestUpdateQuot();
  MRequestUpdateQuot? _updateQuotData;
  MQuotation? updateData;
  MQuotationData? _quotData;
  MQuotationData? _quotDataTemp;

  @override
  void initState() {
    super.initState();
    if (widget.data != null) _approvePartner = widget.data!;
    if (widget.service != null) _header = widget.service!;
    if (widget.detail != null) _requestDetail = widget.detail!;
    _init();
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
          leading: NavigatorBackButton(loading: _loading),
          backgroundColor: OCSColor.primary,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Txt(
                _util.language.key('partner-information'),
                style: TxtStyle()
                  ..fontSize(16)
                  ..textColor(Colors.white),
              ),
              Expanded(child: SizedBox()),
            ],
          ),
          actions: [
            if (_quotData?.items?.isNotEmpty ?? false) _rejectWidget(),
            MessageIcon(
              receiverImage: _approvePartner.image,
              receiverName: _util.language.by(
                km: _approvePartner.partnerName,
                en: _approvePartner.partnerNameEnglish,
                autoFill: true,
              ),
              receiverId: _approvePartner.partnerId,
              requestId: _header.id,
              requestStatus: _header.status?.toLowerCase(),
            ),
          ],
        ),
        body: _initLoading
            ? Center(
                child: CircularProgressIndicator.adaptive(),
              )
            : SafeArea(
                bottom: false,
                child: Parent(
                  style: ParentStyle()..height(_util.query.height),
                  child: Stack(
                    children: [
                      CustomScrollView(
                        slivers: [
                          _buildBody(),
                        ],
                      ),
                      if ((_header.status?.toUpperCase() ==
                                  RequestStatus.pending ||
                              _header.status?.toUpperCase() ==
                                  RequestStatus.accepted) &&
                          _approvePartner.status?.toUpperCase() !=
                              RequestStatus.rejected &&
                          (_approvePartner.quotationId ?? 0) > 0)
                        if (_quotData?.items?.isNotEmpty ?? false)
                          Positioned(
                            bottom: _util.query.bottom <= 0
                                ? 15
                                : _util.query.bottom,
                            child: Parent(
                              style: ParentStyle()
                                ..alignment.center()
                                ..padding(
                                  horizontal: 16,
                                )
                                ..width(_util.query.width),
                              child: BuildButton(
                                title: _util.language.key('approve'),
                                fontSize: 16,
                                onPress: _quotData?.requireDeposit ?? false
                                    ? _confirmDeposit
                                    : _confirmDialog,
                              ),
                            ),
                          ),
                      _buildButtonRequest(),
                      if (_loading)
                        Positioned(
                          child: Container(
                            color: Colors.black.withOpacity(.3),
                            child: const Center(
                              child: CircularProgressIndicator.adaptive(
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  void _setDataQuot() {
    // if (_header.status?.toLowerCase() != "approved" &&
    //     _header.status?.toLowerCase() != "fixing" &&
    //     _header.status?.toLowerCase() != "heading") return;
    // List<MItemQuotation>? items = [];
    // _updateQuotData = _requestDetail.quotUpdateRequest;
    // _updateQuotData?.details?.forEach((e) {
    //   List<MItemQuotation>? data = _approvePartner.quotation?.items
    //       ?.where((v) => v.id == e.quotDetailId)
    //       .toList();
    //   items.add(MItemQuotation(
    //     id: e.quotDetailId,
    //     cost: e.cost,
    //     name: e.name,
    //     nameEnglish: e.nameEnglish,
    //     unitType: e.unitType,
    //     qty: e.quantity,
    //     unitPrice: (e.quantity ?? 0) / (e.cost ?? 0),
    //     itemDiscount:
    //         data != null && data.isNotEmpty ? data[0].itemDiscount : null,
    //   ));
    // });
    //
    // double cost = 0;
    // items.forEach((e) {
    //   cost += e.cost ?? 0;
    // });
    // updateData = _approvePartner.quotation?.copyWith(
    //   items: items,
    //   cost: cost,
    // );
    //
    // setState(() {});
  }

  Future _getUpdateQuot(
    int quotId,
  ) async {
    if (quotId == 0 || _requestDetail.quotUpdateRequest != null) return;
    setState(() {
      _initLoading = true;
    });
    MResponse res = await _requestUpdateQuotRepo.get(quotId);
    if (!res.error) {
      if (res.data.isNotEmpty) {
        _updateQuotData = res.data[0];
        _requestDetail =
            _requestDetail.copyWith(quotUpdateRequest: _updateQuotData);
      }
    } else {
      _util.snackBar(message: res.message, status: SnackBarStatus.danger);
    }
    setState(() {
      _initLoading = false;
    });
  }

  void _init() async {
    if (widget.isNot ?? false) {
      setState(() {
        _initLoading = true;
      });

      var res = await _repo.list(
          MServiceRequestFilter(refId: Model.customer.id, id: widget.refId));

      if (!res.error) {
        if (res.data.isNotEmpty) _header = res.data[0];
      }
      var _res = await _repo.getDetail(widget.refId ?? 0);

      if (!_res.error) {
        _requestDetail = _res.data;
        var partner = _requestDetail.acceptedPartners
            ?.where((e) => (e.quotationId ?? 0) == (widget.quotId ?? 0))
            .first;

        _approvePartner = partner!;

        await _getUpdateQuot(_approvePartner.quotationId ?? 0);
      }

      setState(() {
        _initLoading = false;
      });
    }
    _setDataQuot();
  }

  Future _allowUpdateQuot() async {
    if (_requestDetail.quotUpdateRequest == null) return;

    _util.pop();
    setState(() {
      _loading = true;
    });

    MResponse _res = await _requestUpdateQuotRepo
        .allow(_requestDetail.quotUpdateRequest?.id ?? 0);

    if (!_res.error) {
      if (_res.data != null) {
        _onSuccessUpdateQuot(_res.data);
      }
    } else {
      _util.snackBar(message: _res.message, status: SnackBarStatus.danger);
    }

    setState(() {
      _loading = false;
    });
  }

  Future _approveUpdateQuot() async {
    if (_requestDetail.quotUpdateRequest == null) return;

    _util.pop();
    setState(() {
      _loading = true;
    });

    MResponse _res = await _requestUpdateQuotRepo
        .approve(_requestDetail.quotUpdateRequest?.id ?? 0);

    if (!_res.error) {
      if (_res.data != null) {
        _util.snackBar(
            message: _util.language.key('success'),
            status: SnackBarStatus.success);
        _updateQuotData = _res.data;
        _requestDetail = _requestDetail.copyWith(
          quotUpdateRequest: _updateQuotData,
          // acceptedPartners: [_approvePartner.copyWith(quotation: updateData)],
        );
        _approvePartner = _requestDetail.acceptedPartners![0];

        context.read<RequestServiceDetailBloc>().add(
              UpdateRequestDetail(header: _header, detail: _requestDetail),
            );
      }
    } else {
      _util.snackBar(message: _res.message, status: SnackBarStatus.danger);
    }

    setState(() {
      _loading = false;
    });
  }

  Future _rejectUpdateQuot() async {
    if (_requestDetail.quotUpdateRequest == null) return;

    _util.pop();
    setState(() {
      _loading = true;
    });

    MResponse _res = await _requestUpdateQuotRepo
        .reject(_requestDetail.quotUpdateRequest?.id ?? 0);

    if (!_res.error) {
      if (_res.data != null) {
        _onSuccessUpdateQuot(_res.data);
      }
    } else {
      _util.snackBar(message: _res.message, status: SnackBarStatus.danger);
    }

    setState(() {
      _loading = false;
    });
  }

  void _onSuccessUpdateQuot(MRequestUpdateQuot data) {
    _util.snackBar(
        message: _util.language.key('success'), status: SnackBarStatus.success);
    _updateQuotData = data;
    _requestDetail =
        _requestDetail.copyWith(quotUpdateRequest: _updateQuotData);
    context.read<RequestServiceDetailBloc>().add(
          UpdateRequestDetail(
            header: _header,
            detail: _requestDetail.copyWith(
              quotUpdateRequest: _updateQuotData,
            ),
          ),
        );

    setState(() {});
  }

  void _updateRequest(String status) {
    int? index = _requestDetail.acceptedPartners
        ?.indexWhere((e) => e.quotationId == (_quotData?.id ?? 0));

    _requestDetail.acceptedPartners
        ?.removeWhere((e) => e.quotationId != (_quotData?.id));

    if (index != null) {
      _requestDetail.acceptedPartners?[index] =
          _requestDetail.acceptedPartners?[index].copyWith(status: status) ??
              MAcceptedPartner();
      if (status == RequestStatus.approved)
        _header = _header.copyWith(status: RequestStatus.approved);
      context.read<ServiceRequestBloc>()
        ..add(UpdateServiceRequest(data: _header));
      context.read<RequestServiceDetailBloc>()
        ..add(
          UpdateRequestDetail(
            header: _header,
            detail: _requestDetail,
          ),
        );
    }
  }

  bool _checkStatus(String? status) {
    if (status == null) return false;
    return status == "approved" || status == "heading" || status == "fixing";
  }

  Widget _rejectWidget() {
    if ((_header.status?.toUpperCase() == RequestStatus.pending ||
            _header.status?.toUpperCase() == RequestStatus.accepted) &&
        _approvePartner.status?.toUpperCase() != RequestStatus.rejected &&
        (_approvePartner.quotationId ?? 0) > 0)
      return TextButton(
        onPressed: () {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              contentPadding:
                  EdgeInsets.only(left: 25, top: 15, bottom: 10, right: 15),
              title: Txt(
                _util.language.key('confirm-reject'),
                style: TxtStyle()
                  ..fontSize(Style.titleSize)
                  ..textColor(OCSColor.text),
              ),
              content: Txt(
                _util.language.key('do-you-want-to-reject-this-request'),
                style: TxtStyle()
                  ..fontSize(Style.subTitleSize)
                  ..textColor(OCSColor.text.withOpacity(0.7)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: Txt(
                    _util.language.key('no'),
                    style: TxtStyle()
                      ..textColor(OCSColor.text.withOpacity(0.6)),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await _onRejectPartner(_approvePartner);
                  },
                  child: Txt(
                    _util.language.key('yes'),
                  ),
                ),
              ],
            ),
          );
        },
        child: Txt(
          _util.language.key('reject'),
          style: TxtStyle()
            ..textColor(Colors.white)
            ..fontSize(16),
        ),
      );
    return SizedBox();
  }

  void _confirmDialog() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        contentPadding:
            EdgeInsets.only(left: 25, top: 15, bottom: 10, right: 15),
        title: Txt(
          _util.language.key('confirm-approve'),
          style: TxtStyle()
            ..fontSize(Style.titleSize)
            ..textColor(OCSColor.text),
        ),
        content: Txt(
          _util.language.key('do-you-want-to-accept-this-request'),
          style: TxtStyle()
            ..fontSize(Style.subTitleSize)
            ..textColor(OCSColor.text.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: Txt(
              _util.language.key('no'),
              style: TxtStyle()..textColor(OCSColor.text.withOpacity(0.6)),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _approvePartnerAccept();
            },
            child: Txt(
              _util.language.key('yes'),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeposit() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        contentPadding:
            EdgeInsets.only(left: 25, top: 15, bottom: 10, right: 15),
        title: Txt(
          _util.language.key('confirm-approve'),
          style: TxtStyle()
            ..fontSize(Style.titleSize)
            ..textColor(OCSColor.text),
        ),
        content: Txt(
          "ជាងជួសជុលទៀមទារបង់ប្រាក់កក់ចំនួន ${OCSUtil.currency(_quotData?.depositAmount ?? 0, sign: "\$")}${(_quotData?.depositPercent ?? 0) > 0 ? "(${OCSUtil.currency(_quotData?.depositPercent ?? 0, sign: "", autoDecimal: true)}%)" : ""} នៃទឹកប្រាក់សរុប",
          style: TxtStyle()
            ..fontSize(Style.subTitleSize)
            ..textColor(OCSColor.text.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: Txt(
              _util.language.key('no'),
              style: TxtStyle()..textColor(OCSColor.text.withOpacity(0.6)),
            ),
          ),
          TextButton(
            onPressed: _approvePartnerAccept,
            child: Txt(
              _util.language.key('pay-now'),
            ),
          ),
        ],
      ),
    );
  }

  Future _approvePartnerAccept() async {
    _util.navigator.pop();
    setState(() {
      _loading = true;
    });

    /// review

    var _res = await _quotRepo.approve(id: _quotData?.id ?? 0);
    if (!_res.error) {
      _updateRequest(RequestStatus.approved);
      if (Globals.tabRequestStatusIndex != 0) {
        context
            .read<ServiceRequestBloc>()
            .add(RemoveServiceRequest(data: _header));
      }
      _util.snackBar(message: "Success", status: SnackBarStatus.success);
      _util.navigator.pop();
    } else {
      print("Error => here ${_res.message}");
      _util.snackBar(message: _res.message, status: SnackBarStatus.danger);
    }
    setState(() {
      _loading = false;
    });
  }

  Future _onRejectPartner(MAcceptedPartner partner) async {
    _util.navigator.pop();
    setState(() {
      _loading = true;
    });

    /// review
    var _res = await _quotRepo.reject(id: _quotData?.id ?? 0);
    if (!_res.error) {
      _updateRequest(RequestStatus.rejected);
      _util.snackBar(message: "Success", status: SnackBarStatus.success);
      _util.navigator.pop();
    } else {
      _util.snackBar(message: _res.message, status: SnackBarStatus.danger);
    }

    setState(() {
      _loading = false;
    });
  }

  Widget _updateQuotStatus() {
    if (_requestDetail.quotUpdateRequest != null &&
        (_requestDetail.quotUpdateRequest?.status?.isNotEmpty ?? false))
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          Parent(
            style: ParentStyle()
              ..width(10)
              ..height(10)
              ..borderRadius(all: 10)
              ..border(
                  all: 1,
                  color: _requestDetail.quotUpdateRequest?.status == "AL" ||
                          _requestDetail.quotUpdateRequest?.status == "AP"
                      ? Colors.green
                      : _requestDetail.quotUpdateRequest?.status == "R"
                          ? Colors.red
                          : Colors.orange),
          ),
          SizedBox(width: 5),
          Txt(
            _util.language.key(
              _requestDetail.quotUpdateRequest?.status == "PR"
                  ? "request-update-invoice"
                  : _requestDetail.quotUpdateRequest?.status == "AL"
                      ? "customer-allow"
                      : _requestDetail.quotUpdateRequest?.status == "AP"
                          ? 'customer-approve'
                          : _requestDetail.quotUpdateRequest?.status == "PC"
                              ? "updated-invoice"
                              : _requestDetail.quotUpdateRequest?.status == "R"
                                  ? 'rejected-update'
                                  : '',
            ),
            style: TxtStyle()
              ..fontSize(
                  _requestDetail.quotUpdateRequest?.status == "PR" ? 14 : 12)
              ..bold(),
          ),
          Expanded(
            child: SizedBox(),
          ),
          if (_requestDetail.quotUpdateRequest?.status == "PR")
            Parent(
              style: ParentStyle()
                ..background.color(Colors.white)
                ..ripple(true)
                ..borderRadius(all: 5),
              gesture: Gestures()
                ..onTap(() {
                  _showAlert(
                      onSubmit: _rejectUpdateQuot,
                      message: _util.language
                          .key('do-you-want-to-reject-this-request'),
                      title: _util.language.key('confirm-reject-request'));
                }),
              child: Row(
                children: [
                  Icon(
                    Icons.close,
                    size: 18,
                    color: Colors.red,
                  ),
                  Txt(
                    _util.language.key('reject-request'),
                    style: TxtStyle()
                      ..fontSize(14)
                      ..textColor(Colors.red),
                  ),
                ],
              ),
            )
        ],
      );

    return SizedBox();
  }

  Widget _quoteInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Txt(
          '${_util.language.key('quotation')}',
          style: TxtStyle()
            ..fontSize(Style.titleSize)
            ..fontWeight(FontWeight.bold)
            ..width(_util.query.width)
            ..textColor(OCSColor.text),
        ),
        SizedBox(height: 5),
        if ((_approvePartner.quotationId ?? 0) > 0) ...[
          Row(
            children: [
              Txt(
                _util.language.key('quotation-code') + " :",
                style: TxtStyle()
                  ..fontSize(12)
                  ..width(100)
                  ..textColor(OCSColor.text),
              ),
              SizedBox(width: 10),
              Txt(
                '#${_approvePartner.quotationCode ?? ""}',
                style: TxtStyle()
                  ..textAlign.right()
                  ..fontSize(12)
                  ..textColor(OCSColor.text),
              ),
            ],
          ),
          if (_quotData != null)
            Row(
              children: [
                Txt(
                  _util.language.key('date') + " :",
                  style: TxtStyle()
                    ..fontSize(12)
                    ..width(100)
                    ..textColor(OCSColor.text),
                ),
                SizedBox(width: 10),
                // todo : Change next time
                Txt(
                  OCSUtil.dateFormat(
                    DateTime.parse(_quotData?.createdDate ?? ""),
                    format: Format.date,
                    langCode: Globals.langCode,
                  ),
                  style: TxtStyle()
                    ..fontSize(12)
                    ..textAlign.right()
                    ..textColor(OCSColor.text),
                )
              ],
            ),
        ],
      ],
    );
  }

  Widget _headerQuote() {
    return Column(
      children: [
        _quoteInfo(),
        SizedBox(height: 5),
        if ((_quotData?.requireDeposit ?? false) &&
            _quotData?.status == RequestStatus.quoteSubmitted) ...[
          Row(
            children: [
              Parent(
                style: ParentStyle()
                  ..width(10)
                  ..height(10)
                  ..border(all: 1, color: Colors.orange)
                  ..borderRadius(all: 50),
              ),
              SizedBox(width: 5),
              Txt(
                "ទៀមទារបង់ប្រាក់កក់ចំនួន ${OCSUtil.currency(_quotData?.depositAmount ?? 0, sign: "\$")}${(_quotData?.depositPercent ?? 0) > 0 ? "(${OCSUtil.currency(_quotData?.depositPercent ?? 0, sign: "", autoDecimal: true)}%)" : ""}",
                style: TxtStyle()..fontSize(12),
              ),
            ],
          ),
          SizedBox(height: 5),
        ],
        if (_checkStatus(_header.status?.toLowerCase()) &&
            _requestDetail.quotUpdateRequest?.status != "PC") ...[
          _updateQuotStatus(),
          SizedBox(height: 5),
        ],
      ],
    );
  }

  Widget _buildButtonRequest() {
    if (_util.query.isKbPopup ||
        _requestDetail.quotUpdateRequest?.status == "R") return SizedBox();
    if (_requestDetail.quotUpdateRequest != null &&
        _checkStatus(_header.status?.toLowerCase()) &&
        _requestDetail.quotUpdateRequest?.status == "PR")
      return Positioned(
        bottom: 15 + _util.query.bottom,
        child: Parent(
          style: ParentStyle()
            ..width(_util.query.width)
            ..padding(horizontal: 15),
          child: BuildButton(
            width: _util.query.width,
            title: _util.language.key('allow-update-invoice'),
            fontSize: 14,
            height: 45,
            onPress: () {
              _showAlert(
                message:
                    _util.language.key('do-you-want-to-accept-this-request'),
                title: _util.language.key('confirm-approve'),
                onSubmit: _allowUpdateQuot,
              );
            },
          ),
        ),
      );
    return SizedBox();
  }

  Widget _buildBody() {
    return SliverToBoxAdapter(
      child: Parent(
        style: ParentStyle()..width(_util.query.width),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: Parent(
                style: ParentStyle()
                  ..height(80)
                  ..overflow.hidden()
                  ..width(_util.query.width)
                  ..background.color(Colors.grey),
                child: MyNetworkImage(url: _approvePartner.image ?? ""),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: Parent(
                style: ParentStyle()
                  ..height(120)
                  ..borderRadius(all: 1)
                  ..overflow.hidden()
                  ..width(_util.query.width)
                  ..background.blur(3),
              ),
            ),
            Parent(
              style: ParentStyle()..padding(horizontal: 15, bottom: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30),
                  _buildPartnerInfo(),
                  SizedBox(height: 15),
                  BuildQuoteTable(
                    quotId: widget.quotId ?? 0,
                    header: _headerQuote(),
                    quoteData: (quote) {
                      _quotData = quote;
                      setState(() {});
                    },
                  ),
                  if ((widget.quotId ?? 0) <= 0 ||
                      ((_quotData?.items?.isEmpty ?? false) &&
                          widget.quotId != null))
                    _noQuotation(),
                  if (_requestDetail.quotUpdateRequest?.status == "PC") ...[
                    _buildUpdatedInvoice(),
                    SizedBox(height: 5),
                    // todo: Change next time

                    // buildQuotTable(
                    //   quotation: updateData ?? MQuotation(),
                    //   context: context,
                    // ),
                    SizedBox(height: 15),
                    _buildButtonApprove(),
                  ],
                  SizedBox(height: 70),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noQuotation() {
    return Parent(
      style: ParentStyle()
        ..height(50)
        ..borderRadius(all: 5)
        ..border(all: 1, color: OCSColor.primary.withOpacity(0.7))
        ..background.color(OCSColor.primary.withOpacity(0.1)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Txt(
            _util.language.key('no-quotation'),
            style: TxtStyle()
              ..fontSize(Style.subTitleSize)
              ..textColor(OCSColor.text.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerInfo() {
    return Parent(
      style: ParentStyle()
        ..background.color(Colors.white)
        ..borderRadius(all: 5)
        ..padding(all: 10)
        ..elevation(1, opacity: 0.2)
        ..width(_util.query.width),
      child: Row(
        children: [
          Parent(
              style: ParentStyle()
                ..height(100)
                ..width(100)
                ..borderRadius(all: 5)
                ..overflow.hidden()
                ..background.color(Colors.white)
                ..alignmentContent.center()
                ..overflow.hidden(),
              child: MyNetworkImage(
                height: 100,
                width: 120,
                url: _approvePartner.image ?? '',
              )),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Txt(
                  _util.language.by(
                    km: _approvePartner.partnerName ?? "",
                    en: _approvePartner.partnerNameEnglish ?? "",
                    autoFill: true,
                  ),
                  style: TxtStyle()
                    ..fontSize(16)
                    ..textOverflow(TextOverflow.ellipsis)
                    ..maxLines(2)
                    ..textColor(OCSColor.text),
                ),
                Txt(
                  '${_approvePartner.partnerPhone ?? ""}',
                  style: TxtStyle()
                    ..fontSize(12)
                    ..maxLines(1)
                    ..textOverflow(TextOverflow.ellipsis)
                    ..textColor(OCSColor.text.withOpacity(0.8)),
                ),
                Txt(
                  _approvePartner.partnerAddress ?? "",
                  style: TxtStyle()
                    ..fontSize(12)
                    ..maxLines(3)
                    ..width(_util.query.width - _util.query.width / 2.3)
                    ..textOverflow(TextOverflow.ellipsis)
                    ..textColor(OCSColor.text.withOpacity(0.8)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showAlert(
      {String message = '', String title = '', required Function onSubmit}) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding:
              EdgeInsets.only(left: 25, top: 15, bottom: 15, right: 15),
          content: Txt(
            message,
            style: TxtStyle()..fontSize(14),
          ),
          title: Txt(
            title,
            style: TxtStyle()..fontSize(16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _util.pop();
              },
              child: Txt(
                _util.language.key('no'),
                style: TxtStyle()..textColor(OCSColor.text.withOpacity(0.7)),
              ),
            ),
            TextButton(
              onPressed: () {
                onSubmit();
              },
              child: Txt(
                _util.language.key('yes'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUpdatedInvoice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Txt(
              _util.language.key('updated-invoices'),
              style: TxtStyle()
                ..fontSize(14)
                ..bold(),
            ),
            SizedBox(width: 3),
            Expanded(
              child: Parent(
                style: ParentStyle()..margin(top: 7),
                child: Divider(
                  color: Colors.black.withOpacity(0.2),
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButtonApprove() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BuildSecondButton(
          title: _util.language.key('reject-update'),
          height: 35,
          width: 120,
          fontSize: 14,
          onPress: () {
            _showAlert(
              onSubmit: _rejectUpdateQuot,
              message: _util.language.key('do-you-want-to-reject-update'),
              title: _util.language.key('confirm-reject-update'),
            );
          },
        ),
        SizedBox(width: 10),
        BuildButton(
          title: _util.language.key('approve-update'),
          height: 35,
          width: 120,
          fontSize: 14,
          onPress: () {
            _showAlert(
              message: _util.language.key('do-you-want-to-accept-this-request'),
              title: _util.language.key('confirm-approve'),
              onSubmit: _approveUpdateQuot,
            );
          },
        ),
      ],
    );
  }
}
