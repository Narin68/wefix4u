import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wefix4utoday/screens/select_service_widget.dart';
import '/modals/discount.dart';
import '/functions.dart';
import '../modals/customer_request_service.dart';
import '/screens/request_partner_info/view_service_detail.dart';
import '/screens/request_service/view_image.dart';
import '/screens/widget.dart';
import '../modals/service.dart';
import '/globals.dart';
import '../modals/quotation.dart';
import 'message/message_function.dart';
import 'package:audioplayers/audioplayers.dart';

Widget buildQuotTable({
  required MQuotationData quotation,
  required BuildContext context,
  MDiscountCode? promoDiscount,
  bool showFooter = true,
}) {
  List<MItemQuotation> _items = [];
  late var _util = OCSUtil.of(context);
  MQuotationData _quotation = quotation;
  double _discount = _quotation.discountAmount ?? 0;
  double _subTotal = _quotation.amount ?? 0;
  double _grandTotal = _quotation.total ?? 0;
  _quotation = quotation;
  _items = _items + (_quotation.items ?? []);
  double _discountCodeAmount = 0;
  double _discountCodePer = 0;
  return Parent(
    style: ParentStyle()
      ..background.color(Colors.white)
      ..overflow.hidden()
      // ..margin(bottom: 60)
      ..borderRadius(all: 5)
      ..elevation(1, opacity: 0.2)
      ..padding(bottom: !showFooter ? 5 : 15),
    child: Column(
      children: [
        Parent(
          style: ParentStyle()
            ..background.color(OCSColor.background)
            ..padding(all: 10, horizontal: 10),
          child: Row(
            children: [
              Txt(
                '${_util.language.key('item')}',
                style: TxtStyle()
                  ..textColor(OCSColor.black)
                  ..fontWeight(FontWeight.normal)
                  ..fontSize(Style.subTextSize),
              ),
              Expanded(child: SizedBox()),
              Txt(
                _util.language.key('discount'),
                style: TxtStyle()
                  ..textColor(OCSColor.black)
                  ..fontWeight(FontWeight.normal)
                  ..fontSize(Style.subTextSize)
                  ..alignmentContent.centerRight()
                  ..textAlign.right(),
              ),
              SizedBox(width: 15),
              Txt(
                _util.language.key('amount'),
                style: TxtStyle()
                  ..textColor(OCSColor.black)
                  ..fontWeight(FontWeight.normal)
                  ..fontSize(Style.subTextSize)
                  ..width(70)
                  ..alignmentContent.centerRight()
                  ..textAlign.right(),
              ),
            ],
          ),
        ),
        ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          shrinkWrap: true,
          itemCount: _items.length,
          primary: false,
          itemBuilder: (_, i) {
            return Column(
              children: [
                Row(
                  children: [
                    Column(
                      children: [
                        Txt(
                          _util.language.by(
                            km: _items[i].name,
                            en: _items[i].nameEnglish,
                            autoFill: true,
                          ),
                          style: TxtStyle()
                            ..fontSize(Style.subTextSize)
                            ..textColor(OCSColor.text)
                            ..textOverflow(TextOverflow.ellipsis)
                            ..maxLines(2)
                            ..width(_util.query.width / 2),
                        ),
                        Txt(
                          "${OCSUtil.currency(
                                (_items[i].cost ?? 0) / (_items[i].qty ?? 0),
                                autoDecimal: true,
                                sign: '\$',
                              )}" +
                              " × " +
                              OCSUtil.currency((_items[i].qty ?? 0),
                                  decimal: 0, sign: '') +
                              " ${_items[i].unitType ?? ""}",
                          style: TxtStyle()
                            ..fontSize(Style.subTextSize)
                            ..textColor(OCSColor.text.withOpacity(0.7)),
                        ),
                      ],
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                    Expanded(child: SizedBox()),
                    Txt(
                      (_items[i].discountAmount ?? 0) <= 0
                          ? ""
                          : OCSUtil.currency(
                              _items[i].discountAmount ?? 0,
                              autoDecimal: true,
                              sign: '\$',
                            ),
                      style: TxtStyle()
                        ..fontSize(Style.subTextSize)
                        ..textColor(OCSColor.text)
                        ..alignmentContent.centerRight()
                        ..textAlign.right(),
                    ),
                    SizedBox(width: 15),
                    Txt(
                      OCSUtil.currency((_items[i].total ?? 0),
                          autoDecimal: false, sign: '\$'),
                      style: TxtStyle()
                        ..fontSize(Style.subTextSize)
                        ..textColor(OCSColor.text)
                        ..width(70)
                        ..textAlign.right()
                        ..alignment.centerRight(),
                    ),
                  ],
                ),
                if (!showFooter) SizedBox(height: 5),
                if (showFooter) Divider(),
              ],
            );
          },
        ),
        if (showFooter)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: footerQuotation(
              context: context,
              subTotal: _subTotal,
              grandTotal: _grandTotal,
              totalDiscount: _discount,
              discountCodeAmount: _discountCodeAmount,
              discountCodePer: _discountCodePer,
              disCountPer: _quotation.discountPercent ?? 0,
              depositPercent: _quotation.depositPercent ?? 0,
              depositAmount: _quotation.depositAmount ?? 0,
              requireDeposit: _quotation.requireDeposit ?? false,
              balance: _quotation.balance ?? 0,
            ),
          ),
      ],
    ),
  );
}

