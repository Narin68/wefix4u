import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '/modals/customer_request_service.dart';
import 'package:ocs_util/ocs_util.dart';
import '/modals/partner.dart';
import '/modals/quotation.dart';

import '/globals.dart';
import '../widget.dart';
import 'view_partner_accept.dart';

Widget buildTopContent(BuildContext context,
    {MRequestService? header,
    String status = '',
    required TxtStyle txtTitleStyle,
    required TxtStyle subtitleStyle,
    required Color color}) {
  late var _util = OCSUtil.of(context);
  return Parent(
    style: ParentStyle()
      ..width(_util.query.width)
      ..background.color(Colors.white)
      ..elevation(1, opacity: 0.2)
      ..borderRadius(all: 5)
      ..padding(all: 10, horizontal: 15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Txt(
          "${header?.targetLocation}",
          style: TxtStyle()
            ..textColor(OCSColor.text)
            ..fontSize(16),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Txt(
              "${_util.language.key('request-code')} :",
              style: txtTitleStyle,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Txt(
                "#${header?.code}",
                style: subtitleStyle.clone()..fontWeight(FontWeight.bold),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Txt(
              "${_util.language.key('status')} :",
              style: txtTitleStyle,
            ),
            SizedBox(width: 10),
            Txt(
              _util.language.key(status),
              style: TxtStyle()
                ..fontSize(11)
                ..borderRadius(all: 2)
                ..borderRadius(all: 2)
                ..fontWeight(FontWeight.w600)
                ..textColor(color)
                ..fontSize(Style.subTitleSize)
                ..textAlign.right(),
            ),
          ],
        ),
        if (status == "rejected" &&
            (header?.rejectedReason?.isNotEmpty ?? false))
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Txt(
                "${_util.language.key('reject_reason')} :",
                style: txtTitleStyle,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Txt(
                  header?.rejectedReason ?? "",
                  style: subtitleStyle,
                ),
              ),
            ],
          ),
      ],
    ),
  );
}

