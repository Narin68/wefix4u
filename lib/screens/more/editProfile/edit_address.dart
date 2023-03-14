import 'package:flutter/material.dart';
import 'package:ocs_auth/ocs_auth.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '/globals.dart';
import '/screens/widget.dart';
import '/blocs/user/user_cubit.dart';
import '/modals/customer.dart';
import '/repositories/customer.dart';
import '/modals/address_filter.dart';
import '/repositories/address.dart';
import '/modals/address.dart';
import '/blocs/address/address_cubit.dart';

class EditAddress extends StatefulWidget {
  final MUserInfo? user;

  final MMyCustomer? info;

  EditAddress({required this.user, required this.info});

  @override
  _EditAddressState createState() => _EditAddressState();
}

class _EditAddressState extends State<EditAddress> {
  late var _util = OCSUtil.of(context);
  var _repo = AddressRepo();
  var _txtPassportNo = TextEditingController(),
      _txtIDCard = TextEditingController(),
      _txtAddress = TextEditingController(),
      _txtPostalCode = TextEditingController();

  MAddress? _country, _province, _district, _commune, _village;

  bool _countryLoading = false,
      _provinceLoading = false,
      _districtLoading = false,
      _communeLoading = false,
      _villageLoading = false,
      _loading = false,
      _initLoading = false;
  List<MAddress> _countries = [],
      _provinces = [],
      _districts = [],
      _communes = [],
      _villages = [];

  var _addressRepo = CustomerRepo();