Widget footerQuotation({
  required BuildContext context,
  double subTotal = 0,
  double grandTotal = 0,
  double totalDiscount = 0,
  double disCountPer = 0,
  double discountCodePer = 0,
  double discountCodeAmount = 0,
  double depositAmount = 0,
  double depositPercent = 0,
  bool requireDeposit = false,
  double balance = 0,
}) {
  late var _util = OCSUtil.of(context);
  totalDiscount += discountCodeAmount;

  String _disCountPer =
      "${(disCountPer + discountCodePer) > 0 ? "(${OCSUtil.currency(disCountPer + discountCodePer, autoDecimal: true, sign: "%", rightSign: true)})" : ""}";
  return Column(
    children: [
      Parent(
        style: ParentStyle()
          ..borderRadius(all: 5)
          ..padding(all: 10)
          ..background.color(OCSColor.background)
          ..borderRadius(all: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Parent(
                        style: ParentStyle()
                          ..padding(right: 30)
                          ..alignmentContent.centerRight(),
                        child: Txt(
                          _util.language.key('sub-total'),
                          style: TxtStyle()
                            ..textAlign.left()
                            ..fontSize(Style.subTitleSize)
                            ..textColor(OCSColor.text),
                        ),
                      ),
                      // SizedBox(width: 30),
                      Txt(
                        OCSUtil.currency(subTotal,
                            sign: "\$", autoDecimal: false),
                        style: TxtStyle()
                          ..textAlign.right()
                          ..fontSize(Style.subTitleSize)
                          ..minWidth(60)
                          ..maxWidth(100)
                          ..textColor(OCSColor.text),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Parent(
                        style: ParentStyle()..alignmentContent.centerRight(),
                        child: Txt(
                          _util.language.key('discount') + _disCountPer,
                          style: TxtStyle()
                            ..padding(right: 30)
                            ..textAlign.left()
                            ..bold()
                            ..fontSize(Style.subTitleSize)
                            ..textColor(OCSColor.text),
                        ),
                      ),
                      Txt(
                        OCSUtil.currency(
                          totalDiscount,
                          sign: "\$",
                          autoDecimal: false,
                        ),
                        style: TxtStyle()
                          ..textAlign.right()
                          ..fontSize(Style.subTitleSize)
                          ..minWidth(60)
                          ..maxWidth(100)
                          ..textColor(OCSColor.text),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Parent(
                        style: ParentStyle()..alignmentContent.centerRight(),
                        child: Txt(
                          _util.language.key('grand-total'),
                          style: TxtStyle()
                            ..padding(right: 30)
                            ..textAlign.left()
                            ..bold()
                            ..fontSize(Style.titleSize)
                            ..textColor(OCSColor.text),
                        ),
                      ),
                      Txt(
                        OCSUtil.currency(grandTotal - discountCodeAmount,
                            sign: "\$", autoDecimal: false),
                        style: TxtStyle()
                          ..textAlign.right()
                          ..fontSize(Style.titleSize)
                          ..minWidth(60)
                          ..bold()
                          ..maxWidth(100)
                          ..textColor(OCSColor.text),
                      ),
                    ],
                  ),
                  // SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
      if (requireDeposit)
        Parent(
          style: ParentStyle()
            ..borderRadius(all: 5)
            ..padding(all: 10)
            ..margin(top: 10)
            ..alignmentContent.centerRight()
            ..background.color(OCSColor.background)
            ..borderRadius(all: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (requireDeposit) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Parent(
                      style: ParentStyle()
                        ..padding(right: 30)
                        ..alignmentContent.centerRight(),
                      child: Txt(
                        _util.language.key('deposit') +
                            "${depositPercent > 0 ? "(${OCSUtil.currency(depositPercent, sign: "", autoDecimal: true)}%)" : ""}",
                        style: TxtStyle()
                          ..textAlign.left()
                          ..fontSize(Style.subTitleSize)
                          ..textColor(OCSColor.text),
                      ),
                    ),
                    // SizedBox(width: 30),
                    Txt(
                      OCSUtil.currency(depositAmount,
                          sign: "\$", autoDecimal: false),
                      style: TxtStyle()
                        ..textAlign.right()
                        ..fontSize(Style.subTitleSize)
                        ..minWidth(60)
                        ..maxWidth(100)
                        ..textColor(OCSColor.text),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Parent(
                      style: ParentStyle()
                        ..width(170)
                        ..padding(right: 30)
                        ..alignmentContent.centerRight(),
                      child: Txt(
                        _util.language.key('balances'),
                        style: TxtStyle()
                          ..textAlign.left()
                          ..fontSize(Style.subTitleSize)
                          ..textColor(OCSColor.text),
                      ),
                    ),
                    // SizedBox(width: 30),
                    Txt(
                      OCSUtil.currency(balance, sign: "\$", autoDecimal: false),
                      style: TxtStyle()
                        ..textAlign.right()
                        ..fontSize(Style.subTitleSize)
                        ..minWidth(60)
                        ..maxWidth(100)
                        ..textColor(OCSColor.text),
                    ),
                  ],
                ),
              ]
            ],
          ),
        ),
    ],
  );
}

