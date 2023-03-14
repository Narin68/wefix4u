import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ocs_auth/ocs_auth.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '/screens/function_temp.dart';
import '/screens/widget.dart';
import '../request_partner/widget.dart';
import '/globals.dart';
import '/modals/customer.dart';
import '/modals/address_filter.dart';
import '/repositories/address.dart';
import '/modals/address.dart';
import '/blocs/user/user_cubit.dart';
import '/screens/more/editProfile/widget.dart';

import 'edit_address.dart';
import 'edit_general_info.dart';
import 'edit_more_info.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late var _util = OCSUtil.of(context);

  FocusNode focusNode = FocusNode();
  MUserInfo _user = MUserInfo();
  MMyCustomer _customer = MMyCustomer();
  MAddress? _country, _province, _commune, _district, _village;
  bool _basicInfoLoading = false;
  Uint8List? _photo;
  late var _auth = OCSAuth.instance;
  String? _profileImage;
  bool _imageLoading = false;
  String _fullAddress = '';
  String _gender = '';
  String _address = '';
  bool _loading = false;
  bool isBackRed = false;
  ScrollController _scrollCtr = ScrollController();

  var _repo = AddressRepo();

  @override
  void initState() {
    super.initState();
    _getUserInfo();
    _scrollCtr.addListener(_onScroll);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollCtr.removeListener(_onScroll);
  }

  _onScroll() {
    var _curr = _scrollCtr.position.pixels;
    if (_curr >= 74) {
      isBackRed = true;
    } else {
      isBackRed = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_loading) _util.navigator.pop();
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 0,
          shadowColor: Colors.white,
          elevation: 0,
        ),
        body: SafeArea(
          top: false,
          child: _loading
              ? Center(
                  child: CircularProgressIndicator.adaptive(),
                )
              : BlocConsumer<MyUserCubit, MyUserState>(
                  listener: (context, state) {
                    if (state is MyUserLoading) {
                      setState(() {
                        _loading = true;
                      });
                    }

                    if (state is MyUserSuccess) {
                      setState(() {
                        _loading = false;
                      });
                      _user = state.user!;
                      _fullAddress = state.customer?.address == "N/A"
                          ? ""
                          : state.customer?.address == null
                              ? ""
                              : state.customer!.address! + ", ";
                      _customer = state.customer!;
                      _gender =
                          state.user?.gender == null || state.user?.gender == ''
                              ? 'N/A'
                              : _util.language
                                  .key('${state.user?.gender?.toLowerCase()}');

                      _profileImage = state.user?.imagePath ?? "";

                      if (_address == '') {
                        _initAddress(_customer);
                      } else
                        _fullAddress += _address;
                      setState(() {});
                    }
                    if (state is MyUserFailure) {
                      setState(() {
                        _loading = false;
                      });
                      _util.snackBar(
                          message: state.message,
                          status: SnackBarStatus.danger);
                      setState(() {});
                    }
                  },
                  builder: (context, state) {
                    if (state is MyUserLoading) {
                      return Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    }
                    if (state is MyUserFailure) {
                      return BuildErrorBloc(
                        message: state.message,
                        onRetry: _getUserInfo,
                      );
                    }
                    if (state is MyUserSuccess) {
                      var lastName = Model.userInfo.lastName;
                      if (Model.userInfo.lastName?.indexOf(".") == 0)
                        lastName = lastName?.replaceFirst('.', '');
                      return CustomScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        controller: _scrollCtr,
                        slivers: [
                          SliverAppBar(
                            leading: NavigatorBackButton(loading: _loading),
                            pinned: true,
                            elevation: isBackRed ? 1 : 0,
                            backgroundColor:
                                isBackRed ? OCSColor.primary : OCSColor.white,
                            title: Txt(
                              _util.language.key('user-info'),
                              style: TxtStyle()
                                ..fontSize(Style.titleSize)
                                ..textColor(Colors.white),
                            ),
                            centerTitle: true,
                            expandedHeight: 180,
                            flexibleSpace: FlexibleSpaceBar(
                              background: _buildHeader(state.user!),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: _buildBody(lastName ?? ""),
                          )
                        ],
                      );
                    }
                    return SizedBox();
                  },
                ),
        ),
      ),
    );
  }

  void _initAddress(MMyCustomer? info) async {
    if (info?.countryId == null || info?.countryId == 0) return;
    setState(() => _basicInfoLoading = true);
    _country = await _getAddress(id: info?.countryId);

    _province = info?.provinceId != null && info?.provinceId != 0
        ? await _getAddress(id: info?.provinceId, refId: _country?.id)
        : null;

    _district = info?.districtId != null && info?.districtId != 0
        ? await _getAddress(id: info?.districtId, refId: _province?.id)
        : null;

    _commune = info?.communeId != null && info?.communeId != 0
        ? await _getAddress(id: info?.communeId, refId: _district?.id)
        : null;

    _village = info?.villageId != null && info?.villageId != 0
        ? await _getAddress(id: info?.villageId, refId: _commune?.id)
        : null;

    _address += _village != null
        ? _util.language.by(
                km: _village?.name, en: _village?.nameEnglish, autoFill: true) +
            ", "
        : '';
    _address += _commune != null
        ? _util.language.by(
                km: _commune?.name, en: _commune?.nameEnglish, autoFill: true) +
            ", "
        : '';
    _address += _district != null
        ? _util.language.by(
                km: _district?.name,
                en: _district?.nameEnglish,
                autoFill: true) +
            ", "
        : '';
    _address += _province != null
        ? _util.language.by(
              km: _province?.name,
              en: _province?.nameEnglish,
              autoFill: true,
            ) +
            ", "
        : '';
    _address += _country != null
        ? _util.language
            .by(km: _country?.name, en: _country?.nameEnglish, autoFill: true)
        : '';

    _fullAddress += _address;
    setState(() => _basicInfoLoading = false);
  }

  Future<MAddress?> _getAddress({int? refId, int? id}) async {
    if (refId != null && refId == 0) return MAddress();

    var result = await _repo.list(MAddressFilter(id: id, referenceId: refId));

    if (!result.error) {
      List<MAddress> data = result.data;

      if (data.length > 0) {
        return data.first;
      }
    } else {
      _util.snackBar(
          message: _util.language.key(result.message),
          status: SnackBarStatus.danger);
      return MAddress();
    }
    return null;
  }

  Future _onPressGallery() async {
    var image = await getImageByGallery();
    if (image != null) {
      _util.navigator.pop();
      _photo = await image.readAsBytes();
      await _updatePhoto();
      setState(() {});
    }
  }

  Future _onPressTakePhoto() async {
    var photo = await getImageByTakeCamera();
    if (photo != null) {
      _util.navigator.pop();
      _photo = await photo.readAsBytes();
      await _updatePhoto();
      setState(() {});
    }
  }

  Future _onRemoveImage() async {
    if (_photo != null) {
      _photo = null;
    } else if (_profileImage != '' || _profileImage != null) {
      _profileImage = '';
      await _updatePhoto();
    }
    setState(() {});
  }

  Future _getUserInfo() async {
    context.read<MyUserCubit>().get(getCustomer: true, loadingWidget: false);
    _user = _user.copyWith(imagePath: Model.userInfo.imagePath);
    setState(() {
      _loading = false;
    });
  }

  Future _updatePhoto({bool isChangeImage = true}) async {
    setState(() {
      _imageLoading = true;
    });
    final result = await _auth.userUpdate(MUserUpdateInfoHeader(
      firstName: _user.firstName,
      lastName: _user.lastName,
      userName: _user.loginName,
      dateOfBirth: _user.dateOfBirth,
      gender: _user.gender,
      isChangeImage: isChangeImage,
      image: _photo ?? Uint8List.fromList([]),
    ));

    if (!result.error) {
      MUserInfo userInfo = result.data!;
      Model.userInfo = userInfo;
      context
          .read<MyUserCubit>()
          .update(customer: Model.customer, user: userInfo);
    } else {
      _util.snackBar(message: result.message, status: SnackBarStatus.danger);
    }
    setState(() {
      _imageLoading = false;
    });
  }

  Widget _buildBody(String lastName) {
    return Parent(
      style: ParentStyle()..padding(horizontal: 5, vertical: 10, top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildUserHeadTitle(
            title: "${_util.language.key("general-info")}",
            onPress: () {
              _util.navigator.to(
                EditGeneralInfo(
                  user: Model.userInfo,
                ),
                transition: OCSTransitions.LEFT,
              );
            },
          ),
          buildUserInfo(
              title: "${_util.language.key("name")}",
              subTitle: "${Model.userInfo.firstName} ${lastName}"),
          buildUserInfo(
              title: "${_util.language.key("gender")}", subTitle: _gender),
          buildUserInfo(
              title: "${_util.language.key("date-of-birth")}",
              subTitle:
                  "${Model.userInfo.dateOfBirth == null ? "" : OCSUtil.dateFormat(DateTime.parse(Model.userInfo.dateOfBirth ?? ''), format: Format.date, langCode: Globals.langCode)}"),
          buildUserHeadTitle(
            title: "${_util.language.key("more-information")}",
            onPress: () {
              _util.navigator.to(
                  EditMoreUserInfo(user: Model.userInfo, info: Model.customer),
                  transition: OCSTransitions.LEFT);
            },
          ),
          buildUserInfo(
              title: "${_util.language.key("passport-no")}",
              subTitle: Model.customer.passportNo ?? ""),
          buildUserInfo(
              title: "${_util.language.key("id-card")}",
              subTitle: Model.customer.peopleIdCard ?? ""),
          _basicInfoLoading == true
              ? Parent(
                  style: ParentStyle()..margin(top: 100),
                  child: Center(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator.adaptive(
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildUserHeadTitle(
                      title: "${_util.language.key("address-info")}",
                      onPress: () {
                        _address = '';
                        _util.navigator.to(
                            EditAddress(
                                user: Model.userInfo, info: Model.customer),
                            transition: OCSTransitions.LEFT);
                      },
                    ),
                    buildUserInfo(
                      title: "${_util.language.key("postal-code")}",
                      subTitle: Model.customer.postalCode ?? "",
                    ),
                    buildUserInfo(
                      title: "${_util.language.key("address")}",
                      subTitle: _fullAddress,
                    ),
                  ],
                )
        ],
      ),
    );
  }

  Widget _buildHeader(MUserInfo user) {
    return Center(
      child: Parent(
        style: ParentStyle()..width(_util.query.width),
        child: Center(
          child: Stack(
            children: [
              Parent(
                style: ParentStyle()
                  ..height(120)
                  ..borderRadius(bottomRight: 5, bottomLeft: 5)
                  ..width(_util.query.width)
                  ..padding(bottom: 5)
                  ..elevation(1, opacity: 0.5)
                  ..boxShadow(
                      color: OCSColor.primary.withOpacity(0.8),
                      blur: 5,
                      offset: Offset(0, 1))
                  ..background.color(OCSColor.primary),
              ),
              Parent(
                style: ParentStyle(),
                child: Column(
                  children: [
                    SizedBox(height: 50),
                    Center(
                      child: Parent(
                        style: ParentStyle()
                          ..width(_util.query.width)
                          ..padding(all: 10, bottom: 10),
                        child: Center(
                          child: Stack(
                            children: [
                              _buildProfile(user),
                              _buildEditProfileIcon(),
                            ],
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
    );
  }

  Widget _buildProfile(MUserInfo user) {
    return Parent(
      gesture: Gestures()
        ..onTap(() {
          if (!_imageLoading) {
            _util.navigator.to(MyViewImage(
              url: Model.userInfo.imagePath,
              // byteImage: _photo,
              onErrorImage: Globals.userAvatarImage,
            ));
          }
        }),
      style: ParentStyle()
        ..borderRadius(all: 50)
        ..overflow.hidden()
        ..background.color(Colors.white)
        ..boxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.15),
          offset: Offset(0, 2),
          blur: 4.0,
        )
        ..width(100)
        ..height(100)
        ..overflow.hidden(),
      child: _imageLoading
          ? Parent(
              style: ParentStyle()..padding(all: 40),
              child: Image.asset(
                'assets/images/loading.gif',
                height: 20,
                width: 20,
                fit: BoxFit.cover,
              ),
            )
          : user.imagePath == null || user.imagePath == ""
              ? Image.asset(
                  Globals.userAvatarImage,
                  fit: BoxFit.cover,
                )
              : MyCacheNetworkImage(
                  url: user.imagePath ?? '',
                  defaultAssetImage: Globals.userAvatarImage,
                  iconSize: 20,
                ),
    );
  }

  Widget _buildEditProfileIcon() {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Visibility(
        visible: true,
        child: Parent(
          gesture: Gestures()
            ..onTap(() async {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return _buildImageAction();
                },
              );
            }),
          style: ParentStyle()
            ..background.color(OCSColor.primary)
            ..width(30)
            ..height(30)
            ..borderRadius(all: 50)
            ..ripple(true)
            ..padding(all: 1)
            ..border(all: 2, color: Colors.white),
          child: Icon(
            Remix.camera_line,
            size: 15,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildImageAction() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Parent(
          style: ParentStyle()
            ..background.color(Colors.white)
            ..borderRadius(topLeft: 5, topRight: 5)
            ..padding(all: 10, top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Txt(
                "${_util.language.key("edit-image")}",
                style: TxtStyle()
                  ..fontSize(16)
                  ..textColor(Colors.black87),
              ),
              SizedBox(height: 5),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildActionModal(
                        icon: Remix.camera_fill,
                        onPress: _onPressTakePhoto,
                        title: "${_util.language.key("take-photo")}",
                        color: Colors.blue),
                    buildActionModal(
                      color: Colors.orangeAccent,
                      icon: Remix.image_2_line,
                      onPress: _onPressGallery,
                      title: "${_util.language.key("gallery")}",
                    ),
                    if (_profileImage != '' || _photo != null)
                      buildActionModal(
                        color: Colors.red,
                        icon: Remix.delete_bin_fill,
                        onPress: () async {
                          if (_profileImage == '' && _photo == null) {
                            _util.snackBar(
                                message: "${_util.language.key("no-image")}",
                                status: SnackBarStatus.danger);
                            return;
                          }
                          _util.navigator.pop();
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => Parent(
                              style: ParentStyle(),
                              child: AlertDialog(
                                contentPadding: EdgeInsets.only(
                                    left: 25, top: 15, bottom: 5, right: 15),
                                title: Txt(
                                  '${_util.language.key("remove-user-image")}',
                                  style: TxtStyle()
                                    ..textColor(OCSColor.text)
                                    ..fontSize(16),
                                ),
                                content: Parent(
                                  style: ParentStyle(),
                                  child: Txt(
                                    '${_util.language.key("are-you-want-to-remove-image")}',
                                    style: TxtStyle()
                                      ..textColor(Colors.black54)
                                      ..fontSize(14),
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'Cancel'),
                                    child: Txt(
                                      '${_util.language.key("cancel")}',
                                      style: TxtStyle()
                                        ..textColor(Colors.black87),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      _util.navigator.pop();
                                      await _onRemoveImage();
                                    },
                                    child: Txt(
                                      '${_util.language.key("remove")}',
                                      style: TxtStyle()..textColor(Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        title: "${_util.language.key("remove")}",
                      ),
                    SizedBox(height: _util.query.bottom + 5),
                  ]),
            ],
          ),
        ),
      ],
    );
  }
}
