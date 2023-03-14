import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '/screens/partner_quotation/quot_detail.dart';
import '/blocs/quotation/quotation_bloc.dart';
import '/globals.dart';

import '../widget.dart';

class QuotationList extends StatefulWidget {
  const QuotationList({Key? key}) : super(key: key);

  @override
  State<QuotationList> createState() => _QuotationListState();
}

class _QuotationListState extends State<QuotationList> {
  late var _util = OCSUtil.of(context);

  ScrollController _scrollCtr = ScrollController();

  @override
  void initState() {
    super.initState();
    _init();
    _scrollCtr.addListener(_onScroll);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollCtr.removeListener(_onScroll);
  }

  _onScroll() {
    var _max = _scrollCtr.position.maxScrollExtent;
    var _curr = _scrollCtr.position.pixels;

    if (_curr >= _max) {
      context.read<QuotationBloc>().add(FetchQuot(partnerId: Model.partner.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: OCSColor.primary,
        title: Row(
          children: [
            Txt(
              _util.language.key('quotation-list'),
              style: TxtStyle()
                ..fontSize(Style.titleSize)
                ..textColor(Colors.white),
            ),
          ],
        ),
        leading: IconButton(
          tooltip: _util.language.key('close'),
          onPressed: () {
            _util.navigator.pop();
          },
          icon: Icon(
            Remix.close_line,
            size: 24,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<QuotationBloc, QuotationState>(
          builder: (context, s) {
            if (s is QuotationSuccess) {
              if (s.data!.isEmpty) return BuildNoDataScreen();
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: RefreshIndicator(
                      onRefresh: _init,
                      child: Parent(
                        style: ParentStyle()
                          ..height(MediaQuery.of(context).size.height - 70),
                        child: ListView.builder(
                            physics: AlwaysScrollableScrollPhysics(),
                            controller: _scrollCtr,
                            padding: EdgeInsets.all(15),
                            itemCount: !s.hasMax!
                                ? s.data!.length + 1
                                : s.data!.length,
                            itemBuilder: (context, i) {
                              return i >= s.data!.length
                                  ? Parent(
                                      style: ParentStyle()..padding(all: 10),
                                      child: Center(
                                        child: CircularProgressIndicator
                                            .adaptive(),
                                      ),
                                    )
                                  : Parent(
                                      gesture: Gestures()
                                        ..onTap(() {
                                          _util.navigator.to(
                                            QuotDetail(
                                              header: s.data![i],
                                            ),
                                            transition: OCSTransitions.LEFT,
                                          );
                                        }),
                                      style: ParentStyle()
                                        ..padding(all: 15)
                                        ..ripple(true)
                                        ..margin(bottom: 10)
                                        ..overflow.hidden()
                                        // ..elevation(01, opacity: 0.2)
                                        ..borderRadius(all: 5)
                                        ..width(
                                            MediaQuery.of(context).size.width)
                                        ..background.color(Colors.white),
                                      child: Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Txt(
                                                '#${s.data?[i].code}',
                                                style: TxtStyle()
                                                  ..fontSize(Style.subTitleSize)
                                                  ..textColor(OCSColor.text),
                                              ),
                                              Txt(
                                                "${OCSUtil.dateFormat(DateTime.parse(s.data?[i].createdDate ?? ""), format: Format.dateTime, langCode: Globals.langCode)}",
                                                style: TxtStyle()
                                                  ..textColor(OCSColor.text
                                                      .withOpacity(0.7))
                                                  ..textAlign.center()
                                                  ..fontSize(Style.subTextSize),
                                              )
                                            ],
                                          ),
                                          Expanded(child: SizedBox()),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Txt(
                                                OCSUtil.currency(
                                                  (s.data![i].total ?? 0),
                                                  sign: "\$",
                                                  decimal: 2,
                                                ),
                                                style: TxtStyle()
                                                  ..fontSize(Style.subTitleSize)
                                                  ..textColor(OCSColor.text),
                                              ),
                                              Row(
                                                children: [
                                                  Parent(
                                                    style: ParentStyle()
                                                      ..width(5)
                                                      ..height(5)
                                                      ..borderRadius(all: 50)
                                                      ..background.color(s
                                                                  .data?[i]
                                                                  .status
                                                                  .toString() ==
                                                              "pending"
                                                          ? Colors.orange
                                                          : (s.data?[i].status ??
                                                                              "")
                                                                          .toLowerCase() ==
                                                                      "in use" ||
                                                                  s.data?[i]
                                                                          .status
                                                                          ?.toUpperCase() ==
                                                                      "QUOTE SUBMITTED"
                                                              ? Colors.green
                                                              : (s.data?[i].status ??
                                                                              "")
                                                                          .toLowerCase() ==
                                                                      "approved"
                                                                  ? Colors.blue
                                                                  : Colors.red),
                                                  ),
                                                  SizedBox(width: 5),
                                                  Txt(
                                                    _util.language.key(
                                                        '${s.data?[i].status?.toLowerCase() == "r" ? "abandoned" : s.data?[i].status?.toUpperCase() == "QUOTE SUBMITTED" ? "in use" : s.data?[i].status?.toLowerCase() ?? ""}'),
                                                    style: TxtStyle()
                                                      ..fontSize(
                                                          Style.subTextSize)
                                                      ..textColor(
                                                        s.data![i].status
                                                                    .toString() ==
                                                                "pending"
                                                            ? Colors.orange
                                                            : (s.data?[i].status ??
                                                                                "")
                                                                            .toLowerCase() ==
                                                                        "in use" ||
                                                                    s.data?[i]
                                                                            .status
                                                                            ?.toUpperCase() ==
                                                                        "QUOTE SUBMITTED"
                                                                ? Colors.green
                                                                : (s.data?[i].status ??
                                                                                "")
                                                                            .toLowerCase() ==
                                                                        "approved"
                                                                    ? Colors
                                                                        .blue
                                                                    : Colors
                                                                        .red,
                                                      ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5),
                                            ],
                                          )
                                        ],
                                      ),
                                    );
                            }),
                      ),
                    ),
                  )
                ],
              );
            }
            if (s is QuotationInitial) {
              return Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }

            if (s is QuotationLoading) {
              return Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }

            if (s is QuotationFailed) {
              return BuildErrorBloc(
                onRetry: _init,
                message: s.message,
              );
            }

            return SizedBox();
          },
        ),
      ),
    );
  }

  Future _init() async {
    context.read<QuotationBloc>()
      ..add(ReloadQuot())
      ..add(FetchQuot(partnerId: Model.partner.id, isInit: true));
  }
}
