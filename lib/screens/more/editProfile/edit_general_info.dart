import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:ocs_auth/ocs_auth.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '/globals.dart';
import '/screens/widget.dart';
import '/blocs/user/user_cubit.dart';

class EditGeneralInfo extends StatefulWidget {
  final MUserInfo user;

  EditGeneralInfo({required this.user});

  @override
  _EditGeneralInfoState createState() => _EditGeneralInfoState();
}

class _EditGeneralInfoState extends State<EditGeneralInfo> {
  late var _util = OCSUtil.of(context);

  late var _auth = OCSAuth.instance;
  bool _loading = false;
  double _labelSize = Style.subTextSize;
  String _genderValue = "";
  var _firstName = TextEditingController();
  var _lastName = TextEditingController();
  var _dob = TextEditingController();
  String _dropdownError = "";
  GlobalKey<FormState> _form = GlobalKey<FormState>();
  FocusNode focusNode = FocusNode();
  bool _isImageChange = false;
  DateTime? _dateOfBirth = DateTime.now();

  Uint8List? _photo;

  String _title = "";

  IconData? _genderIcon;

  String lastName = '';
  String _dateError = '';

  @override
  void initState() {
    super.initState();
    initUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_loading) _util.navigator.pop();

        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: OCSColor.primary,
          title: Txt(
            _util.language.key('general-info'),
            style: TxtStyle()
              ..fontSize(16)
              ..textColor(Colors.white),
          ),
          leading: NavigatorBackButton(loading: _loading),
        ),
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Center(
                child: Parent(
                  style: ParentStyle()..maxWidth(Globals.maxScreen),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: _buildBody(),
                      )
                    ],
                  ),
                ),
              ),
              if (!_util.query.isKbPopup)
                Positioned(
                  bottom: _util.query.bottom <= 0 ? 15 : _util.query.bottom,
                  child: Parent(
                    style: ParentStyle()
                      ..alignment.center()
                      ..padding(horizontal: 15)
                      ..width(_util.query.width),
                    child: BuildButton(
                      iconData: Remix.edit_box_line,
                      title: _util.language.key('update'),
                      onPress: _onUpdate,
                      fontSize: 16,
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
                )
            ],
          ),
        ),
      ),
    );
  }

  void initUserInfo() {
    lastName = widget.user.lastName!;
    if (lastName.indexOf(".") == 0) lastName = lastName.replaceFirst('.', '');

    _genderValue = widget.user.gender ?? "";
    _firstName.text = widget.user.firstName ?? "";
    _lastName.text = lastName;
    _dob.text = widget.user.dateOfBirth == null
        ? ''
        : OCSUtil.dateFormat(DateTime.parse(widget.user.dateOfBirth ?? ''),
            format: Format.date, langCode: Globals.langCode);
    _dateOfBirth = (widget.user.dateOfBirth == null
        ? null
        : DateTime.parse(widget.user.dateOfBirth!));
  }

  Future _onUpdate() async {
    bool _isValid = _form.currentState!.validate();
    if (_genderValue == "") {
      setState(() =>
          _dropdownError = "${_util.language.key("please-select-gender")}");
      _isValid = false;
    }

    if (_dob.text == "") {
      _dateError = "${_util.language.key("please-select-gender")}";
      _isValid = false;
      setState(() {});
    }

    if (_isValid) {
      setState(() {
        _loading = true;
      });
      final result = await _auth.userUpdate(MUserUpdateInfoHeader(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.isEmpty ? "." : _lastName.text.trim(),
        userName: widget.user.loginName,
        gender: _genderValue,
        isChangeImage: _isImageChange,
        dateOfBirth: DateFormat("MM-dd-yyyy").format(_dateOfBirth!),
        image: _isImageChange ? _photo : Uint8List.fromList([]),
      ));
      if (!result.error) {
        var user = result.data!;
        context
            .read<MyUserCubit>()
            .update(user: user, customer: Model.customer);
        _util.navigator.replace(BuildSuccessScreen(
          successTitle:
              _util.language.key("you-successfully-updated-general-info"),
        ));
      } else {
        _util.snackBar(message: result.message, status: SnackBarStatus.danger);
      }
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _dropDown() {
    return DropdownButtonFormField(
      hint: _genderValue == ""
          ? Txt(
              _util.language.key("select-gender"),
              style: TxtStyle()
                ..textColor(OCSColor.text)
                ..fontSize(Style.subTitleSize)
                ..fontFamily('kmFont'),
            )
          : Row(
              children: [
                if (_genderValue.toLowerCase() == "male")
                  Icon(
                    Remix.men_line,
                    size: 16,
                    color: OCSColor.text,
                  ),
                if (_genderValue.toLowerCase() == "female")
                  Icon(
                    Remix.women_line,
                    size: 16,
                    color: OCSColor.text,
                  ),
                if (_genderValue != "") SizedBox(width: 5),
                Txt(
                  _util.language.key("${_genderValue.toLowerCase()}"),
                  style: TxtStyle()
                    ..textColor(OCSColor.text)
                    ..fontFamily("kmFont")
                    ..fontSize(Style.subTitleSize),
                ),
              ],
            ),
      isExpanded: true,
      decoration: InputDecoration.collapsed(hintText: ''),
      iconSize: 22,
      icon: Icon(
        Remix.arrow_down_s_line,
        color: Colors.black54,
      ),
      style: TextStyle(color: Colors.black54, fontSize: 14),
      items: ['Male', 'Female'].map(
        (val) {
          switch (val.toLowerCase()) {
            case "male":
              _title = _util.language.key("male");
              _genderIcon = Remix.men_line;
              break;

            case "female":
              _title = _util.language.key("female");
              _genderIcon = Remix.women_line;
          }

          return DropdownMenuItem<String>(
            value: val,
            child: Row(
              children: [
                Icon(
                  _genderIcon,
                  size: 16,
                  color: OCSColor.text,
                ),
                SizedBox(width: 5),
                Txt(
                  _title == "" ? _util.language.key("select-gender") : _title,
                  style: TxtStyle()
                    ..textColor(OCSColor.text)
                    ..fontFamily("kmFont")
                    ..fontSize(Style.subTitleSize),
                ),
              ],
            ),
          );
        },
      ).toList(),
      onChanged: _loading
          ? null
          : (v) => {
                setState(
                  () {
                    focusNode.unfocus();
                    _genderValue = v as String;
                    _dropdownError = "";
                  },
                )
              },
      onTap: () {
        focusNode.unfocus();
      },
    );
  }

  Widget _buildBody() {
    return Parent(
      style: ParentStyle()..padding(horizontal: 15, top: 10),
      child: Form(
        key: _form,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            MyTextField(
              borderWidth: Style.borderWidth,
              backgroundColor: Colors.white,
              textInputAction: TextInputAction.next,
              readOnly: _loading,
              focusNode: focusNode,
              controller: _firstName,
              label: _util.language.key('first-name'),
              labelTextSize: _labelSize,
              placeholder: _util.language.key('enter-first-name'),
              validator: (v) {
                if (v == "") {
                  return "${_util.language.key("this-field-is-required")}";
                }
                return null;
              },
              onSubmitted: (v) {},
            ),
            MyTextField(
              borderWidth: Style.borderWidth,
              backgroundColor: Colors.white,
              textInputAction: TextInputAction.next,
              readOnly: _loading,
              controller: _lastName,
              label: _util.language.key('last-name'),
              labelTextSize: _labelSize,
              placeholder: _util.language.key('enter-last-name'),
            ),
            _buildGenderDropList(),
            SizedBox(height: 13),
            _buildDateOfBirthField(),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderDropList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Txt(
              _util.language.key('gender'),
              style: TxtStyle()
                ..textColor(_dropdownError == ""
                    ? OCSColor.text.withOpacity(0.7)
                    : Colors.red)
                ..fontSize(_labelSize),
            ),
            Txt(
              "*",
              style: TxtStyle()
                ..textColor(Colors.red.withOpacity(0.7))
                ..fontSize(_labelSize),
            )
          ],
        ),
        Parent(
          style: ParentStyle()
            ..border(
                all: 1,
                color: _dropdownError == "" ? Colors.black12 : Colors.red)
            ..borderRadius(all: 5)
            ..background.color(Colors.white)
            ..padding(vertical: 7, horizontal: 10),
          child: _dropDown(),
        ),
        _dropdownError == ""
            ? SizedBox.shrink()
            : Parent(
                style: ParentStyle()
                  ..minHeight(6)
                  ..margin(top: 2)
                  ..maxHeight(10)
                  ..overflow.visible()
                  ..alignmentContent.topLeft(),
                child: Row(
                  children: [
                    Icon(Remix.information_line, color: Colors.red, size: 12),
                    SizedBox(width: 2),
                    Text(_dropdownError,
                        style: TextStyle(color: Colors.red, fontSize: 11)),
                  ],
                ),
              ),
      ],
    );
  }

  Widget _buildDateOfBirthField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Txt(
              _util.language.key('date-of-birth'),
              style: TxtStyle()
                ..textColor(_dateError == ""
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
            ..onTap(() {
              if (_loading == false)
                DatePicker.showDatePicker(
                  context,
                  showTitleActions: true,
                  minTime: DateTime(1900, 3, 5),
                  maxTime: DateTime.now(),
                  onChanged: (date) {},
                  onConfirm: (date) {
                    _dateOfBirth = date;
                    _dob.text = OCSUtil.dateFormat(date,
                        format: Format.date, langCode: Globals.langCode);
                    _dateError = '';
                    setState(() {});
                  },
                  currentTime: widget.user.dateOfBirth == null
                      ? _dateOfBirth != null
                          ? _dateOfBirth
                          : DateTime.now()
                      : DateTime.parse(widget.user.dateOfBirth!),
                  locale:
                      Globals.langCode == "en" ? LocaleType.en : LocaleType.kh,
                  theme: DatePickerTheme(
                    backgroundColor: Colors.white,
                    itemStyle: TextStyle(fontFamily: "kmFont"),
                  ),
                );
            }),
          child: Txt(
            "${_dob.text == "" ? _util.language.key('select-date-of-birth') : _dob.text}",
            style: TxtStyle()
              ..fontSize(14)
              ..textColor(OCSColor.text),
          ),
          style: ParentStyle()
            ..width(_util.query.width)
            ..borderRadius(all: 5)
            ..background.color(Colors.white)
            ..padding(all: 10, horizontal: 15)
            ..height(50)
            ..alignmentContent.centerLeft()
            ..border(
              all: 1,
              color: _dateError != "" ? Colors.red : OCSColor.border,
            )
            ..ripple(true),
        ),
        _dateError == ""
            ? SizedBox.shrink()
            : Parent(
                style: ParentStyle()
                  ..minHeight(6)
                  ..margin(top: 2)
                  ..maxHeight(10)
                  ..overflow.visible()
                  ..alignmentContent.topLeft(),
                child: Row(
                  children: [
                    Icon(Remix.information_line, color: Colors.red, size: 12),
                    SizedBox(width: 2),
                    Text(_util.language.key("this-field-is-required"),
                        style: TextStyle(color: Colors.red, fontSize: 11)),
                  ],
                ),
              ),
      ],
    );
  }
}
