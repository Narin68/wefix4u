import 'package:flutter/material.dart';
import 'package:ocs_auth/models/response.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import 'package:intl/intl.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import '/functions.dart';
import '/blocs/settlement_rule/settlement_rule_cubit.dart';
import '/blocs/wallet/wallet_cubit.dart';
import '/modals/wallet_transaction.dart';
import '../create_wallet.dart';
import '/blocs/wallet_transaction/wallet_transaction_bloc.dart';
import '/modals/wallet.dart';
import '/repositories/wallet_repo.dart';
import '/modals/settlement_rule.dart';
import '/screens/widget.dart';
import '/globals.dart';

class PartnerWallet extends StatefulWidget {
  const PartnerWallet({Key? key}) : super(key: key);

  @override
  State<PartnerWallet> createState() => _PartnerWalletState();
}

class _PartnerWalletState extends State<PartnerWallet> {
  late var _util = OCSUtil.of(context);
  ScrollController _scrCtrl = ScrollController();
  bool _loading = false;
  bool _initLoading = false;

  MSettlementData _settlementData = MSettlementData();
  WalletRepo _walletRepo = WalletRepo();
  MWalletData _walletData = MWalletData();
  bool _expand = false;
  String _withdrawStatus = "";
  TextEditingController _descTxt = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrCtrl.addListener(_onScroll);
    _init();
  }

  @override
  void dispose() {
    super.dispose();
    _scrCtrl.removeListener(_onScroll);
  }

  void _onScroll() {
    var max = _scrCtrl.position.maxScrollExtent;
    var curr = _scrCtrl.position.pixels;
    if (curr >= max) {
      context
          .read<WalletTransactionBloc>()
          .add(FetchWalletTransaction(walletId: _walletData.id ?? 0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/wallet.png', width: 30, height: 30),
            SizedBox(width: 10),
            Txt(
              _util.language.key("wallet"),
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
        actions: [
          IconButton(
            onPressed: _withdrawStatus.toLowerCase() == "p" ||
                    (_walletData.balance ?? 0) <= 0
                ? null
                : () {
                    if (_loading || _initLoading) return;
                    Model.userWallet == null ||
                            (Model.userWallet?.bankName?.isEmpty ?? false)
                        ? showDialog(
                            context: context,
                            builder: (_) {
                              return VerifyBankAccount(
                                isUpdate: true,
                                onSuccess: (data) {
                                  context
                                      .read<WalletCubit>()
                                      .updateWallet(data);
                                  setState(() {});
                                },
                              );
                            })
                        : showDialog(
                            context: context,
                            builder: (context) {
                              return BuildRequestWithdrawal(
                                balance: _walletData.balance ?? 0,
                                onSubmit: _requestWithdraw,
                              );
                            },
                          );
                  },
            icon: Icon(Icons.request_page),
            tooltip: _util.language.key('request-withdraw'),
          )
        ],
      ),
      body: _initLoading
          ? Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : CustomScrollView(
              physics: NeverScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBalanceCard(),
                          Txt(
                            _util.language.key("history"),
                            style: TxtStyle()
                              ..padding(all: 15, vertical: 7)
                              ..fontSize(Style.titleSize)
                              ..width(_util.query.width)
                              ..background
                                  .color(Color.fromRGBO(229, 241, 241, 1))
                              ..fontWeight(FontWeight.w600)
                              ..textColor(OCSColor.text),
                          ),
                          _buildList(),
                        ],
                      ),
                      if (_loading)
                        Positioned(
                          child: Container(
                            color: Colors.black12,
                            width: _util.query.width,
                            height: _util.query.height,
                            child: Center(
                              child: CircularProgressIndicator.adaptive(),
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              ],
            ),
    );
  }

  Future _requestWithdraw(double amount, String desc) async {
    _util.pop();
    setState(() {
      _loading = true;
    });
    var _res = await _walletRepo.withdrawalRequest(
      amount: amount,
      walletId: _walletData.id ?? 0,
      desc: desc,
    );
    if (_res.error) {
      _util.snackBar(
        message: _res.message,
        status: SnackBarStatus.danger,
      );
    } else {
      context
          .read<WalletTransactionBloc>()
          .add(AddWalletTransaction(data: _res.data));
      _util.snackBar(
        message: _util.language.key('success'),
        status: SnackBarStatus.success,
      );
    }
    setState(() {
      _loading = false;
    });
  }

  Future _init() async {
    context.read<WalletCubit>().getByRef(init: true);
    context.read<SettlementRuleCubit>().getSettlementRule();
    initTransactionBloc();
  }

  Future _reloadData() async {
    var _res = await WalletRepo().getUserWallet();
    if (!_res.error) {
      MResponse _result = await WalletRepo().withdrawalRequestList();

      if (!_result.error) {
        context
            .read<WalletCubit>()
            .updateWallet(_res.data, status: _result.data);
      } else {
        context.read<WalletCubit>().updateWallet(_res.data);
      }
    }
    await initTransactionBloc();
  }

  Future initTransactionBloc() async {
    context.read<WalletTransactionBloc>()
      ..add(ReloadWalletTransaction())
      ..add(FetchWalletTransaction(
        isInit: true,
        walletId: Model.userWallet?.id ?? 0,
      ));
  }

  Widget _buildList() {
    return BlocBuilder<WalletTransactionBloc, WalletTransactionState>(
      builder: (context, state) {
        if (state is WalletTransactionLoading) {
          return Parent(
            style: ParentStyle()
              ..height(_util.query.height / 2)
              ..alignmentContent.center(),
            child: Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          );
        }
        if (state is WalletTransactionFailed) {
          return Parent(
            style: ParentStyle()
              ..height(_util.query.height / 2)
              ..alignmentContent.center(),
            child: BuildErrorBloc(
              onRetry: _reloadData,
              message: state.message,
            ),
          );
        }
        if (state is WalletTransactionSuccess) {
          if (state.data == null || state.data!.isEmpty)
            return Parent(
              style: ParentStyle()
                ..height(_util.query.height / 2)
                ..alignmentContent.center(),
              child: BuildNoDataScreen(),
            );
          for (var i = 0; i < state.data!.length; i++) {
            state.data![i] = state.data![i].copyWith(createdBy: "wefix4u");
          }

          var list = state.data
              ?.map((d) => DateFormat("yyyyMMdd")
                  .format(DateTime.parse(d.createdDate ?? "")))
              .toSet()
              .toList();
          var res = list
              ?.map((c) => state.data!
                  .where((d) =>
                      c ==
                      DateFormat("yyyyMMdd")
                          .format(DateTime.parse(d.createdDate ?? "")))
                  .toList())
              .toList();
          var _dateList = res?.map((e) => e[0].createdDate).toSet().toList();
          return RefreshIndicator(
            onRefresh: _reloadData,
            child: Parent(
              style: ParentStyle()
                ..height(_util.query.height -
                    (!_expand ||
                            (Model.userWallet?.bankName?.isNotEmpty ?? false)
                        ? 250
                        : 300))
                ..background.color(Colors.white),
              child: ListView.builder(
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                controller: _scrCtrl,
                padding: EdgeInsets.only(bottom: 50),
                itemCount: state.hasMax!
                    ? _dateList?.toSet().length
                    : (_dateList?.toSet().length ?? 0) + 1,
                itemBuilder: (_, i) {
                  return i >= (_dateList?.length ?? 0)
                      ? Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: SizedBox(
                            width: 30,
                            height: 35,
                            child: Center(
                              child: CircularProgressIndicator.adaptive(),
                            ),
                          ),
                        )
                      : StickyHeader(
                          header: Txt(
                            OCSUtil.dateFormat(
                              DateTime.parse(_dateList?[i] ?? ""),
                              format: Format.date,
                              langCode: Globals.langCode,
                            ),
                            style: TxtStyle()
                              ..padding(all: 15, vertical: 7)
                              ..width(_util.query.width)
                              ..fontSize(Style.subTextSize)
                              ..background
                                  .color(Color.fromRGBO(229, 241, 241, 1))
                              ..textColor(OCSColor.text),
                          ),
                          content: ListView.builder(
                            shrinkWrap: true,
                            primary: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: res?[i].length ?? 0,
                            itemBuilder: (_, j) {
                              MWalletTransactionData? data = res![i][j];
                              return Parent(
                                gesture: Gestures()
                                  ..onTap(() {
                                    showReceipt(data);
                                  }),
                                style: ParentStyle()
                                  // ..background.color(Colors.white)
                                  ..padding(vertical: 5, horizontal: 20)
                                  ..ripple(true)
                                  ..border(
                                    bottom: 1,
                                    color: Colors.black.withOpacity(0.05),
                                  ),
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Txt(
                                          "${data.createdBy}",
                                          style: TxtStyle()
                                            ..fontSize(Style.subTitleSize)
                                            ..fontWeight(FontWeight.w500)
                                            ..textColor(OCSColor.text),
                                        ),
                                        Txt(
                                          "${data.code ?? "N/A"}",
                                          style: TxtStyle()
                                            ..fontSize(Style.subTextSize)
                                            ..textColor(
                                              OCSColor.text.withOpacity(0.7),
                                            ),
                                        ),
                                      ],
                                    ),
                                    Expanded(child: SizedBox()),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Txt(
                                          "${data.transactionType?.toLowerCase() == "w" ? "-" : "+"} ${OCSUtil.currency(double.parse("${data.amount}"), sign: "\$")}",
                                          style: TxtStyle()
                                            ..fontWeight(FontWeight.bold)
                                            ..fontSize(Style.subTextSize)
                                            ..textColor(
                                              _checkColor(data),
                                            ),
                                        ),
                                        // Txt(
                                        //   "${_util.language.key(res?[i][j].transactionType?.toLowerCase() == "w" ? "withdraws" : res?[i][j].transactionType?.toLowerCase() == "e" ? "earning" : "transfer-to-wallet")}",
                                        //   style: TxtStyle()
                                        //     ..fontSize(Style.subTextSize - 1),
                                        // ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                },
              ),
            ),
          );
        }
        return SizedBox();
      },
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding:
            const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 15),
        child: Parent(
          style: ParentStyle()
            ..overflow.hidden()
            // ..elevation(1, opacity: 1, angle: 0.1)
            ..linearGradient(colors: [
              OCSColor.primary,
              OCSColor.primary,
              OCSColor.primary,
              Color(0xff812121),
            ], end: Alignment(0.8, 1), begin: Alignment.topLeft)
            ..boxShadow(
              color: OCSColor.primary.withOpacity(0.8),
              blur: 5,
              offset: Offset(0, 1),
            )
            ..borderRadius(all: 5),
          child: Stack(
            children: [
              Positioned(
                bottom: -50,
                left: -50,
                child: Parent(
                  style: ParentStyle()
                    ..width(120)
                    ..height(120)
                    ..borderRadius(all: 100)
                    ..background.color(Colors.red.withOpacity(0.5)),
                ),
              ),
              Positioned(
                top: -50,
                right: -50,
                child: Parent(
                  style: ParentStyle()
                    ..width(120)
                    ..height(120)
                    ..borderRadius(all: 100)
                    ..background.color(Colors.red.withOpacity(0.5)),
                ),
              ),
              Parent(
                style: ParentStyle()
                  ..padding(all: 15, bottom: 0)
                  ..borderRadius(all: 5)
                  ..width(Globals.maxScreen)
                  ..boxShadow(color: Colors.black12, offset: Offset(0, 1)),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Txt(
                              _util.language.key('balance'),
                              style: TxtStyle()
                                ..fontSize(Style.subTitleSize)
                                ..textColor(Colors.white),
                            ),
                            BlocConsumer<WalletCubit, WalletState>(
                              listener: (_, s) async {
                                if (s is WalletLoading) {
                                  setState(() {
                                    _initLoading = true;
                                  });
                                }

                                if (s is WalletFailure) {
                                  setState(() {
                                    _initLoading = false;
                                  });
                                }
                                if (s is WalletSuccess) {
                                  _walletData = s.data!;
                                  _withdrawStatus = s.withdrawStatus ?? '';
                                  setState(() {
                                    _initLoading = false;
                                  });
                                }
                              },
                              builder: (context, s) {
                                if (s is WalletSuccess) {
                                  return Txt(
                                    OCSUtil.currency(
                                        ((s.data?.balance ?? 0) * 100)
                                                .roundToDouble() /
                                            100,
                                        sign: "\$"),
                                    style: TxtStyle()
                                      ..fontSize(Style.titleSize + 4)
                                      ..fontWeight(FontWeight.w600)
                                      ..borderRadius(all: 5)
                                      ..textColor(Colors.white),
                                  );
                                }
                                return Txt(
                                  OCSUtil.currency(_walletData.balance ?? 0,
                                      sign: "\$"),
                                  style: TxtStyle()
                                    ..fontSize(Style.titleSize + 4)
                                    ..fontWeight(FontWeight.w600)
                                    ..borderRadius(all: 5)
                                    ..textColor(Colors.white),
                                );
                              },
                            ),
                            if (Model.userWallet?.bankName != null &&
                                (Model.userWallet?.bankName?.isNotEmpty ??
                                    false)) ...[
                              AnimatedContainer(
                                height: _expand ? 60 : 0,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Txt(
                                          _util.language.key('bank-account'),
                                          style: TxtStyle()
                                            ..textColor(Colors.white)
                                            ..fontSize(11),
                                        ),
                                        SizedBox(width: 5),
                                        Txt(
                                          showNumber(
                                              "${Model.userWallet?.bankAccount}"),
                                          style: TxtStyle()
                                            ..textColor(Colors.white)
                                            ..fontSize(11),
                                        )
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Txt(
                                          _util.language.key('account-name'),
                                          style: TxtStyle()
                                            ..textColor(Colors.white)
                                            ..fontSize(11),
                                        ),
                                        SizedBox(width: 5),
                                        Txt(
                                          "${Model.userWallet?.accountName ?? "N/A"}",
                                          style: TxtStyle()
                                            ..textColor(Colors.white)
                                            ..fontSize(11),
                                        )
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Txt(
                                          _util.language.key('bank-name'),
                                          style: TxtStyle()
                                            ..textColor(Colors.white)
                                            ..fontSize(11),
                                        ),
                                        SizedBox(width: 5),
                                        Txt(
                                          "${Model.userWallet?.bankName}",
                                          style: TxtStyle()
                                            ..textColor(Colors.white)
                                            ..fontSize(11),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ]
                          ],
                        ),
                        Expanded(child: SizedBox()),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            BlocConsumer<SettlementRuleCubit,
                                SettlementRuleState>(
                              listener: (_, s) async {
                                if (s is SettlementRuleLoading) {
                                  setState(() {
                                    _initLoading = true;
                                  });
                                }

                                if (s is SettlementRuleSuccess) {
                                  _settlementData = s.data!;
                                  setState(() {
                                    _initLoading = false;
                                  });
                                }

                                if (s is SettlementRuleFailure) {
                                  setState(() {
                                    _initLoading = false;
                                  });
                                }
                              },
                              builder: (context, s) {
                                if (s is SettlementRuleSuccess) {
                                  return Txt(
                                    "${drawEarning(s.data)}",
                                    style: TxtStyle()
                                      ..fontSize(Style.subTextSize)
                                      ..textColor(Colors.white),
                                  );
                                }

                                return Txt(
                                  "${drawEarning(_settlementData)}",
                                  style: TxtStyle()
                                    ..fontSize(Style.subTextSize)
                                    ..textColor(Colors.white),
                                );
                              },
                            ),
                            BlocBuilder<WalletCubit, WalletState>(
                              builder: (context, s) {
                                if (s is WalletSuccess) {
                                  return Txt(
                                    OCSUtil.currency(s.data?.earning ?? 0,
                                        sign: "\$"),
                                    style: TxtStyle()
                                      ..fontSize(Style.titleSize + 4)
                                      ..fontWeight(FontWeight.w600)
                                      ..borderRadius(all: 5)
                                      ..textColor(Colors.white),
                                  );
                                }
                                return Txt(
                                  OCSUtil.currency(_walletData.balance ?? 0,
                                      sign: "\$"),
                                  style: TxtStyle()
                                    ..fontSize(Style.titleSize + 4)
                                    ..fontWeight(FontWeight.w600)
                                    ..borderRadius(all: 5)
                                    ..textColor(Colors.white),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (Model.userWallet?.bankName != null &&
                        (Model.userWallet?.bankName?.isEmpty ?? false))
                      SizedBox(
                        height: 10,
                      ),
                    if (Model.userWallet?.bankName != null &&
                        (Model.userWallet?.bankName?.isNotEmpty ?? false))
                      Parent(
                        style: ParentStyle()
                          ..padding(all: 10, horizontal: 30, top: 0, bottom: 5)
                          ..borderRadius(all: 50),
                        gesture: Gestures()
                          ..onPanUpdate((p) {
                            if (p.localPosition.dy > 30) {
                              setState(() {
                                _expand = true;
                              });
                            } else if (p.localPosition.dy < -20) {
                              setState(() {
                                _expand = false;
                              });
                            }
                          })
                          ..onTap(() {
                            setState(() {
                              _expand = _expand ? false : true;
                            });
                          }),
                        child: Icon(
                          _expand
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String drawEarning(MSettlementData? data) {
    var walletRoutine = data?.walletRoutine?.toLowerCase() == "m"
        ? "month"
        : data?.walletRoutine?.toLowerCase() == "w"
            ? "week"
            : "day";
    var wallet = data?.walletRoutine?.toLowerCase() == "m"
        ? "this-month"
        : data?.walletRoutine?.toLowerCase() == "w"
            ? "this-week"
            : "this-day";
    var duration = data?.walletDuration ?? 0;

    var earning =
        " ${OCSUtil.currency(duration, autoDecimal: true)} ${_util.language.key("${walletRoutine}")}"
        "${_util.language.by(km: "នេះ", en: "${(data?.walletDuration ?? 0) > 1 ? "s" : ""}")}";

    return "${_util.language.key('earning')}${_util.language.by(km: "", en: " ${(data?.walletDuration ?? 0) > 1 ? "this" : ""}")}${duration > 1 ? earning : _util.language.key("$wallet")}";
  }

  void showReceipt(MWalletTransactionData data) {
    Intl.defaultLocale = Globals.langCode;
    String withdrawApprove = _util.language
            .by(km: "ដកប្រាក់ទៅកាន់គណនី", en: "Withdrawal to") +
        " ${data.bankName} "
            "${_util.language.by(km: "", en: "account ")}${_util.language.by(km: "លេខ", en: "")} " +
        "${data.bankAccount}";
    String withdrawRejected = _util.language.key('request-withdraw-reject');
    String receive = _util.language.key('receive-from') + " ${data.createdBy}";
    String pending = _util.language.key('awaiting-approve');
    // print(data.id);
    print(data.approveDescription);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return WillPopScope(
          onWillPop: () async {
            return true;
          },
          child: Dialog(
            insetPadding: EdgeInsets.all(0),
            backgroundColor: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Parent(
                      style: ParentStyle()
                        ..borderRadius(all: 2)
                        ..background.color(Colors.white)
                        ..maxWidth(_util.query.width > 500
                            ? Globals.maxScreen
                            : _util.query.width - 30),
                      child: Parent(
                        style: ParentStyle()
                          ..width(_util.query.width > 500
                              ? Globals.maxScreen
                              : _util.query.width - 30)
                          ..padding(all: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Parent(
                                  style: ParentStyle()
                                    ..padding(all: 13)
                                    ..background.color(Colors.white)
                                    ..borderRadius(all: 50)
                                    ..border(
                                      all: 1,
                                      color: _checkColor(data),
                                    ),
                                  child: Icon(
                                    data.transactionType?.toLowerCase() != "w"
                                        ? Icons.call_received
                                        : data.status?.toLowerCase() == "p"
                                            ? Remix.loader_2_line
                                            : data.status?.toLowerCase() == "r"
                                                ? Icons.close
                                                : Icons.call_made,
                                    color: _checkColor(data),
                                  ),
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Txt(
                                        OCSUtil.currency(
                                          data.amount ?? 0,
                                          sign: "\$",
                                        ),
                                        style: TxtStyle()
                                          ..fontSize(Style.titleSize + 4)
                                          ..textColor(OCSColor.text),
                                      ),
                                      Txt(
                                        "${data.transactionType?.toLowerCase() != "w" ? receive : data.status?.toLowerCase() == "r" ? withdrawRejected : data.status?.toLowerCase() == "p" ? pending : withdrawApprove}",
                                        style: TxtStyle()
                                          ..fontSize(Style.subTextSize)
                                          ..textColor(
                                              OCSColor.text.withOpacity(0.7)),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                              crossAxisAlignment: CrossAxisAlignment.center,
                            ),
                            SizedBox(height: 10),
                            Divider(
                              height: 1,
                              color: Colors.black12,
                            ),
                            SizedBox(height: 10),
                            _buildAction(_util.language.key('transaction-code'),
                                data.code ?? "N/A"),
                            if (data.transactionType?.toLowerCase() != "w")
                              _buildAction(
                                _util.language.key('transaction-on-request'),
                                data.requestCode ?? "N/A",
                              ),
                            _buildAction(
                                _util.language.key(
                                    data.transactionType?.toLowerCase() ==
                                                "w" &&
                                            data.status?.toLowerCase() == "p"
                                        ? 'request-date'
                                        : 'transaction-date'),
                                "${OCSUtil.dateFormat((data.transactionType?.toLowerCase() == "w" && data.status?.toLowerCase() == "p") || (data.transactionType?.toLowerCase() == "r") ? data.updatedDate : data.createdDate ?? "", format: Format.dateTime)}"),
                            if ((data.description ?? "").isNotEmpty ||
                                (data.approveDescription ?? "").isNotEmpty)
                              Parent(
                                style: ParentStyle()
                                  ..width(_util.query.width)
                                  ..padding(all: 10)
                                  ..borderRadius(all: 5)
                                  ..background.color(OCSColor.background)
                                  ..margin(top: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Txt(
                                      _util.language.key('description') + " :",
                                      style: TxtStyle()
                                        ..fontSize(Style.subTextSize)
                                        ..textColor(
                                          OCSColor.text.withOpacity(0.6),
                                        ),
                                    ),
                                    Txt(
                                      data.status?.toLowerCase() != "p"
                                          ? (data.approveDescription ??
                                              (data.description ?? ""))
                                          : data.description ?? "",
                                      style: TxtStyle()
                                        ..margin(left: 5)
                                        ..fontSize(Style.subTextSize)
                                        ..textColor(
                                          OCSColor.text.withOpacity(0.8),
                                        ),
                                    ),
                                  ],
                                ),
                              ),
                            SizedBox(height: 10),
                            if (data.attachmentUrl?.isNotEmpty ?? false)
                              Parent(
                                gesture: Gestures()
                                  ..onTap(() {
                                    _util.to(MyViewImage(
                                      url: data.attachmentUrl ?? '',
                                    ));
                                  }),
                                style: ParentStyle()
                                  ..width(_util.query.width)
                                  ..maxHeight(150)
                                  ..overflow.hidden()
                                  ..borderRadius(all: 5)
                                  ..background.color(Colors.white),
                                child: MyNetworkImage(
                                    url: data.attachmentUrl ?? ''),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _checkColor(MWalletTransactionData data) {
    return data.transactionType?.toLowerCase() == "w"
        ? data.transactionType?.toLowerCase() == "w" &&
                data.status?.toLowerCase() == "p"
            ? Colors.orange
            : data.transactionType?.toLowerCase() == "w" &&
                    data.status?.toLowerCase() == "a"
                ? Colors.green
                : Colors.red
        : Colors.green;
  }

  Widget _buildAction(String title, String data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Txt(
          "$title :",
          style: TxtStyle()
            ..width(150)
            ..fontSize(Style.subTextSize)
            ..textColor(OCSColor.text.withOpacity(0.6)),
        ),
        Expanded(child: SizedBox()),
        Txt(
          "$data",
          style: TxtStyle()
            ..textOverflow(TextOverflow.ellipsis)
            ..fontSize(Style.subTextSize)
            ..textColor(
              OCSColor.text.withOpacity(0.8),
            ),
        ),
      ],
    );
  }
}

class BuildRequestWithdrawal extends StatefulWidget {
  final Function(double amount, String desc)? onSubmit;
  final double balance;

  const BuildRequestWithdrawal({Key? key, this.onSubmit, required this.balance})
      : super(key: key);

  @override
  State<BuildRequestWithdrawal> createState() => _BuildRequestWithdrawalState();
}

class _BuildRequestWithdrawalState extends State<BuildRequestWithdrawal> {
  late var _util = OCSUtil.of(context);
  var _key = GlobalKey<FormState>();
  TextEditingController _txt = TextEditingController(),
      _descTxt = TextEditingController();
  String lastName = '';
  String _date = '';
  var now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Parent(
        style: ParentStyle()..maxWidth(Globals.maxScreen),
        child: Form(
          key: _key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Parent(
                style: ParentStyle()
                  ..borderRadius(topRight: 5, topLeft: 5)
                  ..background.color(OCSColor.background)
                  ..width(_util.query.width)
                  ..padding(all: 10, horizontal: 15),
                child: Txt(
                  _util.language.key("withdraw"),
                  style: TxtStyle()
                    ..fontSize(16)
                    ..textColor(OCSColor.text),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    MyTextField(
                      controller: _txt,
                      icon: Icons.monetization_on,
                      focusColor: OCSColor.primary,
                      placeholder: _util.language.key('amount-withdraw'),
                      textInputType: TextInputType.numberWithOptions(
                        decimal: false,
                        signed: false,
                      ),
                      validator: (v) {
                        if (v!.isEmpty)
                          return _util.language.key('this-field-is-required');

                        return null;
                      },
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    MyTextArea(
                      controller: _descTxt,
                      placeHolder: _util.language.key('enter-description'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Parent(
                gesture: Gestures()
                  ..onTap(() async {
                    bool _isValid = true;
                    if (!_key.currentState!.validate()) return;

                    if (((widget.balance * 100).roundToDouble() / 100) >=
                        double.parse(_txt.text)) {
                      if (widget.onSubmit != null && _isValid)
                        await widget.onSubmit!(
                            double.parse(_txt.text), _descTxt.text);
                    } else {
                      _util.snackBar(
                          message:
                              _util.language.key("not-enough-cash-to-withdraw"),
                          status: SnackBarStatus.warning);
                      return;
                    }
                  }),
                style: ParentStyle()
                  ..background.color(OCSColor.background)
                  ..width(_util.query.width)
                  ..alignmentContent.center()
                  ..borderRadius(bottomRight: 5, bottomLeft: 5)
                  ..ripple(true)
                  ..padding(all: 10, horizontal: 15),
                child: Txt(
                  _util.language.key('request'),
                  style: TxtStyle()
                    ..fontSize(14)
                    ..textColor(OCSColor.text),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
