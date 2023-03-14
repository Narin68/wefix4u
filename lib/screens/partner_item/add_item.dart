import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import '/screens/widget.dart';
import '/blocs/partner_item/partner_item_bloc.dart';
import '/globals.dart';
import '/modals/partner_item.dart';
import '/repositories/partner_item_repo.dart';

class AddItem extends StatefulWidget {
  final bool isUpdate;
  final MPartnerServiceItemData? data;

  const AddItem({Key? key, this.isUpdate = false, this.data}) : super(key: key);

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  late var _util = OCSUtil.of(context);
  TextEditingController _txtName = TextEditingController(),
      _txtEnName = TextEditingController(),
      _txtUnitPrice = TextEditingController(),
      _txtUnitType = TextEditingController(),
      _txtDesc = TextEditingController();

  PartnerItemRepo _repo = PartnerItemRepo();
  var _form = GlobalKey<FormState>();
  bool _loading = false;
  MPartnerServiceItemData? _data;

  @override
  void initState() {
    super.initState();
    if (widget.isUpdate) _initData();
  }

  _initData() {
    _data = widget.data!;
    _txtEnName.text = _data?.nameEnglish ?? "";
    _txtName.text = _data?.name ?? "";
    _txtUnitPrice.text = _data?.unitPrice.toString() ?? "";
    _txtUnitType.text = _data?.unitType ?? "";
    _txtDesc.text = _data?.description ?? "";
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
          leading: NavigatorBackButton(loading: _loading),
          title: Txt(
            _util.language.key(widget.isUpdate ? 'update-item' : 'add-item'),
            style: TxtStyle()
              ..textColor(Colors.white)
              ..fontSize(16),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Parent(
                  style: ParentStyle()
                    ..padding(all: 15, bottom: 15, top: 20)
                    ..height(_util.query.isKbPopup
                        ? _util.query.height - 350
                        : _util.query.height),
                  child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: MyTextField(
                                borderWidth: 1,
                                labelTextSize: Style.subTitleSize,
                                textInputAction: TextInputAction.next,
                                controller: _txtName,
                                backgroundColor: Colors.white,
                                placeholder: _util.language.key('enter-name'),
                                label: _util.language.key('name'),
                                validator: (v) {
                                  if (v!.isEmpty)
                                    return _util.language
                                        .key('this-field-is-required');
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: MyTextField(
                                borderWidth: 1,
                                labelTextSize: Style.subTitleSize,
                                textInputAction: TextInputAction.next,
                                controller: _txtEnName,
                                backgroundColor: Colors.white,
                                placeholder:
                                    _util.language.key('enter-eng-name'),
                                label: _util.language.key('eng-name'),
                              ),
                            )
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: MyTextField(
                                borderWidth: 1,
                                labelTextSize: Style.subTitleSize,
                                textInputAction: TextInputAction.next,
                                textInputType: TextInputType.numberWithOptions(
                                  decimal: true,
                                  signed: false,
                                ),
                                controller: _txtUnitPrice,
                                backgroundColor: Colors.white,
                                placeholder:
                                    _util.language.key('enter-unit-price'),
                                label: _util.language.key('unit-price'),
                                validator: (v) {
                                  if (v!.isEmpty)
                                    return _util.language
                                        .key('this-field-is-required');
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: MyTextField(
                                borderWidth: 1,
                                labelTextSize: Style.subTitleSize,
                                textInputAction: TextInputAction.next,
                                controller: _txtUnitType,
                                backgroundColor: Colors.white,
                                placeholder:
                                    _util.language.key('enter-unit-type'),
                                label: _util.language.key('unit-type'),
                                validator: (v) {
                                  if (v!.isEmpty)
                                    return _util.language
                                        .key('this-field-is-required');
                                  return null;
                                },
                              ),
                            )
                          ],
                        ),
                        // SizedBox(height: 5),
                        MyTextArea(
                          controller: _txtDesc,
                          label: _util.language.key('description'),
                          placeHolder: _util.language.key('enter-description'),
                          labelSize: 12,
                        ),
                        Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                ),
              ),
              if (!_util.query.isKbPopup)
                Positioned(
                  bottom: _util.query.bottom <= 0 ? 15 : _util.query.bottom,
                  child: Parent(
                    style: ParentStyle()
                      ..alignment.center()
                      ..width(_util.query.width)
                      ..padding(horizontal: 15),
                    child: BuildButton(
                      title: _util.language
                          .key(widget.isUpdate ? 'update' : 'add'),
                      fontSize: 16,
                      onPress: widget.isUpdate ? _onUpdate : _onSubmit,
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

  Future _onSubmit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _loading = true;
    });
    var _res = await _repo.add(MPartnerServiceItem(
      partnerId: Model.partner.id,
      name: _txtName.text.trim(),
      nameEnglish: _txtEnName.text.trim(),
      unitType: _txtUnitType.text.trim(),
      unitPrice: double.parse(_txtUnitPrice.text.trim()),
      description: _txtDesc.text,
    ));
    if (!_res.error) {
      _txtName.clear();
      _txtEnName.clear();
      _txtUnitType.clear();
      _txtUnitPrice.clear();
      _txtDesc.clear();
      context.read<PartnerItemBloc>()
        ..add(ReloadItem())
        ..add(FetchPartnerItem(isInit: true));
      _util.snackBar(message: 'success', status: SnackBarStatus.success);
    } else {
      _util.snackBar(message: _res.message, status: SnackBarStatus.danger);
    }
    setState(() {
      _loading = false;
    });
  }

  Future _onUpdate() async {
    if (!_form.currentState!.validate()) return;
    if (_data?.name == _txtName.text.trim() &&
        _data?.nameEnglish == _txtEnName.text &&
        _data?.unitType == _txtUnitType.text &&
        _data?.unitPrice == double.parse(_txtUnitPrice.text) &&
        (_data?.description == _txtDesc.text ||
            (_data?.description == null && _txtDesc.text.isEmpty))) {
      _util.pop();
      return;
    }
    setState(() {
      _loading = true;
    });

    var _res = await _repo.update(MPartnerServiceItem(
      partnerId: Model.partner.id,
      name: _txtName.text.trim(),
      nameEnglish: _txtEnName.text.trim(),
      unitType: _txtUnitType.text.trim(),
      unitPrice: double.parse(_txtUnitPrice.text.trim()),
      description: _txtDesc.text,
      id: widget.data?.id,
    ));
    if (!_res.error) {
      _util.navigator.pop();
      context.read<PartnerItemBloc>().add(UpdateItem(data: _res.data));
      _util.snackBar(message: 'success', status: SnackBarStatus.success);
    } else {
      _util.snackBar(message: _res.message, status: SnackBarStatus.danger);
    }
    setState(() {
      _loading = false;
    });
  }
}
