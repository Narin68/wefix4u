import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:ocs_util/ocs_util.dart';
import '/modals/discount.dart';
import '/functions.dart';
import '/globals.dart';
import '../service_request_widget.dart';
import '/modals/quotation.dart';
import '/screens/widget.dart';

class QuotDetail extends StatefulWidget {
  final MQuotationData? header;

  const QuotDetail({Key? key, this.header}) : super(key: key);

  @override
  State<QuotDetail> createState() => _QuotDetailState();
}

class _QuotDetailState extends State<QuotDetail> {
  late var _util = OCSUtil.of(context);
  bool _loading = false;
  bool _failed = false;
  MQuotationData _header = MQuotationData();
  String _message = '';
  MQuotation _quotation = MQuotation();
  var _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _header = widget.header ?? MQuotationData();
    _getDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _loading || _failed
            ? null
            : () async {
                Uint8List? bytes = await OCSUtil.capture(_key, pixelRatio: 2);
                File file = await uintWriteToFile(bytes!);

                var saved = await GallerySaver.saveImage(file.path);
                if (saved ?? false) _util.toast("Saved");
              },
        child: Icon(
          Icons.save_alt,
          color: Colors.white,
        ),
        backgroundColor: OCSColor.primary,
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: OCSColor.primary,
        title: Txt(
          _util.language.key('quotation-detail'),
          style: TxtStyle()
            ..fontSize(16)
            ..textColor(Colors.white),
        ),
        leading: NavigatorBackButton(),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : _failed
              ? Center(
                  child: BuildErrorBloc(message: _message, onRetry: _getDetail),
                )
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: RepaintBoundary(
                        key: _key,
                        child: Parent(
                          style: ParentStyle()
                            ..background.color(Colors.white)
                            ..padding(all: 15)
                            ..maxWidth(Globals.maxScreen),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Txt(
                                    _util.language.key('quotation'),
                                    style: TxtStyle()
                                      ..fontWeight(FontWeight.bold)
                                      ..fontSize(Style.titleSize)
                                      ..textColor(OCSColor.text),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Txt(
                                        _util.language.key('quotation-code') +
                                            " :",
                                        style: TxtStyle()
                                          ..fontSize(Style.subTextSize)
                                          ..width(100)
                                          ..textColor(OCSColor.text),
                                      ),
                                      SizedBox(width: 10),
                                      Txt(
                                        "#${_header.code ?? ""}",
                                        style: TxtStyle()
                                          ..textAlign.right()
                                          ..fontSize(Style.subTextSize)
                                          ..textColor(
                                              OCSColor.text.withOpacity(0.7)),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Txt(
                                        _util.language.key('date') + " :",
                                        style: TxtStyle()
                                          ..fontSize(Style.subTextSize)
                                          ..width(100)
                                          ..textColor(OCSColor.text),
                                      ),
                                      SizedBox(width: 10),
                                      Txt(
                                        OCSUtil.dateFormat(
                                          DateTime.parse(
                                              _header.createdDate ?? ""),
                                          format: Format.date,
                                          langCode: Globals.langCode,
                                        ),
                                        style: TxtStyle()
                                          ..fontSize(Style.subTextSize)
                                          ..textAlign.right()
                                          ..textColor(
                                              OCSColor.text.withOpacity(0.7)),
                                      )
                                    ],
                                  ),
                                  if (Globals.userType.toLowerCase() ==
                                      "partner")
                                    Row(
                                      children: [
                                        Txt(
                                          _util.language.key('status') + ":",
                                          style: TxtStyle()
                                            ..fontSize(Style.subTextSize)
                                            ..width(100)
                                            ..textColor(OCSColor.text),
                                        ),
                                        SizedBox(width: 8),
                                        Parent(
                                          style: ParentStyle()
                                            ..width(5)
                                            ..height(5)
                                            ..borderRadius(all: 50)
                                            ..background.color(_header.status!
                                                        .toLowerCase()
                                                        .toString() ==
                                                    "pending"
                                                ? Colors.orange
                                                : _header.status!
                                                                .toLowerCase() ==
                                                            "in use" ||
                                                        _header.status
                                                                ?.toUpperCase() ==
                                                            "QUOTE SUBMITTED"
                                                    ? Colors.green
                                                    : (_header.status ?? "")
                                                                .toLowerCase() ==
                                                            "approved"
                                                        ? Colors.blue
                                                        : Colors.red),
                                        ),
                                        SizedBox(width: 5),
                                        Txt(
                                          _util.language.key(
                                              '${_header.status == "R" ? "abandoned" : _header.status?.toUpperCase() == "QUOTE SUBMITTED" ? "in use" : _header.status?.toLowerCase() ?? ""}'),
                                          style: TxtStyle()
                                            ..fontSize(Style.subTextSize)
                                            ..textColor(
                                              _header.status.toString() ==
                                                      "pending"
                                                  ? Colors.orange
                                                  : _header.status!
                                                                  .toLowerCase() ==
                                                              "in use" ||
                                                          _header.status
                                                                  ?.toUpperCase() ==
                                                              "QUOTE SUBMITTED"
                                                      ? Colors.green
                                                      : (_header.status ?? "")
                                                                  .toLowerCase() ==
                                                              "approved"
                                                          ? Colors.blue
                                                          : Colors.red,
                                            ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              SizedBox(height: 15),
                              buildQuotTable(
                                quotation: _header,
                                context: context,
                              ),
                              // QuotationTable(quotation: _quotation),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
    );
  }

  Future _getDetail() async {
    // _quotation = MQuotation(
    //   status: _header.status,
    //   vat: _header.vatAmount,
    //   code: _header.code,
    //   id: _header.id,
    //   desc: _header.description,
    //   cost: _header.total,
    //   items: _header.items,
    //   requestId: _header.requestId,
    //   quotDiscount: (_header.discountAmount ?? 0) > 0 ||
    //           (_header.discountPercent ?? 0) > 0
    //       ? MDiscount(
    //           discount: (_header.discountPercent != null &&
    //                   (_header.discountPercent ?? 0) > 0)
    //               ? _header.discountAmount
    //               : _header.amount,
    //           discountBy: (_header.discountPercent != null &&
    //                   (_header.discountPercent ?? 0) > 0)
    //               ? "P"
    //               : "A",
    //         )
    //       : null,
    // );
  }
}
