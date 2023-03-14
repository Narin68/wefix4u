import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '/modals/invoice.dart';
import '../invoice/invoice_detail.dart';
import '/blocs/invoice/invoice_bloc.dart';
import '/blocs/receipt/receipt_bloc.dart';
import '/globals.dart';
import '/screens/widget.dart';
import 'receipt_detail.dart';

class CusInvoiceAndReceiptList extends StatefulWidget {
  const CusInvoiceAndReceiptList({Key? key}) : super(key: key);

  @override
  State<CusInvoiceAndReceiptList> createState() =>
      _CusInvoiceAndReceiptListState();
}

class _CusInvoiceAndReceiptListState extends State<CusInvoiceAndReceiptList> {
  late var _util = OCSUtil.of(context);

  ScrollController _invoiceScroll = ScrollController(),
      _receiptScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _initInvoice();
    _initReceipt();

    _invoiceScroll.addListener(_onScroll);
    _receiptScroll.addListener(_onScrollReceipt);
  }

  @override
  void dispose() {
    super.dispose();
    _invoiceScroll.removeListener(_onScroll);
    _receiptScroll.removeListener(_onScrollReceipt);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: OCSColor.primary,
          bottom: TabBar(
            onTap: (int i) {
              i == 0
                  ? context.read<InvoiceBloc>().add(
                        FetchInvoice(
                          status: 'unpaid',
                          isInit: true,
                          cusId: Model.customer.id,
                        ),
                      )
                  : context.read<ReceiptBloc>().add(
                        FetchReceipt(
                          status: 'paid',
                          isInit: true,
                          cusId: Model.customer.id,
                        ),
                      );
            },
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                text: _util.language.key('invoice'),
              ),
              Tab(
                text: _util.language.key('receipt'),
              )
            ],
          ),
          title: Txt(
            _util.language.key('invoice-and-receipt-list'),
            style: TxtStyle()
              ..fontSize(16)
              ..textColor(Colors.white),
          ),
          leading: IconButton(
            tooltip: _util.language.key('back'),
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
        body: TabBarView(
          children: [
            BlocBuilder<InvoiceBloc, InvoiceState>(
              builder: (context, s) {
                if (s is InvoiceSuccess) {
                  if (s.data!.isEmpty)
                    return Center(child: BuildNoDataScreen());
                  return RefreshIndicator(
                    onRefresh: _initInvoice,
                    child: Parent(
                      style: ParentStyle()..height(_util.query.height),
                      child: ListView.builder(
                        padding: EdgeInsets.all(15),
                        shrinkWrap: true,
                        physics: AlwaysScrollableScrollPhysics(),
                        controller: _invoiceScroll,
                        itemCount:
                            !s.hasMax! ? s.data!.length + 1 : s.data!.length,
                        itemBuilder: (_, i) {
                          return i >= s.data!.length
                              ? Center(
                                  child: CircularProgressIndicator.adaptive(),
                                )
                              : _buildList(data: s.data![i], isInvoice: true);
                        },
                      ),
                    ),
                  );
                }
                if (s is InvoiceInitial) {
                  return Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }

                if (s is InvoiceLoading) {
                  return Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }
                if (s is InvoiceFailed) {
                  return Center(
                    child: BuildErrorBloc(
                      message: s.message,
                      onRetry: _initInvoice,
                    ),
                  );
                }
                return SizedBox();
              },
            ),
            BlocBuilder<ReceiptBloc, ReceiptState>(
              builder: (context, s) {
                if (s is ReceiptSuccess) {
                  if (s.data!.isEmpty)
                    return Center(child: BuildNoDataScreen());
                  return RefreshIndicator(
                    onRefresh: _initReceipt,
                    child: Parent(
                      style: ParentStyle()..height(_util.query.height),
                      child: ListView.builder(
                        padding: EdgeInsets.all(15),
                        shrinkWrap: true,
                        physics: AlwaysScrollableScrollPhysics(),
                        controller: _receiptScroll,
                        itemCount:
                            !s.hasMax! ? s.data!.length + 1 : s.data!.length,
                        itemBuilder: (_, i) {
                          return i >= s.data!.length
                              ? Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Center(
                                    child: CircularProgressIndicator.adaptive(),
                                  ),
                                )
                              : _buildList(isInvoice: false, data: s.data![i]);
                        },
                      ),
                    ),
                  );
                }
                if (s is ReceiptInitial) {
                  return Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }

                if (s is ReceiptLoading) {
                  return Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }
                if (s is ReceiptFailed) {
                  return Center(
                    child: BuildErrorBloc(
                      message: s.message,
                      onRetry: _initReceipt,
                    ),
                  );
                }
                return SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onScroll() {
    double max = _invoiceScroll.position.maxScrollExtent;
    double _curr = _invoiceScroll.position.pixels;
    if (_curr >= max - 60) {
      context.read<InvoiceBloc>().add(
            FetchInvoice(
              status: 'unpaid',
              isInit: false,
              cusId: Model.customer.id,
            ),
          );
    }
  }

  void _onScrollReceipt() {
    double max = _receiptScroll.position.maxScrollExtent;
    double _curr = _receiptScroll.position.pixels;

    if (_curr >= max) {
      context.read<ReceiptBloc>().add(
            FetchReceipt(
              status: 'paid',
              cusId: Model.customer.id,
            ),
          );
    }
  }

  Future _initInvoice() async {
    context.read<InvoiceBloc>()
      ..add(ReloadInvoice())
      ..add(
        FetchInvoice(
          status: 'unpaid',
          isInit: false,
          cusId: Model.customer.id,
        ),
      );
  }

  Future _initReceipt() async {
    context.read<ReceiptBloc>()
      ..add(ReloadReceipt())
      ..add(
        FetchReceipt(
          status: 'paid',
          isInit: false,
          cusId: Model.customer.id,
        ),
      );
  }

  Widget _buildList({required MInvoiceData data, bool isInvoice = true}) {
    return Parent(
      style: ParentStyle()
        ..background.color(Colors.white)
        ..margin(bottom: 10)
        ..overflow.hidden()
        ..borderRadius(all: 5),
      child: Parent(
        gesture: Gestures()
          ..onTap(() {
            isInvoice
                ? _util.navigator.to(InvoiceDetail(header: data),
                    transition: OCSTransitions.LEFT)
                : _util.navigator.to(ReceiptDetail(header: data),
                    transition: OCSTransitions.LEFT);
          }),
        style: ParentStyle()
          ..ripple(true)
          ..border(left: 3, color: isInvoice ? Colors.blueGrey : Colors.green)
          ..padding(all: 15, horizontal: 15)
          ..background.color(Colors.white),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Txt(
                  '${_util.language.by(km: data.partnerName, en: data.partnerNameEnglish, autoFill: true)}',
                  style: TxtStyle()
                    ..fontSize(Style.subTitleSize)
                    ..textColor(OCSColor.text),
                ),
                Txt(
                  '#${data.code}',
                  style: TxtStyle()
                    ..fontSize(Style.subTextSize)
                    ..textColor(OCSColor.text.withOpacity(0.7)),
                ),
              ],
            ),
            Expanded(child: SizedBox()),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Txt(
                  '${OCSUtil.currency(data.total ?? 0, sign: '\$')}',
                  style: TxtStyle()
                    ..fontSize(Style.subTitleSize)
                    ..textColor(OCSColor.text),
                ),
                Txt(
                  '${OCSUtil.dateFormat(DateTime.parse(data.createdDate ?? ""), langCode: Globals.langCode, format: Format.dateTime)}',
                  style: TxtStyle()
                    ..fontSize(Style.subTextSize)
                    ..textColor(OCSColor.text.withOpacity(0.7)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
