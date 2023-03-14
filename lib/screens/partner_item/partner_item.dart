import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '/globals.dart';
import '/screens/widget.dart';
import '/blocs/partner_item/partner_item_bloc.dart';
import '/modals/partner_item.dart';
import '/repositories/partner_item_repo.dart';
import '../more/request_partner/widget.dart';
import 'add_item.dart';

class PartnerItem extends StatefulWidget {
  const PartnerItem({Key? key}) : super(key: key);

  @override
  State<PartnerItem> createState() => _PartnerItemState();
}

class _PartnerItemState extends State<PartnerItem> {
  late var _util = OCSUtil.of(context);
  var _scrollCtr = ScrollController();
  bool _loading = false;
  bool _isSuccess = true;
  PartnerItemRepo _repo = PartnerItemRepo();

  @override
  void initState() {
    super.initState();
    _scrollCtr.addListener(_onScrollItem);
    _init();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollCtr.removeListener(_onScrollItem);
  }

  void _onScrollItem() {
    final _max = _scrollCtr.position.maxScrollExtent;
    final _currScroll = _scrollCtr.position.pixels;
    if (_currScroll >= _max) {
      _getData();
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
        appBar: AppBar(
          leading: IconButton(
            tooltip: _util.language.key('close'),
            icon: Icon(
              Remix.close_line,
              size: 24,
            ),
            onPressed: () {
              if (!_loading) _util.navigator.pop();
            },
          ),
          title: Row(
            children: [
              Txt(
                _util.language.key('product-and-service'),
                style: TxtStyle()
                  ..textColor(Colors.white)
                  ..fontSize(Style.titleSize),
              ),
            ],
          ),
          backgroundColor: OCSColor.primary,
        ),
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: () async {
              _init();
            },
            child: Stack(
              children: [
                Parent(
                    style: ParentStyle()..height(_util.query.height),
                    child: BlocConsumer<PartnerItemBloc, PartnerItemState>(
                      listener: (_, state) {
                        if (state is PartnerItemFailure) {
                          _isSuccess = false;
                          setState(() {});
                        }
                        if (state is PartnerItemSuccess) {
                          _isSuccess = true;
                          setState(() {});
                        }
                      },
                      builder: (context, state) {
                        if (state is PartnerItemLoading) {
                          return Center(
                            child: CircularProgressIndicator.adaptive(),
                          );
                        }
                        if (state is PartnerItemFailure) {
                          return BuildErrorBloc(
                            message: state.message,
                            onRetry: _init,
                          );
                        }
                        if (state is PartnerItemSuccess) {
                          if (state.data!.isEmpty) return BuildNoDataScreen();
                          return ListView.builder(
                              padding: EdgeInsets.only(
                                  top: 15, left: 15, right: 15, bottom: 80),
                              physics: AlwaysScrollableScrollPhysics(),
                              controller: _scrollCtr,
                              itemCount: state.hasMax!
                                  ? state.data?.length
                                  : (state.data?.length ?? 0) + 1,
                              itemBuilder: (_, i) {
                                return i >= (state.data?.length ?? 0)
                                    ? Parent(
                                        style: ParentStyle()
                                          ..margin(vertical: 20),
                                        child: const Center(
                                          child: CircularProgressIndicator
                                              .adaptive(),
                                        ),
                                      )
                                    : Parent(
                                        gesture: Gestures()
                                          ..onTap(() {
                                            showModalBottomSheet(
                                                context: context,
                                                backgroundColor:
                                                    Colors.transparent,
                                                builder:
                                                    (BuildContext context) {
                                                  return _itemAction(
                                                      state.data![i]);
                                                });
                                          }),
                                        style: ParentStyle()
                                          ..width(_util.query.width)
                                          ..padding(all: 15, vertical: 15)
                                          ..background.color(Colors.white)
                                          ..borderRadius(all: 5)
                                          ..margin(bottom: 10)
                                          ..ripple(true),
                                        child: Stack(
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                // Image
                                                Parent(
                                                  style: ParentStyle()
                                                    ..width(50)
                                                    ..height(50)
                                                    ..borderRadius(all: 60)
                                                    ..padding(all: 10),
                                                  child: Image.asset(
                                                      'assets/images/repair-tools.png'),
                                                ),

                                                SizedBox(width: 20),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Txt(
                                                        _util.language.by(
                                                            en: state.data?[i]
                                                                .nameEnglish,
                                                            km: state
                                                                .data?[i].name,
                                                            autoFill: true),
                                                        style: TxtStyle()
                                                          ..fontSize(Style
                                                              .subTitleSize)
                                                          ..textColor(
                                                              OCSColor.text),
                                                      ),
                                                      Txt(
                                                        OCSUtil.currency(
                                                          state.data?[i]
                                                                  .unitPrice ??
                                                              0,
                                                          sign: '\$',
                                                          autoDecimal: false,
                                                        ),
                                                        style: TxtStyle()
                                                          ..fontSize(Style
                                                              .subTitleSize)
                                                          ..fontWeight(
                                                              FontWeight.bold)
                                                          ..textColor(
                                                              Colors.green),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: Txt(
                                                OCSUtil.dateFormat(
                                                  state.data?[i].createdDate ??
                                                      "",
                                                  format: Format.dateTime,
                                                ),
                                                style: TxtStyle()
                                                  ..fontSize(12)
                                                  ..textColor(OCSColor.text
                                                      .withOpacity(0.7)),
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                              });
                        }
                        return SizedBox();
                      },
                    )),
                if (!_util.query.isKbPopup && _isSuccess)
                  Positioned(
                    bottom: _util.query.bottom <= 0 ? 15 : _util.query.bottom,
                    child: Parent(
                      style: ParentStyle()
                        ..alignment.center()
                        ..width(_util.query.width)
                        ..padding(all: 15, bottom: 0),
                      child: BuildButton(
                        title: _util.language.key('add-item'),
                        fontSize: 16,
                        onPress: () {
                          _util.navigator
                              .to(AddItem(), transition: OCSTransitions.LEFT);
                        },
                        iconData: Remix.add_line,
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
      ),
    );
  }

  Future _onDelete(int id) async {
    _util.navigator.pop();
    setState(() {
      _loading = true;
    });
    var _res = await _repo.delete(id: id);
    if (!_res.error) {
      context.read<PartnerItemBloc>().add(DeleteItem(id: id));
      _util.snackBar(
          message: _util.language.key('success'),
          status: SnackBarStatus.success);
    } else {
      _util.snackBar(message: _res.message, status: SnackBarStatus.danger);
    }
    setState(() {
      _loading = false;
    });
  }

  Widget _itemAction(MPartnerServiceItemData data) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Parent(
          style: ParentStyle()
            // ..height(150 + _util.query.bottom)
            ..background.color(Colors.white)
            ..padding(all: 10, top: 5)
            ..width(_util.query.width)
            ..borderRadius(all: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Txt(
                _util.language
                    .by(km: data.name, en: data.nameEnglish, autoFill: true),
                style: TxtStyle()
                  ..fontSize(16)
                  ..maxLines(2)
                  ..textAlign.center()
                  ..textColor(Colors.black87),
              ),
              SizedBox(height: 5),
              Column(
                children: [
                  buildActionModal(
                    icon: Remix.edit_line,
                    onPress: () {
                      _util.navigator.pop();
                      _util.navigator.to(
                        AddItem(
                          data: data,
                          isUpdate: true,
                        ),
                        transition: OCSTransitions.UP,
                      );
                    },
                    color: Colors.green,
                    title: _util.language.key('update'),
                  ),
                  buildActionModal(
                    icon: Remix.delete_bin_line,
                    onPress: () {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          contentPadding: EdgeInsets.only(
                            bottom: 0,
                            top: 20,
                            left: 25,
                            right: 15,
                          ),
                          title: Txt(
                            _util.language.key('delete-item'),
                            style: TxtStyle()
                              ..fontSize(16)
                              ..textColor(OCSColor.text.withOpacity(0.7)),
                          ),
                          content: Txt(
                            _util.language.key('do-you-want-to-delete'),
                            style: TxtStyle()
                              ..fontSize(14)
                              ..textColor(OCSColor.text.withOpacity(0.7)),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'Cancel'),
                              child: Txt(
                                _util.language.key('no'),
                                style: TxtStyle()
                                  ..textColor(OCSColor.text.withOpacity(0.6)),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _util.navigator.pop();
                                _onDelete(data.id!);
                              },
                              child: Txt(
                                _util.language.key('yes'),
                                style: TxtStyle()..textColor(Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    color: Colors.red,
                    title: _util.language.key('delete'),
                  ),
                ],
              ),
              SizedBox(height: _util.query.bottom + 5)
            ],
          ),
        ),
      ],
    );
  }

  void _getData() {
    context.read<PartnerItemBloc>().add(FetchPartnerItem());
  }

  void _init() {
    context.read<PartnerItemBloc>()
      ..add(ReloadItem())
      ..add(FetchPartnerItem(isInit: true));
  }
}
