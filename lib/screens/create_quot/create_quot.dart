import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import '../partner_service_request/submit_quot.dart';
import '/repositories/quotation_repo.dart';
import '/modals/customer_request_service.dart';
import '/globals.dart';
import '/modals/partner_item.dart';
import '/repositories/partner_item_repo.dart';
import '/modals/quotation.dart';
import '/screens/widget.dart';
import 'add_quot_item.dart';

class CreateQuotation extends StatefulWidget {
  final Function(MSubmitQuotData)? onSuccess;
  final MSubmitQuotData? quot;
  final bool? isUpdate;
  final MRequestService? data;
  final MServiceRequestDetail? detail;

  const CreateQuotation({
    Key? key,
    this.onSuccess,
    this.quot,
    this.isUpdate,
    this.data,
    this.detail,
  }) : super(key: key);

  @override
  State<CreateQuotation> createState() => _CreateQuotationState();
}

class _CreateQuotationState extends State<CreateQuotation> {
  late var _util = OCSUtil.of(context);
  List<MItemQuotation> _items = [];
  List<MPartnerServiceItemData> _products = [];
  PartnerItemRepo _repo = PartnerItemRepo();
  double _totalPrice = 0;
  double _totalDis = 0;
  double _grandTotal = 0;
  bool _isUpdateQuot = false;
  bool isDisPercent = false;
  TextEditingController _disAmountTxt = TextEditingController();
  TextEditingController _disPerTxt = TextEditingController();
  double _totalAfterItemDis = 0;
  MSubmitQuotData? _submitQuotData;
  bool _loading = false;
  QuotRepo _quotRepo = QuotRepo();
  var _txtDesc = TextEditingController();
  MRequestService? _header;

  @override
  void initState() {
    super.initState();
    _isUpdateQuot = widget.isUpdate ?? false;
    _items = _items + (widget.quot?.items ?? []);
    _submitQuotData = widget.quot;
    _txtDesc.text = _submitQuotData?.description ?? "";
    _header = widget.data;
    _calPrice();
    _init();
  }

  void _init() async {
    var _res = await _repo.list(record: 1000);
    if (!_res.error) {
      _products = _res.data;
    }
  }

