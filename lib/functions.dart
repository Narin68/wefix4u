import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ocs_auth/ocs_auth.dart';
import 'package:ocs_firebase/remote_config.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '/screens/customer_service_request/customer_service_request_detail.dart';
import '/screens/partner_service_request/partner_service_request_detail.dart';
import '/screens/partner_wallet/wallet.dart';
import '/screens/news_and_promotion/news_detail.dart';
import '/blocs/news_and_promotion/news_and_promotion_cubit.dart';
import 'blocs/my_notification_count/my_notification_count_cubit.dart';
import 'blocs/user/user_cubit.dart';
import 'globals.dart';
import 'screens/notification/notification.dart';

import 'screens/widget.dart';

final _auth = OCSAuth.instance;
final httpClient = new HttpClient();

void messagingAction(BuildContext context,
    {required Map<String, dynamic> jsonData,
    bool fromNotification = false,
    int refId = 0}) {
  if (jsonData.isEmpty) return;

  String type = jsonData["ref_type"];
  int id = 0;
  if (jsonData["ref_id"] != null) id = int.parse(jsonData["ref_id"].toString());
  switch (type.toLowerCase()) {
    case "request":

      /// Request service
      _toRequest(id, context);
      break;

    case "request_feedback":
      OCSUtil.of(context).to(
        CustomerServiceRequestDetail(
          id: refId,
          notNotif: false,
          showFeedback: true,
        ),
        transition: OCSTransitions.LEFT,
      );
      break;

    case "quotation":

      /// When partner submit quot
      // if (Globals.userType.toLowerCase() == UserType.customer)
      // todo:Change next time
      // OCSUtil.of(context).to(
      //   PartnerAccept(refId: refId, isNot: true, quotId: id),
      //   transition: OCSTransitions.LEFT,
      // );
      break;

    case "news":

      /// News notification
      OCSUtil.of(context)
          .navigator
          .to(NewsDetail(id: id), transition: OCSTransitions.LEFT);
      break;
    case "wallettransaction":

      /// Wallet Transaction
      OCSUtil.of(context)
          .navigator
          .to(PartnerWallet(), transition: OCSTransitions.LEFT);
      break;
    default:
      if (!fromNotification)
        OCSUtil.of(context).to(NotificationScreen(
          mainContext: context,
          onClose: () {
            context.notificationCount();
          },
        ));
      break;
  }
}

void _toRequest(int refId, BuildContext context) {
  if (Globals.userType.toLowerCase() == UserType.customer) {
    OCSUtil.of(context).to(
        CustomerServiceRequestDetail(
          id: refId,
          notNotif: false,
        ),
        transition: OCSTransitions.LEFT);
  } else {
    OCSUtil.of(context).to(
      PartnerServiceRequestDetail(
        id: refId,
        notNotif: false,
      ),
      transition: OCSTransitions.LEFT,
    );
  }
}

Future saveToken(String token) async {
  await _auth.saveFirebaseToken(
    lang: Globals.langCode,
    token: token,
    userId: Model.userInfo.userId ?? "",
    deviceId: OCSUtil.deviceId,
  );
}

/// On get token
Future onGetToken(String? token) async {
  if ((token ?? "").isEmpty) return;

  var prefToken = await _auth.getFirebaseToken() ?? '';
  if (prefToken.isEmpty || (token != prefToken)) {
    saveToken(token!);
  } else {
    print('Firebase Token: $prefToken');
  }
  Globals.fbToken = token!;
}

/// Message on the background
Future onBackground(BuildContext context, RemoteMessage message) async {
  context.notificationCount();
  var messageData = message.data;
  String refType = messageData['ref_type'];
  context.notificationCount();
  switch (refType.toLowerCase()) {
    case "news":
      context.read<MyNotificationCountCubit>().setNewsCount(1);
      context.read<NewsAndPromotionCubit>()
        ..fetch(isInit: true, isLoading: false);
      break;

    case "wallettransaction":
      break;
  }
}

/// On open message
Future onOpen(BuildContext context, RemoteMessage message) async {
  context.notificationCount();
  var messageData = message.data;
  print("On open message => ${message.data}");
  messagingAction(context, jsonData: messageData);
}

void loadUserInfo(BuildContext context) {
  context
      .read<MyUserCubit>()
      .update(user: Model.userInfo, customer: Model.customer);
}

Future checkPermission() async {
  var status = await Permission.location.status;
  if (status.isDenied) {
    await [
      Permission.location,
    ].request();
  }
  if (await Permission.speech.isPermanentlyDenied) {
    openAppSettings();
  }
}

Future setUsedAccess() async {
  var pref = await SharedPreferences.getInstance();
  pref.setBool(Prefs.usedLogin, true);
}

Future<bool> getUsedAccess() async {
  var pref = await SharedPreferences.getInstance();
  bool access = pref.getBool(Prefs.usedLogin) ?? false;
  return access;
}

Future saveFirebaseToken() async {
  FirebaseMessaging.instance.getToken().then((token) async {
    saveToken(token ?? "");
    Globals.fbToken = token ?? "";
    print("Firebase Save => $token");
  });
}

