import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '/screens/widget.dart';
import '/globals.dart';
import 'message_detail.dart';

class MessageList extends StatefulWidget {
  const MessageList({Key? key}) : super(key: key);

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  late var _util = OCSUtil.of(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: NavigatorBackButton(),
        title: Txt(
          "Messages",
          style: TxtStyle()
            ..fontSize(Style.titleSize)
            ..textColor(Colors.white),
        ),
      ),
      body: ListView.builder(
          itemCount: 15,
          padding: EdgeInsets.only(bottom: 10, top: 10),
          itemBuilder: (_, i) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Parent(
                gesture: Gestures()
                  ..onTap(() {
                    _util.navigator
                        .to(MessageDetail(), transition: OCSTransitions.UP);
                  }),
                style: ParentStyle()
                  ..ripple(true, splashColor: Colors.blue.withOpacity(0.1))
                  ..background.color(Colors.white)
                  ..borderRadius(all: 10)
                  ..padding(vertical: 10, horizontal: 10),
                child: Row(
                  children: [
                    Parent(
                      style: ParentStyle()
                        ..elevation(5, opacity: 0.2)
                        ..borderRadius(all: 50)
                        ..background.color(Colors.white)
                        ..overflow.hidden(),
                      child: Image.network(
                        i % 2 == 0
                            ? 'https://i.pinimg.com/736x/14/d9/0b/14d90b2543ed1041bbdbaf6bca3c3806--native-american-women-american-art.jpg'
                            : "https://images.unsplash.com/photo-1633332755192-727a05c4013d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8dXNlcnxlbnwwfHwwfHw%3D&w=1000&q=80",
                        height: 45,
                        width: 45,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Txt(
                            "Sreng rithea",
                            style: TxtStyle()
                              ..fontSize(14)
                              ..textColor(OCSColor.text),
                          ),
                          Txt(
                            (i % 2 == 0 ? "You : " : "") + "Hello brother",
                            style: TxtStyle()
                              ..fontSize(12)
                              ..maxLines(1)
                              ..textOverflow(TextOverflow.ellipsis)
                              ..textColor(
                                i % 2 == 0
                                    ? OCSColor.text.withOpacity(0.6)
                                    : Colors.blue,
                              ),
                          ),
                        ],
                      ),
                    ),
                    // Expanded(child: SizedBox()),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Txt(
                          OCSUtil.dateFormat(
                            DateTime.now(),
                            format: Format.time24,
                          ),
                          style: TxtStyle()
                            ..fontSize(12)
                            ..textColor(
                              OCSColor.text.withOpacity(0.6),
                            ),
                        ),
                        i % 2 == 0
                            ? Icon(
                                Remix.check_double_line,
                                color: Color.fromRGBO(46, 204, 113, 1),
                                size: 18,
                              )
                            : Parent(
                                style: ParentStyle()
                                  ..width(8)
                                  ..height(8)
                                  ..borderRadius(all: 10)
                                  ..background.color(Colors.blue),
                              )
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
