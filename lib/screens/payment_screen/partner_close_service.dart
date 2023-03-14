import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:wefix4utoday/modals/quotation.dart';
import '../view_quote.dart';
import '/blocs/request_service_detail/request_service_detail_bloc.dart';
import '/blocs/service_request/service_request_bloc.dart';
import '/globals.dart';
import '/modals/partner.dart';
import '/repositories/customer_request_service.dart';
import '/modals/customer_request_service.dart';
import '/screens/widget.dart';

class PartnerCloseService extends StatefulWidget {
  final MRequestService? data;
  final MServiceRequestDetail? detail;

  const PartnerCloseService({Key? key, this.data, this.detail})
      : super(key: key);

  @override
  State<PartnerCloseService> createState() => _PartnerCloseServiceState();
}

class _PartnerCloseServiceState extends State<PartnerCloseService> {
  late var _util = OCSUtil.of(context);
  MRequestService _data = MRequestService();
  bool _loading = false;
  ServiceRequestRepo _repo = ServiceRequestRepo();
  String _userName = '';
  MAcceptedPartner _acceptedPartner = MAcceptedPartner();
  String _date = '';
  var txtTitleStyle = TxtStyle()
    ..fontSize(13)
    ..textColor(
      OCSColor.text.withOpacity(0.8),
    )
    ..width(80)
    ..textColor(OCSColor.text);
  var subtitleStyle = TxtStyle()
    ..fontSize(13)
    ..textColor(OCSColor.text.withOpacity(0.8));
  MQuotationData? _quoteData;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    _data = widget.data!;
    String phone = _data.customerPhone ?? "";
    if ((_data.customerPhone ?? "").contains('+855')) {
      phone = phone.replaceAll('+855', '0');
      _data = _data.copyWith(customerPhone: phone);
    }
    _userName = _data.customerName ?? "";
    if (_userName.contains('.')) _userName = _userName.replaceFirst('.', '');
    _date = OCSUtil.dateFormat(DateTime.now(),
        format: Format.date, langCode: Globals.langCode);
    widget.detail?.acceptedPartners?.forEach((e) {
      if (e.partnerId == Model.partner.id) {
        _acceptedPartner = e;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_loading) _util.navigator.pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: OCSColor.primary,
          toolbarHeight: 0,
          elevation: 0,
          shadowColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    title: Txt(
                      _util.language.key('close-service'),
                      style: TxtStyle()
                        ..fontSize(16)
                        ..textColor(Colors.white),
                    ),
                    leading: NavigatorBackButton(loading: _loading),
                    centerTitle: true,
                    pinned: true,
                    elevation: 1,
                    shadowColor: Colors.black,
                    expandedHeight: 150,
                    backgroundColor: OCSColor.primary,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Parent(
                        style: ParentStyle()
                          ..height(141)
                          ..background.color(Colors.white)
                          ..width(_util.query.width)
                          ..padding(bottom: 10),
                        child: Parent(
                          style: ParentStyle()
                            ..width(_util.query.width)
                            ..overflow.hidden()
                            ..elevation(1, opacity: 0.9)
                            ..background.color(OCSColor.primary)
                            ..borderRadius(bottomLeft: 5, bottomRight: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Parent(
                                style: ParentStyle()
                                  ..height(140)
                                  ..padding(horizontal: 20, top: 20)
                                  ..width(_util.query.width),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Parent(
                                      style: ParentStyle()
                                        ..width(60)
                                        ..height(60)
                                        ..borderRadius(all: 50)
                                        ..overflow.hidden()
                                        ..background.color(Colors.white)
                                        ..elevation(1, opacity: 0.5),
                                      child: MyNetworkImage(
                                        url: _data.customerImage ?? '',
                                        defaultAssetImage:
                                            Globals.userAvatarImage,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Parent(
                                      style: ParentStyle()
                                        ..alignmentContent.center(),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Txt(
                                            "${_userName}",
                                            style: TxtStyle()
                                              ..fontSize(14)
                                              ..textColor(Colors.white),
                                          ),
                                          Txt(
                                            _data.customerPhone ?? "",
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
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Parent(
                      style: ParentStyle()
                        ..padding(all: 15)
                        // ..margin(top: 10)
                        ..background.color(Colors.white),
                      child: Column(
                        children: [
                          BuildQuoteTable(
                            quotId: _acceptedPartner.quotationId ?? 0,
                            header: _headerInvoice(),
                            quoteData: (quote) {
                              _quoteData = quote;
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              if (_quoteData?.items?.isNotEmpty ?? false)
                Positioned(
                  bottom: _util.query.bottom <= 0 ? 15 : _util.query.bottom,
                  child: Parent(
                    style: ParentStyle()
                      ..width(_util.query.width)
                      ..alignmentContent.center(),
                    child: BuildButton(
                      width: _util.query.width - 30,
                      title: _util.language.key('submit-invoice'),
                      fontSize: 15,
                      onPress: () {
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => _confirmClose(),
                        );
                      },
                    ),
                  ),
                ),
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
          ),
        ),
      ),
    );
  }

  Widget _headerInvoice() {
    return Parent(
      style: ParentStyle()
        ..width(_util.query.width)
        ..alignmentContent.center(),
      child: Parent(
        style: ParentStyle()
          ..alignment.center()
          ..height(80)
          ..margin(bottom: 10)
          ..width(_util.query.width)
          ..background.color(Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Txt(
                  _util.language.key('invoice'),
                  style: TxtStyle()
                    ..fontSize(Style.titleSize)
                    ..fontWeight(FontWeight.bold)
                    ..textColor(OCSColor.text),
                ),
              ],
            ),
            Expanded(child: SizedBox()),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Txt(
                  _util.language.key('date') + " : ${_date}",
                  style: TxtStyle()
                    ..fontSize(12)
                    ..textColor(OCSColor.text.withOpacity(0.7)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _confirmClose() {
    return AlertDialog(
      contentPadding: EdgeInsets.only(left: 25, top: 15, bottom: 10, right: 15),
      title: Txt(
        _util.language.key('confirm-close-service'),
        style: TxtStyle()
          ..fontSize(16)
          ..textColor(OCSColor.text),
      ),
      content: Txt(
        _util.language.key('do-you-want-to-close-this-service'),
        style: TxtStyle()
          ..fontSize(14)
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
          onPressed: _onCloseService,
          child: Txt(
            _util.language.key('yes'),
          ),
        ),
      ],
    );
  }

  Future _onCloseService() async {
    _util.navigator.pop();
    setState(() {
      _loading = true;
    });
    var _res = await _repo.closeService(_data.id ?? 0);
    if (_res.error) {
      _util.snackBar(message: _res.message, status: SnackBarStatus.danger);
    } else {
      setState(() {
        _loading = false;
      });
      _util.navigator.pop();
      _util.navigator.pop();
      onSuccess(_res.data);
      _util.navigator.to(BuildSuccessScreen(
        successTitle: _util.language.key('you-success-close-service'),
      ));
    }
    setState(() {
      _loading = false;
    });
  }

  Future onSuccess(String data) async {
    var json = jsonDecode(data);
    MRequestService header = MRequestService.fromJson(json[0]);
    context.read<ServiceRequestBloc>()..add(UpdateServiceRequest(data: header));
  }
}
