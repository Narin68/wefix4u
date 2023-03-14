import 'dart:async';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ocs_auth/ocs_auth.dart';
import 'package:ocs_util/ocs_util.dart';
import '/modals/discount.dart';
import '/repositories/discount_code.dart';
import '/repositories/wallet_transaction_repo.dart';
import '/globals.dart';
import '/screens/widget.dart';

class MyAbaPaymentScreen extends StatefulWidget {
  final String db;
  final String firstName;
  final String lastName;
  final String invoiceNo;
  final double amount;
  final String? url;
  final Function(String message)? onClose;
  final AppBar? appBar;
  final String? langCode;
  final Function()? onSuccess;
  final int? reqId;
  final int? partnerId;
  final MDiscountCode? discount;

  const MyAbaPaymentScreen({
    Key? key,
    required this.db,
    required this.firstName,
    required this.lastName,
    required this.invoiceNo,
    required this.amount,
    this.url,
    this.onClose,
    this.appBar,
    this.langCode,
    this.onSuccess,
    this.reqId,
    this.partnerId,
    this.discount,
  }) : super(key: key);

  @override
  State<MyAbaPaymentScreen> createState() => _MyAbaPaymentScreenState();
}

class _MyAbaPaymentScreenState extends State<MyAbaPaymentScreen>
    with WidgetsBindingObserver {
  final _repo = PaymentRepo();
  final flutterWebViewPlugin = FlutterWebviewPlugin();
  late final _util = OCSUtilities(context);
  final _auth = OCSAuth();
  String token = '';
  String refreshToken = '';
  bool loading = false;
  bool isOpenDeeplink = false;
  String data = '';
  late String url;
  int onCountUrlChange = 0;
  double _amount = 0;

  StreamSubscription<String>? _onUrlChange;
  WalletTransactionRepo _walletRepo = WalletTransactionRepo();
  DiscountRepo _discountRepo = DiscountRepo();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    url = '${(widget.url ?? AuthConfig.webServer)}/aba_payway/checkout/init';
    _amount = widget.amount;
    init();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed && isOpenDeeplink) {
      final result = await _repo.after(invoiceNo: widget.invoiceNo);
      if (!result.error &&
          (result.data == 'Completed' || result.data == 'Pending')) {
        // _createTransaction();
        flutterWebViewPlugin.evalJavascript('showSuccessPage();');
        isOpenDeeplink = false;
      } else {
        flutterWebViewPlugin
            .evalJavascript('showError("${Globals.langCode}");');
        flutterWebViewPlugin.evalJavascript('hideLoading();');
      }
    }
    if (state != AppLifecycleState.resumed && isOpenDeeplink) {
      flutterWebViewPlugin.evalJavascript('showLoading();');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await flutterWebViewPlugin.canGoBack()) {
          flutterWebViewPlugin.goBack();
        } else {
          _util.navigator.pop();
        }

        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Txt(
            "${_util.language.key('invoice-no')} " + "#${widget.invoiceNo}",
            style: TxtStyle()
              ..fontSize(Style.titleSize)
              ..textColor(Colors.white),
          ),
          backgroundColor: OCSColor.primary,
          leading: NavigatorBackButton(
            onPress: () async {
              if (await flutterWebViewPlugin.canGoBack()) {
                flutterWebViewPlugin.goBack();
              } else {
                _util.navigator.pop();
              }
            },
          ),
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : WebviewScaffold(
                url: url,
                clearCache: true,
                clearCookies: true,
                scrollBar: false,
                withZoom: false,
                hidden: true,
                headers: {
                  'data': data,
                  'oc_database': widget.db,
                  'oc_access_token': token,
                  'oc_refresh_token': refreshToken,
                  'oc_device_id': OCSUtil.deviceId,
                  'lang_code': widget.langCode ?? 'en',
                },
                javascriptChannels: {
                  JavascriptChannel(
                    name: 'OpenDeeplink',
                    onMessageReceived: (JavascriptMessage message) async {
                      final data = jsonDecode(message.message);
                      try {
                        isOpenDeeplink = true;
                        flutterWebViewPlugin.evalJavascript('showLoading();');
                        await launchUrlString(data['abapay_deeplink']);
                      } catch (e) {
                        if (Platform.isAndroid) {
                          await launchUrlString(data['play_store']);
                        } else if (Platform.isIOS) {
                          await launchUrlString(data['app_store']);
                        }
                      }
                    },
                  ),
                  JavascriptChannel(
                    name: 'CloseWebView',
                    onMessageReceived: (JavascriptMessage message) async {
                      if (widget.onClose != null) {
                        if (message.message == 'close_save') {
                          final result = await PaymentRepo()
                              .after(invoiceNo: widget.invoiceNo);

                          if (!result.error) {
                            widget.onClose!(result.data);
                          } else {
                            widget.onClose!('Error');
                          }
                          _util.pop();
                        }
                      }
                      if (message.message == "close") _util.navigator.pop();

                      if (message.message == 'success') {
                        // await _createTransaction();
                        // _updateDiscount();
                      }
                    },
                  ),
                },
                ignoreSSLErrors: true,
              ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    _onUrlChange?.cancel();
  }

  void init() async {
    setState(() => loading = true);
    await _auth.refreshToken();
    final tkens = await OCSAuth().tokens();
    token = tkens?.accessToken ?? "";
    refreshToken = tkens?.refreshToken ?? '';

    // data
    data = jsonEncode({
      'tran_id': widget.invoiceNo,
      'firstname': widget.firstName,
      'lastname': widget.lastName,
      'amount': _amount,
      'OnWebView': true,
    });

    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(data);

    data = encoded;

    setState(() => loading = false);
  }

// Future _createTransaction() async {
//   // if (!_readyCreateTran)
//   await _walletRepo.createTransactionList(
//     amount: _amount,
//     refId: widget.reqId ?? 0,
//   );
//
//   // setState(() {
//   //   _readyCreateTran = true;
//   // });
// }

// Future _updateDiscount() async {
//   if (widget.discount != null) _discountRepo.update(widget.discount!);
// }
}
