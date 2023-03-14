import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:ocs_auth/models/response.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '../../map_picker.dart';
import '/screens/service_request_widget.dart';
import '/blocs/service/service_bloc.dart';
import '/repositories/partner_repo.dart';
import '/screens/more/business_info/request_more_service.dart';
import '/screens/more/request_partner/select_coverage.dart';
import '/modals/address.dart';
import '/modals/service.dart';
import '/blocs/partner/partner_cubit.dart';
import '/screens/widget.dart';

import '/globals.dart';
import '/modals/partner.dart';
import 'business_request.dart';
import 'update_business_info.dart';

class BusinessInfo extends StatefulWidget {
  const BusinessInfo({Key? key}) : super(key: key);

  @override
  State<BusinessInfo> createState() => _BusinessInfoState();
}

class _BusinessInfoState extends State<BusinessInfo> {
  late var _util = OCSUtil.of(context);
  late var theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
  List<GlobalKey<ExpansionTileCardState>> _tileCardProvinces = [];
  List<GlobalKey<ExpansionTileCardState>> _tileCardDistricts = [];
  List<GlobalKey<ExpansionTileCardState>> _tileCardCommunes = [];
  List<MAddress> _provinces = [],
      _districts = [],
      _communes = [],
      _allAddress = [];
  var txtTitleStyle = TxtStyle()
    ..fontSize(Style.subTitleSize)
    ..textColor(
      OCSColor.text.withOpacity(0.7),
    )
    ..width(100);
  var subtitleStyle = TxtStyle()
    ..fontSize(Style.subTitleSize)
    ..textColor(OCSColor.text.withOpacity(0.9));

  List<MAddress> _rawAddress = [];
  List<MAddress> _checkedCoverage = [];
  List<MAddress> _oldCoverage = [];
  bool _loading = false;
  MPartnerRequestDetail _detail = MPartnerRequestDetail();
  PartnerRepo _repo = PartnerRepo();

