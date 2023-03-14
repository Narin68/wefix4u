import 'package:flutter/material.dart';
import 'package:division/division.dart';
import 'package:ocs_util/color.dart';

Widget buildActionModal(
    {required String title,
    required Color color,
    required Function onPress,
    required IconData icon}) {
  return Parent(
    gesture: Gestures()
      ..onTap(() {
        onPress();
      }),
    style: ParentStyle()
      ..padding(horizontal: 5, vertical: 10)
      ..background.color(Colors.white)
      ..borderRadius(all: 5)
      ..ripple(true),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Parent(
          style: ParentStyle()
            ..padding(all: 5)
            ..borderRadius(all: 20),
          child: Icon(icon, size: 18, color: color),
        ),
        SizedBox(width: 10),
        Txt(
          title,
          style: TxtStyle()
            ..margin(top: 2)
            ..textColor(OCSColor.text)
            ..fontSize(15),
        )
      ],
    ),
  );
}
