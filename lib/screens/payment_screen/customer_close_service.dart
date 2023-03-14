import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ocs_auth/ocs_auth.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '/modals/invoice.dart';
import '/repositories/invoice_repo.dart';
import '../cus_invoice_receipt/widget.dart';
import '/modals/discount.dart';
import '/repositories/discount_code.dart';
import '/blocs/request_service_detail/request_service_detail_bloc.dart';
import '/screens/payment_screen/payment.dart';
import '/screens/payment_screen/widget.dart';
import '/blocs/service_request/service_request_bloc.dart';
import '/signalr.dart';
import '../service_request_widget.dart';
import '/globals.dart';
import '/modals/partner.dart';
import '/repositories/customer_request_service.dart';
import '/modals/customer_request_service.dart';
import '/screens/widget.dart';

class CustomerCloseService extends StatefulWidget {
  final MRequestService? data;
  final MServiceRequestDetail? detail;

  const CustomerCloseService({Key? key, this.data, this.detail})
      : super(key: key);

  @override
  State<CustomerCloseService> createState() => _CustomerCloseServiceState();
}

class _CustomerCloseServiceState extends State<CustomerCloseService> {
  late var _util = OCSUtil.of(context);
  MRequestService _data = MRequestService();
  MServiceRequestDetail _requestDetail = MServiceRequestDetail();
  MAcceptedPartner _acceptedPartner = MAcceptedPartner();
  String _date = '';
  ServiceRequestRepo _repo = ServiceRequestRepo();
  bool _loading = false;
  bool _initLoading = false;
  var subtitleStyle = TxtStyle()
    ..fontSize(13)
    ..textColor(OCSColor.text.withOpacity(0.8));
  bool _isShow = false;
  double _grandTotal = 0;
  TextEditingController _codeTxt = TextEditingController();
  DiscountRepo _discountRepo = DiscountRepo();
  MDiscountCode? _discountData;
  double _discountCodeAmount = 0;
  MInvoiceData? invoiceData;

