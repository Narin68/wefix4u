import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:skeletons/skeletons.dart';
import '/modals/news_and_promotion.dart';
import '/globals.dart';
import '/repositories/news_and_promotion.dart';
import '../widget.dart';

class NewsDetail extends StatefulWidget {
  final int? id;

  const NewsDetail({Key? key, this.id}) : super(key: key);

  @override
  State<NewsDetail> createState() => _NewsDetailState();
}

class _NewsDetailState extends State<NewsDetail> {
  var _repo = NewsAndPromotionRepo();
  bool _loading = false;
  var _data = MNewsAndPromotion();
  late final _util = OCSUtil.of(context);
  late TxtStyle _dStyle, _style, _dTitleStyle, _titleStyle;

  @override
  void initState() {
    super.initState();
    _dTitleStyle = TxtStyle()
      ..fontWeight(FontWeight.w600)
      ..textColor(OCSColor.text)
      ..fontSize(Style.titleSize);

    _dStyle = TxtStyle()
      ..textColor(OCSColor.text)
      ..fontSize(Style.subTitleSize)
      ..animate(500);

    _titleStyle = _dTitleStyle.clone();
    _style = _dStyle.clone();
    _init();
  }

  void _init() async {
    setState(() {
      _loading = true;
    });
    var _res = await _repo.get(MNewsAndPromotionFilter(id: widget.id));

    if (!_res.error) {
      _data = _res.data[0];
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Txt(
          _util.language.key('news-and-promotions'),
          style: TxtStyle()
            ..fontSize(16)
            ..textColor(Colors.white),
        ),
        leading: NavigatorBackButton(),
      ),
      body: Container(
        child: _loading
            ? Center(
                child: CircularProgressIndicator.adaptive(),
              )
            : SingleChildScrollView(
                child: Parent(
                  style: ParentStyle()
                    ..padding(all: 15)
                    ..minHeight(MediaQuery.of(context).size.height - 100),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      _buildPromotionCard(_data),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildPromotionCard(MNewsAndPromotion data) {
    return Parent(
        style: ParentStyle()
          ..padding(all: 15, bottom: 0)
          // ..elevation(1, opacity: 0.2)
          ..background.color(Colors.white)
          // ..border(all: 1, color: OCSColor.border)
          ..margin(bottom: 10)
          ..borderRadius(all: 5)
        // ..overflow.hidden()
        ,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Parent(
              style: ParentStyle()
                ..margin(top: 6)
                ..borderRadius(all: 3)
                ..overflow.hidden()
                // ..background.color(OCSColor.border)
                ..minHeight(100)
                ..width(_util.query.width),
              child: FadeInImage.assetNetwork(
                fit: BoxFit.fitWidth,
                // height: _util.query.width / 2,
                placeholder: 'placeholder',
                fadeInDuration: Duration(milliseconds: 1),
                placeholderErrorBuilder: (_, a, b) {
                  return SkeletonLine(
                    style: SkeletonLineStyle(
                      // width: 74,
                      height: 130,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                },
                imageErrorBuilder: (_, a, b) {
                  return Parent(
                    style: ParentStyle()
                      ..padding(vertical: 15)
                      ..minHeight(140)
                      ..border(all: 1, color: Colors.black.withOpacity(0.05)),
                    child: Image.asset(
                      'assets/images/no-image.png',
                      fit: BoxFit.cover,
                      height: 60,
                    ),
                  );
                },
                image: data.image ?? "",
              ),
              gesture: Gestures()
                ..onTap(() {
                  if (data.image != null)
                    _util.navigator.to(MyViewImage(url: data.image ?? ""));
                }),
            ),
            SizedBox(
              height: 15,
            ),
            Txt(data.title ?? '', style: _titleStyle),
            Txt(data.content ?? '', style: _style),
            SizedBox(
              height: 15,
            )
          ],
        ));
  }
}
