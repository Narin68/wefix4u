import 'dart:io';
import 'dart:typed_data';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ocs_auth/ocs_auth.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:open_file/open_file.dart';
import 'package:remixicon/remixicon.dart';
import '/functions.dart';
import '/screens/function_temp.dart';
import '/screens/map_picker.dart';
import '/screens/widget.dart';
import '/blocs/partner/partner_cubit.dart';
import '/blocs/service/service_bloc.dart';
import '/globals.dart';
import '/modals/address.dart';
import '/modals/apply_partner.dart';
import '/modals/file.dart';
import '/repositories/file_repo.dart';
import '/repositories/partner_repo.dart';
import 'select_coverage.dart';
import 'widget.dart';

class StepTwoForm extends StatefulWidget {
  @override
  _StepTwoFormState createState() => _StepTwoFormState();
}

class _StepTwoFormState extends State<StepTwoForm> {
  late final _util = OCSUtil.of(context);
  double _labelSize = Style.subTextSize;
  bool _loading = false;
  var _form = GlobalKey<FormState>();
  List<PlatformFile> _files = [];

  List<MAddress> _provinces = [], _districts = [], _communes = [];
  XFile? _image;

  PartnerRepo _repo = PartnerRepo();
  ServiceBloc _serviceBloc = ServiceBloc();
  String _audioType = "Audio";
  String _videoType = "Video";
  String _imageType = "Image";
  String _fileType = "Doc";
  String _errorCoverage = "";
  String _errorImage = "";
  String _errorPinMap = '';
  String _address = '';
  List<MFile> _mfile = [];
  late var theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
  double? _lat;
  List<GlobalKey<ExpansionTileCardState>> _tileCardProvinces = [];
  double? _lng;
  List<MAddress> _coverages = [];
  FileRepo _fileRepo = FileRepo();
  bool _loadingMap = false;
  List<GlobalKey<ExpansionTileCardState>> _tileCardDistricts = [];
  List<GlobalKey<ExpansionTileCardState>> _tileCardCommunes = [];
  List<int> _coverageIds = [];
  List<MAddress> _listAddress = [];

