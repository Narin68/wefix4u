import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '/screens/service_request_widget.dart';
import '/blocs/service_request/service_request_bloc.dart';
import '/globals.dart';
import '/modals/customer_request_service.dart';
import '/repositories/customer_request_service.dart';
import '/modals/quotation.dart';
import '../widget.dart';
import 'package:intl/intl.dart';

class PreviewQuot extends StatefulWidget {
  final List<MItemQuotation>? items;
  final MSubmitQuotData? quotation;
  final bool isReview;

  final double? total;
  final double? subtotal;
  final MRequestService? data;
  final MServiceRequestDetail? detail;

  const PreviewQuot({
    Key? key,
    this.items,
    this.quotation,
    this.total,
    this.data,
    this.detail,
    this.isReview = true,
    this.subtotal,
  }) : super(key: key);

  @override
  State<PreviewQuot> createState() => _PreviewQuotState();
}

class _PreviewQuotState extends State<PreviewQuot> {
  late final _util = OCSUtil.of(context);
  double _fontSize = Style.subTextSize;
  List<MItemQuotation> _items = [];
  bool _loading = false;
  ServiceRequestRepo _repo = ServiceRequestRepo();
  TextEditingController _txtDesc = TextEditingController(),
      _depositAmountTxt = TextEditingController(),
      _depositPerTxt = TextEditingController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  MSubmitQuotData? _submitQuotData;
  MQuotationData? _quotData;
  MRequestService? _header;
  bool _requireDeposit = false;
  var _formKey = GlobalKey<FormState>();
  bool _isDepositPer = false;

  @override
  void initState() {
    super.initState();
    _items = (_items) + (widget.items ?? []);
    _submitQuotData = widget.quotation;
    _header = widget.data;
    _init();
  }

