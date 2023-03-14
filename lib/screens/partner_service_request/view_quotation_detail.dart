import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ocs_auth/models/response.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:wefix4utoday/modals/discount.dart';
import '../../repositories/quotation_repo.dart';
import '../view_quote.dart';
import '/modals/requestUpdateQuot.dart';
import '../create_quot/update_quot.dart';
import '/repositories/request_update_invoice.dart';
import '/blocs/request_service_detail/request_service_detail_bloc.dart';
import '../create_quot/create_quot.dart';
import '/globals.dart';
import '/modals/partner.dart';
import '../widget.dart';
import '/modals/customer_request_service.dart';
import '/modals/quotation.dart';

class ViewQuotationDetail extends StatefulWidget {
  final MServiceRequestDetail detail;
  final MRequestService data;

  const ViewQuotationDetail(
      {Key? key, required this.detail, required this.data})
      : super(key: key);

  @override
  State<ViewQuotationDetail> createState() => _ViewQuotationDetailState();
}

class _ViewQuotationDetailState extends State<ViewQuotationDetail> {
  late var _util = OCSUtil.of(context);
  MServiceRequestDetail _requestDetail = MServiceRequestDetail();
  MAcceptedPartner data = MAcceptedPartner();
  MRequestService? _header;

  List<MItemQuotation> _itemQuotation = [];
  var txtTitleStyle = TxtStyle()
    ..fontSize(Style.subTitleSize)
    ..textColor(
      OCSColor.text.withOpacity(0.8),
    )
    ..width(80)
    ..textColor(OCSColor.text);
  var subtitleStyle = TxtStyle()
    ..fontSize(Style.subTitleSize)
    ..textColor(OCSColor.text.withOpacity(0.8));
  double _fontSize = 12;
  bool _loading = false;
  RequestUpdateQuot _repo = RequestUpdateQuot();
  MRequestUpdateQuot? _updateQuotData;
  MQuotationData? _quotData;
  bool _initLoading = false;

  @override
  void initState() {
    super.initState();
    _requestDetail = widget.detail;
    _header = widget.data;
    context.read<RequestServiceDetailBloc>().add(GetRequestDetail());
    _getUpdateQuot();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: NavigatorBackButton(),
        backgroundColor: OCSColor.primary,
        title: Txt(
          "${_util.language.key('quotation')}",
          style: TxtStyle()
            ..fontSize(16)
            ..textColor(Colors.white),
        ),
        actions: [
          // if (widget.data.status?.toLowerCase() == "quote submitted")
          //   IconButton(
          //     tooltip: _util.language.key("update-quotation"),
          //     onPressed: _toUpdate,
          //     icon: Icon(Icons.edit_note),
          //   )
        ],
      ),
      body: _initLoading
          ? Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : Parent(
              style: ParentStyle(),
              child: Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Parent(
                          style: ParentStyle()..padding(all: 15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              BuildQuoteTable(
                                quotId: _requestDetail
                                        .acceptedPartners?[0].quotationId ??
                                    0,
                                header: _headerQuote(),
                                quoteData: (quote) {
                                  _quotData = quote;
                                  setState(() {});
                                },
                              ),
                              if (_requestDetail.quotUpdateRequest?.status ==
                                  "PC") ...[
                                _buildUpdatedInvoice(),
                                if ((_checkStatus(
                                        _header?.status?.toLowerCase()) &&
                                    _requestDetail.quotUpdateRequest?.status ==
                                        "PC")) ...[
                                  SizedBox(height: 5),
                                  _buildStatus(
                                    _requestDetail.quotUpdateRequest,
                                  ),
                                ],
                                SizedBox(height: 5),
                                // todo : Change next time
                                // buildQuotTable(
                                //   promoDiscount: _requestDetail.promoDiscount,
                                //   quotation: updateData ?? MQuotation(),
                                //   context: context,
                                // ),
                              ],
                              SizedBox(height: 70),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  if (_checkStatus(_header?.status?.toLowerCase()))
                    _buildButtonRequestUpdateQuot(
                        _requestDetail.quotUpdateRequest),
                  if (_loading)
                    Positioned(
                      child: Container(
                        color: Colors.black.withOpacity(.3),
                        child: const Center(
                          child: CircularProgressIndicator.adaptive(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                      ),
                    ),
                ],
              )),
    );
  }

  void temp() {
    // var accepted = state.detail?.acceptedPartners?[0];
    // List<MItemQuotation>? items = [];
    // _updateQuotData?.details?.forEach((e) {
    //   List<MItemQuotation>? data = accepted?.quotation?.items
    //       ?.where((v) => v.id == e.quotDetailId)
    //       .toList();
    //   items.add(
    //     MItemQuotation(
    //       id: e.quotDetailId,
    //       cost: e.cost,
    //       name: e.name,
    //       nameEnglish: e.nameEnglish,
    //       unitType: e.unitType,
    //       qty: e.quantity,
    //       unitPrice: (e.quantity ?? 0) / (e.cost ?? 0),
    //       itemDiscount: data != null && data.isNotEmpty
    //           ? data[0].itemDiscount
    //           : null,
    //     ),
    //   );
    // });
    // double cost = 0;
    // items.forEach((e) {
    //   cost += e.cost ?? 0;
    // });
    // MQuotation? updateData =
    // accepted?.quotation?.copyWith(items: items, cost: cost);
  }

