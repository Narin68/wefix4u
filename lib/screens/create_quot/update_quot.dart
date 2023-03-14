import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:ocs_util/ocs_util.dart';
import '/blocs/request_service_detail/request_service_detail_bloc.dart';
import '/modals/requestUpdateQuot.dart';
import '/repositories/request_update_invoice.dart';
import '/modals/customer_request_service.dart';
import '/globals.dart';
import '/modals/partner_item.dart';
import '/repositories/partner_item_repo.dart';
import '/modals/quotation.dart';
import '/screens/widget.dart';

class UpdateQuotation extends StatefulWidget {
  final Function(MSubmitQuotData)? onSuccess;
  final MSubmitQuotData? quot;
  final MRequestService? data;
  final MServiceRequestDetail? detail;

  const UpdateQuotation({
    Key? key,
    this.onSuccess,
    this.quot,
    this.data,
    this.detail,
  }) : super(key: key);

  @override
  State<UpdateQuotation> createState() => _UpdateQuotationState();
}

class _UpdateQuotationState extends State<UpdateQuotation> {
  late var _util = OCSUtil.of(context);
  List<MItemQuotation> _items = [];
  List<MPartnerServiceItemData> _products = [];
  PartnerItemRepo _repo = PartnerItemRepo();
  double _totalPrice = 0;
  double _totalDis = 0;
  double _grandTotal = 0;
  bool _isUpdateQuot = false;
  bool isDisPercent = false;
  MSubmitQuotData? _quotationData;
  bool _loading = false;
  var _txtDesc = TextEditingController();
  MRequestService _header = MRequestService();
  RequestUpdateQuot _requestUpdateQuotRepo = RequestUpdateQuot();
  MServiceRequestDetail _requestDetail = MServiceRequestDetail();

