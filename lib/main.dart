import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ocs_auth/ocs_auth.dart';
import 'package:ocs_auth/repos/user.dart';
import 'package:ocs_firebase/ocs_firebase.dart';
import 'package:ocs_util/ocs_util.dart';
import '/blocs/count_message/count_message_cubit.dart';
import '/screens/auths/login.dart';
import '/repositories/customer.dart';
import 'blocs/chat_request/chat_request_bloc.dart';
import 'blocs/message/message_bloc.dart';
import 'blocs/my_notification_count/my_notification_count_cubit.dart';
import 'functions.dart';
import 'screens/home/home_menus.dart';
import '/blocs/settlement_rule/settlement_rule_cubit.dart';
import '/blocs/wallet/wallet_cubit.dart';
import '/signalr.dart';
import '/blocs/request_service_detail/request_service_detail_bloc.dart';
import '/blocs/business/business_bloc.dart';
import '/repositories/invoice_repo.dart';
import '/repositories/partner_repo.dart';
import '/blocs/partner/partner_cubit.dart';
import '/blocs/partner_item/partner_item_bloc.dart';
import '/repositories/customer_request_service.dart';
import '/repositories/news_and_promotion.dart';
import 'blocs/address/address_cubit.dart';
import 'blocs/service_request/service_request_bloc.dart';
import 'blocs/invoice/invoice_bloc.dart';
import 'blocs/language/language_cubit.dart';
import 'blocs/news_and_promotion/news_and_promotion_cubit.dart';
import 'blocs/quotation/quotation_bloc.dart';
import 'blocs/receipt/receipt_bloc.dart';
import 'blocs/service/service_bloc.dart';
import 'blocs/service_category/service_category_bloc.dart';
import 'blocs/user/user_cubit.dart';
import 'blocs/wallet_transaction/wallet_transaction_bloc.dart';
import 'globals.dart';
import 'modals/customer.dart';
import 'repositories/quotation_repo.dart';
import 'repositories/service_repo.dart';

void main() async {
  OCSColor.primaryValue = 0xffC13027; //#C13027
  WidgetsFlutterBinding.ensureInitialized();
  await OCSFirebase.init();
  runApp(RestartWidget(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Parent(
      style: ParentStyle(),
      gesture: Gestures()
        ..onTap(() {
          FocusManager.instance.primaryFocus?.unfocus();
        }),
      child: MainBuilder(
        debugShowCheckedModeBanner: false,
        fontFamily: "kmFont",
        changeLangListener: (context, s) {
          Globals.langCode = s;
        },
        themeData: ThemeData(
          fontFamily: "kmFont",
          primarySwatch:
              MaterialColor(OCSColor.primaryValue, OCSColor.primarySwatch),
          scaffoldBackgroundColor: OCSColor.background,
          appBarTheme: AppBarTheme(),
        ),
        builder: (context) => Splash(
          logoSize: 100,
          bottom: Center(
            child: RichText(
              text: const TextSpan(
                text: 'Developed by',
                style: TextStyle(fontSize: 12),
                children: [
                  TextSpan(text: ' . '),
                  TextSpan(
                    text: 'wefix4u',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  )
                ],
              ),
            ),
          ),
          onSplash: (ctx) async {
            Format.date = "dd MMM yyyy";
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]);
            await OCSUtil.init();

            await _getDomain();
            await OCSAuth.config(
              deviceId: OCSUtil.deviceId,
              server: ApisString.server,
              externalToken: Globals.exToken,
              webServer: ApisString.webServer,
              database: Globals.databaseName,
            );
            _checkAuth(ctx);
          },
          logo: "assets/logo/logo-white.png",
          appTitle: 'wefix4u',
          isMaintenance: FBEnv.isMaintenance,
        ),
        providers: [
          BlocProvider(create: (_) => LanguageCubit()..init()),
          BlocProvider(create: (_) => MyUserCubit()),
          BlocProvider(create: (_) => UserCubit()..init()),
          BlocProvider(create: (_) => AddressCubit()),
          BlocProvider(create: (_) => PartnerCubit()),
          BlocProvider(create: (_) => NotificationCountCubit()),
          BlocProvider(create: (_) => WalletCubit()),
          BlocProvider(create: (_) => SettlementRuleCubit()),
          BlocProvider(create: (_) => ServiceBloc(repo: ServiceRepo())),
          BlocProvider(create: (_) => ServiceCategoryBloc()),
          BlocProvider(
              create: (_) =>
                  RequestServiceDetailBloc(repo: ServiceRequestRepo())),
          BlocProvider(
              create: (_) => ServiceRequestBloc(repo: ServiceRequestRepo())),
          BlocProvider(create: (_) => PartnerItemBloc()),
          BlocProvider(
              create: (_) => NewsAndPromotionCubit(NewsAndPromotionRepo())),
          BlocProvider(create: (_) => NotificationCubit()),
          BlocProvider(create: (_) => BusinessBloc(repo: PartnerRepo())),
          BlocProvider(create: (_) => InvoiceBloc(repo: InvoiceRepo())),
          BlocProvider(create: (_) => ReceiptBloc(repo: InvoiceRepo())),
          BlocProvider(create: (_) => QuotationBloc(repo: QuotRepo())),
          BlocProvider(create: (_) => WalletTransactionBloc()),
          BlocProvider(create: (_) => MessageBloc()),
          BlocProvider(create: (_) => CountMessageCubit()),
          BlocProvider(create: (_) => ChatRequestBloc()),
          BlocProvider(create: (_) => MyNotificationCountCubit()..init()),
        ],
        title: "wefix4u",
      ),
    );
  }
}

