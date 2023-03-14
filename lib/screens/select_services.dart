import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '/screens/auths/login.dart';
import '/blocs/service/service_bloc.dart';
import '/globals.dart';
import '/modals/service.dart';
import 'function_temp.dart';
import 'more/request_partner/request_partner_form.dart';
import '/screens/widget.dart';

import 'request_service/request_form.dart';
import 'select_service_widget.dart';

class SelectServices extends StatefulWidget {
  final int serviceCateId;
  final String actionType;
  final String serviceCateName;

  SelectServices({
    Key? key,
    this.serviceCateId = 0,
    this.actionType = 'request-service',
    this.serviceCateName = '',
  }) : super(key: key);

  @override
  _SelectServicesState createState() => _SelectServicesState();
}

class _SelectServicesState extends State<SelectServices> {
  late var _util = OCSUtil.of(context);

  var _scrollCtr = ScrollController();
  List<MService> _services = [];
  TextEditingController _searchTxt = TextEditingController();
  bool _loading = false;
  bool _isComingSoon = false;

  @override
  void initState() {
    super.initState();
    _scrollCtr.addListener(_onScrollItem);
    widget.actionType == 'request-service'
        ? clearApplyServiceModel()
        : clearApplyPartnerData();
    _initData();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollCtr.removeListener(_onScrollItem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: _isComingSoon ? Colors.white : OCSColor.primary,
        elevation: 0,
        shadowColor: Colors.white,
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Parent(
          style: ParentStyle()..height(_util.query.height),
          child: Stack(
            children: [
              CustomScrollView(
                physics: NeverScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    centerTitle: true,
                    leading: NavigatorBackButton(
                      iconColor: _isComingSoon ? OCSColor.text : Colors.white,
                    ),
                    pinned: false,
                    elevation: 1,
                    title: Txt(
                      widget.serviceCateName.isEmpty
                          ? _util.language.key('select-service').toUpperCase()
                          : widget.serviceCateName,
                      style: TxtStyle()
                        ..fontSize(Style.titleSize)
                        ..textColor(
                            _isComingSoon ? OCSColor.text : Colors.white),
                    ),
                    iconTheme: IconThemeData(color: OCSColor.text),
                    actionsIconTheme: IconThemeData(color: OCSColor.text),
                    backgroundColor:
                        _isComingSoon ? Colors.white : OCSColor.background,
                    collapsedHeight: _isComingSoon ? null : 110,
                    flexibleSpace: _isComingSoon ? SizedBox() : _header(),
                  ),
                  SliverToBoxAdapter(
                    child: _body(),
                  )
                ],
              ),
              if (!_isComingSoon)
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
                        ripple: _services.isNotEmpty,
                        onPress: _services.isEmpty
                            ? null
                            : () {
                                if (_loading) return;
                                if (_services.length > 0) {
                                  if (!Globals.hasAuth) {
                                    Globals.isRequestService = true;
                                    _util.navigator.to(Login());
                                    return;
                                  }
                                  widget.actionType == "request-service"
                                      ? _util.navigator.to(RequestForm(),
                                          transition: OCSTransitions.LEFT)
                                      : _util.navigator.to(RequestPartnerForm(),
                                          transition: OCSTransitions.LEFT);
                                } else if (_services.length <= 0) {
                                  _util.snackBar(
                                    message:
                                        _util.language.key("select-service"),
                                    status: SnackBarStatus.warning,
                                  );
                                }
                              },
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  void _onScrollItem() {
    final _max = _scrollCtr.position.maxScrollExtent;
    final _currScroll = _scrollCtr.position.pixels;
    bool _scrollAtBottom = _max - _currScroll <= 0;
    if (_scrollAtBottom) {
      context
          .read<ServiceBloc>()
          .add(GetData(serviceCateId: widget.serviceCateId));
    }
    setState(() {});
  }

  Future _initData() async {
    context
        .read<ServiceBloc>()
        .add(InitService(serviceCateId: widget.serviceCateId));
  }

  Future _reloadData() async {
    context.read<ServiceBloc>().add(ReloadData(
        search: _searchTxt.text, serviceCateId: widget.serviceCateId));
  }

  Widget _body() {
    return Column(
      children: [
        Parent(
          style: ParentStyle()..height(_util.query.height),
          child: BlocConsumer<ServiceBloc, ServiceState>(
            listener: (context, state) {
              if (state is ServiceLoading) {
                _loading = true;
                setState(() {});
              }
              if (state is ServiceFailure) {
                _loading = false;
                setState(() {});
              }
              if (state is ServiceSuccess) {
                _loading = false;
                if (widget.serviceCateId > 0) {
                  if (state.data!.isEmpty && _searchTxt.text == '')
                    _isComingSoon = true;
                }
                _services = state.selectData ?? [];
                setState(() {});
              }
            },
            builder: (context, state) {
              if (state is ServiceInitial) {
                return Parent(
                    style: ParentStyle()
                      ..height(200)
                      ..padding(bottom: 150),
                    child: Center(
                      child: CircularProgressIndicator.adaptive(),
                    ));
              }
              if (state is ServiceLoading) {
                return Parent(
                    style: ParentStyle()..padding(bottom: 200),
                    child: Center(
                      child: CircularProgressIndicator.adaptive(),
                    ));
              }
              if (state is ServiceFailure) {
                return Parent(
                  style: ParentStyle()
                    ..height(200)
                    ..padding(bottom: 150),
                  child: BuildErrorBloc(
                    message: state.message,
                    onRetry: _initData,
                  ),
                );
              }
              if (state is ServiceSuccess) {
                if (state.data?.isEmpty ?? false) {
                  if (_searchTxt.text.isNotEmpty || widget.serviceCateId == 0) {
                    return Parent(
                      style: ParentStyle()..padding(bottom: 100),
                      child: BuildNoDataScreen(),
                    );
                  } else if (widget.serviceCateId > 0) {
                    return Parent(
                      style: ParentStyle()
                        ..height(_util.query.height)
                        ..background.color(Colors.white),
                      child: _comingSoonScreen(),
                    );
                  }
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    context
                        .read<ServiceBloc>()
                        .add(ReloadData(serviceCateId: widget.serviceCateId));
                  },
                  child: Parent(
                    style: ParentStyle()..minHeight(_util.query.height),
                    child: AlignedGridView.count(
                      shrinkWrap: true,
                      physics: AlwaysScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      controller: _scrollCtr,
                      padding: EdgeInsets.only(
                        top: 10,
                        left: 15,
                        right: 15,
                        bottom: 250 +
                            _util.query.bottom +
                            (_util.query.isKbPopup
                                ? _util.query.kbHeight - 20
                                : 0),
                      ),
                      scrollDirection: Axis.vertical,
                      itemCount: state.hasReach!
                          ? state.data?.length
                          : state.data!.length + 1,
                      itemBuilder: (context, i) {
                        bool select = false;
                        if ((state.data != null || state.data!.length > 0)) {
                          if (i < (state.data?.length ?? 0) &&
                              state.selectData != null) {
                            select = (state.selectData ?? [])
                                .any((e) => e.code == state.data?[i].code);
                          }
                        }

                        return i >= (state.data?.length ?? 0)
                            ? Parent(
                                style: ParentStyle()..margin(vertical: 20),
                                child: const Center(
                                  child: CircularProgressIndicator.adaptive(),
                                ),
                              )
                            : buildServiceBox(
                                onPress: () {
                                  context
                                      .read<ServiceBloc>()
                                      .add(SelectService(data: state.data?[i]));
                                },
                                onLongPress: () {
                                  serviceDetailDialog(context,
                                      data: state.data![i]);
                                },
                                title: _util.language.by(
                                  km: state.data?[i].name,
                                  en: state.data?[i].nameEnglish,
                                  autoFill: true,
                                ),
                                src: state.data?[i].imagePath,
                                select: select,
                              );
                      },
                    ),
                  ),
                );
              }
              return SizedBox();
            },
          ),
        ),
        // SizedBox(height: 60),
      ],
    );
  }

  Widget _comingSoonScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: SizedBox()),
        Parent(
          style: ParentStyle(),
          child: Image.asset(
            'assets/images/coming-soon.png',
            width: 70,
            height: 70,
          ),
        ),
        Txt(
          _util.language.key('coming-soon'),
          style: TxtStyle()
            ..alignmentContent.center()
            ..margin(top: 16)
            ..fontSize(Style.titleSize)
            ..textColor(OCSColor.text),
        ),
        Expanded(flex: 2, child: SizedBox()),
        // SizedBox(height: 100),
      ],
    );
  }

  Widget _header() {
    return FlexibleSpaceBar(
      background: Parent(
        style: ParentStyle()
          ..margin(bottom: 5)
          ..borderRadius(bottomRight: 5, bottomLeft: 5)
          ..background.color(OCSColor.primary)
          ..elevation(1, opacity: 1)
          ..boxShadow(
              color: OCSColor.primary.withOpacity(0.8),
              blur: 2,
              offset: Offset(0, 1)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Parent(
              style: ParentStyle()..padding(all: 16, vertical: 10),
              child: Stack(
                children: [
                  Positioned(
                    top: 13,
                    left: 15,
                    child: Parent(
                      style: ParentStyle(),
                      child: Icon(
                        Remix.search_line,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  TextField(
                    readOnly: _loading,
                    controller: _searchTxt,
                    autofocus: false,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14.0,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintStyle: TextStyle(
                        fontSize: 13.5,
                        fontFamily: 'kmFont',
                        fontWeight: FontWeight.w100,
                        color: Colors.white,
                      ),
                      border: InputBorder.none,
                      hintText: _util.language.key('search'),
                      filled: true,
                      fillColor: Colors.white38,
                      contentPadding: const EdgeInsets.only(
                          left: 50.0, bottom: 5.0, top: 5.0),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: OCSColor.primary),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.grey.withOpacity(0.1)),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    cursorColor: OCSColor.primary,
                    onSubmitted: (v) async {
                      await _reloadData();
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
