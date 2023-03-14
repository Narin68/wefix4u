import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:ocs_util/ocs_util.dart';

import '/globals.dart';
import '/modals/customer_request_service.dart';
import '../widget.dart';

Widget confirmAccept(BuildContext context, {required Function onSubmit}) {
  return AlertDialog(
    contentPadding: EdgeInsets.only(left: 25, top: 15, bottom: 10, right: 15),
    title: Txt(
      OCSUtil.of(context).language.key('confirm-accept-request'),
      style: TxtStyle()
        ..fontSize(16)
        ..textColor(OCSColor.text),
    ),
    content: Txt(
      OCSUtil.of(context).language.key('do-you-want-to-accept-this-request'),
      style: TxtStyle()
        ..fontSize(14)
        ..textColor(OCSColor.text.withOpacity(0.7)),
    ),
    actions: <Widget>[
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
        ),
      ),
    ],
  );
}

Widget modalAskGiveUp(BuildContext context, {required Function onSubmit}) {
  return TextButton(
    onPressed: () {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          contentPadding:
              EdgeInsets.only(left: 25, top: 15, bottom: 10, right: 15),
          title: Txt(
            OCSUtil.of(context).language.key('give-up-service-request'),
            style: TxtStyle()
              ..fontSize(Style.titleSize)
              ..textColor(OCSColor.text),
          ),
          content: Txt(
            OCSUtil.of(context).language.key('do-you-want-to-give-up'),
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
              ),
            ),
          ],
        ),
      );
    },
    child: Txt(
      OCSUtil.of(context).language.key('give-up'),
      style: TxtStyle()
        ..fontSize(Style.titleSize)
        ..textColor(Colors.white),
    ),
  );
}

Widget buildBtn(BuildContext context,
    {MRequestService? header,
    MServiceRequestDetail? detail,
    required Function onClick,
    String status = '',
    String title = ''}) {
  late var _util = OCSUtil.of(context);
  if (status == "rejected" ||
      status == "given-up" ||
      status.isEmpty ||
      status == "quot-submit" ||
      status == "closed" ||
      status == "done") return SizedBox();

  if (header?.status?.toUpperCase() != RequestStatus.canceled &&
      header?.status?.toLowerCase() != "failed" &&
      header?.status != RequestStatus.waitingFeedback)
    return Positioned(
      bottom: _util.query.bottom <= 0 ? 15 : _util.query.bottom,
      child: Parent(
        style: ParentStyle()
          ..alignment.center()
          ..padding(
            horizontal: 16,
          )
          ..width(_util.query.width),
        child: BuildButton(
          title: _util.language.key(title),
          fontSize: 16,
          onPress: () {
            onClick();
          },
        ),
      ),
    );
  return SizedBox();
}

Widget ratingSection(BuildContext context, MRequestService header) {
  return Parent(
    style: ParentStyle()
      ..width(OCSUtil.of(context).query.width)
      ..margin(bottom: 15)
      ..background.color(OCSColor.white)
      ..elevation(1, opacity: 0.2)
      ..borderRadius(all: 5)
      ..padding(all: 10, horizontal: 15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Txt(
          "${OCSUtil.of(context).language.key('rating')}",
          style: TxtStyle()
            ..fontSize(Style.subTitleSize)
            ..textColor(OCSColor.text),
        ),
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
        Txt(
          "${OCSUtil.of(context).language.key('comment')}",
          style: TxtStyle()
            ..fontSize(Style.subTitleSize)
            ..margin(top: 10)
            ..textColor(OCSColor.text),
        ),
        Txt(
          header.comment?.isEmpty ?? false || header.comment == null
              ? "N/A"
              : "${header.comment}",
          style: TxtStyle()
            ..fontSize(Style.subTextSize)
            ..textColor(OCSColor.text),
        ),
      ],
    ),
  );
}