class BuildGoogleMapView extends StatefulWidget {
  final double lat;
  final double long;

  const BuildGoogleMapView({Key? key, required this.long, required this.lat})
      : super(key: key);

  @override
  State<BuildGoogleMapView> createState() => _BuildGoogleMapViewState();
}

class _BuildGoogleMapViewState extends State<BuildGoogleMapView> {
  late final _util = OCSUtil.of(context);
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? _googleMapController;
  CameraPosition cameraPosition = CameraPosition(
    target: LatLng(11.561902228675693, 104.87935669720174),
    zoom: 18,
  );
  Set<Marker> markers = Set();

  void initState() {
    super.initState();
    cameraPosition = CameraPosition(
      target: LatLng(widget.lat, widget.long),
      zoom: 18,
    );
    setMarker();
  }

  setMarker() {
    var start = LatLng(widget.lat, widget.long);

    markers.add(
      Marker(
        markerId: MarkerId(start.toString()),
        position: start,
        infoWindow: InfoWindow(
          title: 'Starting Point ',
          snippet: 'Start Marker',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Txt(
          "${_util.language.key('request-location')}",
          style: TxtStyle()
            ..fontSize(Style.subTitleSize)
            ..textColor(OCSColor.text.withOpacity(0.7)),
        ),
        // SizedBox(height: 5),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Parent(
            style: ParentStyle()
              ..width(_util.query.width)
              ..height(200)
              ..background.color(Colors.white)
              ..boxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.02),
                offset: Offset(0, 0),
                blur: 3.0,
                spread: 0.5,
              )
              ..elevation(1, opacity: 0.5)
              ..overflow.hidden()
              ..padding(all: 1)
              ..borderRadius(all: 5),
            child: Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: cameraPosition,
                  compassEnabled: false,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    _googleMapController = controller;
                  },
                  onCameraMoveStarted: () {
                    // mapPickerController.mapMoving();
                  },
                  onCameraMove: (camera) {
                    this.cameraPosition = cameraPosition;
                  },
                  markers: markers,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Column(
                    children: [
                      Parent(
                        style: ParentStyle()
                          ..padding(horizontal: 10, vertical: 5)
                          ..background.color(Colors.white)
                          ..overflow.hidden()
                          ..ripple(true)
                          ..boxShadow(
                              color: Colors.black12,
                              offset: Offset(1, 1),
                              blur: 2)
                          ..alignmentContent.center()
                          ..borderRadius(topRight: 5),
                        child: Row(
                          children: [
                            Txt(
                              "Open Maps",
                              style: TxtStyle()
                                ..textColor(Colors.blue)
                                ..fontSize(14)
                                ..bold(),
                            ),
                            SizedBox(width: 5),
                            Image.asset(
                              'assets/images/google-maps.png',
                              width: 20,
                            )
                          ],
                        ),
                        gesture: Gestures()
                          ..onTap(() {
                            openMap(widget.lat, widget.long);
                          }),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 12,
                  child: Column(
                    children: [
                      Parent(
                        style: ParentStyle()
                          ..width(38)
                          ..height(30)
                          ..background.color(Colors.white.withOpacity(0.7))
                          ..borderRadius(topLeft: 2, topRight: 2),
                        child: Icon(
                          Remix.fullscreen_fill,
                          size: 20,
                          color: Colors.black54,
                        ),
                        gesture: Gestures()
                          ..onTap(() {
                            _util.navigator.to(MapFullScreen(
                                lat: widget.lat, long: widget.long));
                          }),
                      ),
                      Parent(
                        gesture: Gestures()
                          ..onTap(() {
                            var newLatLng = LatLng(widget.lat, widget.long);
                            _googleMapController!.animateCamera(
                                CameraUpdate.newCameraPosition(
                                    CameraPosition(target: newLatLng, zoom: 18)
                                    //17 is new zoom level
                                    ));
                            setState(() {});
                          }),
                        style: ParentStyle()
                          ..width(38)
                          ..height(30)
                          ..background.color(Colors.white.withOpacity(0.7))
                          ..borderRadius(bottomLeft: 2, bottomRight: 2),
                        child: Icon(
                          Remix.refresh_line,
                          size: 20,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      _util.snackBar(message: "Can't open Google Map!");
    }
  }
}

class BuildServiceBox extends StatefulWidget {
  final List<MService> list;

  const BuildServiceBox({Key? key, required this.list}) : super(key: key);

  @override
  State<BuildServiceBox> createState() => _BuildServiceBoxState();
}

class _BuildServiceBoxState extends State<BuildServiceBox> {
  late var _util = OCSUtil.of(context);
  List<MService> services = [];

  @override
  void initState() {
    super.initState();
    services = widget.list;
  }

  @override
  Widget build(BuildContext context) {
    return Parent(
      style: ParentStyle()
        ..width(_util.query.width)
        ..background.color(Colors.white)
        ..borderRadius(all: 5)
        ..elevation(1, opacity: 0.2)
        ..padding(all: 15),
      child: AlignedGridView.count(
        primary: true,
        shrinkWrap: true,
        padding: EdgeInsets.all(0),
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        itemCount: services.length,
        itemBuilder: (_, i) {
          return Parent(
            gesture: Gestures()
              ..onTap(() {
                _util.navigator.to(ViewServiceDetail(data: services[i]),
                    transition: OCSTransitions.UP);
              }),
            style: ParentStyle(),
            child: Column(
              children: [
                Parent(
                  style: ParentStyle()
                    ..background.color(Colors.white)
                    ..elevation(1, opacity: 0.2)
                    ..borderRadius(all: 5),
                  child: services[i].imagePath == null
                      ? Image.asset(
                          'assets/images/no-image.png',
                          fit: BoxFit.cover,
                        )
                      : Parent(
                          style: ParentStyle()
                            ..height(70)
                            ..padding(all: 10),
                          child: Hero(
                            tag: "service",
                            child: FadeInImage.assetNetwork(
                              placeholder: '',
                              image: ApisString.webServer +
                                  "/" +
                                  (services[i].imagePath ?? ""),
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
                          ),
                        ),
                ),
                SizedBox(height: 5),
                Txt(
                  _util.language.by(
                    km: services[i].name,
                    en: services[i].nameEnglish,
                    autoFill: true,
                  ),
                  style: TxtStyle()
                    ..fontSize(Style.subTextSize)
                    ..textAlign.center()
                    ..maxLines(2)
                    ..textColor(OCSColor.text.withOpacity(0.8))
                    ..textOverflow(TextOverflow.ellipsis),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Widget buildDescription({String? description, required BuildContext context}) {
  late var _util = OCSUtil.of(context);
  return description != null && description.isNotEmpty
      ? Parent(
          style: ParentStyle()
            ..width(_util.query.width)
            ..background.color(OCSColor.background)
            ..elevation(1, opacity: 0.2)
            ..borderRadius(all: 5)
            ..margin(bottom: 15)
            ..padding(all: 10, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Txt(
                _util.language.key('description'),
                style: TxtStyle()
                  ..fontSize(Style.subTitleSize)
                  ..textColor(
                    OCSColor.text.withOpacity(0.7),
                  ),
              ),
              Txt(
                description.trim(),
                style: TxtStyle()
                  ..fontSize(Style.subTextSize)
                  ..textColor(OCSColor.text.withOpacity(0.8)),
              ),
            ],
          ),
        )
      : SizedBox();
}

class BuildServiceSection extends StatefulWidget {
  final List<MService> list;

  const BuildServiceSection({Key? key, required this.list}) : super(key: key);

  @override
  State<BuildServiceSection> createState() => _BuildServiceSectionState();
}

class _BuildServiceSectionState extends State<BuildServiceSection> {
  late var _util = OCSUtil.of(context);
  List<MService> _list = [];

  @override
  void initState() {
    super.initState();
    _list = _list + widget.list;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Txt(
          "${_util.language.key('service')}",
          style: TxtStyle()
            ..fontSize(Style.subTitleSize)
            ..textColor(OCSColor.text.withOpacity(0.7)),
        ),
        Parent(
          style: ParentStyle()
            ..width(_util.query.width)
            ..background.color(Colors.white)
            ..alignmentContent.center(),
          child: AlignedGridView.count(
            padding: EdgeInsets.all(0),
            primary: true,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            itemCount: _list.length,
            itemBuilder: (_, i) {
              return Stack(
                children: [
                  Parent(
                    style: ParentStyle()
                      ..margin(all: 5)
                      ..padding(all: 10, horizontal: 0)
                      ..elevation(1, opacity: 0.3)
                      ..background.color(Colors.white)
                      ..alignmentContent.center()
                      ..borderRadius(all: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Parent(
                          style: ParentStyle()
                            ..borderRadius(all: 5)
                            // todo: change padding
                            ..alignmentContent.center(),
                          child: MyNetworkImage(
                            height: 60,
                            url: (_list[i].imagePath ?? ""),
                          ),
                        ),
                        SizedBox(height: 5),
                        Column(
                          children: [
                            Txt(
                              _util.language.by(
                                km: _list[i].name,
                                en: _list[i].nameEnglish,
                                autoFill: true,
                              ),
                              style: TxtStyle()
                                ..fontSize(Style.subTextSize)
                                // ..width(100)
                                ..textAlign.center()
                                ..padding(horizontal: 5)
                                ..textColor(OCSColor.text.withOpacity(0.8))
                                ..maxLines(2)
                                ..textOverflow(TextOverflow.ellipsis),
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.center,
                        ),
                      ],
                    ),
                    gesture: Gestures()
                      ..onTap(() {
                        serviceDetailDialog(context, data: _list[i]);
                      }),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

Widget buildImageSection(
    {List<String>? pathList, required BuildContext context}) {
  late var _util = OCSUtil.of(context);

  return pathList!.isNotEmpty
      ? Parent(
          style: ParentStyle(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Txt(
                _util.language.key('image'),
                style: TxtStyle()
                  ..fontSize(Style.subTitleSize)
                  ..margin(top: 15)
                  ..textColor(OCSColor.text.withOpacity(0.7)),
              ),
              Parent(
                style: ParentStyle()..height(90),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: pathList.length,
                  padding: EdgeInsets.only(left: 5, right: 5),
                  itemBuilder: (_, i) {
                    var paths = pathList
                        .map((e) => ApisString.webServer + "/" + e)
                        .toList();
                    return Parent(
                      gesture: Gestures()
                        ..onTap(() {
                          _util.navigator.to(ViewMultiImage(
                            paths: paths,
                            isXFile: false,
                            index: i,
                          ));
                        }),
                      style: ParentStyle()
                        ..width(120)
                        ..elevation(1, opacity: 0.2)
                        ..borderRadius(all: 5)
                        ..overflow.hidden()
                        ..background.color(Colors.grey.withOpacity(0.3))
                        ..margin(right: 10),
                      child: MyNetworkImage(
                        url: paths[i],
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        )
      : SizedBox();
}

Widget buildVoiceList(BuildContext context,
    {required List<int> audioDurations,
    double value = 0,
    required List<PlayerState> playerStates,
    required List<AudioPlayer> audioPlayers}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Txt(
        OCSUtil.of(context).language.key('voice'),
        style: TxtStyle()
          ..fontSize(14)
          ..margin(top: 15)
          ..textColor(OCSColor.text.withOpacity(0.7)),
      ),
      Parent(
        style: ParentStyle()..width(180),
        child: ListView.builder(
          shrinkWrap: true,
          primary: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (_, i) {
            return buildVoice(context,
                audioPlayer: audioPlayers[i],
                value: value,
                playerState: playerStates[i],
                audioDuration: audioDurations[i], onPlay: () {
              if (playerStates[i] != PlayerState.playing) {
                for (var i = 0; i < playerStates.length; i++) {
                  if (playerStates[i] == PlayerState.playing) {
                    stopAudio(audioPlayers[i]);
                  }
                }
              }
            });
          },
          itemCount: audioPlayers.length,
        ),
      ),
    ],
  );
}

Widget buildVoice(BuildContext context,
    {int audioDuration = 0,
    double? value = 0,
    PlayerState? playerState,
    required AudioPlayer audioPlayer,
    Function? onDelete,
    Function? onPlay}) {
  return Row(
    children: [
      Parent(
        style: ParentStyle()..width(180),
        child: Parent(
          style: ParentStyle()
            ..margin(bottom: 10)
            ..borderRadius(all: 20)
            ..overflow.hidden()
            ..background.color(Colors.blue),
          child: Stack(
            children: [
              LinearProgressIndicator(
                value: playerState == PlayerState.playing ? value : 0,
                backgroundColor: Colors.transparent,
                color: Colors.black12,
                minHeight: 30,
              ),
              Parent(
                gesture: Gestures()
                  ..onTap(() {
                    if (audioDuration <= 0) return;

                    if (onPlay != null) onPlay();

                    if (playerState != PlayerState.playing) {
                      playAudio(audioPlayer);
                      return;
                    }

                    if (playerState == PlayerState.playing) {
                      pauseAudio(audioPlayer);
                    } else {
                      playAudio(audioPlayer);
                    }
                  }),
                style: ParentStyle()
                  ..width(250)
                  ..height(30)
                  ..borderRadius(all: 20)
                  ..background.color(Colors.transparent),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 5),
                    Icon(
                      playerState == PlayerState.playing
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.white,
                        height: 2,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    (audioDuration > 0)
                        ? Txt(
                            getTimeString(audioDuration),
                            style: TxtStyle()
                              ..fontSize(11)
                              ..textColor(Colors.white),
                          )
                        : Parent(
                            style: ParentStyle()..margin(left: 5),
                            child: SizedBox(
                              child: CircularProgressIndicator(
                                  strokeWidth: 1, color: Colors.white),
                              width: 17,
                              height: 17,
                            ),
                          ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      if (onDelete != null) ...[
        Expanded(child: SizedBox()),
        Parent(
          style: ParentStyle()
            ..width(30)
            ..height(30)
            ..ripple(true)
            ..borderRadius(all: 30)
            ..boxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.09),
              offset: Offset(0, 0),
              blur: 3.0,
              spread: 0.5,
            )
            ..background.color(Colors.white),
          child: Icon(
            Remix.delete_bin_line,
            size: 18,
            color: Colors.red,
          ),
          gesture: Gestures()
            ..onTap(() {
              if (playerState == PlayerState.playing) return;
              onDelete();
            }),
        ),
      ]
    ],
  );
}

Widget buildVideoSection(
    {List<String>? pathList, required BuildContext context}) {
  // var url =
  //     "https://firebasestorage.googleapis.com/v0/b/wefix4utoday.appspot.com/o/SRQ_10062022679825_26?alt=media&token=780ef755-53f6-4a53-9ff9-7ef87b7371aa";
  late var _util = OCSUtil.of(context);
  if (pathList!.length <= 0) return SizedBox();
  return Parent(
    style: ParentStyle(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Txt(
          _util.language.key('video'),
          style: TxtStyle()
            ..fontSize(Style.subTitleSize)
            ..margin(top: 15)
            ..textColor(OCSColor.text.withOpacity(0.7)),
        ),
        Parent(
          style: ParentStyle()..padding(all: 5, top: 0),
          child: AlignedGridView.count(
            crossAxisCount: 4,
            primary: true,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: pathList.length,
            itemBuilder: (_, i) {
              return Parent(
                style: ParentStyle()..margin(right: 5),
                gesture: Gestures()
                  ..onTap(() {
                    _util.navigator.to(
                      MyVideoPlayer(
                        path: Globals.firebaseServer + pathList[i],
                        isNetwork: true,
                      ),
                      transition: OCSTransitions.UP,
                    );
                  }),
                child: Stack(
                  children: [
                    Center(
                      child: Parent(
                        style: ParentStyle()
                          ..height(80)
                          ..borderRadius(all: 5)
                          ..overflow.hidden(),
                        child: Image.asset(
                          'assets/images/video-background.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Parent(
                      style: ParentStyle()
                        ..height(80)
                        ..borderRadius(all: 5)
                        ..overflow.hidden()
                        ..background.blur(0.5),
                    ),
                    Parent(
                      style: ParentStyle()
                        ..height(80)
                        ..borderRadius(all: 5)
                        ..overflow.hidden(),
                      child: Center(
                        child: Parent(
                          style: ParentStyle()
                            ..padding(all: 10)
                            ..borderRadius(all: 50)
                            ..background.color(Colors.black45),
                          child: Icon(
                            Remix.play_line,
                            size: 25,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        )
      ],
    ),
  );
}

class MapFullScreen extends StatefulWidget {
  final double? lat;
  final double? long;
  final Function? onBack;

  MapFullScreen({this.lat, this.long, this.onBack});

  @override
  State<MapFullScreen> createState() => _MapFullScreenState();
}

class _MapFullScreenState extends State<MapFullScreen> {
  late final _util = OCSUtil.of(context);
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? _googleMapController;
  CameraPosition cameraPosition = CameraPosition(
    target: LatLng(11.561902228675693, 104.87935669720174),
    zoom: 18,
  );
  Set<Marker> markers = Set();

  void initState() {
    super.initState();
    cameraPosition = CameraPosition(
      target: LatLng(widget.lat!, widget.long!),
      zoom: 18,
    );
    setMarker();
  }

  setMarker() {
    var start = LatLng(widget.lat ?? 0, widget.long ?? 0);

    markers.add(
      Marker(
        markerId: MarkerId(start.toString()),
        position: start,
        infoWindow: InfoWindow(
          title: 'Starting Point ',
          snippet: 'Start Marker',
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        // iphone
        statusBarBrightness: Brightness.light,
      ),
      child: WillPopScope(
        onWillPop: () async {
          _util.navigator.pop();
          return false;
        },
        child: Scaffold(
          body: SafeArea(
            top: false,
            child: Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: cameraPosition,
                  compassEnabled: false,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    _googleMapController = controller;
                  },
                  onCameraMoveStarted: () {
                    // mapPickerController.mapMoving();
                  },
                  onCameraMove: (camera) {
                    this.cameraPosition = cameraPosition;
                  },
                  markers: markers,
                ),
                Positioned(
                  top: 10 + _util.query.top,
                  right: 12,
                  child: Column(
                    children: [
                      Parent(
                        style: ParentStyle()
                          ..width(38)
                          ..height(30)
                          ..background.color(Colors.white.withOpacity(0.7))
                          ..borderRadius(topLeft: 2, topRight: 2)
                          ..overflow.hidden(),
                        child: Icon(
                          Remix.fullscreen_exit_line,
                          size: 20,
                          color: Colors.black54,
                        ),
                        gesture: Gestures()
                          ..onTap(() {
                            _util.navigator.pop();
                          }),
                      ),
                      Parent(
                        gesture: Gestures()
                          ..onTap(() {
                            var newLatLng = LatLng(widget.lat!, widget.long!);
                            _googleMapController!.animateCamera(
                                CameraUpdate.newCameraPosition(CameraPosition(
                                    target: newLatLng, zoom: 18)));
                            setState(() {});
                          }),
                        style: ParentStyle()
                          ..width(38)
                          ..height(30)
                          ..background.color(Colors.white.withOpacity(0.7))
                          ..borderRadius(bottomLeft: 2, bottomRight: 2)
                          ..overflow.hidden(),
                        child: Icon(
                          Remix.refresh_line,
                          size: 20,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 10 + _util.query.top,
                  left: 12,
                  child: Parent(
                    gesture: Gestures()
                      ..onTap(() {
                        _util.navigator.pop();
                      }),
                    style: ParentStyle(),
                    child: Icon(
                      Remix.close_line,
                      size: 25,
                      color: OCSColor.text,
                    ),
                  ),
                ),
                Positioned(
                  bottom: _util.query.bottom,
                  left: 0,
                  child: Column(
                    children: [
                      Parent(
                        style: ParentStyle()
                          // ..width(70)
                          // ..height(30)
                          ..padding(horizontal: 10, vertical: 10)
                          ..background.color(Colors.white)
                          ..overflow.hidden()
                          ..ripple(true)
                          ..boxShadow(
                              color: Colors.black12,
                              offset: Offset(1, 1),
                              blur: 10)
                          ..alignmentContent.center()
                          ..borderRadius(topRight: 5)
                        // ..overflow.hidden()
                        ,
                        child: Row(
                          children: [
                            Txt(
                              "Open Maps",
                              style: TxtStyle()
                                ..textColor(Colors.blue)
                                ..fontSize(14)
                                ..bold(),
                            ),
                            SizedBox(width: 5),
                            Image.asset(
                              'assets/images/google-maps.png',
                              width: 20,
                            )
                          ],
                        ),
                        gesture: Gestures()
                          ..onTap(() {
                            openMap(widget.lat ?? 0, widget.long ?? 0);
                          }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      _util.snackBar(message: "Can't open Google Map!");
    }
  }
}

Widget buildServiceRequestInfo(BuildContext context,
    {required MRequestService header,
    required MServiceRequestDetail detail,
    String status = "",
    Color statusColor = Colors.orange}) {
  var txtTitleStyle = TxtStyle()
    ..fontSize(Style.subTextSize)
    ..textColor(
      OCSColor.text.withOpacity(0.7),
    )
    ..width(
        header.fixingDate != null && (header.fixingDate?.isNotEmpty ?? false)
            ? 120
            : 100);
  var subtitleStyle = TxtStyle()
    ..fontSize(Style.subTitleSize)
    ..textColor(OCSColor.text.withOpacity(0.9));
  String phone = showNumber(header.customerPhone);
  String contactPhone = showNumber(header.contactPhone);
  contactPhone = contactPhone.isNotEmpty ? ", " + contactPhone : contactPhone;

  String date = OCSUtil.dateFormat(DateTime.parse('${header.createdDate}'),
      format: Format.dateTime, langCode: Globals.langCode);

  late var _util = OCSUtil.of(context);
  String timeFormat = header.arrivalTime ?? '';
  if (header.status?.toLowerCase() == "heading" &&
      (header.arrivalTime?.isNotEmpty ?? false)) {
    timeFormat = OCSUtil.dateFormat(timeFormat, format: Format.time);
  }

  return Column(
    children: [
      Parent(
        style: ParentStyle()
          ..background.color(Colors.white)
          ..boxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: Offset(0, 1),
              blur: 1)
          ..borderRadius(all: 5)
          ..padding(all: 15, top: 10)
          ..width(_util.query.width),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Txt(
              "${_util.language.key("requester_info")}",
              style: TxtStyle()
                ..fontSize(14)
                ..textColor(OCSColor.text),
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Parent(
                  style: ParentStyle()
                    ..borderRadius(all: 60)
                    ..width(60)
                    ..overflow.hidden()
                    ..elevation(1, opacity: 0.2)
                    ..background.color(Colors.white)
                    ..height(60),
                  child: MyNetworkImage(
                    iconSize: 20,
                    url: header.customerImage ?? '',
                    defaultAssetImage: Globals.userAvatarImage,
                  ),
                ),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (detail.userDeleted ?? false)
                      Txt(
                        "${_util.language.by(km: "អ្នកប្រើប្រាស់ត្រូវបានលុបគណនី", en: "User has been deleted account", autoFill: true)}",
                        style: TxtStyle()
                          ..fontSize(12)
                          ..bold()
                          ..textColor(Colors.red),
                      ),
                    Txt(
                      "${_util.language.by(km: header.customerName, en: header.customerNameEnglish, autoFill: true).replaceAll('.', '')}",
                      style: TxtStyle()..fontSize(12),
                    ),
                    Txt(
                      "${phone}${contactPhone}",
                      style: TxtStyle()..fontSize(12),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
      SizedBox(height: 15),
      Parent(
        style: ParentStyle()
          ..width(_util.query.width)
          ..background.color(OCSColor.white)
          ..boxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: Offset(0, 1),
              blur: 1)
          ..borderRadius(all: 5)
          ..margin(bottom: 15)
          ..padding(all: 10, horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Txt(
              "${header.targetLocation}",
              style: TxtStyle()
                ..textColor(OCSColor.text)
                ..fontSize(Style.subTitleSize),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Txt(
                  "${_util.language.key("request-code")} :",
                  style: txtTitleStyle,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Txt(
                    "#${header.code ?? ""}",
                    style: subtitleStyle.clone()..fontWeight(FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Txt(
                  "${_util.language.key('request-date')} :",
                  style: txtTitleStyle,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Txt(
                    "${date}",
                    style: subtitleStyle,
                  ),
                ),
              ],
            ),
            if (header.fixingDate?.isNotEmpty ?? false)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Txt(
                    "${_util.language.key('fixing-time')} :",
                    style: txtTitleStyle,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Txt(
                      OCSUtil.dateFormat(header.fixingDate ?? "",
                          format: Format.dateTime),
                      style: subtitleStyle,
                    ),
                  ),
                ],
              ),
            if (header.status?.toLowerCase() == "heading" &&
                (header.arrivalTime?.isNotEmpty ?? false))
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Txt(
                    Globals.userType.toLowerCase() == 'partner'
                        ? _util.language.key('arrival-time') + " :"
                        : _util.language.key('arrival-times') + " :",
                    style: txtTitleStyle,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Txt(
                      timeFormat,
                      style: subtitleStyle,
                    ),
                  ),
                ],
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Txt(
                  "${_util.language.key('status')} :",
                  style: txtTitleStyle,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Txt(
                    _util.language.key(status),
                    style: TxtStyle()
                      ..borderRadius(all: 2)
                      ..borderRadius(all: 2)
                      ..fontWeight(FontWeight.w600)
                      ..textColor(statusColor)
                      ..fontSize(Style.subTitleSize)
                      ..textAlign.left(),
                  ),
                ),
              ],
            ),
            if (status == "rejected" &&
                (header.rejectedReason?.isNotEmpty ?? false))
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Txt(
                    "${_util.language.key('reject_reason')} :",
                    style: txtTitleStyle,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Txt(
                      header.rejectedReason ?? "",
                      style: subtitleStyle,
                    ),
                  ),
                ],
              ),
            if (header.desc?.isNotEmpty ?? false)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Txt(
                    "${_util.language.key('description')} :",
                    style: txtTitleStyle,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Txt(
                      "${header.desc?.trim()}",
                      style: TxtStyle()
                        ..textColor(OCSColor.text)
                        ..fontSize(14),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
      // SizedBox(height: 5),
      if ((header.partnerId == Model.partner.id) &&
          (header.lateReason != null &&
              (header.lateReason?.isNotEmpty ?? false))) ...[
        Parent(
          style: ParentStyle()
            ..background.color(Colors.white)
            ..boxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: Offset(0, 1),
                blur: 1)
            ..borderRadius(all: 5)
            ..padding(all: 15, top: 10)
            ..width(_util.query.width),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Txt(
                _util.language.key('late-reason') + " :",
                style: TxtStyle()
                  ..fontSize(Style.subTitleSize)
                  ..textColor(
                    OCSColor.text.withOpacity(0.7),
                  ),
              ),
              SizedBox(width: 10),
              Txt(
                header.lateReason ?? "",
                style: subtitleStyle,
              ),
            ],
          ),
        ),
        SizedBox(height: 15),
      ],
    ],
  );
}

Future modelGiveFeedBack(BuildContext context,
    {required Function(double rate, String description) onFeedBack,
    required Function() onSkip}) async {
  late var _util = OCSUtil.of(context);
  TextEditingController _txtComment = TextEditingController();
  double _rating = 0;
  bool _isRating = false;
  showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: AlertDialog(
          contentPadding: EdgeInsets.all(0),
          content: SingleChildScrollView(
            child: Parent(
              style: ParentStyle()
                ..width(350)
                ..overflow.hidden(),
              child: Column(
                children: [
                  Parent(
                    style: ParentStyle()
                      ..height(45)
                      ..borderRadius(all: 5)
                      ..alignmentContent.center()
                      ..background.color(Colors.white),
                    child: Txt(
                      _util.language.key('give-a-feedback-to-partner'),
                      style: TxtStyle()
                        ..textAlign.center()
                        ..fontSize(15)
                        ..textColor(OCSColor.text),
                    ),
                  ),
                  Parent(
                    style: ParentStyle()
                      ..padding(all: 15, bottom: 10)
                      ..background.color(OCSColor.background),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Txt(
                          _util.language
                              .key("how-was-the-quality-of-partner-service"),
                          style: TxtStyle()
                            ..fontSize(14)
                            ..textAlign.center()
                            ..textColor(OCSColor.text.withOpacity(0.7)),
                        ),
                        SizedBox(height: 15),
                        RatingBar.builder(
                          // unratedColor: Colors.red,
                          itemSize: 25,
                          initialRating: _rating,
                          minRating: 0,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          glowColor: Colors.orange,
                          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Colors.orange,
                          ),
                          onRatingUpdate: (rating) {
                            _rating = rating;
                            _isRating = true;
                          },
                        ),
                        SizedBox(height: 20),
                        MyTextArea(
                          controller: _txtComment,
                          placeHolder: _util.language.key('comment'),
                        ),
                        SizedBox(height: 20),
                        Parent(
                          style: ParentStyle()
                            ..alignment.center()
                            ..padding(
                              horizontal: 50,
                            )
                            ..width(_util.query.width),
                          child: BuildButton(
                            width: 50,
                            height: 40,
                            title: _util.language.key('rate'),
                            fontSize: 16,
                            onPress: () {
                              if (!_isRating) {
                                _util.snackBar(
                                    message:
                                        _util.language.key('please-rating'),
                                    status: SnackBarStatus.warning);
                                return;
                              }
                              onFeedBack(_rating, _txtComment.text);
                            },
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        TextButton(
                          onPressed: onSkip,
                          child: Txt(_util.language.key('skip'),
                              style: TxtStyle()
                                ..textColor(OCSColor.text.withOpacity(0.7))),
                        )
                      ],
                    ),
                  ),
                  Parent(
                    style: ParentStyle()
                      ..padding(all: 15)
                      ..borderRadius(all: 5)
                      ..alignmentContent.center()
                      ..background.color(Colors.white),
                    child: Txt(
                      _util.language.key('thank-you-for-using-our-service'),
                      style: TxtStyle()
                        ..textAlign.center()
                        ..fontSize(14)
                        ..textColor(OCSColor.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