Future checkVersion(BuildContext context) async {
  var _util = OCSUtil.of(context);
  final packageInfo = await PackageInfo.fromPlatform();
  var lVersion = packageInfo.version;
  final url = await OCSFbConfig.getString(
      Platform.isAndroid ? 'play_store_url' : 'app_store_url');
  String rVersion = await OCSFbConfig.getString(
      Platform.isAndroid ? 'android_version' : 'ios_version');
  var rv = int.parse(rVersion.split('.').fold('', (p, e) => p + e.trim()));
  var lv = int.parse(lVersion.split('.').fold('', (p, e) => p + e.trim()));

  if (rv > lv)
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return WillPopScope(
            child: AlertDialog(
              contentPadding: EdgeInsets.all(0),
              content: Parent(
                style: ParentStyle()..maxWidth(Globals.maxScreen),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Parent(
                      style: ParentStyle()
                        ..padding(all: 10)
                        ..background.color(OCSColor.background)
                        ..width(_util.query.width)
                        ..alignmentContent.center()
                        ..maxWidth(Globals.maxScreen),
                      child: Txt(
                        _util.language.key('update-available'),
                        style: TxtStyle()
                          ..fontSize(16)
                          ..textColor(OCSColor.text)
                          ..textAlign.left(),
                      ),
                    ),
                    Parent(
                      style: ParentStyle()..padding(all: 15, top: 0),
                      child: Column(
                        children: [
                          Txt(
                            "${_util.language.key('update-version-content')} $lVersion ${_util.language.key('to')} $rVersion",
                            style: TxtStyle()
                              ..fontSize(Style.subTitleSize)
                              ..margin(vertical: 25, bottom: 20)
                              ..textColor(OCSColor.text),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Parent(
                            gesture: Gestures()
                              ..onTap(() {
                                _util.pop();
                              }),
                            style: ParentStyle()
                              ..ripple(true)
                              ..background.color(OCSColor.background),
                            child: Txt(
                              _util.language.key('later'),
                              style: TxtStyle()
                                ..padding(all: 10)
                                ..fontSize(14)
                                ..alignmentContent.center()
                                ..textColor(OCSColor.text.withOpacity(0.7)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Parent(
                            gesture: Gestures()
                              ..onTap(() async {
                                await launchUrl(Uri.parse(url));
                                _util.navigator.pop();
                              }),
                            style: ParentStyle()
                              ..ripple(true)
                              ..background
                                  .color(OCSColor.primary.withOpacity(0.2)),
                            child: Txt(
                              _util.language.key('update-now'),
                              style: TxtStyle()
                                ..alignmentContent.center()
                                ..padding(all: 10)
                                ..fontSize(14)
                                ..fontWeight(FontWeight.bold)
                                ..textColor(OCSColor.primary),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            onWillPop: () async {
              return false;
            });
      },
    );
}

Future requestLocationPermission(BuildContext context) async {
  late var _util = OCSUtil.of(context);
  var status = await Permission.location.status;
  if (!status.isGranted && Platform.isAndroid) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: AlertDialog(
            contentPadding: EdgeInsets.all(15),
            content: Parent(
              style: ParentStyle(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/map.png',
                    height: 170,
                  ),
                  Txt(
                    "wefix4u app collect your location data to access your home location to find nearest & suitable service maintenance partner.",
                    style: TxtStyle()
                      ..fontSize(14)
                      ..margin(vertical: 15)
                      ..width(Globals.maxScreen)
                      ..textColor(OCSColor.text)
                      ..textAlign.center(),
                  ),
                  BuildButton(
                    title: 'Accept',
                    fontSize: 14,
                    height: 40,
                    width: 180,
                    onPress: () async {
                      _util.navigator.pop();
                      await [
                        Permission.location,
                      ].request();
                    },
                  ),
                  SizedBox(height: 5),
                  TextButton(
                    onPressed: () {
                      _util.navigator.pop();
                    },
                    child: Txt(
                      "Deny",
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
      },
    );
  }
}

Future openFile(String url) async {
  File? _file = await downloadFile(url);
  OpenFile.open(_file.path);
}

Future<File> downloadFile(String url) async {
  var request = await httpClient.getUrl(Uri.parse(url));
  var response = await request.close();
  var bytes = await consolidateHttpClientResponseBytes(response);
  String dir = (await getApplicationDocumentsDirectory()).path;
  File file = new File(
      '$dir/${OCSUtil.dateFormat(DateTime.now(), langCode: "en", format: "MMDDYYY")}${DateTime.now().millisecond}');
  await file.writeAsBytes(bytes);
  return file;
}

Future deleteFile(File file) async {
  try {
    await file.delete();
    print("Success delete file");
  } catch (e) {
    print("Error delete file $e");
  }
}

Future<File> uintWriteToFile(Uint8List data) async {
  final tempDir = await getTemporaryDirectory();
  File file = await File('${tempDir.path}/image.png').create();
  file.writeAsBytesSync(data);
  return file;
}

String showNumber(String? number) {
  String newNumber = number ?? '';
  if (newNumber.contains('+855')) {
    newNumber = '0' + newNumber.split('+855')[1];
  }

  if (newNumber.length > 6) {
    final n1 = newNumber.substring(0, 3);
    final n2 = newNumber.substring(3, 6);
    final n3 = newNumber.substring(6, newNumber.length);
    newNumber = '$n1 $n2 $n3';
  }
  return newNumber;
}
