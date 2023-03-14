import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import '/screens/widget.dart';
import '/modals/wallet.dart';
import '/globals.dart';
import '/repositories/wallet_repo.dart';

class VerifyBankAccount extends StatefulWidget {
  final Function(MWalletData) onSuccess;

  final bool isUpdate;

  const VerifyBankAccount(
      {Key? key, required this.onSuccess, this.isUpdate = false})
      : super(key: key);

  @override
  State<VerifyBankAccount> createState() => _VerifyBankAccountState();
}

class _VerifyBankAccountState extends State<VerifyBankAccount> {
  TextEditingController _txtAccount = TextEditingController();
  TextEditingController _txtBankName = TextEditingController();
  TextEditingController _txtAccountName = TextEditingController();
  var _form = GlobalKey<FormState>();
  late var _util = OCSUtil.of(context);
  bool _loading = false;
  List<String> _bankNamesEn = [
    "ABA",
    "ACLEDA",
    "SATHAPANA",
    "Canadia",
    "Prince",
    "Vattanac"
  ];

  String _selectedBank = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!widget.isUpdate)
          await _createWallet(true);
        else
          return true;

        return false;
      },
      child: Dialog(
        backgroundColor: Colors.white,
        child: Parent(
          style: ParentStyle()..maxWidth(Globals.maxScreen),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Parent(
                    style: ParentStyle()
                      ..borderRadius(topRight: 5, topLeft: 5)
                      ..background.color(OCSColor.background)
                      ..width(MediaQuery.of(context).size.width)
                      ..margin(bottom: 5)
                      ..padding(all: 10, horizontal: 15),
                    child: Txt(
                      _util.language.key('verify-your-bank-account'),
                      style: TxtStyle()
                        ..fontSize(16)
                        ..textColor(OCSColor.text),
                    ),
                  ),
                  Parent(
                    style: ParentStyle()..padding(all: 15, top: 10),
                    child: Form(
                      key: _form,
                      child: Column(
                        children: [
                          MyTextField(
                            controller: _txtAccount,
                            label: _util.language.key('bank-account'),
                            textInputType: TextInputType.numberWithOptions(
                              decimal: false,
                              signed: false,
                            ),
                            placeholder:
                                _util.language.key('input-account-number'),
                            validator: (v) {
                              if (widget.isUpdate) if (v!.isEmpty)
                                return _util.language
                                    .key('this-field-is-required');

                              if (_txtBankName.text.isNotEmpty &&
                                  _txtAccount.text.isEmpty) {
                                return _util.language
                                    .key('this-field-is-required');
                              }
                              return null;
                            },
                            noStar: !widget.isUpdate,
                          ),
                          MyTextField(
                            placeholder:
                                _util.language.key('input-account-name'),
                            controller: _txtAccountName,
                            label: _util.language.key('account-name'),
                            validator: (v) {
                              if (widget.isUpdate) if (v!.isEmpty)
                                return _util.language
                                    .key('this-field-is-required');

                              if (_txtAccountName.text.isNotEmpty &&
                                  _txtAccountName.text.isEmpty) {
                                return _util.language
                                    .key('this-field-is-required');
                              }
                              return null;
                            },
                            noStar: !widget.isUpdate,
                          ),
                          OCSDropdown(
                            context,
                            validator: !widget.isUpdate
                                ? null
                                : (v) {
                                    if (widget.isUpdate) if (v!.isEmpty)
                                      return _util.language
                                          .key('this-field-is-required');

                                    if (_txtAccount.text.isNotEmpty &&
                                        _txtBankName.text.isEmpty) {
                                      return _util.language
                                          .key('this-field-is-required');
                                    }
                                    return null;
                                  },
                            autoValidateMode:
                                AutovalidateMode.onUserInteraction,
                            onSelected: (v) {
                              _selectedBank = v;
                              _txtBankName.text = v;
                            },
                            hinText: _selectedBank.isEmpty
                                ? _util.language.key("select-bank")
                                : _selectedBank,
                            label: _util.language.key('bank'),
                            value: _selectedBank.isEmpty ? null : _selectedBank,
                            items: _bankNamesEn
                                .map(
                                  (e) => DropdownMenuItem(
                                    child: Txt(e),
                                    value: e,
                                  ),
                                )
                                .toList(),
                          )
                        ],
                      ),
                    ),
                  ),
                  Parent(
                    style: ParentStyle()
                      ..padding(vertical: 15, horizontal: 15, top: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        BuildSecondButton(
                          title: _util.language.key('cancel'),
                          fontSize: 14,
                          width: 100,
                          height: 40,
                          onPress: () async {
                            if (!widget.isUpdate)
                              await _createWallet(true);
                            else
                              _util.pop();
                          },
                        ),
                        SizedBox(width: 10),
                        BuildButton(
                          title: _util.language.key('create'),
                          fontSize: 14,
                          width: 100,
                          height: 40,
                          onPress: () async {
                            if (!_form.currentState!.validate()) return;
                            setState(() {
                              _loading = true;
                            });
                            widget.isUpdate
                                ? await _updateWallet()
                                : await _createWallet(false);
                            setState(() {
                              _loading = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_loading)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      color: Colors.black12,
                      height: 375,
                      child: Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future _createWallet(bool close) async {
    var _res = await WalletRepo().createWallet(
      bankAccount: _txtAccount.text,
      bankName: _txtBankName.text,
      accountName: _txtAccountName.text,
    );
    if (close) _util.pop();
    if (_res.error) {
      if (!close)
        _util.snackBar(
          message: _res.message,
          status: SnackBarStatus.danger,
        );
    } else {
      if (_txtAccount.text.isNotEmpty)
        _util.snackBar(
          message: _util.language.key("success"),
          status: SnackBarStatus.success,
        );
      widget.onSuccess(_res.data);
      if (!close) _util.pop();
    }
  }

  Future _updateWallet() async {
    var _res = await WalletRepo().updateWallet(
      Model.userWallet?.id ?? 0,
      bankAccount: _txtAccount.text,
      bankName: _txtBankName.text,
      accountName: _txtAccountName.text,
    );
    if (_res.error) {
      _util.snackBar(
        message: _res.message,
        status: SnackBarStatus.danger,
      );
    } else {
      _util.snackBar(
        message: _util.language.key("success"),
        status: SnackBarStatus.success,
      );
      widget.onSuccess(_res.data);
      _util.pop();
    }
  }
}

//
// Future _noCustomer(BuildContext context, MUserInfo userInfo) async {
//   var _util = OCSUtil.of(context);
//   var cusResp =
//   await _customerRepo.list(MMyCustomerFilter(code: userInfo.loginName));
//   if (Globals.userType.toLowerCase() == "customer") {
//     if (!cusResp.error) {
//       _customer =
//       cusResp.data.length < 1 ? MMyCustomer() : (cusResp.data ?? []).first;
//       Model.customer = _customer;
//       _util.navigator.replace(HomeMenus(), isFade: true);
//     } else {
//       _util.navigator.replace(HomeMenus(), isFade: true);
//     }
//   } else if (Globals.userType.toLowerCase() == "partner") {
//     if (!cusResp.error) {
//       _customer =
//       cusResp.data.length < 1 ? MMyCustomer() : (cusResp.data ?? []).first;
//       var res = await _partnerRepo.getPartner(_customer.id);
//       if (!res.error) {
//         var partner = res.data.length < 1 ? MPartner() : (res.data ?? []).first;
//         Model.customer = _customer;
//         Model.partner = partner;
//         _util.navigator.replace(HomeMenus(), isFade: true);
//       }
//     }
//   }
// }
//
// Future _hasCustomer(BuildContext context) async {
//   var _util = OCSUtil.of(context);
//   if (Globals.userType.toLowerCase() == "customer") {
//     _util.navigator.replace(HomeMenus(), isFade: true);
//   } else if (Globals.userType.toLowerCase() == "partner") {
//     if (Model.partner.id != null) {
//       _util.navigator.replace(HomeMenus(), isFade: true);
//     } else {
//       var res = await _partnerRepo.getPartner(Model.customer.id);
//       if (!res.error) {
//         var partner = res.data.length < 1 ? MPartner() : (res.data ?? []).first;
//
//         Model.partner = partner;
//         _util.navigator.replace(HomeMenus(), isFade: true);
//       }
//     }
//   }
// }
