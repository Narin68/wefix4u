import 'dart:async';
import 'package:dio/dio.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ocs_util/ocs_util.dart';
import '/functions.dart';
import '../service_request_widget.dart';
import '/modals/address.dart';
import '/blocs/partner/partner_cubit.dart';
import '/globals.dart';
import '/modals/partner.dart';
import '/screens/widget.dart';

class RequestPartnerInfo extends StatefulWidget {
  final MPartnerRequest partnerRequest;

  const RequestPartnerInfo({Key? key, required this.partnerRequest})
      : super(key: key);

  @override
  State<RequestPartnerInfo> createState() => _RequestPartnerInfoState();
}

class _RequestPartnerInfoState extends State<RequestPartnerInfo> {
  late final _util = OCSUtil.of(context);
  CameraPosition cameraPosition = CameraPosition(
    target: LatLng(11.561902228675693, 104.87935669720174),
    zoom: 18,
  );
  var dio = Dio();
  var txtTitleStyle = TxtStyle()
    ..fontSize(Style.subTitleSize)
    ..textColor(
      OCSColor.text.withOpacity(0.7),
    )
    ..width(80);
  var subtitleStyle = TxtStyle()
    ..fontSize(Style.subTitleSize)
    ..textColor(OCSColor.text.withOpacity(0.7));
  late var theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
  List<GlobalKey<ExpansionTileCardState>> _tileCardProvinces = [];
  List<GlobalKey<ExpansionTileCardState>> _tileCardDistricts = [];
  List<GlobalKey<ExpansionTileCardState>> _tileCardCommunes = [];
  List<MAddress> _provinces = [], _districts = [], _communes = [];

  MPartnerRequestDetail _detail = MPartnerRequestDetail();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future _initData() async {
    setState(() {
      _loading = true;
    });
    await Future.delayed(Duration(milliseconds: 100));
    context.read<PartnerCubit>().getPartnerRequestDetail(widget.partnerRequest);
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: OCSColor.primary,
        title: Txt(
          _util.language.key('request-partner'),
          style: TxtStyle()
            ..fontSize(16)
            ..textColor(Colors.white),
        ),
        leading: NavigatorBackButton(),
      ),
      body: SafeArea(
        bottom: false,
        child: Parent(
          style: ParentStyle()..height(_util.query.height),
          child: _loading
              ? Center(
                  child: CircularProgressIndicator.adaptive(),
                )
              : SingleChildScrollView(
                  child: BlocConsumer<PartnerCubit, PartnerState>(
                    listener: (context, state) {
                      if (state is PartnerSuccess) {
                        _initCoverage(state.detail!);
                        _detail = state.detail!;
                        setState(() {});
                      }
                    },
                    builder: (context, state) {
                      if (state is PartnerInitial) {
                        return Parent(
                          style: ParentStyle()
                            ..width(_util.query.width)
                            ..height(_util.query.height)
                            ..alignmentContent.center(),
                          child: Center(
                            child: CircularProgressIndicator.adaptive(),
                          ),
                        );
                      }
                      if (state is PartnerLoading) {
                        return Parent(
                          style: ParentStyle()
                            ..width(_util.query.width)
                            ..height(_util.query.height - 100)
                            ..alignmentContent.center(),
                          child: Center(
                            child: CircularProgressIndicator.adaptive(),
                          ),
                        );
                      }
                      if (state is PartnerSuccess) {
                        if ((state.data?.isEmpty ?? true) || state.data == null)
                          return SizedBox();
                        return Parent(
                          style: ParentStyle()..padding(all: 15, top: 0),
                          child: Column(
                            children: [
                              SizedBox(height: 15),
                              _header(state.data![0]),
                              SizedBox(height: 15),
                              _imageSection(state.detail),
                              SizedBox(height: 15),
                              _businessSection(state.data![0]),
                              SizedBox(height: 15),
                              _locationSection(state.detail, state.data![0]),
                              SizedBox(height: 15),
                              _coverageSection(),
                              SizedBox(height: 15),
                              _mapSection(state.detail),
                              SizedBox(height: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Txt(
                                    _util.language.key("service"),
                                    style: TxtStyle()
                                      ..textColor(
                                          OCSColor.text.withOpacity(0.7))
                                      ..fontSize(Style.subTitleSize),
                                  ),
                                  BuildServiceBox(
                                    list: state.detail?.services ?? [],
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              _filesSection(state.detail),
                              SizedBox(height: _util.query.bottom),
                            ],
                          ),
                        );
                      }
                      return SizedBox();
                    },
                  ),
                ),
        ),
      ),
    );
  }