Future _checkAuth(BuildContext context) async {
  var _util = OCSUtil.of(context);
  bool isAuth = await isAuthenticated();

  var res = await OCSAuth.instance.refreshToken(false);

  print("Result => ${res}");

  if (isAuth) {
    // authSync(context);
    var current = await UserInfoRepo.getFromPref();
    Model.userInfo = current!;
    await setUsedAccess();
    Globals.hasAuth = true;
    await _setUserType();
    await _getCustomer();
    _util.navigator.replace(HomeMenus(), isFade: true);
  } else {
    await _whenError(_util);
  }
}

Future _whenError(OCSUtilities util) async {
  Globals.userType = 'customer';
  bool _access = await getUsedAccess();
  if (_access) {
    util.navigator.replace(HomeMenus(), isFade: true);
    util.navigator.to(Login(), isFade: true);
  } else {
    util.navigator.replace(HomeMenus(), isFade: true);
  }
  Globals.hasAuth = false;
}

Future _getCustomer() async {
  var currentCus = await CustomerRepo.getCusFromPref();
  if (currentCus != null) {
    Model.customer = currentCus;
  } else {
    CustomerRepo _customerRepo = CustomerRepo();
    var cusResp = await _customerRepo
        .list(MMyCustomerFilter(code: Model.userInfo.loginName));
    if (!cusResp.error) {
      Model.customer =
          cusResp.data.length < 1 ? MMyCustomer() : (cusResp.data ?? []).first;
    }
  }
}

Future _setUserType() async {
  var _pref = await SharedPreferences.getInstance();
  var userType = _pref.getString(Prefs.userType);
  if (userType == '' ||
      userType == null ||
      Model.userInfo.userType?.toLowerCase() == UserType.customer)
    Globals.userType =
        (Model.userInfo.userType?.toLowerCase()) ?? UserType.customer;
  else
    Globals.userType = userType;
}

Future _getDomain() async {
  ApisString.webServer = await OCSFbConfig.getString('web_server');
  ApisString.server = await OCSFbConfig.getString('api_server');
  ApisString.webServer = await OCSFbConfig.getString('test_web');
  ApisString.server = await OCSFbConfig.getString('test_api');
}

class RestartWidget extends StatefulWidget {
  RestartWidget({this.child});

  final Widget? child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget>
    with WidgetsBindingObserver {
  Key key = UniqueKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future didChangeAppLifecycleState(AppLifecycleState state) async {
    print("SignalR Connected => ${await MySignalR.connected()}");

    if (await MySignalR.connected() == false) {
      await MySignalR.reconnect();
      if (state.name.toLowerCase() == 'resumed') {
        print("SignalR Connected => ${await MySignalR.connected()}");
      }
    }
    if (state.name.toLowerCase() == 'resumed') {
      MySignalR.verify();
      setState(() {});
    }
  }

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child ?? SizedBox(),
    );
  }
}