Widget buildPartnerCard(BuildContext context,
    {required MAcceptedPartner data,
    required MRequestService header,
    required MServiceRequestDetail detail}) {
  late var _util = OCSUtil.of(context);

  if (data.status == RequestStatus.rejected) return SizedBox();

  return Parent(
    gesture: Gestures()
      ..onTap(() {
        print(data.quotationId);
        if (data.status?.toUpperCase() == RequestStatus.rejected) return;

        // todo: Change next time
        _util.navigator.to(
          PartnerAccept(
            detail: detail,
            data: data,
            service: header,
            quotId: data.quotationId,
          ),
          transition: OCSTransitions.LEFT,
        );
      }),
    style: ParentStyle()
      ..width(_util.query.width - 32)
      ..overflow.hidden(true)
      ..alignmentContent.center()
      ..borderRadius(all: 5)
      ..margin(bottom: 5)
      ..padding(vertical: 10, horizontal: 5)
      ..elevation(1, opacity: 0.2)
      ..background.color(Colors.white),
    child: Column(
      children: [
        Parent(
          style: ParentStyle(),
          child: Row(
            children: [
              SizedBox(width: 5),
              Parent(
                style: ParentStyle()
                  ..borderRadius(all: 5)
                  ..overflow.hidden(true)
                  ..width(110)
                  ..overflow.hidden()
                  ..background.blur(10)
                  ..alignmentContent.center()
                  ..background.color(Colors.white)
                  ..boxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: Offset(0, 1),
                    blur: 3.0,
                    spread: 0.5,
                  ),
                child: MyNetworkImage(
                  url: "${data.image ?? ""}",
                  width: 300,
                  height: 100,
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Txt(
                      _util.language.by(
                        km: data.partnerName,
                        en: data.partnerNameEnglish,
                        autoFill: true,
                      ),
                      style: TxtStyle()
                        ..fontSize(Style.subTitleSize)
                        ..textColor(OCSColor.text)
                        ..textOverflow(TextOverflow.ellipsis),
                    ),
                    Txt(
                      data.partnerPhone ?? "",
                      style: TxtStyle()
                        ..fontSize(Style.subTextSize)
                        ..textColor(OCSColor.text.withOpacity(0.7))
                        ..textOverflow(TextOverflow.ellipsis),
                    ),
                    Txt(
                      data.partnerAddress ?? "",
                      style: TxtStyle()
                        ..fontSize(Style.subTextSize)
                        ..maxLines(1)
                        ..textColor(OCSColor.text.withOpacity(0.7))
                        ..textOverflow(TextOverflow.ellipsis),
                    ),
                    if (data.status?.toUpperCase() != RequestStatus.accepted)
                      Txt(
                        OCSUtil.currency((data.quotationAmount ?? 0),
                            autoDecimal: false, sign: '\$'),
                        style: TxtStyle()
                          ..fontWeight(FontWeight.bold)
                          ..fontSize(Style.subTitleSize)
                          ..textColor(Colors.green),
                      ),
                    if (detail.quotUpdateRequest != null &&
                        (detail.quotUpdateRequest?.status != "AL" &&
                            detail.quotUpdateRequest?.status != "AP" &&
                            detail.quotUpdateRequest?.status != "R"))
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 10),
                          Parent(
                            style: ParentStyle()
                              ..width(8)
                              ..height(8)
                              ..borderRadius(all: 10)
                              ..border(all: 1, color: Colors.orange),
                          ),
                          SizedBox(width: 5),
                          Txt(
                            _util.language.key(
                              detail.quotUpdateRequest?.status == "PR"
                                  ? "request-update-invoice"
                                  : 'updated-invoice',
                            ),
                            style: TxtStyle()..fontSize(12),
                          ),
                        ],
                      ),
                    if (data.status?.toUpperCase() == RequestStatus.accepted)
                      Txt(
                        _util.language.key('no-quotation'),
                        style: TxtStyle()
                          ..fontSize(Style.subTextSize)
                          ..borderRadius(all: 2)
                          ..fontWeight(FontWeight.bold)
                          ..textColor(Colors.white)
                          ..textColor(Colors.red),
                      ),
                    if (data.status?.toUpperCase() == RequestStatus.rejected)
                      Txt(
                        _util.language.key('rejected'),
                        style: TxtStyle()
                          ..fontSize(Style.subTextSize)
                          ..margin(top: 2)
                          ..fontWeight(FontWeight.bold)
                          ..borderRadius(all: 2)
                          ..textColor(Colors.red),
                      ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    ),
  );
}

double _getPrice(MQuotation? data) {
  double total = 0;
  double discount = 0;
  double subTotal = 0;
  data?.items?.forEach((e) {
    if (e.itemDiscount != null) {
      e = e.copyWith(
        discountAmount: e.itemDiscount?.discountBy == "A"
            ? (e.itemDiscount?.discount ?? 0)
            : ((e.cost ?? 0) / 100) * (e.itemDiscount?.discount ?? 0),
      );
    }
    discount += (e.discountAmount ?? 0);
    subTotal += (e.cost ?? 0);
  });

  total = subTotal - discount + (data?.vat ?? 0);

  if ((data?.discountAmount ?? 0) <= 0)
    data = data?.copyWith(
        discountAmount: data.quotDiscount?.discountBy == "A"
            ? (data.quotDiscount?.discount ?? 0)
            : ((total) / 100) * (data.quotDiscount?.discount ?? 0));

  discount += (data?.discountAmount ?? 0);
  total -= (data?.discountAmount ?? 0);

  return total;
}

Widget buildDonePartnerCard(BuildContext context,
    {required MAcceptedPartner approvePartner,
    required MRequestService header,
    required MServiceRequestDetail detail}) {
  late var _util = OCSUtil.of(context);
  return Parent(
    gesture: Gestures()
      ..onTap(() {
        _util.navigator.to(
          PartnerAccept(
            data: approvePartner,
            service: header,
            detail: detail,
            quotId: approvePartner.quotationId,
          ),
          transition: OCSTransitions.LEFT,
        );
      }),
    style: ParentStyle()
      ..ripple(true)
      ..overflow.hidden()
      ..margin(vertical: 5)
      ..alignmentContent.center()
      ..elevation(1, opacity: 0.2)
      ..borderRadius(all: 5)
      ..padding(horizontal: 15, right: 15, vertical: 5, bottom: 0)
      ..background.color(Colors.white),
    child: Parent(
      style: ParentStyle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              // todo: Change
              Parent(
                style: ParentStyle()
                  ..borderRadius(all: 5)
                  ..overflow.hidden()
                  ..width(120)
                  ..height(100)
                  ..borderRadius(all: 5)
                  ..alignmentContent.center()
                  ..elevation(1, opacity: 0.2)
                  ..background.color(Colors.white),
                child: MyNetworkImage(
                  url: "${approvePartner.image ?? ""}",
                  width: 200,
                  height: 100,
                ),
              ),
              SizedBox(height: 10),
              Txt(
                _util.language.by(
                  km: approvePartner.partnerName ?? "",
                  en: approvePartner.partnerNameEnglish,
                  autoFill: true,
                ),
                style: TxtStyle()
                  ..fontSize(Style.subTitleSize)
                  ..textColor(OCSColor.text)
                  ..textAlign.center()
                  ..width(120)
                  ..maxLines(3)
                  ..textOverflow(TextOverflow.ellipsis),
              ),
              Txt(
                approvePartner.partnerPhone ?? "",
                style: TxtStyle()
                  ..fontSize(Style.subTextSize)
                  ..textAlign.center()
                  ..textColor(OCSColor.text.withOpacity(0.7))
                  ..textOverflow(TextOverflow.ellipsis),
              ),
              SizedBox(height: 10),
            ],
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Txt(
                  _util.language.key('rating'),
                  style: TxtStyle()
                    ..fontSize(Style.subTitleSize)
                    ..margin(top: 10)
                    ..textColor(OCSColor.text),
                ),
                // SizedBox(height: 2),
                RatingBar.builder(
                  itemSize: 16,
                  initialRating: header.rating ?? 0,
                  minRating: 0,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  glow: false,
                  tapOnlyMode: false,
                  glowColor: Colors.orange,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.orange,
                  ),
                  ignoreGestures: true,
                  onRatingUpdate: (rating) {
                    // _rating = rating;
                  },
                ),
                if (header.comment != null && header.comment != '') ...[
                  Txt(
                    _util.language.key('comment'),
                    style: TxtStyle()
                      ..fontSize(Style.subTitleSize)
                      ..margin(top: 10)
                      ..textColor(OCSColor.text),
                  ),
                  Txt(
                    header.comment != null &&
                            (header.comment?.isNotEmpty ?? false)
                        ? "${header.comment?.trim()}"
                        : "N/A",
                    style: TxtStyle()
                      ..fontSize(Style.subTextSize)
                      ..textColor(OCSColor.text),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildNoAcceptPartner(String title) {
  return Parent(
    style: ParentStyle()
      ..height(50)
      ..margin(top: 10)
      ..borderRadius(all: 5)
      ..border(all: 1, color: OCSColor.primary.withOpacity(0.7))
      ..background.color(OCSColor.primary.withOpacity(0.1)),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Txt(
          title,
          style: TxtStyle()
            ..fontSize(Style.subTitleSize)
            ..textColor(OCSColor.text.withOpacity(0.8)),
        ),
      ],
    ),
  );
}

void confirmCancelModel(BuildContext context, {required Function onSubmit}) {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      contentPadding: EdgeInsets.only(left: 25, top: 15, bottom: 10, right: 15),
      title: Txt(
        OCSUtil.of(context).language.key('confirm-cancel-request'),
        style: TxtStyle()
          ..fontSize(16)
          ..textColor(OCSColor.text),
      ),
      content: Txt(
        OCSUtil.of(context).language.key('do-you-want-to-cancel-this-request'),
        style: TxtStyle()
          ..fontSize(14)
          ..textColor(OCSColor.text.withOpacity(0.7)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: Txt(
            OCSUtil.of(context).language.key('no'),
            style: TxtStyle()..textColor(OCSColor.text.withOpacity(0.6)),
          ),
        ),
        TextButton(
          onPressed: () {
            onSubmit();
          },
          child: Txt(
            OCSUtil.of(context).language.key('yes'),
            style: TxtStyle()..textColor(Colors.blue),
          ),
        ),
      ],
    ),
  );
}
