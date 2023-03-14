import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ocs_auth/my_strings.dart';
import 'package:remixicon/remixicon.dart';
import 'package:ocs_util/ocs_util.dart';
import '/modals/address.dart';
import '/repositories/request_service_repo.dart';
import '../widget.dart';
import '/globals.dart';
import '../map_picker.dart';
import 'request_form_step_two.dart';

class RequestForm extends StatefulWidget {
  @override
  _RequestFormState createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
  late var _util = OCSUtil.of(context);

  double _labelSize = Style.subTextSize;
  String _errorPinMap = '';
  String _map = '';
  double? _lat;
  double? _lng;
  TextEditingController _addressTxt = TextEditingController(),
      _phoneTxt = TextEditingController(),
      _contactPhone2 = TextEditingController();

  var _form = GlobalKey<FormState>();
  bool _loading = false;
  int _provinceId = 0;

  @override
  void initState() {
    super.initState();
    _initDataForm();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: OCSColor.primary,
        title: Txt(
          _util.language.key('request-info'),
          style: TxtStyle()
            ..fontSize(16)
            ..textColor(Colors.white),
        ),
        leading: NavigatorBackButton(),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Parent(
                      style: ParentStyle()..padding(all: 15, top: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 15),
                          _formSection(),
                          SizedBox(height: 70),
                        ],
                      ),
                    ),
                  )
                ],
              ),
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
                    onPress: _onNextToStepTwo,
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
          ],
        ),
      ),
    );
  }

  void _onNextToStepTwo() {
    if (_provinceId == 0) {
      _util.snackBar(
          message: _util.language.key("not-available-location"),
          status: SnackBarStatus.warning);
      return;
    }
    bool valid = true;
    if (_map == "") {
      _errorPinMap = "${_util.language.key("please-select-location")}";
      valid = false;
      setState(() {});
    }
    if (valid == true && _form.currentState!.validate()) {
      _util.navigator.to(StepTwoServiceForm(), transition: OCSTransitions.LEFT);
    }
  }

  void _initDataForm() {
    _addressTxt.text = ApplyServiceModel.address;
    _map = ApplyServiceModel.pinMap;
    _lat = ApplyPartnerDataModel.lat;
    _lng = ApplyPartnerDataModel.long;
    _contactPhone2.text = ApplyServiceModel.phone;
    !Globals.hasAuth
        ? _phoneTxt.text = ApplyServiceModel.phone1
        : _phoneTxt.text = Model.customer.phone1?.replaceAll('+855', '0') ?? "";
    _provinceId = ApplyServiceModel.provinceId ?? 0;
  }

  Future _toPinMap(double? lat, double? lng) async {
    _util.navigator.to(
        MyMapPicker(
          lat: lat,
          long: lng,
          onSubmit: (address, lat, long) async {
            _map = address;
            _lat = lat;
            _lng = long;
            _errorPinMap = '';
            ApplyPartnerDataModel.lat = _lat;
            ApplyPartnerDataModel.long = long;
            ApplyServiceModel.pinMap = _map;
            setState(() {
              _loading = true;
            });
            var res = await RequestServiceRepo().getProvinceId(address);
            if (!res.error) {
              if (res.data.isNotEmpty) {
                print("Available Location");
                MAddress data = res.data[0];
                ApplyServiceModel.provinceId = data.id;
                _provinceId = data.id ?? 0;
              } else {
                ApplyServiceModel.provinceId = 0;
                _provinceId = 0;
                _util.snackBar(
                    message: _util.language.key("not-available-location"),
                    status: SnackBarStatus.warning);
              }
            }
            setState(() {
              _loading = false;
            });
          },
        ),
        transition: OCSTransitions.LEFT);
  }

  Widget _formSection() {
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyTextField(
            borderWidth: Style.borderWidth,
            controller: _addressTxt,
            backgroundColor: Colors.white,
            label: _util.language.key('address'),
            labelTextSize: Style.subTitleSize,
            labelColor: OCSColor.text.withOpacity(0.7),
            placeholder: _util.language.key('enter-address'),
            onChanged: (v) {
              ApplyServiceModel.address = v!;
            },
          ),
          _buildPinMapField(),
          _buildContactField(),
        ],
      ),
    );
  }

  Widget _buildContactField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyTextField(
          borderWidth: Style.borderWidth,
          labelColor: OCSColor.text.withOpacity(0.7),
          readOnly: Globals.hasAuth,
          textColor: OCSColor.text,
          textInputType:
              TextInputType.numberWithOptions(signed: false, decimal: false),
          controller: _phoneTxt,
          leading: Parent(
            style: ParentStyle()..margin(left: 10),
            child: Txt("+855",
                style: TxtStyle()
                  ..fontSize(14)
                  ..textColor(OCSColor.text.withOpacity(0.5))),
          ),
          backgroundColor: Colors.white,
          label: _util.language.key('contact-phone-1'),
          labelTextSize: _labelSize,
          placeholder: '012345678',
          onChanged: (v) {
            ApplyServiceModel.phone1 = v ?? '';
          },
          validator: (v) {
            final regExp = RegExp(AuthPattern.allPhone);
            if (!regExp.hasMatch(v!)) {
              return "${_util.language.key("invalid-phone-number")}";
            }
            return null;
          },
        ),
        MyTextField(
          borderWidth: Style.borderWidth,
          labelColor: OCSColor.text.withOpacity(0.7),
          readOnly: false,
          textInputType:
              TextInputType.numberWithOptions(signed: false, decimal: false),
          controller: _contactPhone2,
          leading: Parent(
            style: ParentStyle()..margin(left: 10),
            child: Txt("+855",
                style: TxtStyle()
                  ..fontSize(14)
                  ..textColor(OCSColor.text.withOpacity(0.5))),
          ),
          backgroundColor: Colors.white,
          label: _util.language.key('contact-phone-2'),
          labelTextSize: _labelSize,
          placeholder: '012345678',
          noStar: true,
          onChanged: (v) {
            ApplyServiceModel.phone = v!;
          },
          validator: (v) {
            if (v == "") {
              return null;
            }
            final regExp = RegExp(AuthPattern.allPhone);
            if (!regExp.hasMatch(v!)) {
              return "${_util.language.key("invalid-phone-number")}";
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPinMapField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Txt(
              _util.language.key('pin-map'),
              style: TxtStyle()
                ..textColor(_errorPinMap == ""
                    ? OCSColor.text.withOpacity(0.7)
                    : Colors.red)
                ..fontSize(_labelSize),
            ),
            Txt(
              "*",
              style: TxtStyle()
                ..textColor(Colors.red.withOpacity(0.7))
                ..fontSize(12),
            )
          ],
        ),
        Stack(
          children: [
            Parent(
              gesture: Gestures()
                ..onTap(() async {
                  _toPinMap(_lat, _lng);
                }),
              child: Txt(
                _map.isNotEmpty ? _map : _util.language.key("select-location"),
                style: TxtStyle()
                  ..fontSize(Style.subTitleSize)
                  ..textOverflow(TextOverflow.ellipsis)
                  ..textColor(_map.isNotEmpty
                      ? OCSColor.text
                      : OCSColor.text.withOpacity(0.5)),
              ),
              style: ParentStyle()
                ..width(_util.query.width)
                ..background.color(Colors.transparent)
                ..borderRadius(all: 5)
                ..padding(all: 10, horizontal: 15)
                ..height(50)
                ..alignmentContent.centerLeft()
                ..border(
                  all: 1,
                  color: _errorPinMap == "" ? OCSColor.border : Colors.red,
                )
                ..ripple(true),
            ),
          ],
        ),
        if (_errorPinMap.isNotEmpty)
          Parent(
            style: ParentStyle()
              ..minHeight(6)
              ..margin(top: 5)
              ..maxHeight(10)
              ..overflow.visible()
              ..alignmentContent.topLeft(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Remix.information_line, color: Colors.red, size: 12),
                SizedBox(width: 2),
                Expanded(
                    child: Txt(_errorPinMap,
                        style: TxtStyle()
                          ..textColor(Colors.red)
                          ..fontSize(10)
                          ..height(10)
                          ..maxLines(1)
                          ..textOverflow(TextOverflow.ellipsis)
                          ..overflow.visible()
                          ..alignmentContent.centerLeft()
                          ..background.color(Colors.transparent)))
              ],
            ),
          ),
        SizedBox(height: 10),
      ],
    );
  }
}
