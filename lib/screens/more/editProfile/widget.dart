import 'package:flutter/material.dart';
import 'package:ocs_util/color.dart';
import 'package:remixicon/remixicon.dart';
import 'package:division/division.dart';
import '/globals.dart';

Widget buildUserInfo({
  String? title,
  String? subTitle,
}) {
  return Parent(
    style: ParentStyle()
      ..padding(all: 20, vertical: 5)
      ..border(bottom: 1, color: Colors.grey.withOpacity(0.05)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Txt(
          "${title}",
          style: TxtStyle()
            ..textColor(OCSColor.text.withOpacity(0.7))
            ..fontSize(12),
        ),
        Txt(
          "${subTitle == '' ? 'N/A' : subTitle}",
          style: TxtStyle()
            ..textColor(OCSColor.text)
            ..textAlign.left()
            ..fontSize(14),
        ),
      ],
    ),
  );
}

Widget buildUserHeadTitle({
  String? title,
  Function? onPress,
  IconData? icon,
}) {
  return Parent(
    style: ParentStyle()
      ..padding(horizontal: 15, right: 0)
      ..height(40)
      ..background.color(Colors.blue.withOpacity(0.09)),
    child: Row(
      children: [
        if (icon != null)
          Icon(
            Remix.user_2_line,
            size: 18,
            color: Colors.black.withOpacity(0.65),
          ),
        if (icon != null) SizedBox(width: 3),
        Txt(
          "${title}",
          style: TxtStyle()
            ..textColor(OCSColor.text)
            ..fontSize(Style.subTitleSize),
        ),
        Expanded(child: SizedBox()),
        IconButton(
            onPressed: () {
              onPress!();
            },
            icon: Icon(
              Remix.edit_line,
              size: 18,
              color: Colors.black54,
            ))
      ],
    ),
  );
}