  @override
  void initState() {
    super.initState();
    context.read<PartnerCubit>().getPartnerDetail();
    context.read<ServiceBloc>().add(InitService());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_loading) _util.navigator.pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: OCSColor.primary,
          title: Txt(
            _util.language.key('business-info'),
            style: TxtStyle()
              ..fontSize(Style.titleSize)
              ..textColor(Colors.white),
          ),
          leading: NavigatorBackButton(loading: _loading),
          actions: [
            IconButton(
              onPressed: () {
                _util.navigator
                    .to(BusinessRequest(), transition: OCSTransitions.LEFT);
              },
              icon: Icon(Remix.share_forward_2_line),
              tooltip: "Your request",
            ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Parent(
                style: ParentStyle()..padding(all: 0, vertical: 0),
                child: BlocConsumer<PartnerCubit, PartnerState>(
                  listener: (context, state) {
                    if (state is PartnerSuccess) {
                      _initCoverage(state.detail!);
                      _oldCoverage = state.detail?.coverage ?? [];
                      _detail = state.detail!;
                      setState(() {});
                    }
                  },
                  builder: (context, state) {
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
                    if (state is PartnerInitial) {
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
                      return SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Parent(
                          style: ParentStyle()..padding(all: 15, vertical: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 15),
                              _imageSection(state.detail),
                              SizedBox(height: 15),
                              _businessSection(
                                  state.partnerData!, state.detail!),
                              SizedBox(height: 15),
                              _locationSection(state.detail, state.partnerData),
                              SizedBox(height: 15),
                              _coverageSection(),
                              SizedBox(height: 15),
                              _servicesSection(state.detail?.services),
                              SizedBox(height: 30),
                            ],
                          ),
                        ),
                      );
                    }
                    if (state is PartnerFailure) {
                      return BuildErrorBloc(
                        message: state.message,
                        onRetry: () {
                          context.read<PartnerCubit>().getPartnerDetail();
                        },
                      );
                    }

                    return SizedBox();
                  },
                ),
              ),
              if (_loading)
                Positioned(
                  child: Container(
                    color: Colors.black.withOpacity(.1),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Future _initCoverage(MPartnerRequestDetail data) async {
    var _list = data.coverage;
    _allAddress = data.coverage ?? [];
    _tileCardProvinces = [];

    _provinces =
        _list!.where((e) => e.type!.toLowerCase() == "provinces").toList();
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

  Widget _businessSection(MPartner? data, MPartnerRequestDetail detail) {
    String phone1 = data?.businessPhone1 ?? "";
    if (phone1.contains('0')) {
      if (phone1.indexOf('0') == 0) phone1 = phone1;
    } else
      phone1 = '0' + phone1;
    String phone2 = data?.businessPhone2 ?? "";
    if (phone2.isNotEmpty) if (phone2.contains('0')) {
      if (phone2.indexOf('0') == 0) phone2 = ", " + phone2;
    } else
      phone2 = ", " + '0' + phone2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Txt(
              _util.language.key("business-info"),
              style: TxtStyle()
                ..padding(all: 5, left: 0)
                ..textColor(OCSColor.text.withOpacity(0.7))
                ..fontSize(Style.subTitleSize),
            ),
            Expanded(child: SizedBox()),
            Txt(
              _util.language.key('update'),
              style: TxtStyle()
                ..borderRadius(all: 3)
                ..padding(all: 5)
                ..fontSize(14)
                ..ripple(true)
                ..textColor(OCSColor.primary),
              gesture: Gestures()
                ..onTap(() {
                  _util.navigator.to(
                    UpdateBusinessInfo(
                      data: data?.copyWith(
                            applicationFiles: detail.applicationFiles,
                          ) ??
                          MPartner(),
                    ),
                    transition: OCSTransitions.LEFT,
                  );
                }),
            ),
          ],
        ),
        Parent(
          style: ParentStyle()
            ..width(_util.query.width)
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
                      km: data?.businessName,
                      en: data?.businessNameEnglish,
                      autoFill: true,
                    )
                    .toUpperCase(),
                style: TxtStyle()
                  ..textColor(OCSColor.text)
                  ..fontSize(Style.titleSize),
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
              if (data?.businessEmail?.isNotEmpty ?? false)
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
                        "${data?.businessEmail == null ? "" : data?.businessEmail}",
                        style: subtitleStyle,
                      ),
                    )
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
                        "${data?.workExperience} ${data?.workExperience == 1 ? _util.language.key('year') : _util.language.key('years')}",
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

  Widget _locationSection(MPartnerRequestDetail? detail, MPartner? data) {
    return Column(
      children: [
        Row(
          children: [
            Txt(
              _util.language.key("address"),
              style: TxtStyle()
                ..textColor(OCSColor.text.withOpacity(0.7))
                ..fontSize(Style.subTitleSize),
            ),
            Expanded(
              child: SizedBox(),
            ),
            Txt(
              _util.language.key('update'),
              style: TxtStyle()
                ..fontSize(Style.subTitleSize)
                ..ripple(true)
                ..borderRadius(all: 3)
                ..padding(all: 5)
                ..textColor(
                  OCSColor.primary,
                ),
              gesture: Gestures()
                ..onTap(() {
                  var lat = data?.latLong!
                      .substring(0, data.latLong!.indexOf(':'))
                      .trim();
                  var long = data?.latLong!
                      .substring(data.latLong!.indexOf(':'))
                      .trim()
                      .substring(2);
                  _util.navigator.to(
                    MyMapPicker(
                      lat: double.tryParse(lat!),
                      long: double.tryParse(long!),
                      onSubmit:
                          (String address, double lat, double long) async {
                        if ('$lat : $long' != data?.latLong) {
                          _onUpdate(
                            address: address,
                            lat: lat,
                            long: long,
                            data: data!,
                          );
                        }
                      },
                    ),
                  );
                }),
            ),
          ],
        ),
        Parent(
          style: ParentStyle()
            ..width(_util.query.width)
            ..background.color(Colors.teal.withOpacity(0.05))
            ..background.color(Colors.white)
            ..elevation(1, opacity: 0.2)
            ..borderRadius(all: 5)
            ..padding(all: 10, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Txt(
                data!.businessAddress ?? "",
                style: TxtStyle()..textColor(OCSColor.text),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future _onUpdate({
    required String address,
    required double lat,
    required double long,
    required MPartner data,
  }) async {
    setState(() {
      _loading = true;
    });
    var _res = await PartnerRepo().update(
      name: data.businessName ?? "",
      nameEnglish: data.businessNameEnglish ?? "",
      phone1: data.businessPhone1 ?? "",
      phone2: data.businessPhone2 ?? "",
      email: data.businessEmail ?? "",
      experience: data.workExperience!,
      latlong: "$lat : $long",
      address: address,
    );

    if (!_res.error) {
      Model.partner = MPartner.fromJson(_res.data);
      MPartnerRequestDetail detail = MPartnerRequestDetail.fromJson(_res.data);
      _util.snackBar(
        message: _util.language.key('success'),
        status: SnackBarStatus.success,
      );

      context
          .read<PartnerCubit>()
          .update(detail: detail, partner: Model.partner);
    } else {
      _util.snackBar(message: _res.message, status: SnackBarStatus.danger);
    }
    setState(() {
      _loading = false;
    });
  }

  Future _updateCovAndServ({
    List<int>? addedServices,
    List<int>? addedCoverages,
    List<int>? removedServices,
    List<int>? removedCoverages,
  }) async {
    setState(() {
      _loading = true;
    });
    MResponse _res = await _repo.updateCovAndServ(
      addedCoverages: addedCoverages,
      addedServices: addedServices,
      removedCoverages: removedCoverages,
      removedServices: removedServices,
    );
    if (!_res.error) {
      _util.snackBar(
          message: _util.language.key('success'),
          status: SnackBarStatus.success);
    } else {
      _util.snackBar(
        message: _res.message,
        status: SnackBarStatus.danger,
      );
    }
    setState(() {
      _loading = false;
    });
  }

  getAddress({MAddress? address, required List<MAddress> list}) {
    if (address == null) {
      _provinces.forEach((e) {
        list.add(e);
        return getAddress(address: e, list: list);
      });
      return getAddress(address: MAddress(), list: list);
    } else {
      List<MAddress> child =
          _allAddress.where((e) => e.referenceId == address.id).toList();
      if (child.isNotEmpty) {
        for (var i = 0; i < list.length; i++) {
          if (list[i].id == address.id) {
            list[i] = list[i].copyWith(someSelected: true);
          }
        }
        list.addAll(child);
        child.forEach((e) {
          return getAddress(address: e, list: list);
        });
      } else if (child.isEmpty) {
        for (var i = 0; i < list.length; i++) {
          if (list[i].id == address.id) {
            list[i] = list[i].copyWith(selected: true);
          }
        }
        if (address.id == null) return list;
      }
    }
  }

  get(int id, List<MAddress> list) {
    if (id == 0) {
      List<MAddress> province = _checkedCoverage
          .where((e) => e.type?.toLowerCase() == "provinces")
          .toList();
      province.forEach((e) {
        list.add(e);
        return get(e.id!, list);
      });
    }
    final has = _checkedCoverage.where((e) => e.referenceId == id).toList();
    if (has.isEmpty) {
      _checkedCoverage.forEach((e) {
        if (e.id == id) {
          if (e.selected == false && e.someSelected == true) {
            list.add(e);
          } else if (e.selected == true) {
            list.add(e);
          }
        }
      });
      return list.toSet().toList();
    }

    _checkedCoverage.forEach((e) {
      if (e.id == id) {
        if (e.selected == false && e.someSelected == true) {
          list.add(e);
          list.addAll(has.map((e) => e));
          has.forEach((e) {
            return get(e.id!, list);
          });
        } else if (e.selected == true) {
          list.add(e);
          return;
        }
      }
    });
  }

  Widget _coverageSection() {
    return Column(
      children: [
        Row(
          children: [
            Txt(
              _util.language.key("coverage"),
              style: TxtStyle()
                ..textColor(OCSColor.text.withOpacity(0.7))
                ..fontSize(Style.subTitleSize),
            ),
            Expanded(
              child: SizedBox(),
            ),
            Visibility(
              visible: true,
              child: Txt(
                _util.language.key('request-more'),
                style: TxtStyle()
                  ..fontSize(Style.subTitleSize)
                  ..ripple(true)
                  ..borderRadius(all: 3)
                  ..padding(all: 5)
                  ..textColor(
                    OCSColor.primary,
                  ),
                gesture: Gestures()
                  ..onTap(() {
                    _rawAddress = getAddress(address: null, list: []);
                    _util.navigator.to(
                      SelectCoverage(
                        checkedList: _rawAddress.toSet().toList(),
                        onSubmit: ({
                          List<MAddress>? checked,
                          List<MAddress>? listAddress,
                          List<int>? ids,
                        }) {
                          _onUpdateCoverages(checked ?? []);
                        },
                      ),
                      transition: OCSTransitions.LEFT,
                    );
                  }),
              ),
            )
          ],
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
                      baseColor: Colors.white,
                      trailing: districts.isNotEmpty ? null : SizedBox(),
                      key: _tileCardProvinces[i],
                      shadowColor: Colors.transparent,
                      title: Txt(
                        '${_util.language.by(km: _provinces[i].name, en: _provinces[i].nameEnglish, autoFill: true)}',
                        style: TxtStyle()..fontSize(Style.subTitleSize),
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
              ..elevation(1, opacity: 0.2)
              ..ripple(false),
          )
      ],
    );
  }

  Future _onUpdateCoverages(List<MAddress> list) async {
    List<MAddress> add = [];
    List<MAddress> remove = [];
    List<MAddress> oldData = [];
    _checkedCoverage = list;
    List<MAddress> raw = get(0, []);
    raw.forEach((e) {
      var has = _oldCoverage.any((el) => el.id == e.id);
      if (has == true)
        oldData.add(e);
      else if (has == false) add.add(e);
    });
    _oldCoverage.forEach((e) {
      var has = oldData.any((el) => e.id == el.id);
      if (has == false) remove.add(e);
    });
    List<int> removed = remove.map((e) => e.id!).toList();
    List<int> added = add.map((e) => e.id!).toList();
    await _updateCovAndServ(addedCoverages: added, removedCoverages: removed);
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
                    shadowColor: Colors.transparent,
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
        },
      ),
    );
  }

  Widget _servicesSection(List<MService>? services) {
    return Column(
      children: [
        Row(
          children: [
            Txt(
              _util.language.key("service"),
              style: TxtStyle()
                ..textColor(OCSColor.text.withOpacity(0.7))
                ..fontSize(Style.subTitleSize),
            ),
            Expanded(
              child: SizedBox(),
            ),
            Visibility(
              visible: true,
              child: Txt(
                _util.language.key('request-more'),
                style: TxtStyle()
                  ..fontSize(Style.subTitleSize)
                  ..ripple(true)
                  ..textColor(OCSColor.primary)
                  ..borderRadius(all: 3)
                  ..padding(all: 5),
                gesture: Gestures()
                  ..onTap(() {
                    context.read<ServiceBloc>()
                      ..add(MultiSelect(data: services ?? []))
                      ..add(ReloadData());
                    _util.navigator.to(
                      RequestMoreService(
                        services: services ?? [],
                        onSubmit: (added, removed) async {
                          _util.navigator.pop();
                          await _updateCovAndServ(
                              addedServices: added, removedServices: removed);
                        },
                      ),
                      transition: OCSTransitions.LEFT,
                    );
                  }),
              ),
            )
          ],
        ),
        BuildServiceBox(
          list: services ?? [],
        )
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
                    ..margin(left: 2)
                    ..borderRadius(all: 5)
                    ..overflow.hidden()
                    ..elevation(1, opacity: 0.2)
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
                    ..height(150)
                    ..maxHeight(150)
                    ..elevation(1, opacity: 0.2)
                    ..margin(right: 2)
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
}
