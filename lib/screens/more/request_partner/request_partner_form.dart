import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ocs_auth/my_strings.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '/functions.dart';
import '/screens/function_temp.dart';
import '/screens/widget.dart';
import '/globals.dart';
import 'step_two_form.dart';
import 'widget.dart';

class RequestPartnerForm extends StatefulWidget {
  @override
  _RequestPartnerFormState createState() => _RequestPartnerFormState();
}

class _RequestPartnerFormState extends State<RequestPartnerForm> {
  bool _loading = false;

  late var _util = OCSUtil.of(context);

  Uint8List? _imageByte;

  XFile? _image;
  var _form = GlobalKey<FormState>();
  double _labelSize = Style.subTextSize;

  FocusNode _focusNode = FocusNode();
  FocusNode _workExFocusNode = FocusNode();
  int val = -1;
  TextEditingController _nameTxt = TextEditingController(),
      _nameEnglishTxt = TextEditingController(),
      _phone1Txt = TextEditingController(),
      _phone2Txt = TextEditingController(),
      _emailTxt = TextEditingController(),
      _workExperTxt = TextEditingController();
  ScrollController _scrollCtr = ScrollController();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: OCSColor.background,
        elevation: 0,
        shadowColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Parent(
          style: ParentStyle(),
          child: Stack(
            children: [
              CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                controller: _scrollCtr,
                slivers: [
                  SliverAppBar(
                    leading: NavigatorBackButton(
                      loading: _loading,
                      iconColor: OCSColor.text,
                    ),
                    pinned: true,
                    title: Txt(
                      "${_util.language.key("business-info")}",
                      style: TxtStyle()
                        ..fontSize(16)
                        ..textColor(OCSColor.text),
                    ),
                    foregroundColor: Colors.blue,
                    centerTitle: true,
                    elevation: 1,
                    iconTheme: IconThemeData(color: OCSColor.text),
                    actionsIconTheme: IconThemeData(color: OCSColor.text),
                    backgroundColor: OCSColor.white,
                    expandedHeight: 180,
                    flexibleSpace: _buildHeader(),
                  ),
                  SliverToBoxAdapter(
                    child: _buildBody(),
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
                      title: _util.language.key('next'),
                      fontSize: 16,
                      onPress: _onSubmit,
                    ),
                  ),
                ),
              if (_loading)
                Positioned(
                  child: Container(
                    color: Colors.black.withOpacity(.3),
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

  Future _initData() async {
    _nameTxt.text = ApplyPartnerDataModel.businessName;
    _nameEnglishTxt.text = ApplyPartnerDataModel.businessNameEng;
    _emailTxt.text = ApplyPartnerDataModel.businessEmail;
    _workExperTxt.text = ApplyPartnerDataModel.workExperience;
    _image = ApplyPartnerDataModel.profileImage;
    if (_image != null) _imageByte = File(_image?.path ?? "").readAsBytesSync();
    if (ApplyPartnerDataModel.businessPhone1.isEmpty) {
      ApplyPartnerDataModel.businessPhone1 =
          Model.customer.phone1?.replaceAll('+855', '0') ?? "";
      _phone1Txt.text = ApplyPartnerDataModel.businessPhone1;
    } else {
      _phone1Txt.text = ApplyPartnerDataModel.businessPhone1;
    }

    _phone2Txt.text = ApplyPartnerDataModel.businessPhone2;
  }

  void _onSubmit() {
    if (!_form.currentState!.validate()) return;
    if (_imageByte == null)
      _util.snackBar(
        message: _util.language.key('please-select-image'),
        status: SnackBarStatus.warning,
      );
    if (_imageByte == null) return;
    _util.navigator.to(StepTwoForm(), transition: OCSTransitions.LEFT);
  }

  Future _getImageByGallery() async {
    final XFile? image = await getImageByGallery();
    if (image != null) {
      _util.navigator.pop();
      _image = image;
      final bytes = File(image.path).readAsBytesSync();
      _imageByte = bytes;
      if (ApplyPartnerDataModel.profileImage != null)
        deleteFile(File(ApplyPartnerDataModel.profileImage?.path ?? ""));
      ApplyPartnerDataModel.profileImage = image;
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
      if (ApplyPartnerDataModel.profileImage != null)
        deleteFile(File(ApplyPartnerDataModel.profileImage?.path ?? ""));
      ApplyPartnerDataModel.profileImage = image;
    }
    setState(() {});
  }

  Widget _buildHeader() {
    return FlexibleSpaceBar(
      background: Stack(
        children: [
          Parent(
            style: ParentStyle()
              ..height(120)
              ..borderRadius(bottomRight: 5, bottomLeft: 5)
              ..width(_util.query.width)
              ..background.color(OCSColor.background),
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
                                  if (_image != null) {
                                    _util.navigator.to(MyViewImage(
                                      byteImage: _imageByte,
                                    ));
                                  }
                                }),
                              style: ParentStyle()
                                ..borderRadius(all: 50)
                                ..overflow.hidden()
                                ..margin(top: 40)
                                ..boxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.1),
                                  offset: Offset(0, 1),
                                  blur: 3.0,
                                  spread: 0.5,
                                )
                                ..width(100)
                                ..height(100)
                                ..overflow.hidden()
                                ..background.color(Colors.white),
                              child: _image != null
                                  ? Image.file(
                                      File(_image!.path),
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      "assets/images/no-image.png",
                                      fit: BoxFit.cover,
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
                                        backgroundColor: Colors.transparent,
                                        builder: (BuildContext context) {
                                          return _addImage();
                                        });
                                  }),
                                style: ParentStyle()
                                  ..background.color(OCSColor.primary)
                                  ..width(30)
                                  ..height(30)
                                  ..borderRadius(all: 50)
                                  ..ripple(true)
                                  ..padding(all: 1)
                                  ..border(all: 1, color: Colors.white)
                                  ..boxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.15),
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
    );
  }