  void _calPrice() {
    _totalPrice = 0;
    _totalDis = 0;
    _totalDis = 0;
    _items.forEach((e) {
      _totalPrice += e.total ?? 0;
    });
    _grandTotal = _totalPrice - _totalDis + (_submitQuotData?.vatAmount ?? 0);
    _totalAfterItemDis = _grandTotal;
    _totalDis = (_submitQuotData?.discountAmount ?? 0);
    _grandTotal -= (_submitQuotData?.discountAmount ?? 0);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        onBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Txt(
            _util.language
                .key(_isUpdateQuot ? 'update-quotation' : 'create-quotation'),
            style: TxtStyle()
              ..fontSize(16)
              ..textColor(Colors.white),
          ),
        ),
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Parent(
                    style: ParentStyle()..padding(all: 15),
                    child: Column(
                      crossAxisAlignment: _items.isNotEmpty
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.center,
                      children: [
                        if (_items.isNotEmpty) ...[
                          _buildTableItems(),
                        ],
                        if (_items.isEmpty) ...[
                          Parent(
                            style: ParentStyle()
                              ..height(_util.query.height / 2.5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Image.asset(
                                  'assets/images/no-item.png',
                                  width: 80,
                                ),
                                SizedBox(height: 10),
                                Txt(
                                  _util.language.key('no-item'),
                                  style: TxtStyle()
                                    ..fontSize(Style.titleSize)
                                    ..textColor(OCSColor.text),
                                ),
                              ],
                            ),
                          ),
                        ],
                        SizedBox(height: 215),
                      ],
                    ),
                  ),
                )
              ],
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
        bottomSheet: _util.query.isKbPopup ? SizedBox() : _buildBottomSheet(),
        floatingActionButton: FloatingActionButton(
          onPressed: _buildAddItem,
          child: Icon(Icons.add),
          tooltip: _util.language.key('add-item'),
        ),
      ),
    );
  }

  void onBack() {
    if (!_loading) {
      _submitQuotData = _submitQuotData?.copyWith(items: []);
      _submitQuotData?.items!.addAll(_items);
      Model.quotationDetail = _submitQuotData;
      _util.navigator.pop();
    }
  }

  Future _updateQuot() async {
    if (_items.isEmpty) {
      _util.snackBar(
        message: _util.language.key('no-item'),
        status: SnackBarStatus.warning,
      );
      return;
    }
    _util.navigator.pop();
    setState(() {
      _loading = true;
    });
    double amount = 0;
    for (var i = 0; i < _items.length; i++) {
      amount += _items[i].total ?? 0;
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
    );

    var _res = await _quotRepo.updateQuot(model);
    if (!_res.error) {
      _util.snackBar(
        message: _util.language.key("success"),
        status: SnackBarStatus.success,
      );
      widget.onSuccess!(_res.data);
    } else {
      _util.snackBar(message: _res.message, status: SnackBarStatus.danger);
    }
    setState(() {
      _loading = false;
    });
  }

  void _confirmDialog() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(0),
        child: SingleChildScrollView(
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
                              OCSUtil.currency(_grandTotal,
                                  sign: "\$", autoDecimal: false),
                              style: TxtStyle()
                                ..fontSize(27)
                                ..textColor(OCSColor.primary),
                            ),
                          ],
                        ),
                      ),
                      MyTextArea(
                        controller: _txtDesc,
                        placeHolder: _util.language.key('enter-description'),
                        label: _util.language.key('description'),
                      ),
                      SizedBox(height: 20),
                      BuildButton(
                        title: _util.language.key('submit'),
                        onPress: _updateQuot,
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
    );
  }

  void _onPressAddItem({
    bool isUpdate = false,
    int index = 0,
    MItemQuotation? data,
  }) {
    if (!isUpdate) {
      for (var i = 0; i < _items.length; i++) {
        if ((_items[i].id ?? 0) > 0 && _items[i].id == data?.id) {
          _items.removeAt(i);
        }
      }
      _items.add(data!);
    } else {
      _items[index] = data!;
    }
    _calPrice();
    setState(() {});
  }

  void _buildAddItem(
      {bool isUpdate = false, MItemQuotation? data, int index = 0}) {
    showDialog(
      context: context,
      builder: (_) {
        return AddUpdateItemQuot(
            isUpdateQuot: _isUpdateQuot,
            data: data,
            isUpdate: isUpdate,
            products: _products,
            onSubmit: (data) {
              _onPressAddItem(isUpdate: isUpdate, data: data, index: index);
            });
      },
    );
  }

  Widget _buildBottomSheet() {
    return Stack(
      children: [
        Parent(
          style: ParentStyle()
            ..background.color(Colors.transparent)
            ..height(205 + _util.query.bottom),
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
                      OCSUtil.currency(_totalPrice, sign: "\$"),
                      style: TxtStyle()..fontSize(14),
                    )
                  ],
                ),
                Row(
                  children: [
                    Txt(
                      _util.language.key('discount') +
                          " ${(_submitQuotData?.discountPercent ?? 0) > 0 ? "(${OCSUtil.currency(_submitQuotData?.discountPercent ?? 0, autoDecimal: true, sign: "%", rightSign: true)})" : ""}",
                      style: TxtStyle()
                        ..fontSize(14)
                        ..bold()
                        ..textColor(Colors.black87),
                    ),
                    Expanded(child: SizedBox()),
                    Parent(
                      gesture: Gestures()
                        ..onTap(() {
                          if (_items.isEmpty) return;
                          showDialog(
                              context: context,
                              builder: (_) {
                                return _buildDisDialog();
                              });
                        }),
                      style: ParentStyle()
                        ..ripple(_items.isNotEmpty)
                        ..padding(left: 5),
                      child: Row(
                        children: [
                          Icon(Icons.edit_note),
                          SizedBox(width: 5),
                          Txt(
                            OCSUtil.currency(_totalDis, sign: "\$"),
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
                  height: 10,
                ),
                Divider(
                  height: 1,
                  color: OCSColor.primary,
                ),
                SizedBox(
                  height: 10,
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
                      OCSUtil.currency(_grandTotal, sign: "\$"),
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
                BuildButton(
                  ripple: _items.isNotEmpty,
                  title: _util.language
                      .key(widget.isUpdate ?? false ? 'save' : 'next'),
                  onPress: _loading
                      ? null
                      : _items.isEmpty
                          ? null
                          : () {
                              _submitQuotData =
                                  _submitQuotData?.copyWith(items: _items);
                              if (!_isUpdateQuot) {
                                _onNextConfirm();
                              } else {
                                _confirmDialog();
                              }
                            },
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
        if (_loading)
          Positioned(
            child: Container(
              height: 200,
              color: Colors.black.withOpacity(.3),
              child: const Center(),
            ),
          )
      ],
    );
  }

  void _onNextConfirm() {
    if (_items.isEmpty || _items[0].name == '') {
      _util.snackBar(
          message: _util.language.key('no-item'),
          status: SnackBarStatus.warning);
      return;
    }
    _util.navigator.to(
      PreviewQuot(
        items: _items,
        subtotal: _totalPrice,
        quotation: _submitQuotData,
        total: _grandTotal,
        data: _header,
        detail: widget.detail,
        isReview: false,
      ),
      transition: OCSTransitions.LEFT,
    );
  }

  Widget _buildTableItems() {
    return Parent(
      style: ParentStyle()
        ..background.color(Colors.white)
        ..overflow.hidden()
        ..margin(bottom: 60)
        ..borderRadius(all: 5)
        ..elevation(1, opacity: 0.2),
      child: Column(
        children: [
          Parent(
            style: ParentStyle()
              ..background.color(OCSColor.background)
              ..padding(all: 10, horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Txt(
                    '${_util.language.key('item')}',
                    style: TxtStyle()
                      ..textColor(OCSColor.black)
                      ..fontWeight(FontWeight.normal)
                      ..fontSize(Style.subTextSize),
                  ),
                ),
                Expanded(child: SizedBox()),
                Expanded(
                  flex: 2,
                  child: Txt(
                    _util.language.key('discount'),
                    style: TxtStyle()
                      ..textColor(OCSColor.black)
                      ..fontWeight(FontWeight.normal)
                      ..fontSize(Style.subTextSize)
                      ..alignmentContent.centerRight()
                      ..textAlign.right(),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  flex: 2,
                  child: Txt(
                    _util.language.key('amount'),
                    style: TxtStyle()
                      ..textColor(OCSColor.black)
                      ..fontWeight(FontWeight.normal)
                      ..fontSize(Style.subTextSize)
                      ..width(70)
                      ..alignmentContent.centerRight()
                      ..textAlign.right(),
                  ),
                ),
                Expanded(child: SizedBox(width: 30)),
              ],
            ),
          ),
          ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            shrinkWrap: true,
            itemCount: _items.length,
            primary: false,
            itemBuilder: (_, i) {
              return Parent(
                style: ParentStyle()
                  ..padding(vertical: 5)
                  ..background.color(Colors.white)
                  ..border(
                    bottom: i != _items.length - 1 ? 0.3 : 0,
                    color: i != _items.length - 1
                        ? OCSColor.border
                        : Colors.transparent,
                  ),
                gesture: Gestures()
                  ..onTap(() {
                    _buildAddItem(
                      isUpdate: true,
                      index: i,
                      data: _items[i],
                    );
                  }),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Txt(
                                _util.language.by(
                                  km: _items[i].name,
                                  en: _items[i].nameEnglish,
                                  autoFill: true,
                                ),
                                style: TxtStyle()
                                  ..fontSize(Style.subTextSize)
                                  ..textColor(OCSColor.text)
                                  ..textOverflow(TextOverflow.ellipsis)
                                  ..maxLines(2)
                                  ..width(_util.query.width / 2),
                              ),
                              Txt(
                                "${OCSUtil.currency(
                                      (_items[i].cost ?? 0) /
                                          (_items[i].qty ?? 0),
                                      autoDecimal: true,
                                      sign: '\$',
                                    )}" +
                                    " × " +
                                    OCSUtil.currency((_items[i].qty ?? 0),
                                        decimal: 0, sign: '') +
                                    " ${_items[i].unitType ?? ""}",
                                style: TxtStyle()
                                  ..fontSize(Style.subTextSize)
                                  ..textColor(OCSColor.text.withOpacity(0.7)),
                              ),
                            ],
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
                          flex: 4,
                        ),
                        // Expanded(child: SizedBox()),
                        Expanded(
                          child: Txt(
                            (_items[i].discountAmount ?? 0) <= 0
                                ? ""
                                : OCSUtil.currency(
                                    _items[i].discountAmount ?? 0,
                                    autoDecimal: true,
                                    sign: '\$',
                                  ),
                            style: TxtStyle()
                              ..width(70)
                              ..fontSize(Style.subTextSize)
                              ..textColor(OCSColor.text)
                              ..alignmentContent.centerRight()
                              ..textAlign.right(),
                          ),
                          flex: 2,
                        ),
                        // SizedBox(width: 15),
                        Expanded(
                          child: Txt(
                            OCSUtil.currency(
                                (_items[i].cost ?? 0) -
                                    (_items[i].discountAmount ?? 0),
                                autoDecimal: false,
                                sign: '\$'),
                            style: TxtStyle()
                              ..fontSize(Style.subTextSize)
                              ..textColor(OCSColor.text)
                              ..width(70)
                              ..textAlign.right()
                              ..alignment.centerRight(),
                          ),
                          flex: 2,
                        ),
                        SizedBox(width: 15),
                        Parent(
                          child: Icon(
                            Icons.delete,
                            size: 16,
                            color: Colors.red,
                          ),
                          style: ParentStyle()
                            ..width(20)
                            ..borderRadius(all: 50)
                            ..height(20)
                            ..ripple(true),
                          gesture: Gestures()
                            ..onTap(() {
                              showDialog(
                                  context: context,
                                  builder: (_) {
                                    return AlertDialog(
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 25),
                                      title: Text(
                                        _util.language.key('remove-item'),
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      content: Text(
                                        _util.language
                                            .key('do-you-want-to-remove-item'),
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            _util.pop();
                                          },
                                          child: Text(
                                            _util.language.key('no'),
                                            style: TextStyle(
                                                color: OCSColor.text
                                                    .withOpacity(0.6)),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _items.removeAt(i);
                                            _calPrice();
                                            _util.pop();

                                            setState(() {});
                                          },
                                          child: Text(
                                            _util.language.key('yes'),
                                          ),
                                        )
                                      ],
                                    );
                                  });
                            }),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDisDialog() {
    var disPercent = _submitQuotData?.isDisPercent;
    _disAmountTxt.text = _submitQuotData?.discountAmount != null &&
            (_submitQuotData?.discountAmount ?? 0) > 0
        ? OCSUtil.currency((_submitQuotData?.discountAmount ?? 0),
            autoDecimal: true)
        : "";
    _disPerTxt.text = _submitQuotData?.discountPercent != null &&
            (_submitQuotData?.discountPercent ?? 0) > 0
        ? OCSUtil.currency(
            ((double.parse(_disAmountTxt.text.isEmpty
                            ? "0"
                            : _disAmountTxt.text)
                        .toDouble() *
                    100) /
                (_totalAfterItemDis)),
            autoDecimal: true,
          )
        : "";
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Parent(
            style: ParentStyle()
              ..borderRadius(topLeft: 5, topRight: 5)
              ..padding(all: 10)
              ..alignmentContent.center()
              ..background.color(OCSColor.background),
            child: Txt(_util.language.key("extra-dis")),
          ),
          Parent(
            style: ParentStyle()..padding(all: 15),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyTextField(
                    placeholder: "0",
                    controller: _disPerTxt,
                    label: _util.language.key('discount-per'),
                    textInputType: TextInputType.number,
                    onChanged: (v) {
                      if (v != "") {
                        disPercent = true;
                        _disAmountTxt.text = OCSUtil.currency(
                            ((_totalAfterItemDis) *
                                double.parse(v!.isEmpty ? "0" : v) /
                                100),
                            autoDecimal: true);
                      } else {
                        disPercent = false;
                        _disAmountTxt.text = "";
                      }
                      setState(() {});
                    },
                  ),
                  MyTextField(
                    placeholder: "0",
                    controller: _disAmountTxt,
                    label: _util.language.key('discount-amount'),
                    textInputType: TextInputType.number,
                    onChanged: (v) {
                      if (v != "") {
                        disPercent = false;
                        _disPerTxt.text = OCSUtil.currency(
                          ((double.parse(v!.isEmpty ? "0" : v).toDouble() *
                                  100) /
                              (_totalAfterItemDis)),
                          autoDecimal: true,
                        );
                      } else {
                        disPercent = false;
                        _disPerTxt.text = "";
                      }
                      setState(() {});
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                        child: Text(
                          _util.language.key('close'),
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (_disAmountTxt.text.isEmpty) {
                            Navigator.pop(context);
                            _submitQuotData = _submitQuotData?.copyWith(
                              discountPercent: 0,
                              discountAmount: 0,
                              isDisPercent: false,
                            );
                            _calPrice();
                            return;
                          }
                          _submitQuotData = _submitQuotData?.copyWith(
                            discountPercent: _disPerTxt.text.isEmpty
                                ? 0
                                : double.parse(_disPerTxt.text),
                            discountAmount: _disAmountTxt.text.isEmpty
                                ? 0
                                : double.parse(_disAmountTxt.text),
                            isDisPercent: disPercent,
                          );
                          _disAmountTxt.clear();
                          _disPerTxt.clear();
                          _calPrice();
                          Navigator.pop(context);
                          setState(() {});
                        },
                        child: Text(_util.language.key('ok')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // actions: [
      //
      // ],
    );
  }
}
