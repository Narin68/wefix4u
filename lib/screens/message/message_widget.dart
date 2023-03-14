import 'dart:io';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '/blocs/count_message/count_message_cubit.dart';
import '/modals/message.dart';
import '../more/request_partner/widget.dart';
import '../request_service/view_image.dart';
import '/globals.dart';
import '../widget.dart';
import 'package:ocs_util/ocs_util.dart';
import 'message_detail.dart';

Widget buildTopTitle(String? receiverName, String? receiverImage) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Expanded(
        child: SizedBox(),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Txt(
            receiverName ?? "",
            style: TxtStyle()
              ..fontSize(Style.titleSize)
              ..textColor(Colors.white),
          ),
        ],
      ),
      Expanded(
        child: SizedBox(),
      ),
      Parent(
        style: ParentStyle()
          ..borderRadius(all: 50)
          ..background.color(Colors.white)
          ..width(40)
          ..height(40)
          ..overflow.hidden()
          ..elevation(1, opacity: 0.2),
        child: receiverName == 'wefix4u'
            ? Padding(
                padding: const EdgeInsets.all(7.0),
                child: Image.asset(
                  'assets/logo/logo-red.png',
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                ),
              )
            : MyNetworkImage(
                iconSize: 25,
                url: (receiverImage ?? ""),
                defaultAssetImage: Globals.userAvatarImage,
              ),
      ),
    ],
  );
}

Widget buildImageAction(OCSUtilities util,
    {required Function getImageByCamera, required Function getImage}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Parent(
        style: ParentStyle()
          ..background.color(Colors.white)
          ..padding(all: 10, top: 5)
          ..borderRadius(all: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Txt(
              util.language.key('image'),
              style: TxtStyle()
                ..fontSize(16)
                ..textColor(Colors.black87),
            ),
            SizedBox(height: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildActionModal(
                  icon: Icons.camera_alt_outlined,
                  onPress: getImageByCamera,
                  color: Colors.green,
                  title: util.language.key("camera"),
                ),
                buildActionModal(
                  icon: Remix.image_line,
                  onPress: getImage,
                  color: Colors.blue,
                  title: util.language.key("gallery"),
                ),
              ],
            ),
            SizedBox(height: util.query.bottom + 5),
          ],
        ),
      ),
    ],
  );
}

Widget buildImageSend(OCSUtilities util,
    {required Function onRemove, required List<XFile> images}) {
  if (images.isEmpty) return SizedBox();
  return Parent(
    style: ParentStyle()..padding(top: 10, horizontal: 10),
    child: GridView.builder(
      primary: true,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
      ),
      itemCount: images.length,
      itemBuilder: (context, i) {
        return Stack(
          children: [
            Parent(
              gesture: Gestures()
                ..onTap(() {
                  util.navigator.to(ViewMultiImage(
                    path: images[i].path,
                    images: images,
                    index: i,
                  ));
                }),
              style: ParentStyle()
                ..margin(all: 5)
                ..width(300)
                ..borderRadius(all: 5)
                ..overflow.hidden()
                ..background.color(Colors.white)
                ..boxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.1),
                  offset: Offset(0, 1),
                  blur: 3.0,
                  spread: 0.5,
                ),
              child: Image.file(
                File(images[i].path),
                fit: BoxFit.cover,
                height: 100,
              ),
            ),
            Positioned(
              child: Parent(
                style: ParentStyle()
                  ..padding(all: 2)
                  ..ripple(true)
                  ..borderRadius(all: 50)
                  ..background.color(Colors.white)
                  ..elevation(1, opacity: 0.5),
                child: Icon(
                  Remix.delete_bin_2_line,
                  size: 16,
                  color: OCSColor.primary,
                ),
                gesture: Gestures()
                  ..onTap(() async {
                    await onRemove();
                  }),
              ),
              right: 0,
              top: 0,
            )
          ],
        );
      },
    ),
  );
}