  @override
  void initState() {
    super.initState();
    _initData();
    _getInvoice();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_loading) _util.navigator.pop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: OCSColor.primary,
          toolbarHeight: 0,
          elevation: 0,
          shadowColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        bottomSheet: _util.query.isKbPopup ? SizedBox() : _buildBottomSheet(),
        floatingActionButton: _util.query.isKbPopup || _discountData != null
            ? SizedBox()
            : _data.status?.toLowerCase() == "closed" &&
                    _data.invoiceStatus?.toLowerCase() != "paid"
                ? FloatingActionButton(
                    onPressed: _loading ? null : _showDisCode,
                    child: Icon(Icons.receipt),
                    tooltip: _util.language.key('add-promotion-code'),
                  )
                : SizedBox(),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     showDialog<void>(
        //       context: context,
        //       barrierDismissible: false,
        //       builder: (BuildContext context) {
        //         return BuildReceiptTable(
        //           onClose: () {
        //             _util.navigator.pop();
        //             _util.navigator.pop();
        //             _util.navigator.pop();
        //           },
        //           promoDiscount: _discountData,
        //           partner: _acceptedPartner,
        //           invoice: invoiceData,
        //         );
        //       },
        //     );
        //   },
        // ),
        body: SafeArea(
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    title: Txt(
                      _util.language.key('checkout-payment'),
                      style: TxtStyle()
                        ..fontSize(16)
                        ..textColor(Colors.white),
                    ),
                    leading: NavigatorBackButton(loading: _loading),
                    centerTitle: true,
                    pinned: true,
                    // collapsedHeight: 56,
                    elevation: 1,
                    expandedHeight: 300,
                    backgroundColor: OCSColor.primary,
                    flexibleSpace: FlexibleSpaceBar(
                      background: _buildHeader(),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Parent(
                      style: ParentStyle()
                        ..padding(all: 15)
                        ..background.color(Colors.white),
                      child: Column(
                        children: [
                          _discountWidget(),
                          SizedBox(height: 15),
                          buildTableInvoice(context,
                              invoice: invoiceData, showFooter: false),
                          SizedBox(
                            height: (205 + _util.query.bottom) +
                                (_discountData != null ? 50 : 0),
                          ),
                          // SizedBox(height: 70),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              if (!_util.query.isKbPopup)
                if (_data.status?.toLowerCase() == "closed" &&
                    _data.invoiceStatus?.toLowerCase() != "paid")
                  Positioned(
                    bottom: 15,
                    child: Parent(
                      style: ParentStyle()
                        ..width(_util.query.width)
                        ..alignmentContent.center(),
                      child: BuildButton(
                          width: _util.query.width - 30,
                          title: _util.language.key('pay-now'),
                          fontSize: 16,
                          onPress: _toPaymentScreen
                          // SuccessPaymentDialog();
                          ),
                    ),
                  ),
              if (_loading || _initLoading)
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
          ),
        ),
      ),
    );
  }

  Future _getInvoice() async {
    setState(() {
      _initLoading = true;
    });
    var res =
        await InvoiceRepo().list(requestId: _data.id ?? 0, withDetail: true);
    if (!res.error) {
      if (res.data.isNotEmpty) {
        invoiceData = res.data[0];
      }
    } else {
      _util.snackBar(message: res.message, status: SnackBarStatus.danger);
    }
    setState(() {
      _initLoading = false;
    });
  }

  Future _getDiscountCode() async {
    if (_codeTxt.text.isEmpty) return;
    _util.pop();
    setState(() {
      _loading = true;
    });

    MResponse res = await _discountRepo.list(_codeTxt.text);

    if (!res.error) {
      _codeTxt.text = "";

      if (res.data.isNotEmpty) {
        _discountData = res.data[0];
        _discountCodeAmount = _discountData?.discountBy == "A"
            ? (_discountData?.discount ?? 0)
            : ((_grandTotal) / 100) * (_discountData?.discount ?? 0);
      } else {
        _util.snackBar(
          message: _util.language.key('not-found-discount-code'),
          status: SnackBarStatus.danger,
        );
      }
    } else {
      _util.snackBar(message: res.message, status: SnackBarStatus.danger);
    }
    setState(() {
      _loading = false;
    });
  }

  void _initData() {
    _data = widget.data!;
    _requestDetail = widget.detail!;
    String phone = _data.customerPhone ?? "";
    if ((_data.customerPhone ?? "").contains('+855')) {
      phone = phone.replaceAll('+855', '0');
      _data = _data.copyWith(customerPhone: phone);
    }
    if (_data.updatedDate != null) {
      _date = OCSUtil.dateFormat(
        DateTime.parse('${widget.data?.updatedDate}'),
        format: Format.date,
        langCode: Globals.langCode,
      );
      _data = _data.copyWith(updatedDate: _date);
    }
    _requestDetail.acceptedPartners?.forEach((e) {
      if (e.partnerId == _data.partnerId) {
        _acceptedPartner = e;
      }
    });
  }

  Future _toPaymentScreen() async {
    setState(() {
      _loading = true;
    });

    final _res = await PaymentRepo().before(
      db: Globals.databaseName,
      invoiceNo: '${invoiceData?.code ?? ""}',
      // invoiceNo: "${_requestDetail.approvedPartner?.invoiceCode}",
    );

    if (!_res.error) {
      await OCSAuth().refreshToken();
      final token = await OCSAuth().tokens();
      String _token = token?.accessToken ?? "";
      _util.navigator.to(
          ABAPayScreen(
            url:
                "${ApisString.webServer}/aba_payway/checkout/init?token=$_token",
            db: Globals.databaseName,
            langCode: Globals.langCode,
            appBar: webViewAppbar(),
            onClose: _onCloseWebView,
            amount: invoiceData?.total ?? 0,
            onSuccess: () async {
              // await _onSuccessPayment();
            },
            lastName: Model.userInfo.firstName ?? "",
            firstName: Model.userInfo.lastName ?? "",
            invoiceNo: '${invoiceData?.code ?? ""}',
          ),
          transition: OCSTransitions.UP);
    } else {
      _util.snackBar(message: _res.message, status: SnackBarStatus.danger);
    }
    setState(() {
      _loading = false;
    });
  }

  AppBar webViewAppbar() {
    return AppBar(
      title: Txt(
        "${_util.language.key('invoice-no')} " + "#${invoiceData?.code ?? ""}",
        style: TxtStyle()
          ..fontSize(Style.titleSize)
          ..textColor(Colors.white),
      ),
      backgroundColor: OCSColor.primary,
      // leading: IconButton(
      //   icon: Icon(
      //     Remix.close_line,
      //     size: 24,
      //     color: Colors.white,
      //   ),
      //   tooltip: _util.language.key('back'),
      //   onPressed: () {
      //     _util.navigator.pop();
      //   },
      // ),
    );
  }

  Future _onCloseWebView(String s) async {
    if (s == 'Error') {
      _util.snackBar(
        message: 'Error Occurred!',
        status: SnackBarStatus.danger,
      );
    } else if (s == 'Completed') {
      await _onSuccessPayment();
    } else if (s == 'Pending') {
      await _onSuccessPayment();
    }
  }

  Future _updateDiscount() async {
    if (_discountData != null) _discountRepo.update(_discountData!);
  }

  Future _onSuccessPayment() async {
    _data = _data.copyWith(
        invoiceStatus: "Paid", status: RequestStatus.waitingFeedback);
    // _requestDetail = _requestDetail.copyWith(promoDiscount: _discountData);
    _requestDetail =
        _requestDetail.copyWith(acceptedPartners: [_acceptedPartner]);
    context.read<ServiceRequestBloc>()..add(UpdateServiceRequest(data: _data));
    context.read<RequestServiceDetailBloc>()
      ..add(UpdateRequestDetail(header: _data, detail: _requestDetail));
    setState(() {});

    await Future.delayed(Duration(milliseconds: 500));

    if (!_isShow)
      await modelGiveFeedBack(context,
          onFeedBack: _onFeedback, onSkip: _onSkip);
  }

  Future _onFeedback(double rate, String comment) async {
    _util.navigator.pop();
    setState(() {
      _loading = true;
    });

    var _res = await _repo.feedbackRequest(
      requestId: _data.id ?? 0,
      comment: comment,
      rating: rate,
    );
    if (!_res.error) {
      _onSuccess(_res.data);
    } else {
      // _modelGiveFeedBack();
      _util.snackBar(message: _res.message, status: SnackBarStatus.danger);
    }

    setState(() {
      _loading = false;
    });
  }

  Future _onSkip() async {
    _util.navigator.pop();
    setState(() {
      _loading = true;
    });
    var _res = await _repo.feedbackRequest(
      requestId: _data.id ?? 0,
      comment: "",
      rating: 0,
    );
    if (!_res.error) {
      _onSuccess(_res.data);
    } else {
      _util.snackBar(message: _res.message, status: SnackBarStatus.danger);
    }
    setState(() {
      _loading = false;
    });
  }

  _onSuccess(data) async {
    _util.snackBar(
      message: _util.language.key('success'),
      status: SnackBarStatus.success,
    );

    var json = jsonDecode(data);
    MRequestService header = MRequestService.fromJson(json[0]);
    if (Globals.tabRequestStatusIndex == 0)
      context.read<ServiceRequestBloc>()
        ..add(UpdateServiceRequest(data: header));
    else if (Globals.tabRequestStatusIndex == 6) {
      context
          .read<ServiceRequestBloc>()
          .add(RemoveServiceRequest(data: header));
    }

    context.read<RequestServiceDetailBloc>()
      ..add(UpdateStatusDetail(status: header.status, id: header.id));

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BuildReceiptTable(
          onClose: () {
            _util.navigator.pop();
            _util.navigator.pop();
            _util.navigator.pop();
          },
          promoDiscount: _discountData,
          partner: _acceptedPartner,
          invoice: invoiceData,
        );
      },
    );
    setState(() {});
  }

  void _showDisCode() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          // insetPadding: EdgeInsets.zero,
          child: Parent(
            style: ParentStyle()..maxWidth(Globals.maxScreen),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Txt(
                  _util.language.key('add-promotion-code'),
                  style: TxtStyle()
                    ..width(_util.query.width)
                    ..padding(all: 10)
                    ..borderRadius(topLeft: 5, topRight: 5)
                    ..background.color(OCSColor.background)
                    ..textAlign.center(),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: MyTextField(
                    controller: _codeTxt,
                    label: _util.language.key('code'),
                    placeholder: _util.language.key('enter-code'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => _util.pop(),
                        child: Txt(_util.language.key('cancel'),
                            style: TxtStyle()
                              ..fontSize(14)
                              ..textColor(OCSColor.text)),
                      ),
                      TextButton(
                        onPressed: _getDiscountCode,
                        child: Txt(
                          _util.language.key('apply'),
                          style: TxtStyle()
                            ..fontSize(14)
                            ..textColor(OCSColor.primary),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _discountWidget() {
    if (_discountData != null)
      return Parent(
        style: ParentStyle()..width(_util.query.width),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Txt(
              _util.language.key('discount'),
              style: TxtStyle()..fontSize(14),
            ),
            SizedBox(height: 5),
            Row(
              children: [
                SizedBox(
                  child: Image.asset('assets/images/wallet.png'),
                  height: 40,
                  width: 40,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Txt(
                      "${_discountData?.code ?? ""}",
                      style: TxtStyle()..fontSize(12),
                    ),
                    Txt(
                      "-${OCSUtil.currency(_discountCodeAmount, sign: "\$", autoDecimal: true)}${_discountData?.discountBy == "P" ? "(${OCSUtil.currency(_discountData?.discount ?? 0, autoDecimal: true)}%)" : ""}",
                      style: TxtStyle()
                        ..fontSize(14)
                        ..bold()
                        ..textColor(Colors.green),
                    ),
                  ],
                ),
                Expanded(child: SizedBox()),
                if (_data.status?.toLowerCase() == "closed" &&
                    _data.invoiceStatus?.toLowerCase() != "paid")
                  IconButton(
                    onPressed: () {
                      _discountCodeAmount = 0;
                      setState(() {
                        _discountData = null;
                      });
                    },
                    icon: Icon(Icons.close),
                  )
              ],
            ),
          ],
        ),
      );
    return SizedBox();
  }

  Widget _buildHeader() {
    return Parent(
      style: ParentStyle()
        ..width(_util.query.width)
        ..overflow.hidden()
        ..background.color(Colors.white)
        ..height(300),
      child: Stack(
        children: [
          Parent(
            style: ParentStyle()
              ..width(_util.query.width)
              ..height(200)
              ..elevation(1, opacity: 0.9)
              ..background.color(OCSColor.primary)
              ..alignmentContent.center()
              ..borderRadius(bottomLeft: 5, bottomRight: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Parent(
                  style: ParentStyle()
                    ..height(180)
                    ..padding(horizontal: 20)
                    ..width(_util.query.width),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Parent(
                        style: ParentStyle()
                          ..width(60)
                          ..height(60)
                          ..borderRadius(all: 5)
                          ..overflow.hidden()
                          ..background.color(Colors.white)
                          ..elevation(1, opacity: 0.5),
                        child: MyNetworkImage(
                          iconSize: 20,
                          url: "${_acceptedPartner.image ?? ""}",
                        ),
                      ),
                      SizedBox(width: 10),
                      Parent(
                        style: ParentStyle()
                          ..alignmentContent.center()
                          ..height(180),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Txt(
                              _util.language.by(
                                km: _acceptedPartner.partnerName,
                                en: _acceptedPartner.partnerNameEnglish,
                                autoFill: true,
                              ),
                              style: TxtStyle()
                                ..fontSize(14)
                                ..textColor(Colors.white),
                            ),
                            Txt(
                              _acceptedPartner.partnerPhone ?? "",
                              style: TxtStyle()
                                ..textColor(Colors.white)
                                ..fontSize(12),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 140,
            left: 0,
            child: Parent(
              style: ParentStyle()
                ..width(_util.query.width)
                ..alignmentContent.center(),
              child: Parent(
                style: ParentStyle()
                  ..alignment.center()
                  ..height(150)
                  ..padding(all: 10, top: 15)
                  ..elevation(1, opacity: 0.3)
                  ..borderRadius(all: 5)
                  ..width(_util.query.width - 100)
                  ..background.color(Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Txt(
                          _util.language.key('payment-amount'),
                          style: TxtStyle()
                            ..fontSize(14)
                            ..textColor(OCSColor.text),
                        ),
                        Txt(
                          OCSUtil.currency(invoiceData?.total ?? 0,
                              autoDecimal: true, sign: "\$"),
                          style: TxtStyle()
                            ..fontSize(22)
                            ..bold()
                            ..textColor(Colors.green),
                        )
                      ],
                    ),
                    Expanded(child: SizedBox()),
                    Row(
                      children: [
                        Column(
                          children: [
                            Txt(
                              _util.language.key('date'),
                              style: TxtStyle()
                                ..fontSize(12)
                                ..textColor(OCSColor.text.withOpacity(0.7)),
                            ),
                            if (invoiceData?.createdDate != null)
                              Txt(
                                OCSUtil.dateFormat(
                                    invoiceData?.createdDate ?? "",
                                    format: Format.date),
                                style: TxtStyle()
                                  ..fontSize(12)
                                  ..textColor(OCSColor.text),
                              ),
                          ],
                        ),
                        Expanded(child: SizedBox()),
                        Column(
                          children: [
                            Txt(
                              _util.language.key('invoice-no'),
                              style: TxtStyle()
                                ..fontSize(12)
                                ..textColor(OCSColor.text.withOpacity(0.7)),
                            ),
                            Txt(
                              "#${invoiceData?.code ?? ""}",
                              style: TxtStyle()
                                ..fontSize(12)
                                ..textColor(OCSColor.text),
                            )
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Stack(
      children: [
        Parent(
          style: ParentStyle()
            ..background.color(Colors.transparent)
            ..height(_data.status?.toLowerCase() == "closed" &&
                    _data.invoiceStatus?.toLowerCase() == "paid"
                ? 150
                : (200 + _util.query.bottom) -
                    (_discountData != null ? 20 : 0)),
          child: Parent(
            style: ParentStyle()
              ..padding(all: 15)
              ..boxShadow(
                color: Colors.black.withOpacity(0.10),
                offset: Offset(0, 0),
                blur: 15,
              )
              ..borderRadius(topRight: 15, topLeft: 15)
              ..background.color(Colors.white),
            child: Column(
              children: [
                Expanded(child: SizedBox()),
                Row(
                  children: [
                    Txt(
                      _util.language.key('total-price'),
                      style: TxtStyle()
                        ..fontSize(14)
                        ..textColor(Colors.black87),
                    ),
                    Expanded(child: SizedBox()),
                    Txt(
                      OCSUtil.currency(invoiceData?.amount ?? 0, sign: "\$"),
                      style: TxtStyle()..fontSize(14),
                    )
                  ],
                ),

                // todo : Change next time
                // Row(
                //   children: [
                //     Txt(
                //       _util.language.key('promotion-discount'),
                //       style: TxtStyle()
                //         ..fontSize(14)
                //         ..textColor(Colors.black87),
                //     ),
                //     Expanded(child: SizedBox()),
                //     Txt(
                //       OCSUtil.currency(_subTotal, sign: "\$"),
                //       style: TxtStyle()..fontSize(14),
                //     )
                //   ],
                // ),

                Row(
                  children: [
                    Txt(
                      _util.language.key('discount') +
                          " ${(invoiceData?.discountPercent ?? 0) > 0 ? "(${OCSUtil.currency(invoiceData?.discountPercent ?? 0, autoDecimal: true, sign: "%", rightSign: true)})" : ""}",
                      style: TxtStyle()
                        ..fontSize(14)
                        ..bold()
                        ..textColor(Colors.black87),
                    ),
                    Expanded(child: SizedBox()),
                    Parent(
                      gesture: Gestures()..onTap(() {}),
                      style: ParentStyle()..padding(left: 5),
                      child: Row(
                        children: [
                          Txt(
                            OCSUtil.currency(invoiceData?.discountAmount ?? 0,
                                sign: "\$"),
                            style: TxtStyle()
                              ..fontSize(14)
                              ..bold(),
                          ),
                        ],
                      ),
                    )
                  ],
                ),

                SizedBox(
                  height: 5,
                ),
                Divider(
                  height: 1,
                  color: OCSColor.primary,
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Txt(
                      _util.language.key('grand-total'),
                      style: TxtStyle()
                        ..bold()
                        ..fontSize(16)
                        ..textColor(Colors.black87),
                    ),
                    Expanded(child: SizedBox()),
                    Txt(
                      OCSUtil.currency(
                          (invoiceData?.total ?? 0) - _discountCodeAmount,
                          sign: "\$"),
                      style: TxtStyle()
                        ..fontSize(16)
                        ..bold(),
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                // Expanded(child: SizedBox()),
                if (!_util.query.isKbPopup)
                  if (_data.status?.toLowerCase() == "closed" &&
                      _data.invoiceStatus?.toLowerCase() != "paid")
                    BuildButton(
                      title: _util.language.key('pay-now'),
                      onPress: _initLoading ? null : _toPaymentScreen,
                      height: 40,
                      fontSize: 16,
                    ),
                SizedBox(
                  height: _util.query.bottom <= 0 ? 0 : _util.query.bottom,
                ),
              ],
            ),
          ),
        ),
        if (_loading || _initLoading)
          Positioned(
            child: Container(
              height: _data.status?.toLowerCase() == "closed" &&
                      _data.invoiceStatus?.toLowerCase() == "paid"
                  ? 150
                  : 200 + _util.query.bottom - (_discountData != null ? 20 : 0),
              color: Colors.black.withOpacity(.3),
              child: const Center(),
            ),
          )
      ],
    );
  }
}