  void _init() {
    _quotData = MQuotationData(
        id: _submitQuotData?.id,
        code: _submitQuotData?.code,
        requestId: _header?.id ?? 0,
        discountAmount: _submitQuotData?.discountAmount,
        discountPercent: _submitQuotData?.discountPercent,
        description: _submitQuotData?.description,
        items: _submitQuotData?.items,
        total: widget.total,
        vatAmount: _submitQuotData?.vatAmount,
        amount: widget.subtotal,
        balance: (_submitQuotData?.total ?? 0) -
            (_submitQuotData?.depositAmount ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_loading) _util.navigator.pop();
        return false;
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: OCSColor.primary,
          leading: NavigatorBackButton(loading: _loading),
          title: Txt(
            _util.language.key('quotation-template'),
            style: TxtStyle()
              ..fontSize(Style.titleSize)
              ..textColor(Colors.white),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: Parent(
            style: ParentStyle()..height(_util.query.height),
            child: Stack(
              children: [
                CustomScrollView(
                  shrinkWrap: true,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Parent(
                        style: ParentStyle()
                          ..padding(all: 15)
                          ..minHeight(_util.query.height),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Txt(
                              _util.language.key('quotation'),
                              style: TxtStyle()
                                ..fontSize(Style.titleSize)
                                ..fontWeight(FontWeight.bold)
                                ..width(_util.query.width)
                                ..textAlign.center()
                                ..textColor(OCSColor.text),
                            ),
                            SizedBox(height: 15),
                            _quotation(),
                            SizedBox(height: 10),
                            if (_submitQuotData != null)
                              buildQuotTable(
                                quotation: _quotData ?? MQuotationData(),
                                context: context,
                              ),
                            SizedBox(height: 80),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                if (widget.isReview == false && !_util.query.isKbPopup)
                  Positioned(
                    bottom: _util.query.bottom <= 0 ? 15 : _util.query.bottom,
                    child: Parent(
                      style: ParentStyle()
                        ..alignment.center()
                        ..padding(
                          horizontal: 15,
                        )
                        ..width(_util.query.width),
                      child: BuildButton(
                        title: _util.language.key('submit'),
                        fontSize: Style.titleSize,
                        onPress: _confirmDialog,
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
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDialog() {
    _requireDeposit = false;
    _depositAmountTxt.clear();
    _depositPerTxt.clear();
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Parent(
                style: ParentStyle()
                  ..borderRadius(all: 5)
                  ..maxWidth(Globals.maxScreen - 150)
                  ..background.color(Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Txt(
                      _util.language.key('confirmation-submit-quot'),
                      style: TxtStyle()
                        ..padding(all: 15, vertical: 10)
                        ..borderRadius(topRight: 5, topLeft: 5)
                        ..background.color(OCSColor.background)
                        ..width(_util.query.width)
                        ..fontSize(Style.subTitleSize)
                        ..textColor(OCSColor.text),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Parent(
                            style: ParentStyle()
                              ..alignment.center()
                              ..background.color(Colors.white)
                              ..borderRadius(all: 5)
                              ..width(_util.query.width)
                              ..padding(all: 10)
                              ..boxShadow(
                                color: Colors.black12,
                                blur: 2,
                                offset: Offset(0, 1),
                              ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Txt(
                                  _util.language.key('total-amount'),
                                  style: TxtStyle()
                                    ..textColor(OCSColor.text.withOpacity(0.7))
                                    ..fontSize(Style.subTitleSize),
                                ),
                                Txt(
                                  OCSUtil.currency(_quotData?.total ?? 0,
                                      sign: "\$", autoDecimal: false),
                                  style: TxtStyle()
                                    ..fontSize(27)
                                    ..textColor(OCSColor.primary),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 15),
                          Parent(
                            style: ParentStyle()
                              ..width(_util.query.width)
                              ..borderRadius(all: 5),
                            child: Row(
                              children: [
                                SizedBox(
                                  child: Checkbox(
                                    value: _requireDeposit,
                                    onChanged: (v) {
                                      _depositAmountTxt.clear();
                                      _depositPerTxt.clear();
                                      _requireDeposit = v ?? false;
                                      setState(() {});
                                    },
                                  ),
                                  width: 25,
                                  height: 25,
                                ),
                                SizedBox(width: 5),
                                Txt(
                                  _util.language.key('require-deposit'),
                                  style: TxtStyle()..fontSize(14),
                                  gesture: Gestures()
                                    ..onTap(() {
                                      _requireDeposit = !_requireDeposit;
                                      setState(() {});
                                    }),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          if (_requireDeposit)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: MyTextField(
                                    textInputType:
                                        TextInputType.numberWithOptions(
                                            signed: false, decimal: false),
                                    autoValidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    controller: _depositPerTxt,
                                    label:
                                        _util.language.key('deposit') + "(%)",
                                    placeholder:
                                        _util.language.key('enter-deposit'),
                                    onChanged: (v) {
                                      if (v != "") {
                                        _isDepositPer = true;
                                        _depositAmountTxt.text =
                                            OCSUtil.currency(
                                                (_quotData?.total ?? 0) *
                                                    double.parse(v ?? "0") /
                                                    100,
                                                autoDecimal: true);
                                      } else {
                                        _isDepositPer = false;
                                        _depositAmountTxt.text = "";
                                      }
                                      setState(() {});
                                    },
                                  ),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: MyTextField(
                                    textInputType:
                                        TextInputType.numberWithOptions(
                                            signed: false, decimal: false),
                                    autoValidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    controller: _depositAmountTxt,
                                    label:
                                        _util.language.key('deposit') + "(\$)",
                                    placeholder:
                                        _util.language.key('enter-deposit'),
                                    validator: (v) {
                                      if (v?.isEmpty ?? false)
                                        return _util.language.key('required');
                                      return null;
                                    },
                                    onChanged: (v) {
                                      _isDepositPer = false;
                                      if (v != "") {
                                        _depositPerTxt.text = OCSUtil.currency(
                                            ((double.parse(v ?? "0")
                                                        .toDouble() *
                                                    100) /
                                                (_quotData?.total ?? 0)),
                                            autoDecimal: true);
                                      } else {
                                        _depositPerTxt.text = "";
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          MyTextArea(
                            labelSize: 12,
                            controller: _txtDesc,
                            label: _util.language.key('description'),
                            placeHolder:
                                _util.language.key('enter-description'),
                          ),
                          SizedBox(height: 20),
                          BuildButton(
                            title: _util.language.key('submit'),
                            onPress: _submitQuot,
                            // width: 100,
                            height: 40,
                            fontSize: Style.subTitleSize,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _onSuccess(String data) async {
    var json = jsonDecode(data);
    if (json.isNotEmpty) {
      MRequestService header = MRequestService.fromJson(json[0]);
      context.read<ServiceRequestBloc>()
        ..add(UpdateServiceRequest(data: header));
    }
  }

  Future _submitQuot() async {
    if (!_formKey.currentState!.validate()) return;
    _util.navigator.pop();
    setState(() {
      _loading = true;
    });
    double amount = 0;
    double depositAmount =
        _requireDeposit ? double.parse(_depositAmountTxt.text) : 0;
    double depositPer = _isDepositPer ? double.parse(_depositPerTxt.text) : 0;

    for (var i = 0; i < _items.length; i++) {
      amount += _items[i].total ?? 0;
      if ((_items[i].id ?? 0) > 0) {
        _items[i] = _items[i].copyWith(
            selected: false,
            discountPer:
                (_items[i].isDisPercent ?? false) ? _items[i].discountPer : 0);
      }
    }

    var model = MSubmitQuotData(
      items: _items,
      amount: amount,
      total: amount - (_submitQuotData?.discountAmount ?? 0),
      requestId: _header?.id ?? 0,
      customerId: _header?.customerId,
      partnerId: Model.partner.id,
      description: _txtDesc.text.trim(),
      discountAmount: _submitQuotData?.discountAmount,
      discountPercent: (_submitQuotData?.isDisPercent ?? false)
          ? _submitQuotData?.discountPercent
          : 0,
      balance:
          (amount - (_submitQuotData?.discountAmount ?? 0)) - (depositAmount),
      requireDeposit: _requireDeposit,
      depositAmount: depositAmount,
      depositPercent: depositPer,
    );

    print(jsonEncode(model.toJson()));

    var _res = await _repo.SubmitQuot(model);
    if (!_res.error) {
      _util.navigator.pop();
      _util.navigator.pop();
      _onSuccess(_res.data);
      _util.navigator.replace(BuildSuccessScreen(
        successTitle: _util.language.key('your-quotation-has-been-submitted'),
      ));
    } else {
      _util.snackBar(message: _res.message, status: SnackBarStatus.danger);
    }
    setState(() {
      _loading = false;
    });
  }

  Widget _quotation() {
    String date = DateFormat("dd-MMMM-yyyy")
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
            ..textColor(OCSColor.text),
        ),
        Txt(
          "$phone",
          style: TxtStyle()
            ..fontSize(_fontSize)
            ..textColor(OCSColor.text),
        ),
        if (widget.detail?.customerEmail?.isNotEmpty ?? false)
          Txt(
            "${widget.detail?.customerEmail ?? ""}",
            style: TxtStyle()
              ..fontSize(_fontSize)
              ..textColor(OCSColor.text),
          ),
        Parent(
          style: ParentStyle(),
          child: Txt(
            "${_header?.targetLocation}",
            style: TxtStyle()
              ..fontSize(_fontSize)
              ..textColor(OCSColor.text),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Parent(
          style: ParentStyle(),
          child: Row(
            children: [
              Txt(
                "${_util.language.key('date')} : ",
                style: TxtStyle()
                  ..fontSize(_fontSize)
                  ..textColor(OCSColor.text),
              ),
              SizedBox(width: 20),
              Txt(
                '${date}',
                style: TxtStyle()
                  ..fontSize(_fontSize)
                  ..textColor(OCSColor.text),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
