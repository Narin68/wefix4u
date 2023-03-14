import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '/globals.dart';
import '/modals/service.dart';

class ViewServiceDetail extends StatefulWidget {
  final MService? data;

  ViewServiceDetail({this.data});

  @override
  State<ViewServiceDetail> createState() => _ViewServiceDetailState();
}

class _ViewServiceDetailState extends State<ViewServiceDetail> {
  late final _util = OCSUtil.of(context);
  MService data = MService();

  @override
  void initState() {
    super.initState();
    data = widget.data!;
  }

  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        // iphone
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                leading: IconButton(
                  icon: Icon(
                    Remix.close_line,
                    size: 25,
                    color: OCSColor.text,
                  ),
                  tooltip: _util.language.key('close'),
                  onPressed: () {
                    _util.navigator.pop();
                  },
                ),
                pinned: false,
                elevation: 0,
                iconTheme: IconThemeData(color: OCSColor.text),
                actionsIconTheme: IconThemeData(color: OCSColor.text),
                backgroundColor: OCSColor.white,
                collapsedHeight: _util.query.height / 4,
                flexibleSpace: Stack(
                  children: [
                    Parent(
                      style: ParentStyle()
                        ..background.color(Colors.white)
                        ..opacity(1)
                        ..width(_util.query.width)
                        ..borderRadius(all: 10)
                        // todo: change padding
                        ..padding(all: Globals.paddingImage + 20)
                        ..borderRadius(bottomRight: 5, bottomLeft: 5)
                        ..overflow.hidden(),
                      child: widget.data?.imagePath != null
                          ? Hero(
                              tag: "service",
                              child: FadeInImage.assetNetwork(
                                placeholder: '',
                                image:
                                    "${ApisString.webServer}/${widget.data?.imagePath!}",
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
                              ),
                            )
                          : Image.asset(
                              'assets/images/no-image.png',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Parent(
                  style: ParentStyle()
                    ..padding(all: 15)
                    ..background.color(Colors.white)
                    ..elevation(1, opacity: 0.5)
                    ..margin(all: 10)
                    ..borderRadius(all: 5)
                    ..width(_util.query.width),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Txt(
                        _util.language.by(
                            km: data.name,
                            en: data.nameEnglish,
                            autoFill: true),
                        style: TxtStyle()
                          ..fontSize(Style.titleSize)
                          ..width(_util.query.width - 40)
                          ..fontWeight(FontWeight.bold)
                          ..textColor(OCSColor.text),
                      ),
                      // SizedBox(height: 5),
                      Txt(
                        "#" + data.code!,
                        style: TxtStyle()
                          ..fontSize(Style.subTitleSize)
                          ..textColor(OCSColor.text),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Txt(
                            _util.language.key('service-category') + " :",
                            style: TxtStyle()
                              ..fontSize(Style.subTitleSize)
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
                                ..fontSize(Style.subTitleSize)
                                ..textColor(OCSColor.text.withOpacity(0.8)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((data.description == '' ||
                                  data.description == null) &&
                              (data.descriptionEnglish == '' &&
                                  data.descriptionEnglish == null))
                            Txt(
                              _util.language.key('description'),
                              style: TxtStyle()..textColor(OCSColor.text),
                            ),
                          Txt(
                            _util.language.by(
                              km: data.description,
                              en: data.descriptionEnglish,
                              autoFill: true,
                            ),
                            style: TxtStyle()
                              ..fontSize(14)
                              ..textColor(OCSColor.text.withOpacity(0.8)),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
