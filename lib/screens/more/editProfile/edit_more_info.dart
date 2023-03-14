import 'package:flutter/material.dart';
import 'package:ocs_auth/ocs_auth.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '/globals.dart';
import '/screens/widget.dart';
import '/blocs/user/user_cubit.dart';
import '/modals/customer.dart';
import '/repositories/customer.dart';

class EditMoreUserInfo extends StatefulWidget {
  final MUserInfo? user;

  final MMyCustomer? info;

  EditMoreUserInfo({required this.user, required this.info});

  @override
  _EditMoreUserInfoState createState() => _EditMoreUserInfoState();
}

class _EditMoreUserInfoState extends State<EditMoreUserInfo> {
  late var _util = OCSUtil.of(context);
  var _txtPassportNo = TextEditingController(),
      _txtIDCard = TextEditingController(),
      _txtAddress = TextEditingController(),
      _txtPostalCode = TextEditingController();

  bool _loading = false, _initLoading = false;

  var _addressRepo = CustomerRepo();

  @override
  void initState() {
    super.initState();
    _initMoreInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: OCSColor.primary,
        title: Txt(
          _util.language.key('user-more-information'),
          style: TxtStyle()
            ..fontSize(16)
            ..textColor(Colors.white),
        ),
        leading: NavigatorBackButton(loading: _loading),
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            CustomScrollView(
              scrollDirection: Axis.vertical,
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Parent(
                        style: ParentStyle()
                          ..padding(horizontal: 15, top: 10)
                          ..height(!_util.query.isKbPopup
                              ? _util.query.height - 140
                              : _util.query.height - 80)
                          ..maxWidth(Globals.maxScreen),
                        child: Parent(
                          style: ParentStyle(),
                          child: Column(
                            children: [
                              SizedBox(height: 10),
                              MyTextField(
                                borderWidth: Style.borderWidth,
                                labelTextSize: 14,
                                controller: _txtPassportNo,
                                readOnly: _loading,
                                label: '${_util.language.key("passport-no")}',
                                placeholder:
                                    _util.language.key('enter-passport-no'),
                              ),
                              MyTextField(
                                borderWidth: Style.borderWidth,
                                labelTextSize: 14,
                                textInputType: TextInputType.numberWithOptions(
                                    signed: false, decimal: false),
                                controller: _txtIDCard,
                                readOnly: _loading,
                                label: '${_util.language.key("id-card")}',
                                placeholder:
                                    _util.language.key('enter-id-card'),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: _util.query.bottom <= 0 ? 15 : _util.query.bottom,
              child: Parent(
                style: ParentStyle()
                  ..padding(horizontal: 15)
                  ..width(_util.query.width),
                child: BuildButton(
                  title: "${_util.language.key("update")}",
                  iconData: Remix.edit_box_line,
                  fontSize: 15,
                  height: 45,
                  iconSize: 18,
                  onPress: () {
                    _onSubmitted();
                  },
                ),
              ),
            ),
            if (_initLoading)
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
    );
  }

  void _initMoreInfo() {
    _txtPassportNo.text = widget.info?.passportNo ?? '';
    _txtPostalCode.text = widget.info?.postalCode ?? '';
    _txtAddress.text =
        widget.info!.address == "N/A" ? "" : widget.info?.address ?? "";
    _txtIDCard.text = widget.info?.peopleIdCard ?? "";
  }

  void _onSubmitted() async {
    setState(() => _initLoading = true);
    var body = widget.info!.copyWith(
      passportNo: _txtPassportNo.text.trim(),
      peopleIdCard: _txtIDCard.text.trim(),
      address: widget.info?.address! == '' ? "N/A" : widget.info?.address,
    );

    if (widget.info?.peopleIdCard?.toLowerCase() ==
            _txtPassportNo.text.trim().toLowerCase() &&
        widget.info?.passportNo?.toLowerCase() ==
            _txtPassportNo.text.trim().toLowerCase()) {
      _util.navigator.pop();
      return;
    }
    var result = await _addressRepo.updateUserMoreInfo(body);

    if (!result.error) {
      var cus = MMyCustomer.fromJson(result.data);
      context.read<MyUserCubit>().update(user: Model.userInfo, customer: cus);
      _util.navigator.replace(
        BuildSuccessScreen(
          successTitle: _util.language.key("you-successfully-update-more-info"),
        ),
      );
    } else {
      _util.snackBar(
        message: _util.language.key(result.message),
        status: SnackBarStatus.danger,
      );
    }
    setState(() => _initLoading = false);
  }
}