  Widget _buildBody() {
    return Parent(
      style: ParentStyle()..padding(horizontal: 15),
      child: Form(
        key: _form,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: MyTextField(
                    borderWidth: Style.borderWidth,
                    labelColor: OCSColor.text.withOpacity(0.7),
                    backgroundColor: Colors.white,
                    controller: _nameTxt,
                    autoFocus: false,
                    readOnly: _loading,
                    focusNode: _focusNode,
                    label: _util.language.key('business-name'),
                    labelTextSize: _labelSize,
                    placeholder: _util.language.key('enter-name'),
                    validator: (String? v) {
                      if (v == "") {
                        return "${_util.language.key("this-field-is-required")}";
                      }
                      return null;
                    },
                    onChanged: (v) {
                      ApplyPartnerDataModel.businessName = v ?? "";
                    },
                    autoValidateMode: AutovalidateMode.onUserInteraction,
                    onSubmitted: (v) {},
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: MyTextField(
                    borderWidth: Style.borderWidth,
                    backgroundColor: Colors.white,
                    controller: _nameEnglishTxt,
                    autoFocus: false,
                    readOnly: _loading,
                    label: _util.language.key('business-eng-name'),
                    labelTextSize: _labelSize,
                    placeholder: _util.language.key('enter-name'),
                    onSubmitted: (v) {},
                    onChanged: (v) {
                      ApplyPartnerDataModel.businessNameEng = v ?? "";
                    },
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
                            ..textColor(OCSColor.text.withOpacity(0.5))),
                    ),
                    readOnly: _loading,
                    label: _util.language.key('phone1'),
                    labelTextSize: _labelSize,
                    onSubmitted: (v) {},
                    placeholder: "012345678",
                    autoValidateMode: AutovalidateMode.onUserInteraction,
                    textInputType: TextInputType.numberWithOptions(
                        signed: false, decimal: false),
                    validator: (v) {
                      if (v == "") {
                        return "${_util.language.key("this-field-is-required")}";
                      }
                      final regExp = RegExp(AuthPattern.allPhone);
                      if (!regExp.hasMatch(v!)) {
                        return "${_util.language.key("invalid-phone-number")}";
                      }
                      return null;
                    },
                    onChanged: (v) {
                      ApplyPartnerDataModel.businessPhone1 = v ?? "";
                    },
                  ),
                ),
                SizedBox(width: 16),
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
                    textInputType: TextInputType.numberWithOptions(
                      signed: false,
                      decimal: false,
                    ),
                    onChanged: (v) {
                      ApplyPartnerDataModel.businessPhone2 = v ?? "";
                    },
                    validator: (v) {
                      if (v!.isEmpty) return null;
                      final regExp = RegExp(AuthPattern.allPhone);
                      if (!regExp.hasMatch(v)) {
                        return "${_util.language.key("invalid-phone-number")}";
                      }
                      return null;
                    },
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
              onChanged: (v) {
                ApplyPartnerDataModel.businessEmail = v ?? "";
              },
            ),
            MyTextField(
              borderWidth: Style.borderWidth,
              backgroundColor: Colors.white,
              controller: _workExperTxt,
              readOnly: _loading,
              focusNode: _workExFocusNode,
              label: _util.language.key('work-experience'),
              labelTextSize: _labelSize,
              placeholder: _util.language.key('enter-work-experience'),
              onSubmitted: (v) {},
              validator: (v) {
                if (v == "") {
                  return "${_util.language.key("this-field-is-required")}";
                }
                return null;
              },
              onChanged: (v) {
                ApplyPartnerDataModel.workExperience = v!;
              },
              textInputType: TextInputType.numberWithOptions(
                signed: false,
                decimal: false,
              ),
              autoValidateMode: AutovalidateMode.onUserInteraction,
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
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