  @override
  void initState() {
    super.initState();
    _initAddress();
    _initMoreInfo();
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
            _util.language.key('address-info'),
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
          child: BlocBuilder<AddressCubit, AddressState>(
            builder: (context, state) {
              return Stack(
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
                                    _buildTopInfo(),
                                    _buildAddress(),
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
                        ..width(_util.query.width)
                        ..padding(horizontal: 15),
                      child: BuildButton(
                        fontSize: 16,
                        title: "${_util.language.key("update")}",
                        iconData: Remix.edit_box_line,
                        iconSize: 18,
                        onPress: () {
                          _onSubmitted();
                        },
                      ),
                    ),
                  ),
                  if (_initLoading || _loading)
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
              );
            },
          ),
        ),
      ),
    );
  }

  void _initMoreInfo() {
    _txtPassportNo.text = widget.info!.passportNo ?? '';
    _txtPostalCode.text = widget.info!.postalCode ?? '';
    _txtAddress.text =
        widget.info?.address == "N/A" ? "" : widget.info?.address ?? "";
    _txtIDCard.text = widget.info!.peopleIdCard ?? "";
  }

  Future _initAddress() async {
    if (widget.info!.countryId == null) return;
    setState(() => _initLoading = true);
    var result = await _repo.list(MAddressFilter(id: 0, referenceId: 0));
    if (!result.error) {
      _countries = result.data;
      setState(() {});
    } else {
      _util.snackBar(
          message: _util.language.key(result.message),
          status: SnackBarStatus.danger);
    }

    if (_countries.length > 0) {
      /// get countries
      try {
        _country =
            _countries.singleWhere((e) => e.id == widget.info!.countryId);
      } catch (e) {
        _country = null;
      }

      /// get province
      _provinces = await _getAddress(refId: _country?.id ?? 0);

      if (_provinces.length > 0) {
        try {
          _province =
              _provinces.singleWhere((e) => e.id == widget.info!.provinceId);
        } catch (e) {
          _province = null;
        }

        _districts = await _getAddress(refId: _province?.id ?? 0);

        if (_districts.length > 0) {
          try {
            _district =
                _districts.singleWhere((e) => e.id == widget.info!.districtId);
          } catch (e) {
            _district = null;
          }

          /// get commune
          _communes = await _getAddress(refId: _district?.id ?? 0);

          if (_communes.length > 0) {
            try {
              _commune =
                  _communes.singleWhere((e) => e.id == widget.info!.communeId);
            } catch (e) {
              _commune = null;
            }
          }

          /// get village
          _villages = await _getAddress(refId: _commune?.id ?? 0);

          if (_villages.length > 0) {
            try {
              _village =
                  _villages.singleWhere((e) => e.id == widget.info!.villageId);
            } catch (e) {
              _village = null;
            }
          }
        }
      }
    }
    setState(() => _initLoading = false);
  }

  void _onSubmitted() async {
    setState(() => _loading = true);
    var body = widget.info!.copyWith(
      countryId: _country?.id,
      provinceId: _province?.id,
      communeId: _commune?.id,
      districtId: _district?.id,
      villageId: _village?.id,
      postalCode: _txtPostalCode.text.trim(),
      address: _txtAddress.text == "" ? "N/A" : _txtAddress.text,
    );
    var result = await _addressRepo.updateUserMoreInfo(body);

    if (!result.error) {
      var cus = MMyCustomer.fromJson(result.data);
      context.read<MyUserCubit>().update(user: Model.userInfo, customer: cus);
      _util.navigator.replace(
        BuildSuccessScreen(
          successTitle:
              _util.language.key("you-successfully-update-address-info"),
        ),
      );
    } else {
      _util.snackBar(
          message: _util.language.key(result.message),
          status: SnackBarStatus.danger);
    }
    setState(() => _loading = false);
  }

  Future<List<MAddress>> _getAddress({int? refId, int? id}) async {
    if (refId != null && refId == 0) return <MAddress>[];

    var result = await _repo.list(MAddressFilter(id: id, referenceId: refId));

    if (!result.error) {
      return result.data;
    } else {
      _util.snackBar(
          message: _util.language.key(result.message),
          status: SnackBarStatus.danger);
      return <MAddress>[];
    }
  }

  Widget _buildTopInfo() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MyTextField(
                borderWidth: Style.borderWidth,
                labelTextSize: Style.subTitleSize,
                controller: _txtPostalCode,
                readOnly: _loading,
                label: '${_util.language.key("postal-code")}',
                placeholder: _util.language.key('enter-postal-code'),
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: MyTextField(
                borderWidth: Style.borderWidth,
                labelTextSize: Style.subTitleSize,
                controller: _txtAddress,
                readOnly: _loading,
                label: "${_util.language.key("address")}",
                placeholder: "${_util.language.key("enter-address")}",
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddress() {
    return Column(
      children: [
        OCSDropdown(context,
            labelColor: OCSColor.text.withOpacity(0.7),
            labelTextSize: Style.subTitleSize,
            readOnly: _loading,
            label: '${_util.language.key("country")}',
            hinText: _countryLoading
                ? _util.language.key('loading') + '...'
                : _util.language.key('select-country'),
            value: _country, onSelected: (v) async {
          setState(() => _provinceLoading = true);
          _country = v;
          _provinces = await _getAddress(refId: _country?.id);
          _province = null;
          _communes = [];
          _commune = null;
          _districts = [];
          _district = null;
          _villages = [];
          _village = null;
          setState(() => _provinceLoading = false);
        },
            items: _countries
                .map((e) => DropdownMenuItem(
                    child: Txt(
                        '${_util.language.by(km: e.name, en: e.nameEnglish, autoFill: true)}'),
                    value: e))
                .toList()),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OCSDropdown(context,
                  labelColor: OCSColor.text.withOpacity(0.7),
                  labelTextSize: Style.subTitleSize,
                  readOnly: _loading,
                  label: '${_util.language.key("province")}',
                  hinText: _provinceLoading
                      ? _util.language.key('loading') + '...'
                      : _util.language.key('select-province'),
                  value: _province, onSelected: (v) async {
                setState(() => _districtLoading = true);
                _province = v;
                _district = null;
                _districts = await _getAddress(refId: _province?.id);
                _commune = null;
                _villages = [];
                _village = null;
                _communes = [];
                setState(() => _districtLoading = false);
              },
                  items: _provinces
                      .map((e) => DropdownMenuItem(
                          child: Txt(
                              '${_util.language.by(km: e.name, en: e.nameEnglish, autoFill: true)}'),
                          value: e))
                      .toList()),
            ),
            SizedBox(width: 15),
            Expanded(
              child: OCSDropdown(context,
                  labelColor: OCSColor.text.withOpacity(0.7),
                  labelTextSize: Style.subTitleSize,
                  readOnly: _loading,
                  label: '${_util.language.key("district")}',
                  hinText: _districtLoading
                      ? _util.language.key('loading') + '...'
                      : _util.language.key('select-district'),
                  value: _district, onSelected: (v) async {
                setState(() => _communeLoading = true);
                _district = v;
                _communes = await _getAddress(refId: _district?.id);
                _village = null;
                _commune = null;
                _villages = [];

                setState(() => _communeLoading = false);
              },
                  items: _districts
                      .map((e) => DropdownMenuItem(
                          child: Txt(
                              '${_util.language.by(km: e.name, en: e.nameEnglish, autoFill: true)}'),
                          value: e))
                      .toList()),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OCSDropdown(context,
                  labelColor: OCSColor.text.withOpacity(0.7),
                  labelTextSize: Style.subTitleSize,
                  readOnly: _loading,
                  label: "${_util.language.key("commune")}",
                  hinText: _communeLoading
                      ? _util.language.key('loading') + '...'
                      : _util.language.key('select-commune'),
                  value: _commune, onSelected: (v) async {
                setState(() => _villageLoading = true);
                _commune = v;
                _villages = await _getAddress(refId: _commune?.id);
                _village = null;
                setState(() => _villageLoading = false);
              },
                  items: _communes
                      .map((e) => DropdownMenuItem(
                          child: Txt(
                              '${_util.language.by(km: e.name, en: e.nameEnglish, autoFill: true)}'),
                          value: e))
                      .toList()),
            ),
            SizedBox(width: 15),
            Expanded(
              child: OCSDropdown(context,
                  labelColor: OCSColor.text.withOpacity(0.7),
                  labelTextSize: Style.subTitleSize,
                  readOnly: _loading,
                  label: '${_util.language.key("village")}',
                  hinText: _villageLoading
                      ? _util.language.key('loading') + '...'
                      : _util.language.key('select-village'),
                  value: _village, onSelected: (v) async {
                _village = v;
                setState(() {});
              },
                  items: _villages
                      .map(
                        (e) => DropdownMenuItem(
                            child: Txt(
                                '${_util.language.by(km: e.name, en: e.nameEnglish, autoFill: true)}'),
                            value: e),
                      )
                      .toList()),
            ),
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
