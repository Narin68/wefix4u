import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import '/screens/widget.dart';

class PromoCode extends StatefulWidget {
  const PromoCode({Key? key}) : super(key: key);

  @override
  State<PromoCode> createState() => _PromoCodeState();
}

class _PromoCodeState extends State<PromoCode> {
  late var _util = OCSUtil.of(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        leading: NavigatorBackButton(),
        title: Text(
          "Promo code",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
      body: Container(
        height: _util.query.height,
        child: Stack(
          children: [
            Parent(
              style: ParentStyle()..height(_util.query.height),
              child: ListView.builder(
                itemCount: 5,
                shrinkWrap: true,
                padding: EdgeInsets.all(15),
                itemBuilder: (_, i) {
                  return Parent(
                    style: ParentStyle()
                      ..padding(all: 15)
                      ..background.color(Colors.white)
                      ..borderRadius(all: 5)
                      ..margin(bottom: 10),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Icon(Remix.coupon_4_line,
                                //     color: OCSColor.primary, size: 20),
                                // SizedBox(width: 10),
                                Txt(
                                  "\$20",
                                  style: TxtStyle()
                                    ..fontSize(14)
                                    ..bold(),
                                ),
                              ],
                            ),
                            Txt(
                              "Expire date : 12 JUN 2022",
                              style: TxtStyle()
                                ..fontSize(12)
                                ..textColor(OCSColor.text.withOpacity(0.7)),
                            )
                          ],
                        ),
                        Expanded(child: SizedBox()),
                        Image.network(
                          'https://cdn-icons-png.flaticon.com/512/7446/7446899.png',
                          width: 40,
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 15 + _util.query.bottom,
              child: Parent(
                style: ParentStyle()
                  ..width(_util.query.width)
                  ..padding(horizontal: 15),
                child: BuildButton(
                  iconData: Icons.add,
                  width: _util.query.width,
                  title: "Add new Promo code",
                  // fontSize: 16,
                  // height: 45,
                  onPress: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
