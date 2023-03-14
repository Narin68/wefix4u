import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:ocs_util/ocs_util.dart';
import '/modals/discount.dart';
import '/globals.dart';
import '/modals/partner_item.dart';
import '/modals/quotation.dart';
import '/screens/widget.dart';

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
        child: Parent(
          style: ParentStyle()
            ..height(
                _util.query.height - 170 - (_util.query.isKbPopup ? 30 : 0)),
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
              Expanded(
                child: SingleChildScrollView(
                  child: Parent(
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
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: MyTextField(
                                  placeholder: "0",
                                  controller: _unitPriceTxt,
                                  textInputAction: TextInputAction.next,
                                  label: _util.language.key('unit-price'),
                                  textInputType:
                                      TextInputType.numberWithOptions(
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
                                                  ((double.parse(
                                                      _qtyTxt.text)))) *
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
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: MyTextField(
                                  label: _util.language.key('discount-per'),
                                  controller: _disPer,
                                  borderWidth: 1,
                                  placeholder: "0",
                                  textInputType:
                                      TextInputType.numberWithOptions(
                                          decimal: true, signed: false),
                                  textInputAction: TextInputAction.next,
                                  onChanged: (v) {
                                    if (v != "" &&
                                        _unitPriceTxt.text.isNotEmpty) {
                                      disPercent = true;
                                      _disAmount.text = OCSUtil.currency(
                                          ((double.parse(_unitPriceTxt.text) *
                                                  ((double.parse(
                                                      _qtyTxt.text)))) *
                                              double.parse(v ?? "0") /
                                              100),
                                          autoDecimal: true);
                                    } else {
                                      _disAmount.text = "";
                                      disPercent = false;
                                    }
                                    setState(() {});
                                  },
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: MyTextField(
                                  controller: _disAmount,
                                  textInputAction: TextInputAction.next,
                                  label: _util.language.key('discount-amount'),
                                  placeholder: "0",
                                  textInputType:
                                      TextInputType.numberWithOptions(
                                          decimal: true, signed: false),
                                  borderWidth: 1,
                                  onChanged: (v) {
                                    disPercent = false;
                                    if (v != "" &&
                                        _unitPriceTxt.text.isNotEmpty) {
                                      _disPer.text = OCSUtil.currency(
                                          ((double.parse(v ?? "0").toDouble() *
                                                  100) /
                                              (double.parse(
                                                      _unitPriceTxt.text) *
                                                  ((double.parse(
                                                      _qtyTxt.text))))),
                                          autoDecimal: true);
                                    } else {
                                      _disPer.text = "";
                                    }
                                    setState(() {});
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),

                          Parent(
                            style: ParentStyle()
                              ..height(50)
                              ..padding(right: 10)
                              ..borderRadius(all: 5)
                              ..border(all: 0.5, color: OCSColor.border),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: data?.selected ?? false,
                                  onChanged: _id > 0
                                      ? null
                                      : (v) {
                                          data = data?.copyWith(selected: v);
                                          setState(() {});
                                        },
                                ),
                                Expanded(
                                  child: Txt(
                                    _util.language.key("save-to-product-list"),
                                    style: TxtStyle()
                                      ..textColor(
                                          _id > 0 ? Colors.grey : OCSColor.text)
                                      ..fontSize(Style.subTextSize),
                                    gesture: Gestures()
                                      ..onTap(() {
                                        if (_id > 0) return;
                                        data = data?.copyWith(
                                            selected: (data?.selected ?? false)
                                                ? false
                                                : true);
                                        setState(() {});
                                      }),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          // if (!_util.query.isKbPopup)
                          BuildButton(
                            onPress: () {
                              _onPressAddItem(
                                  isDisPercent: disPercent, isUpdate: isUpdate);
                            },
                            title: isUpdate
                                ? _util.language.key('update')
                                : _util.language.key('add'),
                            height: 40,
                            iconData: isUpdate
                                ? Icons.edit
                                : Icons.add_circle_outline,
                            fontSize: 14,
                          ),
                        ],
                      ),
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

  void _init({bool isUpdate = false, MItemQuotation? data}) {
    if (isUpdate) {
      _nameTxt.text = data?.name ?? "";
      _nameEngTxt.text = data?.nameEnglish ?? "";
      _qtyTxt.text = OCSUtil.currency(data?.qty ?? 0, autoDecimal: true);
      _unitPriceTxt.text = data?.unitPrice?.toString() ?? "";
      _unitTypeTxt.text = data?.unitType ?? "";
      // _disPer.text = data?.discountPer == 0
      //     ? ""
      //     : OCSUtil.currency(data?.discountPer ?? 0, autoDecimal: true);

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
      total: (double.parse(_unitPriceTxt.text) * double.parse(_qtyTxt.text)) -
          (_disAmount.text.isNotEmpty ? double.parse(_disAmount.text) : 0),
      nameEnglish: _nameEngTxt.text,
      qty: double.parse(_qtyTxt.text),
      cost: double.parse(_unitPriceTxt.text) * double.parse(_qtyTxt.text),
      discountPer: (_disPer.text.isNotEmpty ? double.parse(_disPer.text) : 0),
      discountAmount:
          (_disAmount.text.isNotEmpty ? double.parse(_disAmount.text) : 0),
      isDisPercent: isDisPercent,
      itemDiscount: _disPer.text.isEmpty || _disPer.text == "0"
          ? null
          : MDiscount(
              discount: isDisPercent
                  ? double.parse(_disPer.text.isEmpty ? "0" : _disPer.text)
                  : double.parse(
                      _disAmount.text.isEmpty ? "0" : _disAmount.text),
              discountBy: _disPer.text.isEmpty
                  ? ""
                  : isDisPercent
                      ? "P"
                      : "A",
            ),
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
