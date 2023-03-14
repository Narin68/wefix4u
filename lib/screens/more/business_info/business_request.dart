import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '/blocs/business/business_bloc.dart';
import '/screens/widget.dart';
import '/globals.dart';
import 'business_request_detail.dart';

class BusinessRequest extends StatefulWidget {
  const BusinessRequest({Key? key}) : super(key: key);

  @override
  State<BusinessRequest> createState() => _BusinessRequestState();
}

class _BusinessRequestState extends State<BusinessRequest> {
  late var _util = OCSUtil.of(context);
  TxtStyle _txtStyle = TxtStyle()
    ..fontSize(Style.subTitleSize)
    ..textColor(OCSColor.text)
    ..margin(right: 5);
  TxtStyle _title = TxtStyle()
    ..fontSize(Style.subTextSize)
    ..textColor(OCSColor.text.withOpacity(0.7))
    ..margin(right: 5);
  ScrollController _scrollCtr = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<BusinessBloc>()
      ..add(ReloadBusinessRequest())
      ..add(FetchedBusinessRequest(refId: Model.partner.id, isInit: true));
    _scrollCtr.addListener(_onScroll);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollCtr.removeListener(_onScroll);
  }

  Future _init() async {
    context.read<BusinessBloc>()
      ..add(ReloadBusinessRequest())
      ..add(FetchedBusinessRequest(refId: Model.partner.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: OCSColor.primary,
        title: Txt(
          _util.language.key('business-request'),
          style: TxtStyle()
            ..fontSize(Style.titleSize)
            ..textColor(Colors.white),
        ),
        leading: NavigatorBackButton(),
      ),
      body: Parent(
        style: ParentStyle()..height(_util.query.height),
        child: BlocBuilder<BusinessBloc, BusinessState>(
          builder: (context, state) {
            if (state is BusinessInitial)
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                ],
              );
            if (state is BusinessLoading)
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                ],
              );
            if (state is BusinessFailure) {
              return BuildErrorBloc(
                message: state.message,
                onRetry: () {
                  _init();
                },
              );
            }
            if (state is BusinessSuccess) {
              if (state.data!.isEmpty) return BuildNoDataScreen();
              return RefreshIndicator(
                onRefresh: _init,
                child: Parent(
                  style: ParentStyle()..height(_util.query.height),
                  child: ListView.builder(
                    padding: EdgeInsets.all(15),
                    controller: _scrollCtr,
                    itemCount: state.hasReach!
                        ? state.data?.length
                        : state.data!.length + 1,
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemBuilder: (_, i) {
                      return i >= state.data!.length
                          ? Parent(
                              style: ParentStyle()..padding(all: 30),
                              child: Center(
                                child: CircularProgressIndicator.adaptive(),
                              ),
                            )
                          : Parent(
                              gesture: Gestures()
                                ..onTap(() {
                                  if (state.data![i].id == null) return;
                                  _util.navigator.to(
                                      BusinessRequestDetail(
                                        id: state.data![i].id!,
                                        header: state.data![i],
                                      ),
                                      transition: OCSTransitions.LEFT);
                                }),
                              style: ParentStyle()
                                ..width(_util.query.width)
                                ..padding(all: 10, horizontal: 15)
                                ..margin(bottom: 10)
                                ..ripple(true)
                                ..borderRadius(all: 4)
                                ..background.color(Colors.white),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      Txt(
                                        "${DateFormat("dd").format(DateTime.parse(state.data![i].createdDate ?? ""))}",
                                        style: TxtStyle()
                                          ..fontSize(Style.titleSize)
                                          ..textColor(Colors.teal),
                                      ),
                                      Txt(
                                        "${OCSUtil.dateFormat(DateTime.parse(state.data![i].createdDate ?? ""), format: "MMM yyyy", langCode: Globals.langCode)}",
                                        style: TxtStyle()
                                          ..fontSize(Style.subTextSize)
                                          ..textColor(
                                              OCSColor.text.withOpacity(0.7)),
                                      )
                                    ],
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                  ),
                                  Parent(
                                    style: ParentStyle()
                                      ..border(
                                          left: 1,
                                          color: OCSColor.text.withOpacity(0.2))
                                      ..margin(left: 15, right: 15)
                                      ..maxHeight(50),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (state.data![i].addedCoverages.length >
                                              0 ||
                                          state.data![i].removedCoverages
                                                  .length >
                                              0) ...[
                                        Row(
                                          children: [
                                            Icon(
                                              Remix.pin_distance_line,
                                              size: 18,
                                              color: OCSColor.text,
                                            ),
                                            Txt(
                                              _util.language.key('coverage'),
                                              style: TxtStyle()
                                                ..fontSize(Style.subTitleSize)
                                                ..margin(left: 5)
                                                ..textColor(OCSColor.text),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Txt(
                                              _util.language.key('added'),
                                              style: _title,
                                            ),
                                            Txt(
                                              "${state.data![i].addedCoverages.length}",
                                              style: _txtStyle,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Txt(
                                              _util.language.key('removed'),
                                              style: _title,
                                            ),
                                            Txt(
                                              "${state.data![i].removedCoverages.length}",
                                              style: _txtStyle,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                      ],
                                      if (state.data![i].addedServices.length >
                                              0 ||
                                          state.data![i].removedServices
                                                  .length >
                                              0) ...[
                                        Row(
                                          children: [
                                            Icon(
                                              Remix.tools_line,
                                              size: 18,
                                              color: OCSColor.text,
                                            ),
                                            Txt(
                                              _util.language.key('service'),
                                              style: TxtStyle()
                                                ..fontSize(Style.subTitleSize)
                                                ..margin(left: 5)
                                                ..textColor(OCSColor.text),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Txt(
                                              _util.language.key('added'),
                                              style: _title,
                                            ),
                                            Txt(
                                              "${state.data![i].addedServices.length}",
                                              style: _txtStyle,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Txt(
                                              _util.language.key('removed'),
                                              style: _title,
                                            ),
                                            Txt(
                                              "${state.data![i].removedServices.length}",
                                              style: _txtStyle,
                                            )
                                          ],
                                        ),
                                      ]
                                    ],
                                  ),
                                  Expanded(child: SizedBox()),
                                  Parent(
                                    style: ParentStyle(),
                                    child: Txt(
                                      '${_util.language.key('${state.data![i].status?.toLowerCase()}')}',
                                      style: TxtStyle()
                                        ..fontSize(Style.subTextSize)
                                        ..textColor(
                                          state.data![i].status!
                                                      .toLowerCase() ==
                                                  'pending'
                                              ? Colors.orange
                                              : state.data![i].status!
                                                          .toLowerCase() ==
                                                      'rejected'
                                                  ? Colors.red
                                                  : Colors.green,
                                        ),
                                    ),
                                  ),
                                ],
                              ),
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
    );
  }

  _onScroll() {
    final _max = _scrollCtr.position.maxScrollExtent;
    final _currScroll = _scrollCtr.position.pixels;

    if (_currScroll >= _max) {
      context
          .read<BusinessBloc>()
          .add(FetchedBusinessRequest(refId: Model.partner.id));
    }
    setState(() {});
  }
}
