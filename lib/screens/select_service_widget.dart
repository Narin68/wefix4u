import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '/screens/widget.dart';

import '../globals.dart';
import '../modals/service.dart';

void serviceDetailDialog(BuildContext context, {required MService data}) {
  late var _util = OCSUtil.of(context);
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: Parent(
            style: ParentStyle()..width(300),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Parent(
                  style: ParentStyle()
                    ..height(150)
                    ..border(all: 1, color: Colors.black.withOpacity(0.1))
                    ..alignmentContent.center()
                    ..borderRadius(all: 3)
                  // ..overflow.hidden()
                  ,
                  child: data.imagePath != null
                      ? FadeInImage.assetNetwork(
                          placeholder: '',
                          image: data.imagePath ?? '',
                          fit: BoxFit.cover,
                          placeholderErrorBuilder: (c, a, b) {
                            return Center(
                              child: SizedBox(
                                width: 30,
                                child: Image.asset(
                                  'assets/images/loading.gif',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                          imageErrorBuilder: (c, a, b) {
                            return Image.asset(
                              'assets/images/no-image.png',
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/images/no-image.png',
                          fit: BoxFit.cover,
                        ),
                ),
                SizedBox(height: 10),
                Txt(
                  _util.language.by(
                    km: data.name,
                    en: data.nameEnglish,
                    autoFill: true,
                  ),
                  style: TxtStyle()
                    ..fontSize(14)
                    ..maxLines(2)
                    ..textOverflow(TextOverflow.ellipsis)
                    ..textColor(OCSColor.text),
                ),
                // SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Txt(
                      _util.language.key('service-category') + " :",
                      style: TxtStyle()
                        ..fontSize(12)
                        ..textColor(OCSColor.text.withOpacity(0.8)),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Txt(
                        _util.language.by(
                          km: data.serviceCateName,
                          en: data.serviceCateNameEnglish,
                          autoFill: true,
                        ),
                        style: TxtStyle()
                          ..fontSize(12)
                          ..maxLines(2)
                          ..textOverflow(TextOverflow.ellipsis)
                          ..textColor(OCSColor.text.withOpacity(0.8)),
                      ),
                    ),
                  ],
                ),
                if ((data.description?.isNotEmpty ?? false) ||
                    (data.descriptionEnglish?.isNotEmpty ?? false)) ...[
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Txt(
                        _util.language.key('description') + " :",
                        style: TxtStyle()
                          ..fontSize(12)
                          ..textColor(OCSColor.text),
                      ),
                      Txt(
                        _util.language.by(
                            km: data.description,
                            en: data.descriptionEnglish,
                            autoFill: true),
                        style: TxtStyle()
                          ..fontSize(12)
                          ..textColor(OCSColor.text.withOpacity(0.8)),
                      ),
                    ],
                  )
                ]
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget buildServiceBox({
  String? src,
  String? title,
  Function? onPress,
  Function? onLongPress,
  bool select = false,
}) {
  return Parent(
    gesture: Gestures()
      ..onTap(() {
        if (onPress != null) onPress();
      })
      ..onLongPressStart((test) {
        if (onLongPress != null) onLongPress();
      }),
    style: ParentStyle(),
    child: Stack(
      children: [
        Parent(
          style: ParentStyle()
            ..borderRadius(all: 5)
            // ..margin(all: 5)
            ..background.color(Colors.white)
            ..border(all: 1, color: select ? OCSColor.primary : Colors.white),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              LayoutBuilder(builder: (context, s) {
                return Parent(
                  style: ParentStyle()
                    ..height(s.biggest.width)
                    // todo: change padding
                    ..padding(all: Globals.paddingImage + 5)
                    ..borderRadius(
                      all: 5,
                      bottomLeft: select ? 0 : 5,
                      bottomRight: select ? 0 : 5,
                    )
                    ..background.color(Colors.transparent),
                  child: MyCacheNetworkImage(
                    url: '$src',
                  ),
                );
              }),
              Parent(
                style: ParentStyle()..padding(horizontal: 7),
                child: Column(
                  children: [
                    Txt(
                      "$title",
                      style: TxtStyle()
                        ..textAlign.center()
                        ..fontSize(12)
                        ..maxLines(3)
                        ..textOverflow(TextOverflow.ellipsis)
                        ..textColor(OCSColor.text),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
        if (select)
          Positioned(
            top: 2,
            right: 2,
            child: Parent(
              style: ParentStyle()
                ..padding(all: 5)
                ..boxShadow(
                  color: OCSColor.primary.withOpacity(0.8),
                  blur: 0.5,
                  offset: Offset(0, 1),
                )
                ..alignmentContent.center()
                ..linearGradient(
                    colors: [OCSColor.primary, OCSColor.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)
                ..borderRadius(all: 20),
              child: Parent(
                style: ParentStyle(),
                child: Icon(
                  Remix.check_fill,
                  size: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