Widget buildNoData(String title) {
  return Center(
    child: BuildNoDataScreen(
      title: title,
      assets: "assets/images/message.png",
    ),
  );
}

Widget buildImageSection(
  OCSUtilities util, {
  String type = "",
  required Function onLongPress,
  MMessageData? data,
  XFile? image,
  required Function onPress,
}) {
  return Column(
    crossAxisAlignment:
        type == "sender" ? CrossAxisAlignment.end : CrossAxisAlignment.start,
    children: [
      Parent(
        gesture: Gestures()
          ..onLongPress(() {
            onLongPress();
          }),
        style: ParentStyle()
          ..overflow.hidden()
          ..borderRadius(all: 5)
          ..margin(top: 5)
          ..background.color(OCSColor.blue.withOpacity(0.1))
          ..maxWidth(util.query.width - 130),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            data?.completed ?? false
                ? Parent(
                    style: ParentStyle()
                      ..borderRadius(bottomLeft: 5, bottomRight: 5)
                      ..overflow.hidden()
                      ..width(util.query.width - 130),
                    child: MyNetworkImage(
                      url: Globals.firebaseServer + (data?.contentUrl ?? ""),
                      height: util.query.width / 2,
                    ),
                    gesture: Gestures()
                      ..onTap(() {
                        onPress();
                      }),
                  )
                : (image != null)
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          Parent(
                            style: ParentStyle()
                              ..opacity(0.2)
                              ..width(util.query.width - 130),
                            child: Image.file(
                              File(image.path),
                              height: util.query.width / 2,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            child: Container(
                              child: Center(
                                child: Image.asset(
                                  'assets/images/loading.gif',
                                  width: 30,
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    : SizedBox(),
            if (data?.contentMsg?.isNotEmpty ?? false)
              Txt(
                data?.contentMsg ?? "",
                style: TxtStyle()
                  ..padding(all: 5, horizontal: 10)
                  ..textAlign.left()
                  ..width(util.query.width - 130)
                  ..fontSize(Style.subTextSize)
                  ..textColor(OCSColor.text.withOpacity(0.7)),
              ),
          ],
        ),
      ),
      type == "sender"
          ? buildTimeRight(util, data: data)
          : buildTimeLeft(util, data: data)
    ],
  );
}

Widget buildTimeRight(OCSUtilities util, {MMessageData? data}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Txt(
        OCSUtil.dateFormat("${data?.createdDate}".split("+")[0],
                format: "hh:mm a", langCode: Globals.langCode) +
            " ${data?.updatedBy?.isNotEmpty ?? false ? util.language.key('edited') : ""}",
        style: TxtStyle()
          ..fontSize(11)
          ..padding(right: 5)
          ..textColor(OCSColor.text.withOpacity(0.5)),
      ),
      if ((data?.completed == false))
        Parent(
          style: ParentStyle()
            ..width(8)
            ..height(8)
            ..margin(right: 5)
            ..borderRadius(all: 10)
            ..border(all: 1, color: Colors.blue),
        ),
      if ((data?.completed ?? false))
        Parent(
          style: ParentStyle()..margin(right: 5),
          child: Icon(
            data?.status == "U" ? Remix.check_line : Remix.check_double_line,
            size: 14,
            color: Colors.blue,
          ),
        ),
    ],
  );
}

Widget buildTimeLeft(OCSUtilities util, {MMessageData? data}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      if ((data?.completed == false))
        Parent(
          style: ParentStyle()
            ..width(8)
            ..height(8)
            ..margin(left: 5)
            ..borderRadius(all: 10)
            ..border(all: 1, color: Colors.blue),
        ),
      Txt(
        ((data?.updatedBy?.isNotEmpty ?? false) && data?.contentType != "A"
                ? util.language.key('edited') + " "
                : "") +
            OCSUtil.dateFormat("${data?.createdDate}".split("+")[0],
                format: "hh:mm a", langCode: Globals.langCode),
        style: TxtStyle()
          ..fontSize(11)
          ..padding(right: 5)
          ..textColor(OCSColor.text.withOpacity(0.5)),
      ),
    ],
  );
}

