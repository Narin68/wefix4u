import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '/modals/invoice.dart';
import '/modals/discount.dart';
import '../service_request_widget.dart';
import '../widget.dart';
import '/functions.dart';
import '/modals/partner.dart';

import '/globals.dart';

class BuildReceiptTable extends StatefulWidget {
  final MInvoiceData? invoice;
  final MAcceptedPartner? partner;
  final Function()? onClose;
  final MDiscountCode? promoDiscount;

  const BuildReceiptTable(
      {Key? key, this.invoice, this.partner, this.onClose, this.promoDiscount})
      : super(key: key);

  @override
  State<BuildReceiptTable> createState() => _BuildReceiptTableState();
}

class _BuildReceiptTableState extends State<BuildReceiptTable> {
  late var _util = OCSUtil.of(context);
  var _key = GlobalKey();
  var headingTxt = TxtStyle()
    ..textColor(OCSColor.black)
    ..fontWeight(FontWeight.normal)
    ..fontSize(14);
  MInvoiceData? _invoiceData;
  List<MInvoiceItem> _items = [];
  String _partnerPhone = "";
  double _discountCodeAmount = 0;
  double _discountCodePer = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _util.navigator.pop();
        _util.navigator.pop();
        _util.navigator.pop();
        return false;
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(0),
        elevation: 1,
        child: Parent(
          style: ParentStyle()
            ..borderRadius(all: 5)
            ..background.color(Colors.white)
            ..maxHeight(700)
            ..maxWidth(_util.query.width > 500
                ? Globals.maxScreen
                : _util.query.width - 30),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RepaintBoundary(
                  key: _key,
                  child: Parent(
                    style: ParentStyle()..background.color(Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Stack(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _invoiceInfo(),
                              SizedBox(height: 10),
                              _buildTable(),
                              // SizedBox(height: 10),
                              footerQuotation(
                                context: context,
                                discountCodeAmount: _discountCodeAmount,
                                discountCodePer: _discountCodePer,
                                grandTotal: _invoiceData?.total ?? 0,
                                subTotal: _invoiceData?.amount ?? 0,
                                disCountPer: _invoiceData?.discountPercent ?? 0,
                                totalDiscount:
                                    _invoiceData?.discountAmount ?? 0,
                              ),
                            ],
                          ),
                          Positioned(
                            bottom: 60,
                            left: 30,
                            child: Image.asset(
                              'assets/images/paid.png',
                              height: 70,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Parent(
                  style: ParentStyle()
                    ..width(_util.query.width)
                    ..margin(top: 15),
                  child: Column(
                    children: [
                      BuildButton(
                        title: _util.language.key('save'),
                        width: 170,
                        ripple: false,
                        height: 40,
                        fontSize: 14,
                        iconData: Remix.download_2_line,
                        iconSize: 20,
                        onPress: () async {
                          Uint8List? bytes =
                              await OCSUtil.capture(_key, pixelRatio: 2);
                          File file = await uintWriteToFile(bytes!);
                          var saved = await GallerySaver.saveImage(file.path);
                          if (saved ?? false) _util.toast("Saved");
                        },
                      ),
                      SizedBox(height: 5),
                      TextButton(
                        onPressed: () {
                          if (widget.onClose != null) widget.onClose!();
                        },
                        child: Txt(
                          _util.language.key('close'),
                        ),
                      ),
                      SizedBox(height: 15),
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

  _init() {
    _invoiceData = widget.invoice!;
    _partnerPhone = _invoiceData?.partnerPhone ?? "";
    if (_partnerPhone.contains('+855'))
      _partnerPhone =
          (widget.partner?.partnerPhone?.replaceAll('+855', "0") ?? "");
    _items = _invoiceData?.items ?? [];
  }

  Widget _invoiceInfo() {
    return Parent(
      style: ParentStyle()
        ..border(bottom: 0.5, color: OCSColor.border, style: BorderStyle.solid)
        ..padding(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Parent(
            style: ParentStyle()
              ..borderRadius(all: 5)
              ..overflow.hidden(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Txt(
                      _util.language.key('receipt'),
                      style: TxtStyle()
                        ..fontSize(16)
                        ..fontWeight(FontWeight.bold)
                        ..textColor(OCSColor.text),
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Txt(
                _util.language.key('issued-by'),
                style: TxtStyle()
                  ..fontSize(12)
                  ..textColor(OCSColor.text),
              ),
              Txt(
                _util.language.by(
                  km: _invoiceData?.partnerName,
                  en: _invoiceData?.partnerNameEnglish,
                  autoFill: true,
                ),
                style: TxtStyle()
                  ..fontSize(14)
                  ..bold()
                  ..textColor(OCSColor.text),
              ),
              Txt(
                "${_partnerPhone}",
                style: TxtStyle()
                  ..fontSize(12)
                  ..textColor(OCSColor.text.withOpacity(0.9)),
              ),
              Txt(
                "${_util.language.by(
                  km: _invoiceData?.partnerAddress,
                  en: _invoiceData?.partnerAddressEnglish,
                  autoFill: true,
                )}",
                style: TxtStyle()
                  ..fontSize(12)
                  ..maxLines(4)
                  ..textOverflow(TextOverflow.ellipsis)
                  ..textColor(OCSColor.text.withOpacity(0.9)),
              ),
            ],
          ),
          SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Txt(
                    _util.language.key('invoice-no') + " :",
                    style: TxtStyle()
                      ..fontSize(12)
                      ..width(100)
                      ..textColor(OCSColor.text),
                  ),
                  SizedBox(width: 10),
                  Txt(
                    "#${_invoiceData?.code ?? ""}",
                    style: TxtStyle()
                      ..textAlign.right()
                      ..fontSize(12)
                      ..textColor(OCSColor.text.withOpacity(0.7)),
                  ),
                ],
              ),
              Row(
                children: [
                  Txt(
                    _util.language.key('request-codes') + " :",
                    style: TxtStyle()
                      ..fontSize(12)
                      ..width(100)
                      ..textColor(OCSColor.text),
                  ),
                  SizedBox(width: 10),
                  Txt(
                    "#${_invoiceData?.requestCode ?? ""}",
                    style: TxtStyle()
                      ..fontSize(12)
                      ..textAlign.right()
                      ..textColor(OCSColor.text.withOpacity(0.7)),
                  )
                ],
              ),
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
                  Txt(
                    OCSUtil.dateFormat(_invoiceData?.createdDate ?? "",
                        format: Format.date),
                    style: TxtStyle()
                      ..fontSize(12)
                      ..textAlign.right()
                      ..textColor(OCSColor.text.withOpacity(0.7)),
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTable() {
    return Parent(
      style: ParentStyle()
        ..background.color(Colors.white)
        ..overflow.hidden(),
      child: Column(
        children: [
          Parent(
            style: ParentStyle()
              // ..background.color(OCSColor.background)
              ..padding(all: 10, horizontal: 0),
            child: Row(
              children: [
                Txt(
                  '${_util.language.key('item')}',
                  style: TxtStyle()
                    ..textColor(OCSColor.black)
                    ..fontWeight(FontWeight.normal)
                    ..fontSize(Style.subTitleSize),
                ),
                Expanded(child: SizedBox()),
                Txt(
                  _util.language.key('discount'),
                  style: TxtStyle()
                    ..textColor(OCSColor.black)
                    ..fontWeight(FontWeight.normal)
                    ..fontSize(Style.subTitleSize)
                    ..alignmentContent.centerRight()
                    ..textAlign.right(),
                ),
                SizedBox(width: 15),
                Txt(
                  _util.language.key('amount'),
                  style: TxtStyle()
                    ..textColor(OCSColor.black)
                    ..fontWeight(FontWeight.normal)
                    ..fontSize(Style.subTitleSize)
                    ..width(70)
                    ..alignmentContent.centerRight()
                    ..textAlign.right(),
                ),
              ],
            ),
          ),
          ListView.builder(
            padding: EdgeInsets.only(bottom: 5),
            shrinkWrap: true,
            itemCount: _items.length,
            primary: false,
            itemBuilder: (_, i) {
              return Column(
                children: [
                  Row(
                    children: [
                      Column(
                        children: [
                          Txt(
                            _util.language.by(
                              km: _items[i].itemName,
                              en: _items[i].itemNameEnglish,
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
                                  (_items[i].amount ?? 0) /
                                      (_items[i].quantity ?? 0),
                                  autoDecimal: true,
                                  sign: '\$',
                                )}" +
                                " × " +
                                OCSUtil.currency((_items[i].quantity ?? 0),
                                    decimal: 0, sign: '') +
                                " ${_items[i].unitType ?? ""}",
                            style: TxtStyle()
                              ..fontSize(Style.subTextSize)
                              ..textColor(OCSColor.text.withOpacity(0.7)),
                          ),
                        ],
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                      Expanded(child: SizedBox()),
                      Txt(
                        (_items[i].discountAmount ?? 0) <= 0
                            ? ""
                            : OCSUtil.currency(
                                _items[i].discountAmount ?? 0,
                                autoDecimal: true,
                                sign: '\$',
                              ),
                        style: TxtStyle()
                          ..fontSize(Style.subTextSize)
                          ..textColor(OCSColor.text)
                          ..alignmentContent.centerRight()
                          ..textAlign.right(),
                      ),
                      SizedBox(width: 15),
                      Txt(
                        OCSUtil.currency(_items[i].total ?? 0,
                            autoDecimal: false, sign: '\$'),
                        style: TxtStyle()
                          ..fontSize(Style.subTextSize)
                          ..textColor(OCSColor.text)
                          ..width(70)
                          ..textAlign.right()
                          ..alignment.centerRight(),
                      ),
                    ],
                  ),
                  Divider(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
