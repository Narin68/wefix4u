import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import '../service_request_widget.dart';
import '/globals.dart';
import '/modals/invoice.dart';

Widget buildTableInvoice(BuildContext context,
    {MInvoiceData? invoice, bool showFooter = true}) {
  List<MInvoiceItem> _items = [];
  late var _util = OCSUtil.of(context);
  double _discount = invoice?.discountAmount ?? 0;
  double _subTotal = invoice?.amount ?? 0;
  double _grandTotal = invoice?.total ?? 0;
  _items = invoice?.items ?? [];
  double _discountCodeAmount = 0;
  double _discountCodePer = 0;
  double _discountPer = invoice?.discountPercent ?? 0;

  return Parent(
    style: ParentStyle()
      ..background.color(Colors.white)
      ..overflow.hidden(),
    child: Column(
      children: [
        Parent(
          style: ParentStyle()..padding(all: 10, horizontal: 0),
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
                          autoDecimal: true, sign: '\$'),
                      style: TxtStyle()
                        ..fontSize(Style.subTextSize)
                        ..textColor(OCSColor.text)
                        ..width(70)
                        ..margin(right: 0)
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
        if (showFooter)
          footerQuotation(
            context: context,
            grandTotal: _grandTotal,
            subTotal: _subTotal,
            discountCodePer: _discountCodePer,
            discountCodeAmount: _discountCodeAmount,
            disCountPer: _discountPer,
            totalDiscount: _discount,
          ),
      ],
    ),
  );
}