Widget buildMessageAction(OCSUtilities _util,
    {MMessageData? data,
    required Function onTapUpdateMessage,
    required Function onTabDelete}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Parent(
        style: ParentStyle()
          ..background.color(Colors.white)
          ..padding(all: 10, top: 5)
          ..borderRadius(all: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Txt(
              _util.language.key('message'),
              style: TxtStyle()
                ..fontSize(16)
                ..textColor(Colors.black87),
            ),
            SizedBox(height: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (data?.sender == Model.userInfo.loginName &&
                    data?.contentType != "A")
                  buildActionModal(
                    icon: Icons.edit,
                    onPress: onTapUpdateMessage,
                    color: Colors.blue,
                    title: _util.language.key("update"),
                  ),
                buildActionModal(
                  icon: Remix.delete_bin_2_line,
                  onPress: onTabDelete,
                  color: Colors.red,
                  title: _util.language.key("delete"),
                ),
              ],
            ),
            SizedBox(height: _util.query.bottom + 5),
          ],
        ),
      ),
    ],
  );
}

class MessageIcon extends StatefulWidget {
  final int? receiverId;
  final String? receiverImage;
  final String? receiverName;
  final int? requestId;
  final String? requestStatus;

  const MessageIcon({
    Key? key,
    this.receiverId,
    this.receiverImage,
    this.receiverName,
    this.requestId,
    this.requestStatus = '',
  }) : super(key: key);

  @override
  State<MessageIcon> createState() => _MessageIconState();
}

class _MessageIconState extends State<MessageIcon> {
  late var _util = OCSUtil.of(context);

  @override
  void initState() {
    super.initState();
    context.read<CountMessageCubit>().fetchCountMessage(widget.requestId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CountMessageCubit, CountMessageState>(
      builder: (context, s) {
        if (s is CountMessageSuccess) {
          return Stack(
            children: [
              Center(
                child: IconButton(
                  onPressed: () {
                    _util.to(
                      MessageDetail(
                        receiverImage: widget.receiverImage,
                        receiverName: widget.receiverName,
                        receiverId: widget.receiverId,
                        requestId: widget.requestId,
                        requestStatus: widget.requestStatus,
                      ),
                      transition: OCSTransitions.LEFT,
                    );
                  },
                  icon: Icon(
                    Icons.message,
                    size: 24,
                  ),
                ),
              ),
              s.data == 0
                  ? SizedBox()
                  : s.requestId == widget.requestId
                      ? Positioned(
                          right: 6,
                          top: 6,
                          child: IgnorePointer(
                            child: Txt(
                              (s.data ?? 0) > 99 ? "+99" : "${s.data}",
                              style: TxtStyle()
                                ..fontSize(10)
                                ..padding(all: 2)
                                ..minWidth(23)
                                ..height(23)
                                ..textAlign.center()
                                ..fontWeight(FontWeight.w600)
                                ..textColor(Colors.white)
                                ..background.color(Colors.red)
                                ..borderRadius(all: 100)
                                ..border(all: 1, color: OCSColor.border),
                            ),
                          ))
                      : SizedBox(),
            ],
          );
        }

        return Stack(
          children: [
            Center(
              child: IconButton(
                onPressed: () {
                  Globals.inMessagePage = true;
                  _util.to(
                      MessageDetail(
                        receiverImage: widget.receiverImage,
                        receiverName: widget.receiverName,
                        receiverId: widget.receiverId,
                        requestId: widget.requestId,
                        requestStatus: widget.requestStatus,
                      ),
                      transition: OCSTransitions.LEFT);
                },
                icon: Icon(
                  Icons.message,
                  size: 24,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
