import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';

class BuildLogo extends StatefulWidget {
  @override
  _BuildLogoState createState() => _BuildLogoState();
}

class _BuildLogoState extends State<BuildLogo> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/logo/logo-red.png',
        height: 50,
      ),
    );
  }
}

class BuildTextLogo extends StatefulWidget {
  const BuildTextLogo({Key? key}) : super(key: key);

  @override
  State<BuildTextLogo> createState() => _BuildTextLogoState();
}

class _BuildTextLogoState extends State<BuildTextLogo> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Parent(
        style: ParentStyle(),
        child: Image.asset(
          'assets/logo/logo-text-red.png',
        ),
      ),
    );
  }
}

class BuildScreenTitle extends StatefulWidget {
  final String? title;
  final double fontSize;

  BuildScreenTitle({required this.title, this.fontSize = 18});

  @override
  _BuildScreenTitleState createState() => _BuildScreenTitleState();
}

class _BuildScreenTitleState extends State<BuildScreenTitle> {
  @override
  Widget build(BuildContext context) {
    return Txt(
      "${widget.title}",
      style: TxtStyle()
        ..fontSize(widget.fontSize)
        ..width(500)
        ..textAlign.center()
        ..textColor(OCSColor.text),
    );
  }
}