  @override
  void initState() {
    super.initState();
    _serviceBloc = BlocProvider.of<ServiceBloc>(context);
    _initData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _loading ? null : _util.navigator.pop();
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: OCSColor.primary,
          title: Txt(
            _util.language.key('business-info'),
            style: TxtStyle()
              ..textColor(Colors.white)
              ..fontSize(16),
          ),
          leading: NavigatorBackButton(),
        ),
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Parent(
                      style: ParentStyle()..padding(horizontal: 16),
                      child: Form(
                        key: _form,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            _businessImageSection(),
                            SizedBox(height: 15),
                            _pinMapSection(),
                            SizedBox(height: 15),
                            _coverageSection(),
                            SizedBox(height: 15),
                            _fileSection(),
                            SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              if (!_util.query.isKbPopup)
                Positioned(
                  bottom: _util.query.bottom <= 0 ? 15 : _util.query.bottom,
                  child: Parent(
                    style: ParentStyle()
                      ..alignment.center()
                      ..padding(
                        horizontal: 16,
                      )
                      ..width(_util.query.width),
                    child: BuildButton(
                      title: _util.language.key('apply'),
                      fontSize: 16,
                      onPress: () async {
                        await _onSubmit();
                      },
                    ),
                  ),
                ),
              if (_loading)
                Positioned(
                  child: Container(
                    color: Colors.black.withOpacity(.3),
                    child: const Center(
                      child: CircularProgressIndicator.adaptive(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                  ),
                ),
              if (_loadingMap)
                Positioned(
                  child: Container(
                    color: Colors.black.withOpacity(.3),
                    child: Center(
                      child: Parent(
                        style: ParentStyle()..height(60),
                        child: Lottie.asset('assets/gifs/loading-map.json'),
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

  Future _toPinMap(double? lat, double? lng) async {
    _util.navigator.to(
      MyMapPicker(
        lat: lat,
        long: lng,
        onSubmit: (address, lat, long) {
          ApplyPartnerDataModel.businessAddress = address;
          _address = address;
          ApplyPartnerDataModel.latLong = "$lat : $long";
          ApplyPartnerDataModel.lat = lat;
          ApplyPartnerDataModel.long = long;
          _lat = lat;
          _lng = long;
          _errorPinMap = '';
          setState(() {});
        },
      ),
      transition: OCSTransitions.LEFT,
    );
  }

  Future _initData() async {
    _files = ApplyPartnerDataModel.files;
    _image = ApplyPartnerDataModel.businessImage;
    _coverages = ApplyPartnerDataModel.checkedAddress;
    _address = ApplyPartnerDataModel.businessAddress;
    _lat = ApplyPartnerDataModel.lat;
    _lng = ApplyPartnerDataModel.long;
    _onDoneCoverage(
      checked: ApplyPartnerDataModel.checkedAddress,
      ids: ApplyPartnerDataModel.coverageIds,
    );
    _files.forEach((e) async {
      await _mappingFile(e);
    });
  }

  void _onDoneCoverage({
    List<MAddress>? checked,
    List<MAddress>? listAddress,
    List<int>? ids,
  }) {
    _coverages = checked ?? [];
    var _list = _coverages;
    _tileCardProvinces = [];
    _listAddress = listAddress ?? [];
    // _coverageIds = [];
    // _listAddress.forEach((e) {
    //   if (e.selected ?? false) {
    //     _coverageIds.add(e.id ?? 0);
    //   }
    // });

    _coverageIds = ids ?? [];
    // print(_coverageIds);
    ApplyPartnerDataModel.checkedAddress = checked ?? [];
    ApplyPartnerDataModel.coverageIds = _coverageIds;
    _provinces =
        _list.where((e) => e.type?.toLowerCase() == "provinces").toList();
    _districts =
        _list.where((e) => e.type?.toLowerCase() == "districts").toList();

    _communes =
        _list.where((e) => e.type?.toLowerCase() == "communes").toList();

    _provinces.forEach((e) {
      _tileCardProvinces.add(GlobalKey());
    });
    _districts.forEach((e) {
      _tileCardDistricts.add(GlobalKey());
    });
    _communes.forEach((e) {
      _tileCardCommunes.add(GlobalKey());
    });
    if (_provinces.isNotEmpty) _errorCoverage = "";
    setState(() {});
  }

  Future _onSubmit() async {
    bool isValid = _checkValidation();

    if (!isValid) return;
    setState(() {
      _loading = true;
    });

    List<int>? _serviceId = [];

    var state = _serviceBloc.state;
    if (state is ServiceSuccess)
      state.selectData!.map((e) => {_serviceId.add(e.id!)}).toList();
    MApplyPartner _model = MApplyPartner(
      id: 0,
      refId: Model.customer.id,
      refCode: Model.userInfo.loginName,
      code: Model.customer.code,
      status: "PENDING",
      workExperience:
          double.parse(ApplyPartnerDataModel.workExperience).round(),
      businessNameEnglish: ApplyPartnerDataModel.businessNameEng,
      businessName: ApplyPartnerDataModel.businessName,
      businessPhone1: ApplyPartnerDataModel.businessPhone1,
      businessPhone2: ApplyPartnerDataModel.businessPhone2,
      businessEmail: ApplyPartnerDataModel.businessEmail,
      businessAddress: ApplyPartnerDataModel.businessAddress,
      businessAddressEnglish: ApplyPartnerDataModel.businessAddress,
      coverageIds: _coverageIds,
      faceImage: await _covertFileToBytes(
          ApplyPartnerDataModel.profileImage?.path ?? ""),
      placeImage: await _covertFileToBytes(
          ApplyPartnerDataModel.businessImage?.path ?? ""),
      serviceIds: _serviceId,
      files: [],
      latLong: ApplyPartnerDataModel.latLong,
    );
    MResponse _response = await _repo.applyPartner(_model);
    if (!_response.error) {
      _navigator();
      await _uploadFiles(_response.data.id);
      await _deleteImages();
    } else {
      _util.snackBar(message: _response.message, status: SnackBarStatus.danger);
    }
    setState(() {
      _loading = false;
    });
  }

  Future _deleteImages() async {
    deleteFile(File(ApplyPartnerDataModel.profileImage?.path ?? ""));
    deleteFile(File(ApplyPartnerDataModel.businessImage?.path ?? ""));
  }

  bool _checkValidation() {
    bool _imageValid = true;
    bool _covValid = true;
    bool _pinValid = true;
    if (_image == null) {
      _imageValid = false;
      _errorImage = _util.language.key("this-field-is-required");
    } else {
      _imageValid = true;
      _errorImage = "";
    }
    if (_provinces.isEmpty) {
      _covValid = false;
      _errorCoverage = _util.language.key("this-field-is-required");
    } else {
      _covValid = true;
      _errorCoverage = "";
    }

    if (ApplyPartnerDataModel.latLong == '') {
      _pinValid = false;
      _errorPinMap = _util.language.key("this-field-is-required");
    } else {
      _pinValid = true;
      _errorPinMap = '';
    }
    if (!_imageValid || !_covValid || !_pinValid) {
      setState(() {});
      return false;
    }
    return true;
  }

  Future _navigator() async {
    context.read<PartnerCubit>().getPartnerRequest(Model.customer.id);

    _util.navigator.pop();
    _util.navigator.pop();
    _util.navigator.replace(BuildSuccessScreen(
      successTitle: _util.language.key('your-request-has-been-sent'),
    ));
  }

  Future _uploadFiles(refId) async {
    if (_mfile.isNotEmpty) {
      for (int i = 0; i < _mfile.length; i++) {
        _mfile[i] = _mfile[i].copyWith(refId: refId, refType: "PN_APPLY_FILES");
        var res = await _fileRepo.uploadFile(_mfile[i]);
        if (res.error) {
          _util.snackBar(message: res.message, status: SnackBarStatus.danger);
          break;
        }
      }
    }
  }

  Future<Uint8List> _covertFileToBytes(String path) async {
    var bytes = await new File(path).readAsBytes();
    return bytes;
  }

  String _getFileType(String ex) {
    if (ex == "m4a" || ex == "mp3" || ex == 'aac')
      return _audioType;
    else if (ex == "png" || ex == "jpeg" || ex == 'jpg')
      return _imageType;
    else if (ex == "mp4")
      return _videoType;
    else
      return _fileType;
  }

  Future _getImageByGallery() async {
    final XFile? image = await getImageByGallery();
    if (image != null) {
      _util.navigator.pop();
      _image = image;
      if (ApplyPartnerDataModel.businessImage != null)
        deleteFile(File(ApplyPartnerDataModel.businessImage!.path));
      ApplyPartnerDataModel.businessImage = _image;
      _errorImage = '';
    }
    setState(() {});
  }

  Future _getImageByTakeCamera() async {
    final XFile? image = await getImageByTakeCamera();
    if (image != null) {
      _util.navigator.pop();
      _image = image;
      _errorImage = '';
      if (ApplyPartnerDataModel.businessImage != null)
        deleteFile(File(ApplyPartnerDataModel.businessImage!.path));
      ApplyPartnerDataModel.businessImage = _image;
    }
    setState(() {});
  }

  Future _getFile() async {
    FilePickerResult? result = await getFile();
    if (result != null) {
      PlatformFile file = result.files.first;

      if (file.extension == "m4a" ||
          file.extension == "mp3" ||
          file.extension == 'aac') {
        return;
      }

      if (file.size <= 2000000) {
        _files.add(file);
        ApplyPartnerDataModel.files = _files;
        await _mappingFile(file);
      } else
        _util.snackBar(
            message: _util.language.key('file_must_be_smaller'),
            status: SnackBarStatus.warning);
      setState(() {});
    } else {
      setState(() {});
    }
  }

  Widget _businessImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Txt(
              _util.language.key("business-image"),
              style: TxtStyle()
                ..textColor(_errorImage == ''
                    ? OCSColor.text.withOpacity(0.7)
                    : Colors.red)
                ..fontSize(_labelSize),
            ),
            Txt(
              "*",
              style: TxtStyle()..textColor(Colors.red),
            )
          ],
        ),
        Parent(
          gesture: Gestures()
            ..onTap(() {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (BuildContext context) {
                  return _addImage();
                },
              );
            }),
          style: ParentStyle()
            ..width(150)
            ..boxShadow(
              color: Colors.black12,
              offset: Offset(0, 1),
              blur: 2.0,
            )
            ..height(_util.query.width / 3)
            // ..maxHeight(150)
            ..ripple(true)
            ..borderRadius(all: 5)
            ..border(
              all: 1,
              color: _errorImage == "" ? Colors.transparent : Colors.red,
            )
            ..background.color(OCSColor.white)
            ..alignmentContent.center(),
          child: _image == null
              ? Column(
                  children: [
                    Expanded(child: SizedBox()),
                    Icon(
                      Remix.image_add_line,
                      size: 20,
                      color: _errorImage == "" ? Colors.blue : Colors.red,
                    ),
                    Txt(
                      _util.language.key("add-image"),
                      style: TxtStyle()
                        ..textColor(
                            _errorImage == "" ? Colors.blue : Colors.red)
                        ..fontSize(Style.subTitleSize),
                    ),
                    Expanded(child: SizedBox()),
                  ],
                )
              : Parent(
                  gesture: Gestures()
                    ..onTap(() {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return _addImage();
                        },
                      );
                    }),
                  style: ParentStyle()
                    ..boxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.1),
                      offset: Offset(0, 1),
                      blur: 3.0,
                      spread: 0.5,
                    )
                    ..width(150)
                    ..background.color(Colors.white)
                    ..borderRadius(all: 5)
                    ..overflow.hidden(),
                  child: Image.file(
                    File(_image!.path),
                    fit: BoxFit.cover,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _pinMapSection() {
    return Column(
      children: [
        Row(
          children: [
            Txt(
              _util.language.key("pin-map"),
              style: TxtStyle()
                ..textColor(_errorPinMap == ''
                    ? OCSColor.text.withOpacity(0.7)
                    : Colors.red)
                ..fontSize(12),
            ),
            Txt(
              "*",
              style: TxtStyle()
                ..textColor(Colors.red.withOpacity(0.7))
                ..fontSize(12),
            )
          ],
        ),
        Parent(
          gesture: Gestures()
            ..onTap(() async {
              _toPinMap(_lat, _lng);
              // if (_lng != null) {
              //   _toPinMap(_lat, _lng);
              // } else {
              //   setState(() {
              //     _loadingMap = true;
              //   });
              //   Future.delayed(Duration(milliseconds: 500));
              //   var _location = await _getLocation();
              //   setState(() {
              //     _loadingMap = false;
              //   });
              //   _toPinMap(_location!.latitude!, _location.longitude!);
              // }
            }),
          child: Txt(
            _address.isNotEmpty
                ? _address
                : _util.language.key("select-location"),
            style: TxtStyle()
              ..fontSize(Style.subTitleSize)
              ..textOverflow(TextOverflow.ellipsis)
              ..textColor(
                _address.isNotEmpty
                    ? OCSColor.text
                    : OCSColor.text.withOpacity(0.5),
              ),
          ),
          style: ParentStyle()
            ..width(_util.query.width)
            ..background.color(Colors.white)
            ..borderRadius(all: 5)
            ..padding(all: 10, horizontal: 15)
            ..height(50)
            ..alignmentContent.centerLeft()
            ..border(
              all: 1,
              color: _errorPinMap != '' ? Colors.red : OCSColor.border,
            )
            ..ripple(true),
        ),
      ],
    );
  }

  Widget _coverageSection() {
    return Column(
      children: [
        Row(
          children: [
            Txt(
              _util.language.key("coverage"),
              style: TxtStyle()
                ..textColor(_errorCoverage == ""
                    ? OCSColor.text.withOpacity(0.7)
                    : Colors.red)
                ..fontSize(_labelSize),
            ),
            Txt(
              "*",
              style: TxtStyle()..textColor(Colors.red),
            ),
            Expanded(child: SizedBox()),
            if (_provinces.isNotEmpty)
              Txt(
                _util.language.key('update-coverage'),
                style: TxtStyle()
                  ..ripple(true)
                  ..fontSize(14)
                  ..borderRadius(all: 3)
                  ..padding(horizontal: 3)
                  ..textColor(OCSColor.primary),
                gesture: Gestures()
                  ..onTap(() {
                    _util.navigator.to(
                        SelectCoverage(
                          checkedList: _coverages,
                          listAddress: _listAddress,
                          onSubmit: _onDoneCoverage,
                        ),
                        transition: OCSTransitions.LEFT);
                  }),
              ),
            // IconButton(
            //   onPressed: () {
            //     _util.navigator.to(
            //         SelectCoverage(
            //           checkedList: _coverages,
            //           listAddress: _listAddress,
            //           onSubmit: _onDoneCoverage,
            //         ),
            //         transition: OCSTransitions.LEFT);
            //   },
            //   icon: Icon(
            //     Remix.pencil_line,
            //     size: 16,
            //     color: OCSColor.text,
            //   ),
            //   tooltip: _util.language.key("select-coverage"),
            // )
          ],
        ),
        if (_provinces.isEmpty)
          Parent(
            gesture: Gestures()
              ..onTap(() async {
                if (_provinces.isEmpty)
                  _util.navigator.to(
                      SelectCoverage(
                        listAddress: _listAddress,
                        checkedList: _coverages,
                        onSubmit: _onDoneCoverage,
                      ),
                      transition: OCSTransitions.LEFT);
              }),
            child: Txt(
              _util.language.key("select-coverage"),
              style: TxtStyle()
                ..fontSize(Style.subTitleSize)
                ..textColor(OCSColor.text.withOpacity(0.5)),
            ),
            style: ParentStyle()
              ..width(_util.query.width)
              ..background.color(Colors.white)
              ..borderRadius(all: 5)
              ..padding(all: 10, horizontal: 15)
              ..height(50)
              ..alignmentContent.centerLeft()
              ..border(
                all: 1,
                color: _errorCoverage == "" ? OCSColor.border : Colors.red,
              )
              ..ripple(true),
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
                return Parent(
                  style: ParentStyle()..width(150),
                  child: Theme(
                    data: theme,
                    child: ExpansionTileCard(
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      baseColor: Colors.white,
                      key: _tileCardProvinces[i],
                      trailing: _provinces[i].selected == true
                          ? SizedBox.shrink()
                          : null,
                      title: Txt(
                        '${_util.language.by(km: _provinces[i].name, en: _provinces[i].nameEnglish, autoFill: true)}',
                        style: TxtStyle()
                          ..fontSize(14)
                          ..width(_provinces.any((e) => e.selected == false)
                              ? 200
                              : 250)
                          ..textOverflow(
                              _provinces.any((e) => e.selected == false)
                                  ? TextOverflow.ellipsis
                                  : TextOverflow.visible)
                          ..textColor(OCSColor.text),
                      ),
                      children: [
                        if (_provinces[i].selected == false)
                          _addressList(_provinces[i], _coverages)
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
              // ..height(_customTileExpanded ? 180 : 180)
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
                    ..fontSize(14)
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
        },
      ),
    );
  }

  Widget _fileSection() {
    return Column(
      children: [
        Row(
          children: [
            Txt(
              _util.language.key("file"),
              style: TxtStyle()
                ..textColor(OCSColor.text.withOpacity(0.7))
                ..fontSize(_labelSize),
            ),
          ],
        ),
        // SizedBox(height: 5),
        Parent(
          style: ParentStyle()
            ..border(all: 1, color: Colors.grey.shade300)
            ..width(_util.query.width)
            ..padding(all: 5)
            ..borderRadius(all: 5),
          child: GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            primary: true,
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemCount: _files.length > 0 ? _files.length + 1 : 1,
            itemBuilder: (_, i) {
              return i < _files.length
                  ? Stack(
                      children: [
                        Parent(
                          gesture: Gestures()
                            ..onTap(() async {
                              await OpenFile.open(_files[i].path);
                            }),
                          style: ParentStyle()
                            ..minWidth(120)
                            ..ripple(true)
                            ..overflow.hidden()
                            ..margin(vertical: 5, horizontal: 5)
                            ..boxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.1),
                              offset: Offset(0, 1),
                              blur: 3.0,
                              spread: 0.5,
                            )
                            ..minHeight(150)
                            ..overflow.hidden()
                            ..borderRadius(all: 5)
                            ..background.color(Colors.white),
                          child: _files[i].extension?.toLowerCase() == "jpg" ||
                                  _files[i].extension?.toLowerCase() == "png" ||
                                  _files[i].extension?.toLowerCase() == "jpeg"
                              ? Image.file(
                                  File(_files[i].path ?? ""),
                                  fit: BoxFit.cover,
                                )
                              : _files[i].extension!.toLowerCase() == "doc" ||
                                      _files[i].extension?.toLowerCase() ==
                                          "docx"
                                  ? Image.asset(
                                      "assets/images/word-logo.png",
                                      fit: BoxFit.cover,
                                    )
                                  : _files[i].extension!.toLowerCase() == "pdf"
                                      ? Image.asset(
                                          "assets/images/pdf-logo.png",
                                          fit: BoxFit.cover,
                                        )
                                      : _files[i].extension?.toLowerCase() ==
                                                  "xls" ||
                                              _files[i]
                                                      .extension
                                                      ?.toLowerCase() ==
                                                  "xlsx"
                                          ? Image.asset(
                                              "assets/images/excel-logo.png",
                                              fit: BoxFit.cover,
                                            )
                                          : _files[i]
                                                          .extension
                                                          ?.toLowerCase() ==
                                                      "pptx" ||
                                                  _files[i]
                                                          .extension
                                                          ?.toLowerCase() ==
                                                      "ppt"
                                              ? Image.asset(
                                                  "assets/images/powerpoint-logo.png",
                                                  fit: BoxFit.cover,
                                                )
                                              : SizedBox(),
                        ),
                        Positioned(
                          child: Parent(
                            style: ParentStyle()
                              ..padding(all: 5)
                              ..ripple(true)
                              ..borderRadius(all: 50)
                              ..background.color(Colors.white)
                              ..elevation(1, opacity: 0.5),
                            child: Icon(
                              Remix.delete_bin_line,
                              size: 18,
                              color: OCSColor.primary,
                            ),
                            gesture: Gestures()
                              ..onTap(() {
                                deleteFile(File(_files[i].path ?? ''));
                                _files.removeAt(i);
                                _mfile.removeAt(i);
                                setState(() {});
                              }),
                          ),
                          right: 0,
                          top: 0,
                        )
                      ],
                    )
                  : Parent(
                      style: ParentStyle()
                        ..width(40)
                        ..ripple(true)
                        ..margin(vertical: 5, horizontal: 5)
                        ..boxShadow(
                          color: Colors.black12,
                          offset: Offset(0, 1),
                          blur: 2.0,
                        )
                        ..height(40)
                        ..borderRadius(all: 5)
                        ..background.color(Colors.white),
                      child: Column(
                        children: [
                          Expanded(child: SizedBox()),
                          Icon(
                            Remix.upload_2_line,
                            size: 20,
                            color: Colors.blue,
                          ),
                          SizedBox(height: 3),
                          Txt(
                            _util.language.key("select"),
                            style: TxtStyle()
                              ..textAlign.center()
                              ..textColor(Colors.blue)
                              ..fontSize(Style.subTitleSize),
                          ),
                          Expanded(child: SizedBox()),
                        ],
                      ),
                      gesture: Gestures()
                        ..onTap(() {
                          _getFile();
                        }),
                    );
            },
          ),
        ),
      ],
    );
  }

  Future _mappingFile(PlatformFile file) async {
    _mfile.add(MFile(
      extension: file.extension,
      file: await _covertFileToBytes(file.path ?? ""),
      fileType: _getFileType(file.extension ?? ""),
    ));
  }

  Widget _addImage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Parent(
          style: ParentStyle()
            ..background.color(Colors.white)
            ..padding(all: 10, top: 5)
            ..width(_util.query.width)
            ..borderRadius(all: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Txt(
                _util.language.key("select-your-image"),
                style: TxtStyle()
                  ..fontSize(16)
                  ..textColor(Colors.black87),
              ),
              SizedBox(height: 5),
              Column(
                children: [
                  buildActionModal(
                    icon: Icons.camera_alt_outlined,
                    onPress: _getImageByTakeCamera,
                    color: Colors.green,
                    title: _util.language.key("camera"),
                  ),
                  buildActionModal(
                    icon: Remix.image_line,
                    onPress: _getImageByGallery,
                    color: Colors.blue,
                    title: _util.language.key("gallery"),
                  ),
                ],
              ),
              SizedBox(
                height: _util.query.bottom + 5,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