  @override
  void initState() {
    super.initState();
    _items = _items + (widget.quot?.items ?? []);
    _quotationData = widget.quot;
    _txtDesc.text = _quotationData?.description ?? "";
    _header = widget.data!;
    _requestDetail = widget.detail!;
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
    // _grandTotal = _totalPrice - _totalDis + (_quotationData?.vatAmount ?? 0);
    _totalDis = (_quotationData?.discountAmount ?? 0);
    _grandTotal = _quotationData?.total ?? 0;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Txt(
            _util.language.key('update-invoice'),
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
          onPressed: _loading ? null : _buildAddItem,
          child: Icon(Icons.add),
          tooltip: _util.language.key('add-item'),
        ),
      ),
    );
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

    MSubmitUpdateQuot model = MSubmitUpdateQuot(
      id: _requestDetail.quotUpdateRequest?.id,
      refId: Model.partner.id,
      details: [],
      quotationId: _quotationData?.id ?? 0,
    );

    _quotationData?.items?.forEach((e) {
      var detail = _requestDetail.quotUpdateRequest?.quotation?.details
          ?.where((v) => e.id == v.id)
          .toList();

      model.details?.add(
        MQuotUpdateDetail(
          unitType: e.unitType,
          nameEnglish: e.nameEnglish,
          name: e.name,
          cost: (e.unitPrice ?? 0) * (e.qty ?? 0),
          headerId: _requestDetail.quotUpdateRequest?.id,
          itemId: e.id,
          quantity: e.qty,
          quotDetailId:
              (detail != null && detail.isNotEmpty) ? detail[0].id : 0,
        ),
      );
    });

    var _res = await _requestUpdateQuotRepo.update(model);

    if (!_res.error) {
      _util.snackBar(
        message: _util.language.key("success"),
        status: SnackBarStatus.success,
      );

      if (_res.data != null) {
        context.read<RequestServiceDetailBloc>().add(
              UpdateRequestDetail(
                header: _header,
                detail: _requestDetail.copyWith(
                  quotUpdateRequest: _res.data,
                ),
              ),
            );
      }
      _util.pop();
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
                      SizedBox(height: 5),
                      MyTextArea(
                        controller: _txtDesc,
                        placeHolder: _util.language.key('enter-description'),
                        label: _util.language.key('description'),
                      ),
                      SizedBox(height: 20),
                      BuildButton(
                        title: _util.language.key('update'),
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
              _onPressAddItem(
                isUpdate: isUpdate,
                data: data,
                index: index,
              );
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
                          " ${(_quotationData?.discountPercent ?? 0) > 0 ? "(${OCSUtil.currency(_quotationData?.discountPercent ?? 0, autoDecimal: true, sign: "%", rightSign: true)})" : ""}",
                      style: TxtStyle()
                        ..fontSize(14)
                        ..bold()
                        ..textColor(Colors.black87),
                    ),
                    Expanded(child: SizedBox()),
                    Parent(
                      style: ParentStyle()
                        ..ripple(_items.isNotEmpty)
                        ..padding(left: 5),
                      child: Row(
                        children: [
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
                  title: _util.language.key('update'),
                  onPress: _loading
                      ? null
                      : _items.isEmpty
                          ? null
                          : () {
                              _quotationData =
                                  _quotationData?.copyWith(items: _items);
                              _confirmDialog();
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
}

class AddUpdateItemQuot extends StatefulWidget {
  final MItemQuotation? data;
  final int? index;
  final bool? isUpdate;
  final Function(MItemQuotation) onSubmit;
  final List<MPartnerServiceItemData>? products;
  final bool? isUpdateQuot;

  const AddUpdateItemQuot({
    Key? key,
    this.index,
    this.data,
    this.isUpdate,
    required this.onSubmit,
    this.products,
    this.isUpdateQuot,
  }) : super(key: key);

  @override
  State<AddUpdateItemQuot> createState() => _AddUpdateItemQuotState();
}

class _AddUpdateItemQuotState extends State<AddUpdateItemQuot> {
  var _nameTxt = TextEditingController();
  var _qtyTxt = TextEditingController();
  var _nameEngTxt = TextEditingController();
  var _unitPriceTxt = TextEditingController();
  var _unitTypeTxt = TextEditingController();
  var _disPer = TextEditingController();
  var _disAmount = TextEditingController();
  var _formKey = GlobalKey<FormState>();

  List<MPartnerServiceItemData> _products = [];
  int _id = 0;
  bool isUpdate = false;
  MItemQuotation? data = MItemQuotation();
  late var _util = OCSUtil.of(context);
  int index = 0;
  bool disPercent = false;
  bool _isUpdateQuot = false;
  List<String> _unitTypes = [];

  @override
  void initState() {
    super.initState();
    _isUpdateQuot = widget.isUpdateQuot ?? false;
    isUpdate = widget.isUpdate ?? false;
    if (widget.data != null) data = widget.data!;
    index = widget.index ?? 0;
    disPercent = widget.data?.isDisPercent ?? false;
    _products = widget.products ?? [];
    _init(isUpdate: isUpdate, data: data);
    _id = data?.id ?? 0;
    _products.forEach((e) {
      _unitTypes.add(e.unitType ?? "");
    });

    _unitTypes = _unitTypes.toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      gestures: const [GestureType.onTap, GestureType.onPanUpdateDownDirection],
      child: Dialog(
        insetPadding: EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Parent(
              style: ParentStyle()
                ..padding(all: 15)
                ..borderRadius(topLeft: 5, topRight: 5)
                ..background.color(OCSColor.background)
                ..width(MediaQuery.of(context).size.width),
              child: Txt(
                isUpdate
                    ? _util.language.key('update-item')
                    : _util.language.key('add-item'),
                style: TxtStyle()
                  ..fontSize(14)
                  ..textColor(Colors.black),
              ),
            ),
            Parent(
              style: ParentStyle()..padding(all: 15),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAutoComplete(
                      controller: _nameTxt,
                    ),
                    _buildAutoCompleteEN(controller: _nameEngTxt),
                    MyTextField(
                      label: _util.language.key('qty'),
                      borderWidth: 1,
                      placeholder: "0",
                      textInputType: TextInputType.numberWithOptions(
                          decimal: true, signed: false),
                      controller: _qtyTxt,
                      textInputAction: TextInputAction.next,
                      autoValidateMode: AutovalidateMode.onUserInteraction,
                      validator: (v) {
                        if (v!.isEmpty) {
                          return _util.language.key("this-field-is-required");
                        }
                        return null;
                      },
                      onChanged: (v) {
                        if (v!.isEmpty || v == "0") {
                          _disPer.text = "";
                          _disAmount.text = "";
                        }

                        if (_disPer.text.isNotEmpty &&
                            _unitPriceTxt.text.isNotEmpty)
                          _disAmount.text = OCSUtil.currency(
                              ((double.parse(_unitPriceTxt.text) *
                                      ((double.parse(_qtyTxt.text)))) *
                                  double.parse(_disPer.text) /
                                  100),
                              autoDecimal: true);
                        setState(() {});
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: MyTextField(
                            placeholder: "0",
                            controller: _unitPriceTxt,
                            textInputAction: TextInputAction.next,
                            label: _util.language.key('unit-price'),
                            textInputType: TextInputType.numberWithOptions(
                                decimal: true, signed: false),
                            borderWidth: 1,
                            autoValidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (v) {
                              if (v!.isEmpty) {
                                return _util.language
                                    .key("this-field-is-required");
                              }
                              return null;
                            },
                            onChanged: (v) {
                              if (v!.isEmpty || v == "0") {
                                _disPer.text = "";
                                _disAmount.text = "";
                              }
                              if (_disPer.text.isNotEmpty &&
                                  _unitPriceTxt.text.isNotEmpty)
                                _disAmount.text = OCSUtil.currency(
                                    ((double.parse(_unitPriceTxt.text) *
                                            ((double.parse(_qtyTxt.text)))) *
                                        double.parse(_disPer.text) /
                                        100),
                                    autoDecimal: true);
                              setState(() {});
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(child: _buildUnitAutoComplete()),
                      ],
                    ),
                    SizedBox(height: 10),
                    if (!_util.query.isKbPopup)
                      BuildButton(
                        onPress: () {
                          _onPressAddItem(
                              isDisPercent: disPercent, isUpdate: isUpdate);
                        },
                        title: isUpdate
                            ? _util.language.key('update')
                            : _util.language.key('add'),
                        height: 40,
                        iconData:
                            isUpdate ? Icons.edit : Icons.add_circle_outline,
                        fontSize: 14,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _init({bool isUpdate = false, MItemQuotation? data}) {
    if (isUpdate) {
      _nameTxt.text = data?.name ?? "";
      _nameEngTxt.text = data?.nameEnglish ?? "";
      _qtyTxt.text = OCSUtil.currency(data?.qty ?? 0, autoDecimal: true);
      _unitPriceTxt.text = data?.unitPrice?.toString() ?? "";
      _unitTypeTxt.text = data?.unitType ?? "";

      _disPer.text =
          (widget.data?.itemDiscount?.discountBy?.toLowerCase() == "p"
              ? OCSUtil.currency(widget.data?.itemDiscount?.discount ?? 0,
                  autoDecimal: true)
              : "");
      _disAmount.text = data?.discountAmount == 0
          ? ""
          : OCSUtil.currency(data?.discountAmount ?? 0, autoDecimal: true);
      _id = data?.id ?? 0;
    } else {
      _qtyTxt.text = "1";
    }
  }

  void _onPressAddItem({bool isUpdate = false, bool isDisPercent = false}) {
    bool valid = true;
    if (_nameTxt.text.isEmpty) valid = false;

    if (_unitPriceTxt.text.isEmpty) valid = false;
    if (_unitTypeTxt.text.isEmpty) valid = false;
    if (_qtyTxt.text.isEmpty) valid = false;
    if (!valid) if (!_formKey.currentState!.validate()) return;
    data = data?.copyWith(
      id: _id,
      name: _nameTxt.text.trim(),
      unitType: _unitTypeTxt.text,
      unitPrice: double.parse(_unitPriceTxt.text),
      nameEnglish: _nameEngTxt.text,
      qty: double.parse(_qtyTxt.text),
      cost: double.parse(_unitPriceTxt.text) * double.parse(_qtyTxt.text),
      // discountPer: (_disPer.text.isNotEmpty ? double.parse(_disPer.text) : 0),
      // discountAmount:
      //     (_disAmount.text.isNotEmpty ? double.parse(_disAmount.text) : 0),
      // isDisPercent: isDisPercent,
      // itemDiscount: _disPer.text.isEmpty || _disPer.text == "0"
      //     ? null
      //     : MDiscount(
      //         discount: isDisPercent
      //             ? double.parse(_disPer.text.isEmpty ? "0" : _disPer.text)
      //             : double.parse(
      //                 _disAmount.text.isEmpty ? "0" : _disAmount.text),
      //         discountBy: _disPer.text.isEmpty
      //             ? ""
      //             : isDisPercent
      //                 ? "P"
      //                 : "A",
      //       ),
    );
    widget.onSubmit(data!);
    _util.pop();

    setState(() {});
  }

  Widget _buildUnitAutoComplete() {
    return Autocomplete<String>(
      displayStringForOption: (String option) {
        return option;
      },
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return _unitTypes;
        }

        return _unitTypes.where((v) {
          return v.toString().toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              );
        }).toList();
      },
      onSelected: (selection) {
        _unitTypeTxt.text = selection;
        _formKey.currentState?.reset();
      },
      initialValue: _unitTypeTxt.value,
      optionsViewBuilder: (context, onAutoCompleteSelect, options) {
        var data = options.toList();
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
            elevation: 1,
            child: Parent(
              style: ParentStyle()
                ..maxHeight(300)
                ..width((_util.query.width / 2.3))
                ..overflow.hidden(),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.all(0.0),
                itemCount: options.length,
                separatorBuilder: (context, i) {
                  return Divider();
                },
                itemBuilder: (BuildContext context, int index) {
                  return Parent(
                    style: ParentStyle()
                      ..padding(all: 15, vertical: 10)
                      ..ripple(true),
                    gesture: Gestures()
                      ..onTap(() {
                        onAutoCompleteSelect(data[index]);
                      }),
                    child: Txt(
                      "${data[index]}",
                      style: TxtStyle()
                        ..fontSize(Style.subTextSize)
                        ..textOverflow(TextOverflow.ellipsis)
                        ..maxLines(1),
                    ),
                  );
                  // some child here
                },
              ),
            ),
          ),
        );
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        _unitTypeTxt = textEditingController;
        return MyTextField(
          onEditingComplete: onFieldSubmitted,
          label: _util.language.key('unit-type'),
          placeholder: _util.language.key('enter-unit-type'),
          focusNode: focusNode,
          controller: textEditingController,
          textInputAction: TextInputAction.next,
          borderWidth: 1,
          autoValidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (v) {
            setState(() {});
          },
          validator: (v) {
            if (v!.isEmpty) {
              return _util.language.key("this-field-is-required");
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildAutoCompleteEN({
    TextEditingController? controller,
  }) {
    return MyTextField(
      readOnly: _isUpdateQuot && isUpdate,
      label: _util.language.key('eng-name'),
      controller: _nameEngTxt,
      placeholder: _util.language.key('enter-eng-name'),
      textInputAction: TextInputAction.next,
      borderWidth: 1,
      onChanged: (v) {
        if (v != data?.nameEnglish) {
          _id = 0;
        } else if (_nameTxt.text == data?.name && v == data?.nameEnglish) {
          _id = data?.id ?? 0;
        }
        setState(() {});
      },
    );
  }

  Widget _buildAutoComplete({TextEditingController? controller}) {
    return Autocomplete<MPartnerServiceItemData>(
      displayStringForOption: (MPartnerServiceItemData option) {
        return option.name ?? "";
      },
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return _products;
        }

        return _products.where((MPartnerServiceItemData v) {
          return v.name.toString().toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  ) ||
              v.nameEnglish.toString().toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  );
        }).toList();
      },
      onSelected: (MPartnerServiceItemData selection) {
        if (!_isUpdateQuot || !isUpdate) {
          _nameTxt.text = selection.name ?? "";
          _nameEngTxt.text = selection.nameEnglish ?? "";
          _unitPriceTxt.text = selection.unitPrice?.toString() ?? "";
          _unitTypeTxt.text = selection.unitType ?? "";
          _id = selection.id ?? 0;
          _formKey.currentState?.reset();
          data = data?.copyWith(
            name: selection.name ?? "",
            nameEnglish: selection.nameEnglish,
            id: selection.id,
            unitPrice: selection.unitPrice,
            unitType: selection.unitType,
          );
        }

        if (_isUpdateQuot) {
          _id = 0;
        }
        setState(() {});
      },
      initialValue: _nameTxt.value,
      optionsViewBuilder: (context, onAutoCompleteSelect, options) {
        var data = options.toList();
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
            elevation: 1,
            child: Parent(
              style: ParentStyle()
                ..maxHeight(300)
                ..width((_util.query.width / 1.5))
                ..overflow.hidden(),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.all(0.0),
                itemCount: options.length,
                separatorBuilder: (context, i) {
                  return Divider();
                },
                itemBuilder: (BuildContext context, int index) {
                  return Parent(
                    style: ParentStyle()
                      ..padding(all: 15, vertical: 10)
                      ..ripple(true),
                    gesture: Gestures()
                      ..onTap(() {
                        onAutoCompleteSelect(data[index]);
                      }),
                    child: Txt(
                      "${data[index].name}",
                      style: TxtStyle()
                        ..fontSize(Style.subTextSize)
                        ..textOverflow(TextOverflow.ellipsis)
                        ..maxLines(1),
                    ),
                  );
                  // some child here
                },
              ),
            ),
          ),
        );
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        // _nameTxt = textEditingController;
        return MyTextField(
          readOnly: _isUpdateQuot && isUpdate,
          onEditingComplete: onFieldSubmitted,
          label: _util.language.key('name'),
          placeholder: _util.language.key('enter-name'),
          focusNode: focusNode,
          controller: textEditingController,
          textInputAction: TextInputAction.next,
          borderWidth: 1,
          autoValidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (v) {
            _nameTxt.text = v ?? "";
            if (v != data?.name) {
              _id = 0;
            } else if (v == data?.name &&
                _nameEngTxt.text == data?.nameEnglish) {
              _id = data?.id ?? 0;
            }
            setState(() {});
          },
          validator: (v) {
            if (v!.isEmpty) {
              return _util.language.key("this-field-is-required");
            }
            return null;
          },
        );
      },
    );
  }
}
