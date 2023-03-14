import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import '/globals.dart';
import '/screens/widget.dart';
import '/modals/address.dart';
import '/modals/address_filter.dart';
import '/repositories/address.dart';

class SelectCoverage extends StatefulWidget {
  final List<MAddress>? checkedList;
  final List<MAddress>? listAddress;
  final Function(
      {List<MAddress> checked,
      List<MAddress> listAddress,
      List<int>? ids})? onSubmit;

  SelectCoverage({this.checkedList, this.onSubmit, this.listAddress});

  @override
  _SelectCoverageState createState() => _SelectCoverageState();
}

class _SelectCoverageState extends State<SelectCoverage> {
  Map<String, dynamic>? formData;

  late var _util = OCSUtil.of(context);
  var _repo = AddressRepo();

  bool _provinceLoading = false,
      _districtLoading = false,
      _communeLoading = false,
      _villageLoading = false,
      _initLoading = false;
  List<MAddress> _provinces = [];

  List<MAddress> _checkedAddress = [];
  List<MAddress> _listAddress = [];
  late var theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
  final List<GlobalKey<ExpansionTileCardState>> _tileCardProvinces = [];
  final List<GlobalKey<ExpansionTileCardState>> _tileCardDistricts = [];
  final List<GlobalKey<ExpansionTileCardState>> _tileCardCommunes = [];
  final List<GlobalKey<ExpansionTileCardState>> _tileCardVillages = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future _initData() async {
    _checkedAddress = _checkedAddress + widget.checkedList!;
    if (widget.listAddress != null) {
      _addGlobalKey();
    }

    if (_listAddress.isEmpty) await _getProvince();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: OCSColor.primary,
        title: Txt(
          _util.language.key('select-coverage'),
          style: TxtStyle()
            ..fontSize(16)
            ..textColor(Colors.white),
        ),
        leading: NavigatorBackButton(),
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Parent(
              style: ParentStyle()..minHeight(_util.query.height),
              child: _provinceLoading == true
                  ? Parent(
                      style: ParentStyle()
                        ..height(600)
                        ..alignmentContent.center(),
                      child: Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    )
                  : _provinces.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Parent(
                              style: ParentStyle(),
                              child: Image.asset(
                                'assets/images/no-data.png',
                                width: 90,
                                height: 90,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Center(
                              child: Txt(
                                _util.language.key('not-available-coverage'),
                                style: TxtStyle()
                                  ..fontSize(16)
                                  ..textColor(OCSColor.text),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _provincesList(),
                            SizedBox(),
                          ],
                        ),
            ),
            if (_provinces.isNotEmpty)
              Positioned(
                bottom: _util.query.bottom <= 0 ? 15 : _util.query.bottom,
                child: Parent(
                  style: ParentStyle()
                    ..alignment.center()
                    ..padding(all: 15, bottom: 0)
                    ..width(_util.query.width),
                  child: BuildButton(
                    title: _util.language.key('done'),
                    fontSize: Style.titleSize,
                    onPress: _onSubmit,
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

  void _onSubmit() {
    List<int> _ids = get(0, []);
    List<MAddress> _checked = [];
    _ids.forEach((e) {
      MAddress loc = _listAddress.where((i) => i.id == e).first;
      _checked.add(loc);
    });
    print(_ids);
    _util.navigator.pop();
    if (widget.onSubmit != null)
      widget.onSubmit!(
        checked: _checked,
        listAddress: _listAddress,
        ids: _ids,
      );
  }

  void _addGlobalKey() {
    _listAddress = _listAddress + widget.listAddress!;
    _provinces = _listAddress
        .where((e) => e.type!.toLowerCase() == "provinces")
        .toList();
    List<MAddress> _districts = _listAddress
        .where((e) => e.type!.toLowerCase() == "districts")
        .toList();

    List<MAddress> _communes =
        _listAddress.where((e) => e.type!.toLowerCase() == "communes").toList();

    _provinces.forEach((e) {
      _tileCardProvinces.add(GlobalKey());
    });
    _districts.forEach((e) {
      _tileCardDistricts.add(GlobalKey());
    });
    _communes.forEach((e) {
      _tileCardCommunes.add(GlobalKey());
    });
  }

  Future _getProvince() async {
    setState(() {
      _provinceLoading = true;
    });
    var result = await _repo.getCoverage();
    if (!result.error) {
      setState(() {
        _provinceLoading = false;
      });
      _listAddress = result.data;
      _provinces = _listAddress;
      for (var i = 0; i < _listAddress.length; i++) {
        _tileCardProvinces.add(GlobalKey());
        for (var j = 0; j < _checkedAddress.length; j++) {
          if (_listAddress[i].id == _checkedAddress[j].id) {
            _listAddress[i] = _checkedAddress[j];
          }
        }
      }
    } else {
      _util.snackBar(
          message: _util.language.key(result.message),
          status: SnackBarStatus.danger);
    }

    setState(() {});
  }

  get(int id, List<int> list) {
    if (id == 0) {
      List<MAddress> province = _listAddress
          .where((e) => e.type?.toLowerCase() == "provinces")
          .toList();
      province.forEach((e) {
        return get(e.id!, list);
      });
    }
    final has = _listAddress.where((e) => e.referenceId == id).toList();
    if (has.isEmpty) {
      _listAddress.forEach((e) {
        if (e.id == id) {
          if (e.selected == false && e.someSelected == true) {
            list.add(id);
          } else if (e.selected == true) {
            list.add(e.id!);
          }
        }
      });
      return list.toSet().toList();
    }

    _listAddress.forEach((e) {
      if (e.id == id) {
        if (e.selected == false && e.someSelected == true) {
          list.add(id);
          has.forEach((i) {
            return get(i.id!, list);
          });
        } else if (e.selected == true) {
          list.add(e.id!);
        }
      }
    });
  }

  _onCheckAddress(int id, List<MAddress> list) {
    if (id > 0) {
      List<MAddress> _child =
          _listAddress.where((e) => e.referenceId == id).toList();

      var safe = _listAddress.where((e) => e.id == id).first;

      list.add(safe);
      _checkedAddress.add(safe);

      for (var i = 0; i < _listAddress.length; i++) {
        if (_listAddress[i].id == id) {
          _listAddress[i] = _listAddress[i].copyWith(selected: true);
        }
      }

      if (_child.isNotEmpty) {
        for (var i = 0; i < _listAddress.length; i++) {
          var has = _child.where((e) => e.id == _listAddress[i].id);
          if (has.isNotEmpty) {
            _listAddress[i] =
                _listAddress[i].copyWith(selected: true, someSelected: false);
          }
        }

        _child.forEach((e) {
          return _onCheckAddress(e.id ?? 0, list);
        });
      } else {
        return list;
      }
    } else {
      return list;
    }
  }

  _onUncheckAddress(int id, List<MAddress> list) {
    if (id > 0) {
      List<MAddress> _child =
          _listAddress.where((e) => e.referenceId == id).toList();

      var safe = _listAddress.where((e) => e.id == id).first;

      list.add(safe);
      _checkedAddress.removeWhere((e) => e.id == id);

      for (var i = 0; i < _listAddress.length; i++) {
        if (_listAddress[i].id == id) {
          _listAddress[i] =
              _listAddress[i].copyWith(selected: false, someSelected: false);
        }
      }

      if (_child.isNotEmpty) {
        for (var i = 0; i < _listAddress.length; i++) {
          var has = _child.where((e) => e.id == _listAddress[i].id);
          if (has.isNotEmpty) {
            _listAddress[i] =
                _listAddress[i].copyWith(selected: false, someSelected: false);
          }
        }

        _child.forEach((e) {
          return _onUncheckAddress(e.id ?? 0, list);
        });
      } else {
        return list;
      }
    } else {
      return list;
    }
  }

  _checkSomeSelect(int id) {
    var safe = _listAddress.where((e) => e.id == id).first;
    var parent = _listAddress.where((e) => e.id == safe.referenceId).first;
    if (id > 0) {
      if (parent.type!.toLowerCase() != 'provinces')
        return _checkSomeSelect(parent.id ?? 0);
      else if (parent.type!.toLowerCase() == 'provinces') {
        List<MAddress> list = [];
        list.add(parent);
        list.addAll(_findChild(parent.id ?? 0, []) ?? []);
        list = list.reversed.toList();
        for (var i = 0; i < list.length; i++) {
          var child = list.where((e) => list[i].id == e.referenceId).toList();
          MAddress? curr = _changeStatus(list[i].id ?? 0, child);
          if (curr != null) list[i] = curr;
          setState(() {});
        }
        return;
      }
    }
  }

  _changeStatus(int id, List<MAddress> list) {
    var curr = _listAddress.where((e) => e.id == id).first;
    if (list.isNotEmpty) {
      var selectAll =
          list.every((e) => e.selected == true && e.someSelected == false);
      var someSelect =
          list.any((e) => e.selected == true || e.someSelected == true);
      if (!someSelect) {
        for (int i = 0; i < _listAddress.length; i++) {
          if (_listAddress[i].id == id) {
            _listAddress[i] =
                _listAddress[i].copyWith(someSelected: false, selected: false);
            curr = curr.copyWith(someSelected: false, selected: false);
          }
        }
      } else if (selectAll) {
        for (int i = 0; i < _listAddress.length; i++) {
          if (_listAddress[i].id == id) {
            _listAddress[i] =
                _listAddress[i].copyWith(selected: true, someSelected: false);
            curr = curr.copyWith(selected: true, someSelected: false);
          }
        }
      } else if (someSelect) {
        for (int i = 0; i < _listAddress.length; i++) {
          if (_listAddress[i].id == id) {
            _listAddress[i] =
                _listAddress[i].copyWith(someSelected: true, selected: false);
            curr = curr.copyWith(someSelected: true, selected: false);
          }
        }
      }
      return curr;
    }
    setState(() {});
  }

  _findChild(int id, List<MAddress> list) {
    var _child = _listAddress.where((e) => e.referenceId == id).toList();
    if (id > 0) {
      if (_child.isNotEmpty) {
        _child.forEach((e) {
          list.add(e);
          return _findChild(e.id ?? 0, list);
        });
        return _findChild(0, list);
      } else {
        return list;
      }
    } else {
      return list;
    }
  }

  Future<List<MAddress>> _getAddress({int? refId, int? id}) async {
    if (refId != null && refId == 0) return <MAddress>[];

    var result = await _repo.list(MAddressFilter(id: id, referenceId: refId));

    if (!result.error) {
      setState(() {});
      return result.data;
    } else {
      _util.snackBar(
          message: _util.language.key(result.message),
          status: SnackBarStatus.danger);
      setState(() {});
      return <MAddress>[];
    }
  }

  void _onChange(value, int id) {
    if (value ?? true) {
      _onCheckAddress(id, []);
    } else {
      _onUncheckAddress(id, []);
    }
    _checkSomeSelect(id);

    setState(() {});
  }

  Future<List<MAddress>> _getMoreAddress(int id) async {
    List<MAddress> _list = await _getAddress(refId: id);

    MAddress _parent = _listAddress.where((e) => e.id == id).first;
    if (_parent.selected == true && _parent.someSelected == false) {
      for (var i = 0; i < _list.length; i++) {
        _list[i] = _list[i].copyWith(selected: true);
      }
    }

    _listAddress += _list;
    return _list;
  }

  Widget _provincesList() {
    var list = _listAddress
        .where((e) => e.type!.toLowerCase() == "provinces")
        .toList();
    return Parent(
      style: ParentStyle()..height(_util.query.height - 80),
      child: ListView.builder(
          padding: EdgeInsets.only(
            bottom: _util.query.bottom + 70,
          ),
          primary: true,
          shrinkWrap: true,
          itemCount: list.length,
          itemBuilder: (_, i) {
            return Theme(
              data: theme,
              child: ExpansionTileCard(
                contentPadding: EdgeInsets.only(left: 5, right: 5),
                borderRadius: BorderRadius.all(Radius.circular(3)),
                key: _tileCardProvinces[i],
                leading: Parent(
                  style: ParentStyle(),
                  child: Checkbox(
                    tristate: list[i].someSelected!,
                    value: list[i].someSelected! ? null : list[i].selected,
                    onChanged: (bool? value) async {
                      if (value ?? true) {
                        _onCheckAddress(list[i].id ?? 0, []);
                      } else {
                        _onUncheckAddress(list[i].id ?? 0, []);
                      }
                      setState(() {});
                    },
                  ),
                ),
                title: Txt(
                  '${_util.language.by(km: list[i].name, en: list[i].nameEnglish, autoFill: true)}',
                  style: TxtStyle()
                    ..fontSize(15)
                    ..textColor(OCSColor.text),
                ),
                children: [_districtList(list[i])],
                onExpansionChanged: (bool expanded) async {
                  if (expanded) {
                    for (var j = 0; j < _tileCardProvinces.length; j++) {
                      if (j != i) {
                        _tileCardProvinces[j].currentState?.collapse();
                      }
                    }
                  }
                  if (expanded) {
                    var has =
                        _listAddress.any((e) => e.referenceId == list[i].id);
                    if (!has) {
                      setState(() {
                        _districtLoading = true;
                      });
                      List<MAddress> _list =
                          await _getMoreAddress(list[i].id ?? 0);
                      setState(() {
                        _districtLoading = false;
                      });
                      _list.forEach((e) {
                        _tileCardDistricts.add(GlobalKey());
                      });
                    }
                  }
                },
              ),
            );
          }),
    );
  }

  Widget _districtList(MAddress province) {
    List<MAddress> list =
        _listAddress.where((e) => e.referenceId == province.id).toList();

    return _districtLoading
        ? Parent(
            style: ParentStyle()
              ..height(170)
              ..alignmentContent.center(),
            child: CircularProgressIndicator.adaptive(),
          )
        : Parent(
            style: ParentStyle()..margin(left: 15),
            child: ListView.builder(
                padding: EdgeInsets.only(right: 15),
                primary: false,
                shrinkWrap: true,
                itemCount: list.length,
                itemBuilder: (_, i) {
                  return Theme(
                    data: theme,
                    child: ExpansionTileCard(
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      key: _tileCardDistricts[i],
                      leading: Parent(
                        style: ParentStyle(),
                        child: Checkbox(
                          tristate: list[i].someSelected!,
                          value:
                              list[i].someSelected! ? null : list[i].selected,
                          onChanged: (bool? value) async {
                            _onChange(value, list[i].id ?? 0);
                          },
                        ),
                      ),
                      title: Txt(
                        '${_util.language.by(km: list[i].name, en: list[i].nameEnglish, autoFill: true)}',
                        style: TxtStyle()
                          ..fontSize(14)
                          ..textColor(OCSColor.text),
                      ),
                      children: [
                        _communeList(district: list[i]),
                      ],
                      onExpansionChanged: (bool expanded) async {
                        if (expanded) {
                          for (var j = 0; j < _tileCardDistricts.length; j++) {
                            if (j != i) {
                              _tileCardDistricts[j].currentState?.collapse();
                            }
                          }
                        }
                        if (expanded) {
                          var has = _listAddress
                              .any((e) => e.referenceId == list[i].id);
                          if (!has) {
                            setState(() {
                              _communeLoading = true;
                            });

                            List<MAddress> _list =
                                await _getMoreAddress(list[i].id ?? 0);

                            setState(() {
                              _communeLoading = false;
                            });
                            _list.forEach((e) {
                              _tileCardCommunes.add(GlobalKey());
                            });
                          }
                        }
                      },
                    ),
                  );
                }),
          );
  }

  Widget _communeList({MAddress? district}) {
    var list =
        _listAddress.where((e) => e.referenceId == district?.id).toList();
    return _communeLoading
        ? Parent(
            style: ParentStyle()
              ..height(170)
              ..alignmentContent.center(),
            child: CircularProgressIndicator.adaptive(),
          )
        : Parent(
            style: ParentStyle()..margin(left: 15),
            child: ListView.builder(
                padding: EdgeInsets.only(right: 15),
                primary: false,
                shrinkWrap: true,
                itemCount: _listAddress
                    .where((e) => e.referenceId == district?.id)
                    .length,
                itemBuilder: (_, i) {
                  return Theme(
                    data: theme,
                    child: ExpansionTileCard(
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      key: _tileCardCommunes[i],
                      leading: Parent(
                        style: ParentStyle(),
                        child: Checkbox(
                          tristate: list[i].someSelected!,
                          value:
                              list[i].someSelected! ? null : list[i].selected,
                          onChanged: (bool? value) async {
                            _onChange(value, list[i].id ?? 0);
                          },
                        ),
                      ),
                      title: Txt(
                        '${_util.language.by(km: list[i].name, en: list[i].nameEnglish, autoFill: true)}',
                        style: TxtStyle()
                          ..fontSize(14)
                          ..textColor(OCSColor.text),
                      ),
                      children: [
                        _villageList(commune: list[i]),
                      ],
                      onExpansionChanged: (bool expanded) async {
                        if (expanded) {
                          for (var j = 0; j < _tileCardCommunes.length; j++) {
                            if (j != i) {
                              _tileCardCommunes[j].currentState?.collapse();
                            }
                          }
                        }
                        var has = _listAddress
                            .any((e) => e.referenceId == list[i].id);
                        if (!has) {
                          setState(() {
                            _villageLoading = true;
                          });
                          var _list = await _getMoreAddress(list[i].id ?? 0);
                          setState(() {
                            _villageLoading = false;
                          });
                          _list.forEach((e) {
                            _tileCardVillages.add(GlobalKey());
                          });
                        }
                      },
                    ),
                  );
                }),
          );
  }

  Widget _villageList({MAddress? commune}) {
    var list = _listAddress.where((e) => e.referenceId == commune?.id).toList();
    return _villageLoading
        ? Parent(
            style: ParentStyle()
              ..height(170)
              ..alignmentContent.center(),
            child: CircularProgressIndicator.adaptive(),
          )
        : Parent(
            style: ParentStyle()..margin(left: 40),
            child: ListView.builder(
                primary: false,
                shrinkWrap: true,
                itemCount: list.length,
                itemBuilder: (_, i) {
                  return Row(
                    children: [
                      Parent(
                        style: ParentStyle(),
                        child: Checkbox(
                          tristate: list[i].someSelected!,
                          value:
                              list[i].someSelected! ? null : list[i].selected,
                          onChanged: (bool? value) async {
                            _onChange(value, list[i].id ?? 0);
                          },
                        ),
                      ),
                      SizedBox(width: 15),
                      Txt(
                        '${_util.language.by(km: list[i].name, en: list[i].nameEnglish, autoFill: true)}',
                        style: TxtStyle()
                          ..fontSize(14)
                          ..textColor(OCSColor.text),
                      ),
                    ],
                  );
                }),
          );
  }
}