  bool _checkStatus(String? status) {
    if (status == null) return false;
    return status == "approved" || status == "heading" || status == "fixing";
  }

  _calculateItemPrice() {
    _itemQuotation.forEach((e) {
      e = e.copyWith(unitPrice: (e.cost ?? 0) / (e.qty ?? 0));
      int index = _itemQuotation.indexWhere((v) => e.id == v.id);
      _itemQuotation[index] = e;
    });
  }

  Future _getUpdateQuot() async {
    if ((widget.data.status?.toLowerCase() != "approved" &&
            widget.data.status?.toLowerCase() != "heading" &&
            widget.data.status?.toLowerCase() != "fixing") ||
        widget.detail.acceptedPartners == null) return;
    int id = widget.detail.acceptedPartners?[0].quotationId ?? 0;
    if (id == 0) return;
    setState(() {
      _loading = true;
    });
    MResponse res = await _repo.get(id);
    if (!res.error) {
      if (res.data.isNotEmpty) {
        _updateQuotData = res.data[0];
        context.read<RequestServiceDetailBloc>().add(
              UpdateRequestDetail(
                header: _header,
                detail: _requestDetail.copyWith(
                  acceptedPartners: [data],
                  quotUpdateRequest: _updateQuotData,
                ),
              ),
            );
      }
    } else {
      _util.snackBar(message: res.message, status: SnackBarStatus.danger);
    }
    setState(() {
      _loading = false;
    });
  }

  void _toUpdateQuot() {
    if ((data.quotationId ?? 0) <= 0) return;
    _calculateItemPrice();
    _util.navigator.to(
      UpdateQuotation(
        quot: _mapping(),
        data: _header,
        detail: _requestDetail,
      ),
      transition: OCSTransitions.LEFT,
    );
  }

  MSubmitQuotData _mapping() {
    MSubmitQuotData _quot = MSubmitQuotData(
      isDisPercent: (_quotData?.discountPercent ?? 0) > 0,
      discountPercent: _quotData?.discountPercent ?? 0,
      discountAmount: _quotData?.discountAmount ?? 0,
      partnerId: Model.partner.id,
      customerId: _header?.customerId ?? 0,
      amount: _quotData?.amount,
      total: _quotData?.total,
      requestId: _header?.id ?? 0,
      items: _quotData?.items,
      description: _quotData?.description,
      code: data.quotationCode,
      id: data.quotationId,
      requireDeposit: false,
    );
    return _quot;
  }

  void _toUpdate() {
    _calculateItemPrice();
    _util.navigator.to(
      CreateQuotation(
        isUpdate: true,
        quot: _mapping(),
        onSuccess: _onSuccessUpdateQuot,
      ),
      transition: OCSTransitions.LEFT,
    );
  }

  _onSuccessUpdateQuot(MSubmitQuotData quot) {
    _util.pop();
    quot.items?.forEach((e) {
      e = e.copyWith(unitPrice: (e.cost ?? 0) / (e.qty ?? 0));
      int? index = quot.items?.indexWhere((v) => e.id == v.id);
      quot.items?[index!] = e;
    });

    MQuotation _quot = MQuotation(
      id: quot.id,
      code: quot.code,
      requestId: quot.requestId,
      discountAmount: quot.discountAmount,
      discountPer: quot.discountPercent,
      desc: quot.description,
      items: quot.items,
      isDisPercent: quot.isDisPercent,
      cost: quot.amount,
      quotDiscount:
          (quot.discountPercent ?? 0) <= 0 && (quot.discountPercent ?? 0) <= 0
              ? MDiscount()
              : MDiscount(
                  discountBy: (quot.discountPercent ?? 0) > 0 ? "P" : "A",
                  discount: quot.isDisPercent ?? false
                      ? quot.discountPercent
                      : quot.discountAmount,
                ),
      vat: quot.vatAmount,
    );

    // data = data.copyWith(quotation: _quot);
    _requestDetail = _requestDetail.copyWith(acceptedPartners: [data]);

    context.read<RequestServiceDetailBloc>().add(UpdateRequestDetail(
        header: _header,
        detail: _requestDetail.copyWith(acceptedPartners: [data])));
    setState(() {});
  }

  Future _requestUpdateQuot() async {
    if ((data.quotationId ?? 0) > 0) return;

    _util.pop();
    setState(() {
      _loading = true;
    });

    MResponse _res = await _repo.request(data.quotationId ?? 0);

    if (!_res.error) {
      if (_res.data != null) {
        _updateQuotData = _res.data;
        context.read<RequestServiceDetailBloc>().add(
              UpdateRequestDetail(
                header: _header,
                detail: _requestDetail.copyWith(
                  acceptedPartners: [data],
                  quotUpdateRequest: _updateQuotData,
                ),
              ),
            );
      }
    } else {
      _util.snackBar(message: _res.message, status: SnackBarStatus.danger);
    }

    setState(() {
      _loading = false;
    });
  }

