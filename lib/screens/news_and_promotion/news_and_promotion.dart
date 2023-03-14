import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:wefix4utoday/blocs/my_notification_count/my_notification_count_cubit.dart';
import '/blocs/user/user_cubit.dart';
import '/globals.dart';
import '/modals/news_and_promotion.dart';
import '/screens/widget.dart';

import '/blocs/news_and_promotion/news_and_promotion_cubit.dart';

class NewsAndPromotionsScreen extends StatefulWidget {
  @override
  _NewsAndPromotionsState createState() => _NewsAndPromotionsState();
}

class _NewsAndPromotionsState extends State<NewsAndPromotionsScreen> {
  late final _util = OCSUtil.of(context);
  final _controller = ScrollController();
  List<MNewsAndPromotion> _list = [];

  @override
  void initState() {
    super.initState();
    context.read<MyNotificationCountCubit>().resetNewsCount();
    context.read<NewsAndPromotionCubit>().fetch(isInit: false);
    _controller.addListener(_onScroll);
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
        backgroundColor: OCSColor.primary,
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<NewsAndPromotionCubit>().fetch(isInit: true);
          },
          child: BlocConsumer<NewsAndPromotionCubit, NewsAndPromotionState>(
            listener: (context, state) {
              if (state is NewsAndPromotionSuccess) {
                _list = state.data ?? [];
                setState(() {});
              }
            },
            builder: (_, s) {
              if (s is NewsAndPromotionLoading) {
                return Center(child: CircularProgressIndicator.adaptive());
              }
              if (s is NewsAndPromotionFailure) {
                return BuildErrorBloc(
                  message: s.message.toUpperCase(),
                  onRetry: () {
                    context.read<NewsAndPromotionCubit>().fetch(isInit: true);
                  },
                );
              }
              if (s is NewsAndPromotionSuccess) {
                List<MNewsAndPromotion> list = s.data ?? [];
                bool max = s.hasReachedMax ?? false;

                if (list.length == 0) {
                  return BuildNoDataScreen();
                }

                return ListView.builder(
                  physics: AlwaysScrollableScrollPhysics(),
                  controller: _controller,
                  padding: const EdgeInsets.all(15),
                  itemCount: list.length + (max ? 0 : 1),
                  itemBuilder: (_, i) {
                    if (i >= list.length) {
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: Center(
                            child: CircularProgressIndicator.adaptive(
                          backgroundColor: Colors.white,
                        )),
                      );
                    }

                    return PromotionCard(list[i]);
                  },
                );
              }
              if (_list.length < 1) return SizedBox();
              return ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                controller: _controller,
                padding: const EdgeInsets.all(16),
                itemCount: _list.length,
                itemBuilder: (_, i) {
                  return PromotionCard(_list[i]);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _onScroll() async {
    var max = _controller.position.maxScrollExtent;
    var pos = _controller.position.pixels;

    if (pos >= max) context.read<NewsAndPromotionCubit>().fetch();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class PromotionCard extends StatefulWidget {
  final MNewsAndPromotion data;

  PromotionCard(this.data);

  @override
  _PromotionCardState createState() => _PromotionCardState();
}

class _PromotionCardState extends State<PromotionCard> {
  late final _util = OCSUtil.of(context);
  late TxtStyle _dStyle, _style, _dTitleStyle, _titleStyle;
  bool _isExpanded = false;
  late MNewsAndPromotion data;

  @override
  void initState() {
    super.initState();
    data = widget.data;
    _dTitleStyle = TxtStyle()
      ..fontWeight(FontWeight.w600)
      ..textColor(OCSColor.text)
      ..fontSize(Style.titleSize);

    _dStyle = TxtStyle()
      ..textColor(OCSColor.text)
      ..fontSize(Style.subTitleSize)
      ..animate(500);

    _titleStyle = _dTitleStyle.clone()
      ..maxLines(2)
      ..textOverflow(TextOverflow.ellipsis);
    _style = _dStyle.clone()
      ..maxLines(3)
      ..textOverflow(TextOverflow.ellipsis);
  }

  @override
  Widget build(BuildContext context) {
    return Parent(
        style: ParentStyle()
          ..padding(all: 15)
          ..background.color(Colors.white)
          ..margin(bottom: 10)
          ..borderRadius(all: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data.image != null && (data.image?.isNotEmpty ?? false))
              Parent(
                style: ParentStyle()
                  ..margin(bottom: 10)
                  ..borderRadius(all: 3)
                  ..overflow.hidden()
                  ..minHeight(100)
                  ..width(_util.query.width),
                child: FadeInImage.assetNetwork(
                  fit: BoxFit.fitWidth,
                  placeholder: 'placeholder',
                  fadeInDuration: Duration(milliseconds: 1),
                  placeholderErrorBuilder: (_, a, b) {
                    return Parent(
                        style: ParentStyle()
                          ..width(_util.query.width)
                          ..background.color(OCSColor.background)
                          ..height(130),
                        child: Center(
                          child: Image.asset(
                            'assets/images/loading.gif',
                            width: 20,
                          ),
                        ));
                  },
                  imageErrorBuilder: (_, a, b) {
                    return Parent(
                      style: ParentStyle()
                        ..width(_util.query.width)
                        ..background.color(OCSColor.background)
                        ..height(130),
                      child: Icon(
                        Icons.image_not_supported_rounded,
                        size: 25,
                        color: OCSColor.text.withOpacity(0.4),
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
            Txt(data.title ?? '', style: _titleStyle),
            Txt(data.content ?? '', style: _style),
            Row(
              children: [
                Expanded(child: SizedBox()),
                IconButton(
                  onPressed: () async {
                    _isExpanded = !_isExpanded;
                    _titleStyle = !_isExpanded
                        ? (_dTitleStyle.clone()
                          ..maxLines(3)
                          ..textOverflow(TextOverflow.ellipsis))
                        : _dTitleStyle;

                    _style = !_isExpanded
                        ? (_dStyle.clone()
                          ..maxLines(3)
                          ..textOverflow(TextOverflow.ellipsis))
                        : _dStyle;

                    setState(() {});
                  },
                  icon: Icon(
                    !_isExpanded ? MdiIcons.chevronDown : MdiIcons.chevronUp,
                    color: OCSColor.icon,
                  ),
                ),
              ],
            )
          ],
        ));
  }
}