  Widget _header(MPartnerRequest? data) {
    return Row(
      children: [
        Txt(
          _util.language.key('request-partner-info'),
          style: TxtStyle()
            ..textColor(OCSColor.text)
            ..fontSize(14),
        ),
        Expanded(
          child: SizedBox(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.circle_outlined,
                color: data!.status!.toLowerCase() == "pending"
                    ? Colors.orange
                    : data.status!.toLowerCase() == "rejected"
                        ? Colors.red
                        : Colors.green,
                size: 12),
            SizedBox(width: 5),
            Txt(
              data.status ?? "",
              style: TxtStyle()
                ..fontSize(13)
                ..textColor(
                  data.status!.toLowerCase() == "pending"
                      ? Colors.orange
                      : data.status!.toLowerCase() == "rejected"
                          ? Colors.red
                          : Colors.green,
                ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _imageSection(MPartnerRequestDetail? data) {
    return Parent(
      style: ParentStyle(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Txt(
                  _util.language.key('profile-image'),
                  style: TxtStyle()
                    ..fontSize(Style.subTitleSize)
                    ..textColor(OCSColor.text.withOpacity(0.7)),
                ),
                SizedBox(height: 5),
                Parent(
                  gesture: Gestures()
                    ..onTap(() async {
                      _util.navigator.to(MyViewImage(
                        url: ApisString.webServer +
                            "/" +
                            data!.applicationFiles!.faceImagePath!,
                      ));
                    }),
                  style: ParentStyle()
                    ..height(150)
                    ..maxHeight(150)
                    ..boxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.07),
                      offset: Offset(0, 0),
                      blur: 2.0,
                      spread: 0.5,
                    )
                    ..margin(left: 2)
                    ..borderRadius(all: 5)
                    ..overflow.hidden()
                    ..minWidth(500)
                    ..background.color(Colors.white),
                  child: MyNetworkImage(
                    url: ApisString.webServer +
                        "/" +
                        data!.applicationFiles!.faceImagePath!,
                  ),
                )
              ],
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Txt(
                  _util.language.key('business-image'),
                  style: TxtStyle()
                    ..fontSize(Style.subTitleSize)
                    ..textColor(OCSColor.text.withOpacity(0.7)),
                ),
                SizedBox(height: 5),
                Parent(
                  gesture: Gestures()
                    ..onTap(() async {
                      _util.navigator.to(MyViewImage(
                        url: ApisString.webServer +
                            "/" +
                            data.applicationFiles!.placeImagePath!,
                      ));
                    }),
                  style: ParentStyle()
                    ..maxHeight(150)
                    ..height(150)
                    ..margin(right: 2)
                    ..boxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.07),
                      offset: Offset(0, 0),
                      blur: 2.0,
                      spread: 0.5,
                    )
                    ..borderRadius(all: 5)
                    ..overflow.hidden()
                    ..minWidth(500)
                    ..background.color(Colors.white),
                  child: MyNetworkImage(
                    url: ApisString.webServer +
                        "/" +
                        data.applicationFiles!.placeImagePath!,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future _initCoverage(MPartnerRequestDetail data) async {
    var _list = data.coverage ?? [];
    _tileCardProvinces = [];

    _provinces =
        _list.where((e) => e.type!.toLowerCase() == "provinces").toList();
    _districts =
        _list.where((e) => e.type!.toLowerCase() == "districts").toList();

    _communes =
        _list.where((e) => e.type!.toLowerCase() == "communes").toList();

    _provinces.forEach((e) {
      _tileCardProvinces.add(GlobalKey());
    });
    _districts.forEach((e) {
      _tileCardDistricts.add(GlobalKey());
    });
    _communes.forEach((e) {
      _tileCardCommunes.add(GlobalKey());
    });
    setState(() {});
  }

  Widget _coverageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Txt(
          _util.language.key("coverage"),
          style: TxtStyle()
            ..width(_util.query.width)
            ..textColor(OCSColor.text.withOpacity(0.7))
            ..fontSize(Style.subTitleSize),
        ),
        if (_provinces.isNotEmpty)
          Parent(
            gesture: Gestures()..onTap(() async {}),
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              primary: true,
              scrollDirection: Axis.vertical,
              itemCount: _provinces.length,
              itemBuilder: (_, i) {
                List<MAddress> districts = _districts
                    .where((e) => e.referenceId == _provinces[i].id)
                    .toList();
                return Parent(
                  style: ParentStyle(),
                  child: Theme(
                    data: theme,
                    child: ExpansionTileCard(
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      baseColor: Colors.white,
                      trailing: districts.isNotEmpty ? null : SizedBox(),
                      key: _tileCardProvinces[i],
                      title: Txt(
                        '${_util.language.by(km: _provinces[i].name, en: _provinces[i].nameEnglish, autoFill: true)}',
                        style: TxtStyle()..fontSize(13),
                      ),
                      children: [
                        _addressList(_provinces[i], _detail.coverage ?? []),
                      ],
                      onExpansionChanged: (bool expanded) async {
                        if (expanded) {
                          for (var j = 0; j < _tileCardProvinces.length; j++) {
                            if (j != i) {
                              _tileCardProvinces[j].currentState?.collapse();
                            }
                          }
                        }
                      },
                    ),
                  ),
                );
              },
            ),
            style: ParentStyle()
              ..width(_util.query.width)
              ..background.color(Colors.white)
              ..borderRadius(all: 5)
              ..padding(all: 10, horizontal: 0, vertical: 0)
              ..border(
                all: 1,
                color: OCSColor.border,
              )
              ..ripple(false),
          )
      ],
    );
  }

  Widget _addressList(MAddress address, List<MAddress> list) {
    List<MAddress> _list =
        list.where((e) => e.referenceId == address.id).toList();
    List<GlobalKey<ExpansionTileCardState>> _tileCards = [];

    switch (address.type?.toLowerCase()) {
      case "provinces":
        _tileCards = _tileCardDistricts;
        break;
      case "districts":
        _tileCards = _tileCardCommunes;
        break;
    }

    return Parent(
      style: ParentStyle()..margin(left: 20),
      child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          primary: true,
          shrinkWrap: true,
          itemCount: _list.length,
          itemBuilder: (_, i) {
            List<MAddress> child =
                list.where((e) => e.referenceId == _list[i].id).toList();
            return _list[i].type?.toLowerCase() == "villages"
                ? Txt(
                    '${_util.language.by(km: _list[i].name, en: _list[i].nameEnglish, autoFill: true)}',
                    style: TxtStyle()
                      ..width(150)
                      ..textOverflow(TextOverflow.ellipsis)
                      ..fontSize(13)
                      ..padding(all: 8)
                      ..textColor(OCSColor.text),
                  )
                : Parent(
                    style: ParentStyle()..width(150),
                    child: ExpansionTileCard(
                      trailing: child.isNotEmpty ? null : SizedBox(),
                      key: _tileCards[i],
                      title: Txt(
                        '${_util.language.by(km: _list[i].name, en: _list[i].nameEnglish, autoFill: true)}',
                        style: TxtStyle()
                          ..fontSize(13)
                          ..width(200)
                          ..textOverflow(TextOverflow.ellipsis)
                          ..textColor(OCSColor.text),
                      ),
                      children: [_addressList(_list[i], list)],
                      onExpansionChanged: (bool expanded) async {
                        if (expanded) {
                          if (expanded) {
                            for (var j = 0; j < _tileCards.length; j++) {
                              if (j != i) {
                                _tileCards[j].currentState?.collapse();
                              }
                            }
                          }
                        }
                      },
                    ),
                  );
          }),
    );
  }

  Widget _businessSection(MPartnerRequest? data) {
    String phone1 = data!.businessPhone1!;
    if (phone1.contains('0')) {
      if (phone1.indexOf('0') == 0) phone1 = phone1;
    } else
      phone1 = '0' + phone1;
    String phone2 = data.businessPhone2!;
    if (phone2.isNotEmpty) if (phone2.contains('0')) {
      if (phone2.indexOf('0') == 0) phone2 = phone2;
    } else
      phone2 = '0' + phone2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Txt(
          _util.language.key("business-info"),
          style: TxtStyle()
            ..textColor(OCSColor.text.withOpacity(0.7))
            ..fontSize(Style.subTitleSize),
        ),
        Parent(
          style: ParentStyle()
            ..width(_util.query.width)
            // ..height(125)
            ..background.color(Colors.white)
            ..boxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.02),
              offset: Offset(0, 0),
              blur: 3.0,
              spread: 0.5,
            )
            ..elevation(1, opacity: 0.2)
            ..borderRadius(all: 5)
            ..padding(all: 10, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Txt(
                _util.language
                    .by(
                        km: data.businessName,
                        en: data.businessNameEnglish,
                        autoFill: true)
                    .toUpperCase(),
                style: TxtStyle()
                  ..textColor(OCSColor.text)
                  ..fontSize(16)
                  ..width(_util.query.width - 35)
                  ..textOverflow(TextOverflow.ellipsis),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Txt(
                    "${_util.language.key('phone')} :",
                    style: txtTitleStyle,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Txt(
                      "${phone1} ${phone2}",
                      style: subtitleStyle,
                    ),
                  ),
                ],
              ),
              if (data.businessEmail?.isNotEmpty ?? false)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Txt(
                      "${_util.language.key('email')} :",
                      style: txtTitleStyle,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Txt(
                        "${data.businessEmail == null ? "N/A" : data.businessEmail}",
                        style: subtitleStyle,
                      ),
                    ),
                  ],
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Txt(
                    "${_util.language.key('experience')} :",
                    style: txtTitleStyle,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Txt(
                        "${data.workExperience} ${data.workExperience == 1 ? _util.language.key('year') : _util.language.key('years')}",
                        style: subtitleStyle),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _locationSection(
      MPartnerRequestDetail? detail, MPartnerRequest? data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Txt(
          _util.language.key("address"),
          style: TxtStyle()
            ..textColor(OCSColor.text.withOpacity(0.7))
            ..fontSize(Style.subTitleSize),
        ),
        Parent(
          style: ParentStyle()
            ..width(_util.query.width)
            ..background.color(Colors.teal.withOpacity(0.05))
            ..background.color(Colors.white)
            ..boxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.02),
              offset: Offset(0, 0),
              blur: 3.0,
              spread: 0.5,
            )
            ..elevation(1, opacity: 0.2)
            ..borderRadius(all: 5)
            ..padding(all: 10, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Txt(
                _util.language.by(
                    km: data!.businessAddress,
                    en: data.businessAddressEnglish,
                    autoFill: true),
                style: TxtStyle()..textColor(OCSColor.text),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mapSection(MPartnerRequestDetail? data) {
    var lat =
        data?.latLong?.substring(0, (data.latLong ?? "").indexOf(':')).trim();
    var long = data?.latLong
        ?.substring((data.latLong ?? "").indexOf(':'))
        .trim()
        .substring(2);
    return BuildGoogleMapView(
        lat: double.parse(lat ?? "0"), long: double.parse(long ?? "0"));
  }

  Widget _filesSection(MPartnerRequestDetail? data) {
    List<String>? _files = [];
    var file = data?.applicationFiles?.files;
    _files = _files + (file?.imagePathList ?? []);
    _files = _files + (file?.audioPathList ?? []);
    _files = _files + (file?.videoPathList ?? []);
    _files = _files + (file?.docPathList ?? []);
    if (_files.length < 1) return SizedBox();

    return Parent(
      style: ParentStyle()
        ..width(_util.query.width)
        ..background.color(Colors.white)
        ..elevation(1, opacity: 0.2)
        ..borderRadius(all: 5)
        ..padding(all: 10, horizontal: 10),
      child: GridView.builder(
        shrinkWrap: true,
        primary: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
        ),
        itemCount: _files.length,
        itemBuilder: (_, i) {
          var extension = (_files?[i] ?? "")
              .substring((_files?[i] ?? "").lastIndexOf('.') + 1);
          return Parent(
            gesture: Gestures()
              ..onTap(() async {
                if (extension.toLowerCase() == "jpg" ||
                    extension.toLowerCase() == "png" ||
                    extension.toLowerCase() == "jpeg") {
                  _util.navigator.to(MyViewImage(
                      url: ApisString.webServer + "/" + (_files?[i] ?? "")));
                } else {
                  await openFile(
                      ApisString.webServer + "/" + (_files?[i] ?? ''));
                }
              }),
            style: ParentStyle()
              ..width(50)
              ..margin(vertical: 5, horizontal: 5)
              ..height(40)
              ..elevation(1, opacity: 0.3)
              ..borderRadius(all: 5)
              ..padding(all: extension.toLowerCase() == "pdf" ? 10 : 0)
              ..background.color(Colors.white),
            child: extension.toLowerCase() == "jpg" ||
                    extension.toLowerCase() == "png" ||
                    extension.toLowerCase() == "jpeg"
                ? MyNetworkImage(
                    width: 50,
                    url: ApisString.webServer + "/" + (_files?[i] ?? ""),
                  )
                : extension.toLowerCase() == "doc" ||
                        extension.toLowerCase() == "docx"
                    ? Image.asset(
                        "assets/images/word-logo.png",
                        fit: BoxFit.cover,
                      )
                    : extension.toLowerCase() == "pdf"
                        ? Image.asset(
                            "assets/images/pdf-logo.png",
                            fit: BoxFit.cover,
                          )
                        : extension.toLowerCase() == "xls" ||
                                extension.toLowerCase() == "xlsx"
                            ? Image.asset(
                                "assets/images/excel-logo.png",
                                fit: BoxFit.cover,
                              )
                            : extension.toLowerCase() == "pptx" ||
                                    extension.toLowerCase() == "ppt"
                                ? Image.asset(
                                    "assets/image/powerpoint-logo.png",
                                    fit: BoxFit.cover,
                                  )
                                : SizedBox(),
          );
        },
      ),
    );
  }
}
