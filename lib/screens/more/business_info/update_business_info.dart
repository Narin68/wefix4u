import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ocs_auth/my_strings.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '/blocs/partner/partner_cubit.dart';
import '/screens/function_temp.dart';
import '/globals.dart';
import '/repositories/partner_repo.dart';
import '/screens/widget.dart';
import '../request_partner/widget.dart';
import '/modals/partner.dart';

class UpdateBusinessInfo extends StatefulWidget {
  final MPartner data;

  const UpdateBusinessInfo({Key? key, required this.data}) : super(key: key);

  @override
  _UpdateBusinessInfoState createState() => _UpdateBusinessInfoState();
}

class _UpdateBusinessInfoState extends State<UpdateBusinessInfo> {
  bool _loading = false;

  late var _util = OCSUtil.of(context);
  var _form = GlobalKey<FormState>();
  double _labelSize = Style.subTitleSize;

  FocusNode _focusNode = FocusNode();
  FocusNode _workExFocusNode = FocusNode();
  int val = -1;
  TextEditingController _nameTxt = TextEditingController(),
      _nameEnglishTxt = TextEditingController(),
      _phone1Txt = TextEditingController(),
      _phone2Txt = TextEditingController(),
      _emailTxt = TextEditingController(),
      _workExperTxt = TextEditingController();
  MPartner data = MPartner();
  XFile? _image;
  Uint8List? _imageByte;

  @override
  void initState() {
    super.initState();
    data = widget.data;
    _initData();
  }

