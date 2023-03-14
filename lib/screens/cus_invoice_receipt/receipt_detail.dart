import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:ocs_util/ocs_util.dart';
import '../../repositories/invoice_repo.dart';
import '/screens/cus_invoice_receipt/widget.dart';
import '/functions.dart';
import '/globals.dart';
import '/modals/invoice.dart';
import '../widget.dart';

class ReceiptDetail extends StatefulWidget {
  final MInvoiceData header;

  const ReceiptDetail({Key? key, required this.header}) : super(key: key);

  @override
  State<ReceiptDetail> createState() => _ReceiptDetailState();
}

class _ReceiptDetailState extends State<ReceiptDetail> {
  late var _util = OCSUtil.of(context);
  bool _loading = false;
  MInvoiceData _header = MInvoiceData();
  String _cusPhone = '';
  String _partnerPhone = '';
  var headingTxt = TxtStyle()
    ..textColor(OCSColor.black)
    ..fontWeight(FontWeight.normal)
    ..fontSize(14);
  var _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _header = widget.header;
    _cusPhone = _header.customerPhone ?? "";

    _partnerPhone = _header.partnerPhone ?? "";
    if (_cusPhone.contains('+855'))
      _cusPhone = _header.customerPhone!.replaceAll('+855', "0");
    if (_partnerPhone.contains('+855'))
      _partnerPhone = _header.partnerPhone!.replaceAll('+855', "0");

    // _calculatePrice();
    _invoiceDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _loading
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
      appBar: AppBar(
        backgroundColor: OCSColor.primary,
        title: Txt(
          _util.language.key('receipt-detail'),
          style: TxtStyle()
            ..fontSize(16)
            ..textColor(Colors.white),
        ),
        leading: NavigatorBackButton(loading: _loading),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 20.0, left: 15, right: 15, bottom: 80),
                      child: Center(
                        child: RepaintBoundary(
                          key: _key,
                          child: Parent(
                            style: ParentStyle()
                              ..width(_util.query.width)
                              ..maxWidth(500)
                              ..background.color(Colors.white),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _invoiceInfo(),
                                      SizedBox(height: 10),
                                      buildTableInvoice(context,
                                          invoice: _header),
                                      // SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Future _invoiceDetail() async {
    setState(() {
      _loading = true;
    });
    var res = await InvoiceRepo().detail(id: _header.id ?? 0);
    if (!res.error) {
      _header = _header.copyWith(items: res.data.items);
    } else {
      _util.snackBar(message: res.message, status: SnackBarStatus.danger);
    }
    setState(() {
      _loading = false;
    });
  }

  Widget _invoiceInfo() {
    return Parent(
      style: ParentStyle()
        ..border(bottom: 0.5, color: OCSColor.border, style: BorderStyle.solid)
        ..padding(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  km: _header.partnerName,
                  en: _header.partnerNameEnglish,
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
                  km: _header.partnerAddress,
                  en: _header.partnerAddressEnglish,
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
                    "#${_header.code ?? ""}",
                    style: TxtStyle()
                      ..textAlign.right()
                      ..fontSize(12)
                      ..textColor(OCSColor.text),
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
                    "#${_header.requestCode ?? ""}",
                    style: TxtStyle()
                      ..fontSize(12)
                      ..textAlign.right()
                      ..textColor(OCSColor.text),
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
                    OCSUtil.dateFormat(
                      DateTime.parse(_header.createdDate ?? ""),
                      format: Format.date,
                      langCode: Globals.langCode,
                    ),
                    style: TxtStyle()
                      ..fontSize(12)
                      ..textAlign.right()
                      ..textColor(OCSColor.text),
                  )
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