  Widget _headerQuote() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Txt(
          '${_util.language.key('quotation')}',
          style: TxtStyle()
            ..fontSize(Style.titleSize)
            ..fontWeight(FontWeight.bold)
            ..width(_util.query.width)
            ..textAlign.center()
            ..textColor(OCSColor.text),
        ),
        SizedBox(height: 10),
        _buildQuotationInfo(),
        if ((_quotData?.requireDeposit ?? false) &&
            _header?.status == RequestStatus.quoteSubmitted) ...[
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
        ],
        SizedBox(height: 5),
        if (_checkStatus(
              _header?.status?.toLowerCase(),
            ) &&
            _requestDetail.quotUpdateRequest?.status != "PC") ...[
          _buildStatus(_requestDetail.quotUpdateRequest),
          SizedBox(height: 5),
        ],
      ],
    );
  }

  Widget _buildButtonRequestUpdateQuot(MRequestUpdateQuot? updateQuotData) {
    String _status = updateQuotData?.status ?? "";
    if (_status == "PR" || _status == "PC" || _status == "R" || _status == "AP")
      return SizedBox();
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
          height: 45,
          title: _util.language.key(updateQuotData == null
              ? 'request-update-invoice'
              : 'update-invoice'),
          fontSize: 16,
          onPress: updateQuotData == null ? _requestUpdate : _toUpdateQuot,
        ),
      ),
    );
  }

  Widget _buildStatus(MRequestUpdateQuot? updateQuotData) {
    String _status = updateQuotData?.status ?? "";
    String status = _status == "PR"
        ? "request-pending"
        : _status == "AL"
            ? "customer-allow"
            : _status == "PC"
                ? "request-change"
                : _status == "AP"
                    ? "customer-approve"
                    : _status == "R"
                        ? "rejected-update-invoice"
                        : "";

    if (updateQuotData == null || _status.isEmpty) return SizedBox();
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
                color: _status == "AL" || _status == "AP"
                    ? Colors.green
                    : _status == "R"
                        ? Colors.red
                        : Colors.orange),
        ),
        SizedBox(width: 5),
        Txt(
          _util.language.key(status),
          style: TxtStyle()
            ..fontSize(12)
            ..bold(),
        ),
        Expanded(
          child: SizedBox(),
        ),
      ],
    );
  }

  void _requestUpdate() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding:
              EdgeInsets.only(left: 25, top: 15, bottom: 10, right: 15),
          content: Txt(
            _util.language.key('want-request-update-invoice'),
            style: TxtStyle()
              ..fontSize(14)
              ..textColor(OCSColor.text.withOpacity(0.7)),
          ),
          title: Txt(
            _util.language.key('request-update-invoice'),
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
              onPressed: _requestUpdateQuot,
              child: Txt(
                _util.language.key('ok'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuotationInfo() {
    String date = DateFormat("dd MMMM yyyy")
        .format(DateTime.parse('${_header?.createdDate}'));
    String? phone = _header?.customerPhone ?? "";
    if (phone.contains('+855')) {
      phone = phone.replaceAll('+855', '0');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Txt(
          "${_util.language.by(km: _header?.customerName, en: _header?.customerNameEnglish, autoFill: true).replaceAll('.', '')}",
          style: TxtStyle()
            ..fontSize(Style.subTitleSize)
            ..textColor(OCSColor.text)
            ..bold(),
        ),
        Txt(
          "$phone",
          style: TxtStyle()
            ..fontSize(_fontSize)
            ..textColor(OCSColor.text),
        ),
        if (widget.detail.customerEmail?.isNotEmpty ?? false)
          Txt(
            "${widget.detail.customerEmail ?? ""}",
            style: TxtStyle()
              ..fontSize(_fontSize)
              ..textColor(OCSColor.text),
          ),
        Parent(
          style: ParentStyle(),
          child: Txt(
            "${widget.data.targetLocation}",
            style: TxtStyle()
              ..fontSize(_fontSize)
              ..textColor(OCSColor.text),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        if ((data.quotationId ?? 0) > 0) ...[
          Parent(
            style: ParentStyle(),
            child: Row(
              children: [
                Txt(
                  "${_util.language.key('quotation-code')} :",
                  style: TxtStyle()
                    ..width(90)
                    ..fontSize(_fontSize)
                    ..textColor(OCSColor.text),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Txt(
                    "#${data.quotationCode}",
                    style: TxtStyle()
                      ..fontSize(_fontSize)
                      ..textColor(OCSColor.text),
                  ),
                ),
              ],
            ),
          ),
          Parent(
            style: ParentStyle(),
            child: Row(
              children: [
                Txt(
                  "${_util.language.key('date')} : ",
                  style: TxtStyle()
                    ..width(90)
                    ..fontSize(_fontSize)
                    ..textColor(OCSColor.text),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Txt(
                    '${date}',
                    style: TxtStyle()
                      ..fontSize(_fontSize)
                      ..textColor(OCSColor.text),
                  ),
                ),
              ],
            ),
          ),
        ]
        // SizedBox(height: 5),
      ],
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
}