  Future _initData() async {
    _nameTxt.text = data.businessName ?? "";
    _nameEnglishTxt.text = data.businessNameEnglish ?? "";
    _emailTxt.text = data.businessEmail ?? "";
    _workExperTxt.text = data.workExperience.toString();
    _phone1Txt.text = data.businessPhone1!.replaceAll('+855', '0');
    _phone2Txt.text = data.businessPhone2!.replaceAll('+855', '0');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _loading ? null : _util.navigator.pop();

        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: OCSColor.primary,
          leading: NavigatorBackButton(loading: _loading),
          title: Txt(
            "${_util.language.key("update-business-info")}",
            style: TxtStyle()
              ..fontSize(16)
              ..textColor(Colors.white),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    leading: SizedBox(),
                    pinned: false,
                    elevation: 0.5,
                    iconTheme: IconThemeData(color: OCSColor.text),
                    actionsIconTheme: IconThemeData(color: OCSColor.text),
                    backgroundColor: OCSColor.white,
                    expandedHeight: 180,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        children: [
                          Parent(
                            style: ParentStyle()
                              ..opacity(0.3)
                              ..height(100)
                              ..borderRadius(bottomRight: 5, bottomLeft: 5)
                              ..width(_util.query.width)
                              ..background.color(Colors.black.withOpacity(0.1))
                              ..borderRadius(all: 10),
                          ),
                          Parent(
                            style: ParentStyle(),
                            child: Column(
                              children: [
                                Parent(
                                  style: ParentStyle(),
                                  child: Center(
                                    child: Parent(
                                      style: ParentStyle()
                                        ..width(_util.query.width)
                                        ..padding(all: 10, bottom: 10)
                                        ..opacity(1),
                                      child: Center(
                                        child: Stack(
                                          children: [
                                            Parent(
                                              gesture: Gestures()
                                                ..onTap(() {
                                                  _util.navigator
                                                      .to(MyViewImage(
                                                    byteImage: _image != null
                                                        ? _imageByte
                                                        : null,
                                                    url:
                                                        "${ApisString.webServer}/${data.applicationFiles?.placeImagePath}",
                                                  ));
                                                }),
                                              style: ParentStyle()
                                                ..borderRadius(all: 10)
                                                ..overflow.hidden()
                                                ..margin(top: 10)
                                                ..elevation(1, opacity: 0.2)
                                                ..width(140)
                                                ..height(130)
                                                ..overflow.hidden()
                                                ..background
                                                    .color(Colors.white),
                                              child: _image != null
                                                  ? Image.file(
                                                      File(_image?.path ?? ""),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : MyNetworkImage(
                                                      url:
                                                          "${ApisString.webServer}/${data.applicationFiles?.placeImagePath ?? ""}",
                                                    ),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: Parent(
                                                gesture: Gestures()
                                                  ..onTap(() async {
                                                    showModalBottomSheet(
                                                        context: context,
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        builder: (BuildContext
                                                            context) {
                                                          return _addImage();
                                                        });
                                                  }),
                                                style: ParentStyle()
                                                  ..background
                                                      .color(OCSColor.primary)
                                                  ..width(30)
                                                  ..height(30)
                                                  ..borderRadius(all: 50)
                                                  ..ripple(true)
                                                  ..padding(all: 1)
                                                  ..border(
                                                      all: 1,
                                                      color: Colors.white)
                                                  ..boxShadow(
                                                    color: Color.fromRGBO(
                                                        0, 0, 0, 0.15),
                                                    offset: Offset(0, 2),
                                                    blur: 4.0,
                                                  ),
                                                child: Icon(
                                                  Remix.image_edit_line,
                                                  size: 15,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Parent(
                      style: ParentStyle()..padding(horizontal: 15),
                      child: Form(
                        key: _form,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 15),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: MyTextField(
                                    borderWidth: Style.borderWidth,
                                    backgroundColor: Colors.white,
                                    controller: _nameTxt,
                                    autoFocus: false,
                                    readOnly: _loading,
                                    focusNode: _focusNode,
                                    label: _util.language.key('business-name'),
                                    labelTextSize: _labelSize,
                                    placeholder:
                                        _util.language.key('enter-name'),
                                    validator: (String? v) {
                                      if (v == "") {
                                        return "${_util.language.key("this-field-is-required")}";
                                      }
                                      return null;
                                    },
                                    onChanged: (v) {},
                                    autoValidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    onSubmitted: (v) {},
                                  ),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: MyTextField(
                                    borderWidth: Style.borderWidth,
                                    backgroundColor: Colors.white,
                                    controller: _nameEnglishTxt,
                                    autoFocus: false,
                                    readOnly: _loading,
                                    label:
                                        _util.language.key('business-eng-name'),
                                    labelTextSize: _labelSize,
                                    placeholder:
                                        _util.language.key('enter-name'),
                                    onSubmitted: (v) {},
                                    onChanged: (v) {},
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: MyTextField(
                                    borderWidth: Style.borderWidth,
                                    backgroundColor: Colors.white,
                                    controller: _phone1Txt,
                                    leading: Parent(
                                      style: ParentStyle()..margin(left: 10),
                                      child: Txt("+855",
                                          style: TxtStyle()
                                            ..fontSize(14)
                                            ..textColor(OCSColor.text
                                                .withOpacity(0.5))),
                                    ),
                                    readOnly: _loading,
                                    label: _util.language.key('phone1'),
                                    labelTextSize: _labelSize,
                                    onSubmitted: (v) {},
                                    placeholder: "012345678",
                                    autoValidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    textInputType:
                                        TextInputType.numberWithOptions(
                                            signed: false, decimal: false),
                                    validator: (v) {
                                      if (v == "") {
                                        return "${_util.language.key("this-field-is-required")}";
                                      }
                                      final regExp =
                                          RegExp(AuthPattern.allPhone);
                                      if (!regExp.hasMatch(v!)) {
                                        return "${_util.language.key("invalid-phone-number")}";
                                      }
                                      return null;
                                    },
                                    onChanged: (v) {},
                                  ),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: MyTextField(
                                    borderWidth: Style.borderWidth,
                                    backgroundColor: Colors.white,
                                    controller: _phone2Txt,
                                    leading: Parent(
                                      style: ParentStyle()..margin(left: 10),
                                      child: Txt("+855",
                                          style: TxtStyle()
                                            ..fontSize(14)
                                            ..textColor(Colors.black54)),
                                    ),
                                    readOnly: _loading,
                                    label: _util.language.key('phone2'),
                                    labelTextSize: _labelSize,
                                    onSubmitted: (v) {},
                                    placeholder: "012345678",
                                    textInputType:
                                        TextInputType.numberWithOptions(
                                      signed: false,
                                      decimal: false,
                                    ),
                                    onChanged: (v) {},
                                    noStar: true,
                                  ),
                                ),
                              ],
                            ),
                            MyTextField(
                              borderWidth: Style.borderWidth,
                              backgroundColor: Colors.white,
                              controller: _emailTxt,
                              readOnly: _loading,
                              label: _util.language.key('email'),
                              labelTextSize: _labelSize,
                              placeholder: _util.language.key('enter-email'),
                              onSubmitted: (v) {},
                              textInputType: TextInputType.emailAddress,
                              onChanged: (v) {},
                            ),
                            MyTextField(
                              borderWidth: Style.borderWidth,
                              backgroundColor: Colors.white,
                              controller: _workExperTxt,
                              readOnly: _loading,
                              focusNode: _workExFocusNode,
                              label: _util.language.key('work-experience'),
                              labelTextSize: _labelSize,
                              placeholder:
                                  _util.language.key('enter-work-experience'),
                              onSubmitted: (v) {},
                              validator: (v) {
                                if (v == "") {
                                  return "${_util.language.key("this-field-is-required")}";
                                }
                                return null;
                              },
                              onChanged: (v) {},
                              textInputType: TextInputType.numberWithOptions(
                                signed: false,
                                decimal: false,
                              ),
                              autoValidateMode:
                                  AutovalidateMode.onUserInteraction,
                            ),
                            SizedBox(height: 70),
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
                        horizontal: 15,
                      )
                      ..width(_util.query.width),
                    child: BuildButton(
                      title: _util.language.key('update'),
                      fontSize: Style.titleSize,
                      onPress: _onSubmit,
                    ),
                  ),
                ),
              if (_loading)
                Positioned(
                  child: Container(
                    color: Colors.black.withOpacity(.3),
                    child: Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Future _onSubmit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _loading = true;
    });
    var _res = await PartnerRepo().update(
      name: _nameTxt.text,
      nameEnglish: _nameEnglishTxt.text,
      phone1: _phone1Txt.text,
      phone2: _phone2Txt.text,
      email: _emailTxt.text,
      experience: int.parse(_workExperTxt.text),
      latlong: data.latLong ?? "",
      address: data.businessAddress ?? "",
      placeImage: _imageByte,
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
      _util.navigator.pop();
    } else {
      _util.snackBar(message: _res.message, status: SnackBarStatus.danger);
    }
    setState(() {
      _loading = false;
    });
  }

  Future _getImageByGallery() async {
    final XFile? image = await getImageByGallery();
    if (image != null) {
      _util.navigator.pop();
      _image = image;
      final bytes = File(image.path).readAsBytesSync();
      _imageByte = bytes;
    }
    setState(() {});
  }

  Future _getImageByTakeCamera() async {
    final XFile? image = await getImageByTakeCamera();
    if (image != null) {
      _util.navigator.pop();
      _image = image;
      final bytes = File(image.path).readAsBytesSync();
      _imageByte = bytes;
    }
    setState(() {});
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
                _util.language.key('select-your-image'),
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
                    title: _util.language.key('camera'),
                  ),
                  buildActionModal(
                    icon: Remix.image_line,
                    onPress: _getImageByGallery,
                    color: Colors.blue,
                    title: _util.language.key('gallery'),
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
}
