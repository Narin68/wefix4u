import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '/screens/select_service_widget.dart';
import '/blocs/service/service_bloc.dart';
import '/modals/service.dart';
import '/screens/widget.dart';

class RequestMoreService extends StatefulWidget {
  final List<MService> services;
  final Function(List<int>? added, List<int> removed) onSubmit;

  RequestMoreService({
    Key? key,
    required this.services,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _RequestMoreServiceState createState() => _RequestMoreServiceState();
}

class _RequestMoreServiceState extends State<RequestMoreService> {
  late var _util = OCSUtil.of(context);

  var _scrollCtr = ScrollController();
  TextEditingController _searchTxt = TextEditingController();
  List<MService> _services = [];
  ServiceBloc? _serviceBloc;

  @override
  void initState() {
    super.initState();
    _scrollCtr.addListener(_onScrollItem);
    _services = _services + widget.services;
    _serviceBloc = context.read<ServiceBloc>();
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
        backgroundColor: OCSColor.primary,
        elevation: 0,
        shadowColor: Colors.white,
      ),
      body: SafeArea(
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
                    leading: NavigatorBackButton(),
                    pinned: false,
                    elevation: 0,
                    title: Txt(
                      _util.language.key('select-service').toUpperCase(),
                      style: TxtStyle()
                        ..fontSize(16)
                        ..textColor(Colors.white),
                    ),
                    iconTheme: IconThemeData(color: OCSColor.text),
                    actionsIconTheme: IconThemeData(color: OCSColor.text),
                    backgroundColor: OCSColor.background,
                    expandedHeight: 110,
                    flexibleSpace: _header(),
                  ),
                  SliverToBoxAdapter(
                    child: _body(),
                  )
                ],
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
                      title: _util.language.key('request'),
                      fontSize: 16,
                      onPress: () {
                        ServiceState? state = _serviceBloc?.state;
                        List<MService> add = [];
                        List<MService> remove = [];
                        List<MService> oldData = [];
                        if (state is ServiceSuccess) {
                          state.selectData?.forEach((e) {
                            var has = _services.any((el) => el.id == e.id);
                            if (has == true)
                              oldData.add(e);
                            else if (has == false) add.add(e);
                          });
                          _services.forEach((e) {
                            var has = oldData.any((el) => e.id == el.id);
                            if (has == false) remove.add(e);
                          });
                          List<int> added = add.map((e) => e.id!).toList();
                          List<int> removed = remove.map((e) => e.id!).toList();

                          widget.onSubmit(added, removed);
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
      context.read<ServiceBloc>().add(GetData());
    }
    setState(() {});
  }

  Future _initData() async {
    context.read<ServiceBloc>().add(InitService(serviceCateId: 0));
  }

  Future _reloadData() async {
    context
        .read<ServiceBloc>()
        .add(ReloadData(search: _searchTxt.text, serviceCateId: 0));
  }

  Widget _body() {
    return Column(
      children: [
        Parent(
          style: ParentStyle()..height(_util.query.height),
          child: BlocBuilder<ServiceBloc, ServiceState>(
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
                // return _serviceLoading(15);

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
                  return Parent(
                    style: ParentStyle()..padding(bottom: 100),
                    child: BuildNoDataScreen(),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<ServiceBloc>().add(ReloadData());
                  },
                  child: Parent(
                    style: ParentStyle()..minHeight(_util.query.height),
                    child: AlignedGridView.count(
                      shrinkWrap: true,
                      physics: AlwaysScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      controller: _scrollCtr,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      padding: EdgeInsets.only(
                          top: 10,
                          left: 15,
                          right: 15,
                          bottom: 250 +
                              _util.query.bottom +
                              (_util.query.isKbPopup
                                  ? _util.query.kbHeight - 20
                                  : 0)),
                      scrollDirection: Axis.vertical,
                      itemCount: state.hasReach!
                          ? state.data?.length
                          : state.data!.length + 1,
                      itemBuilder: (context, i) {
                        bool select = false;
                        if ((state.data != null || state.data!.length > 0)) {
                          if (i < state.data!.length &&
                              state.selectData != null) {
                            select = state.selectData!
                                .any((e) => e.code == state.data?[i].code);
                          }
                        }

                        return i >= state.data!.length
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
                                    autoFill: true),
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

  Widget _header() {
    return FlexibleSpaceBar(
      background: Parent(
        style: ParentStyle()
          ..margin(bottom: 5)
          ..borderRadius(bottomRight: 5, bottomLeft: 5)
          ..background.color(OCSColor.primary)
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
