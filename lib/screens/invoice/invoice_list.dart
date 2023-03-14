import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '/blocs/invoice/invoice_bloc.dart';
import '/modals/invoice.dart';
import '/screens/widget.dart';
import '/globals.dart';
import 'invoice_detail.dart';

class InvoiceList extends StatefulWidget {
  const InvoiceList({Key? key}) : super(key: key);

  @override
  State<InvoiceList> createState() => _InvoiceListState();
}

class _InvoiceListState extends State<InvoiceList> {
  late var _util = OCSUtil.of(context);
  ScrollController _scrollCtr = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<InvoiceBloc>()
      ..add(ReloadInvoice())
      ..add(FetchInvoice(
        partnerId: Model.partner.id,
        isInit: true,
      ));
    _scrollCtr.addListener(_onScroll);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollCtr.removeListener(_onScroll);
  }

  _onScroll() {
    double max = _scrollCtr.position.maxScrollExtent;
    double curr = _scrollCtr.position.pixels;

    if (curr >= max) {
      context
          .read<InvoiceBloc>()
          .add(FetchInvoice(partnerId: Model.partner.id));
    }
  }

  _init() {
    context.read<InvoiceBloc>()
      ..add(ReloadInvoice())
      ..add(FetchInvoice(partnerId: Model.partner.id, isInit: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: OCSColor.primary,
        title: Row(
          children: [
            // Image.asset('assets/images/invoice.png', width: 30, height: 30),
            // SizedBox(width: 10),
            Txt(
              _util.language.key('invoice-list'),
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
        child: RefreshIndicator(
          onRefresh: () async {
            _init();
          },
          child: BlocBuilder<InvoiceBloc, InvoiceState>(
            builder: (context, state) {
              if (state is InvoiceInitial) {
                return Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }

              if (state is InvoiceLoading) {
                return Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }

              if (state is InvoiceFailed) {
                return BuildErrorBloc(
                  onRetry: _init,
                  message: state.message,
                );
              }

              if (state is InvoiceSuccess) {
                if (state.data!.isEmpty) return BuildNoDataScreen();
                return Parent(
                  style: ParentStyle()..height(_util.query.height),
                  child: ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    controller: _scrollCtr,
                    padding: EdgeInsets.all(15),
                    shrinkWrap: true,
                    itemCount: !state.hasMax!
                        ? state.data!.length + 1
                        : state.data?.length,
                    itemBuilder: (context, i) {
                      var data = MInvoiceData();
                      i >= state.data!.length
                          ? data = MInvoiceData()
                          : data = state.data![i];

                      return i >= state.data!.length
                          ? Center(
                              child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: CircularProgressIndicator.adaptive(),
                            ))
                          : Parent(
                              gesture: Gestures()
                                ..onTap(() {
                                  _util.navigator.to(
                                      InvoiceDetail(
                                        header: data,
                                      ),
                                      transition: OCSTransitions.LEFT);
                                }),
                              style: ParentStyle()
                                ..margin(bottom: 10)
                                ..background.color(Colors.white)
                                ..overflow.hidden()
                                // ..elevation(1, opacity: 0.2)
                                ..borderRadius(all: 5)
                                ..ripple(true),
                              child: Parent(
                                style: ParentStyle()
                                  // ..background.color(Colors.white)
                                  ..padding(all: 10, horizontal: 15),
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Txt(
                                          "#${data.code ?? ""}",
                                          style: TxtStyle()
                                            ..fontSize(Style.subTitleSize)
                                            ..textColor(OCSColor.text),
                                        ),
                                        Txt(
                                          "${OCSUtil.dateFormat(DateTime.parse(data.createdDate ?? ""), format: Format.date, langCode: Globals.langCode)}",
                                          style: TxtStyle()
                                            ..fontSize(Style.subTextSize)
                                            ..textColor(
                                                OCSColor.text.withOpacity(0.5)),
                                        ),
                                      ],
                                    ),
                                    Expanded(child: SizedBox()),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Txt(
                                          OCSUtil.currency(data.total ?? 0,
                                              sign: "\$", decimal: 2),
                                          style: TxtStyle()
                                            ..fontSize(Style.subTitleSize)
                                            ..textColor(OCSColor.text),
                                        ),
                                        SizedBox(height: 5),
                                        Txt(
                                          "${_util.language.key(data.status!.toLowerCase())}",
                                          style: TxtStyle()
                                            ..textColor(data.status!
                                                        .toLowerCase() ==
                                                    "unpaid"
                                                ? Color.fromRGBO(187, 48, 18, 1)
                                                : Colors.green)
                                            ..padding(
                                                horizontal: 7, vertical: 1)
                                            ..minWidth(50)
                                            ..textAlign.center()
                                            ..fontSize(Style.subTextSize - 1)
                                            ..background.color(
                                              data.status!.toLowerCase() ==
                                                      "unpaid"
                                                  ? Color.fromRGBO(
                                                      187, 48, 18, 0.1)
                                                  : Color.fromRGBO(
                                                      92, 173, 0, 0.1),
                                            )
                                            ..borderRadius(all: 3),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                    },
                  ),
                );
              }

              return SizedBox();
            },
          ),
        ),
      ),
    );
  }
}
