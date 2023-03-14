import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ocs_auth/ocs_auth.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:signalr_flutter/signalr_api.dart';
import 'package:signalr_flutter/signalr_flutter.dart';
import 'package:wefix4utoday/screens/partner_wallet/wallet.dart';
import '/screens/customer_service_request/customer_service_request_detail.dart';
import '/screens/partner_service_request/partner_service_request_detail.dart';
import '/modals/message.dart';
import '/repositories/message_repo.dart';
import '/blocs/settlement_rule/settlement_rule_cubit.dart';
import '/blocs/wallet/wallet_cubit.dart';
import '/blocs/wallet_transaction/wallet_transaction_bloc.dart';
import '/modals/settlement_rule.dart';
import '/modals/wallet_transaction.dart';
import '/screens/more/business_info/business_request.dart';
import '/blocs/business/business_bloc.dart';
import '/modals/business.dart';
import '/modals/partner.dart';
import '/blocs/service_request/service_request_bloc.dart';
import '/modals/customer_request_service.dart';
import 'blocs/count_message/count_message_cubit.dart';
import 'blocs/message/message_bloc.dart';
import 'blocs/my_notification_count/my_notification_count_cubit.dart';
import 'blocs/partner/partner_cubit.dart';
import 'blocs/request_service_detail/request_service_detail_bloc.dart';
import 'globals.dart';
import 'main.dart';
import 'modals/wallet.dart';
import 'screens/message/message_detail.dart';
import 'screens/widget.dart';

Future onStatusChange(status) async {
  if (status.toString().toLowerCase() == "connected") {
    MySignalR.verify();
  }
}

Future onNewMessage(BuildContext context, m, msg) async {
  var json = jsonDecode(msg);

  // print("On new message => ${msg}");

  switch (m.toString().toLowerCase()) {
    case "response":
      break;

    case "verify":
      print(msg);
      break;

    case "watchpartnerrequest":
      _watchPartnerRequest(context, msg);
      break;

    case "watchpartnerstatus":
      _watchPartnerStatus(context, msg);
      break;

    case "watchwallet":
      MWalletData data = MWalletData.fromJson(jsonDecode(msg)["Wallet"]);
      context.read<WalletCubit>().updateWallet(data);
      break;

    case "wathsettlementrule":
      _watchSettlementRule(context, msg);
      break;

    case "watchwithdrawalrequest":
      break;

    case "message":
      var json = jsonDecode(msg);
      context.read<NotificationCountCubit>().count();
      showMessage(context,
          message: json["Message"], title: json["Title"], onTab: () {});
      break;

    case "chat":
      await _watchMessage(context, msg);
      break;

    case "seen":
      _watchSeen(context, msg);
      break;

    case "updatechat":
      var json = jsonDecode(msg);
      MMessageData data = MMessageData.fromJson(json);
      context.read<MessageBloc>().add(UpdateMessage(data: data));
      break;

    case "multipleseen":
      _multipleSeen(msg, context);
      break;

    case "gotservice":
      print("Got service => ${msg}");
      _gotService(context, json);
      break;

    case "gotaccepted":
      print("GotAccepted => ${msg}");
      _getAccepted(context, json);
      break;

    case "quotesubmitted":
      print("Quot submitted => ${json}");
      _submitQuot(context, json);
      break;

    case "gotcancel":
      print("Cancel => $json");
      _gotCancel(context, json);
      break;

    case "gotreject":
      print("Reject => $json");
      _gotReject(context, json);
      break;

    case "gotapprove":
      print("Approve => $json");
      _gotApprove(context, json);
      break;

    case "heading":
      print("Heading => $json");
      _heading(context, json);
      break;

    case "fixing":
      print("Fixing => $json");
      _fixing(context, json);
      break;

    case "close":
      print("close => $json");
      _close(context, json);
      break;

    case "gotpayment":
      print("Got payment => $json");
      _gotPayment(context, json);
      break;

    case "walletupdate":
      print("WalletUpdate => $json");
      _updateWallet(context, json);
      break;

    case "gotfeedback":
      print("Got feedBack => $json");
      _feedback(context, json);
      break;

    case "customergotreject":
      print("Got feedBack => $json");
      _rejectByCompany(context, json);
      break;
  }
}

void _multipleSeen(String msg, BuildContext context) {
  var json = jsonDecode(msg);
  List<MMessageData> data = [];
  json["Data"].forEach((x) => data.add(MMessageData.fromJson(x)));
  List<int> ids = [];
  data.forEach((e) {
    ids.add(e.id ?? 0);
  });
  context.read<MessageBloc>().add(UpdateSeenMessage(ids: ids));
}

Future<MReceiver> _getSender(int id, String username) async {
  MResponse _res = await MessageRepo().getSender(id, username);
  if (!_res.error) {
    return _res.data;
  } else {
    return MReceiver();
  }
}

void _watchSeen(BuildContext context, msg) {
  var json = jsonDecode(msg);
  MMessageData data = MMessageData.fromJson(json);
  context.read<MessageBloc>().add(UpdateSeenMessage(ids: [data.id ?? 0]));
}

void _gotCancel(BuildContext context, msg) {
  var header = MRequestService.fromJson(msg);
  String km = "សំណើរលេខ ${header.code} ត្រូវបានបោះបង់ចោល";
  String en = "Request ${header.code} has been canceled";
  _updateRequest(context, header,
      km: km, en: en, snackBarStatus: SnackBarStatus.danger);
  _updateRequestDetail(context, header);
}

void _getAccepted(BuildContext context, msg) {
  var header = MRequestService.fromJson(msg);
  String en = "Your request ${header.code} has been accepted";
  String km = "សំណើររបស់អ្នកលេខ ${header.code} មានការទទួលជួសជុល";
  _updateRequest(context, header, en: en, km: km);
  _updateRequestDetail(context, header, getDetail: true);
}

void _gotApprove(BuildContext context, msg) {
  var header = MRequestService.fromJson(msg);
  String en =
      "Congratulation! You have been approved to serve services on request ${header.code} ";
  String km =
      "អបអរសាទរ! អ្នកត្រូវបានយល់ព្រមទទួលអោយធ្វើទៅលើសេវាកម្មដែលពាក់ព័ន្ធទៅនឹងសំណើរលេខ ${header.code}";
  _updateRequest(context, header, en: en, km: km);
  _updateRequestDetail(context, header, getDetail: false);
}

void _gotReject(BuildContext context, msg) {
  var header = MRequestService.fromJson(msg);
  String en = '';
  String km = '';
  if (header.status?.toUpperCase() == RequestStatus.rejected) {
    en = "Sorry, you have been rejected by a customer on request ";
    km =
        "សូមអភ័យទោស អ្នកត្រូវបានអតិថិជនបដិសេធមិនអោយធ្វើសេវាកម្មដែលពាក់ព័ន្ធនឹងសំណើរលេខ ${header.code} ឡើយ។";
  } else if (header.status?.toUpperCase() == RequestStatus.canceled) {
    en = "Request ${header.code} has been canceled";
    km = "សំណើរលេខ ${header.code} ត្រូវបានបានបោះបង់។";
  }
  _updateRequest(context, header,
      en: en, km: km, snackBarStatus: SnackBarStatus.danger);
  _updateRequestDetail(context, header);
}

void _gotService(BuildContext context, json) {
  MRequestService header = MRequestService.fromJson(json);

  String en = "There is a request on some services which is suitable for you";
  String km = "មានសំណើរសូមប្រើប្រាស់សេវាកម្មមួយចំនួនដែលមានពាក់ព័ន្ធនឹងអ្នក។";
  _setRequestCount(context);
  if (Globals.userType == UserType.partner) {
    _addNewRequest(context, header: header);
    _showAlert(context, message: [en, km], header: header);
  }
}

void _heading(BuildContext context, msg) {
  MRequestService header = MRequestService.fromJson(msg);

  String en =
      "Service provider is heading to a location of your request ${header.code}";
  String km =
      "អ្នកផ្តល់សេវាកម្មកំពុងធ្វើដំណើរទៅកាន់ទីតាំងដែលពាក់ព័ន្ធទៅនឹងសំណើររបស់អ្នកលេខ ${header.code} ។";
  _updateRequest(context, header, en: en, km: km);
  _updateRequestDetail(context, header);
}

void _fixing(BuildContext context, msg) {
  MRequestService header = MRequestService.fromJson(msg);
  String en = "Fixing process on your request ${header.code} is in progress";
  String km =
      "ដំណើរការជួសជុលពាក់ព័ន្ធទៅនឹងសំណើររបស់អ្នកលេខ ${header.code} កំពុងត្រូវបានបំពេញ។";
  _updateRequest(context, header, en: en, km: km);
  _updateRequestDetail(context, header);
}

void _close(BuildContext context, msg) {
  MRequestService header = MRequestService.fromJson(msg);
  String en =
      "The process of your request ${header.code} has been fulfilled and invoice has been submitted";
  String km =
      "ដំណើរការពាក់ព័ន្ធនឹងសំណើររបស់អ្នកលេខ ${header.code} ត្រូវបានបញ្ចប់រួចរាល់";
  _updateRequest(context, header, en: en, km: km);
  _updateRequestDetail(
    context,
    header,
  );
}

void _feedback(BuildContext context, msg) {
  MRequestService header = MRequestService.fromJson(msg);
  String en =
      "A request ${header.code} which you have been worked on got confirmed finished by customer with ${header.rating} rating";
  String km =
      "សំណើរលេខ ${header.code} ដែលអ្នកបានធ្វើត្រូវបានបញ្ជាក់ថាបានបញ្ចប់ជោគជ័យជាមួយនឹងការវាយតំលៃ ${header.rating} ។";
  _updateRequest(context, header, en: en, km: km);
  _updateRequestDetail(context, header);
}

void _gotPayment(BuildContext context, msg) {
  MRequestService header = MRequestService.fromJson(msg);
  String en =
      "Congratulation! customer has already made payment on request ${header.code} ";
  String km =
      "អបអរសាទរ! អតិថិជនបានបង់ប្រាក់ទៅលើសំណើរលេខ ${header.code} រួចរាល់ហើយ";
  _updateRequest(context, header, en: en, km: km);
  _updateRequestDetail(context, header);
}

void _rejectByCompany(BuildContext context, msg) {
  MRequestService header = MRequestService.fromJson(msg);
  String en = "Request ${header.code} has been rejected";
  String km = "សំណើរលេខ ${header.code} ត្រូវបានបានបដិសេធ។";
  _updateRequest(context, header,
      en: en, km: km, snackBarStatus: SnackBarStatus.danger);
  _updateRequestDetail(context, header, getDetail: true);
}

void _updateWallet(BuildContext context, msg) {
  MWalletTransactionData data = MWalletTransactionData.fromJson(msg);
  context
      .read<WalletCubit>()
      .updateBalanceAndEarning(balance: data.balance, earning: data.earning);
  String en = '';
  String km = '';

  if (data.transactionType?.toUpperCase() == "E") {
    en =
        "Your wallet is received ${OCSUtil.currency(data.amount ?? 0, sign: "\$")} from a payment on request ${data.requestCode}";
    km =
        "ទឹកប្រាក់ចំនួន ${OCSUtil.currency(data.amount ?? 0, sign: "\$")} បញ្ចូលទៅកាន់កាបូបលុយរបស់អ្នកតាមរយៈការបង់ប្រាក់លើសំណើរលេខ ${data.requestCode}";
    context.read<WalletTransactionBloc>().add(AddWalletTransaction(data: data));
  } else if (data.transactionType?.toUpperCase() == "R") {
    km =
        "ទឹកប្រាក់ ${OCSUtil.currency(data.amount ?? 0, sign: "\$", decimal: 2)} ត្រូវបានផ្ទេរទៅកាន់សមតុល្យសាច់ប្រាក់កាបូបរបស់អ្នក";
    en =
        "Your wallet is received ${OCSUtil.currency(data.amount ?? 0, sign: "\$", decimal: 2)} from your earning to balance";
    _updateWalletTransaction(context, data);
  } else if (data.transactionType?.toUpperCase() == "W" &&
      data.status?.toUpperCase() == "A") {
    km =
        "ទឹកប្រាក់ ${OCSUtil.currency(data.amount ?? 0, sign: "\$", decimal: 2)} ត្រូវបានផ្ទេរទៅកាន់គណនី ${data.bankName ?? ""} លេខ ${data.bankAccount ?? ""}";
    en =
        "We has withdraw ${OCSUtil.currency(data.amount ?? 0, sign: "\$", decimal: 2)} from your wallet to ${data.bankName ?? ""} account ${data.bankAccount ?? ""}";
    _updateWalletTransaction(context, data);
  } else if (data.transactionType?.toUpperCase() == "W" &&
      data.status?.toUpperCase() == "R") {
    km =
        "សំណើរដកប្រាក់ចំនួន ${OCSUtil.currency(data.amount ?? 0, sign: "\$", decimal: 2)} របស់អ្នកត្រូវបានបដិសេធ";
    en =
        "Your withdraw request ${OCSUtil.currency(data.amount ?? 0, sign: "\$", decimal: 2)} has been rejected";
    _updateWalletTransaction(context, data);
    showSnackBar(context, message: Globals.langCode == "km" ? km : en,
        onTab: () {
      OCSUtil.of(context).to(PartnerWallet(), transition: OCSTransitions.LEFT);
    }, status: SnackBarStatus.danger);

    return;
  }

  if (en.isNotEmpty && km.isNotEmpty)
    showSnackBar(context, message: Globals.langCode == "km" ? km : en,
        onTab: () {
      OCSUtil.of(context).to(PartnerWallet(), transition: OCSTransitions.LEFT);
    });
}

void _updateWalletTransaction(
    BuildContext context, MWalletTransactionData data) {
  context
      .read<WalletTransactionBloc>()
      .add(UpdateWalletTransaction(data: data));
}

void _setRequestCount(BuildContext context) {
  context.read<MyNotificationCountCubit>().setServiceRequestCount(1);
}

void _submitQuot(BuildContext context, json) {
  var header = MRequestService.fromJson(json);
  String en =
      "${header.partnerName} has been submitted a quotation on your request ${header.code}";
  String km =
      "${header.partnerName} បានចេញតារាងតំលៃទៅលើសំណើររបស់អ្នកលេខ ${header.code}";
  _showAlert(context, message: [en, km], header: header);
  _updateRequestDetail(context, header, getDetail: true);
}

void _updateRequest(
  BuildContext context,
  MRequestService header, {
  String km = '',
  String en = '',
  SnackBarStatus snackBarStatus = SnackBarStatus.success,
}) {
  context.read<ServiceRequestBloc>()..add(UpdateServiceRequest(data: header));
  _setRequestCount(context);
  if (km.isNotEmpty || en.isNotEmpty)
    _showAlert(context,
        message: [en, km], header: header, snackBarStatus: snackBarStatus);
}

void _updateRequestDetail(BuildContext context, MRequestService header,
    {bool getDetail = false}) {
  context.read<RequestServiceDetailBloc>()
    ..add(UpdateStatusDetail(
        id: header.id, status: header.status, getDetail: getDetail));
}

Future _watchMessage(BuildContext context, msg) async {
  var json = jsonDecode(msg);
  MMessageData data = MMessageData.fromJson(json);
  context.read<MessageBloc>().add(AddMessage(data: data));
  context.read<CountMessageCubit>().fetchCountMessage(data.requestId);
  if (Globals.inMessagePage && Globals.requestId == data.requestId) return;
  if (data.receivers?[0] != Model.userInfo.loginName) return;
  var sender = await _getSender(data.id ?? 0, data.sender ?? "");

  showMessage(context,
      message: data.contentType == "T"
          ? data.contentMsg
          : OCSUtil.of(context).language.key(
                '${data.contentType == "I" ? "sent-image-message" : "sent-voice-message"}',
              ),
      showLogo: data.sender == "COMPANY" ? true : false,
      title: OCSUtil.of(context).language.by(
            km: sender.receiverName,
            en: sender.receiverNameEnglish,
          ),
      onTab: (sender.receiverId == null ||
                  (Globals.inMessagePage &&
                      Globals.requestId != data.requestId)) &&
              data.sender != "COMPANY"
          ? null
          : () {
              OCSUtil.of(context).to(
                MessageDetail(
                  requestId: data.requestId ?? 0,
                  receiverImage: sender.receiverImage,
                  receiverName: data.sender == "COMPANY"
                      ? "wefix4u"
                      : OCSUtil.of(context).language.by(
                            km: sender.receiverName,
                            en: sender.receiverNameEnglish,
                          ),
                  receiverId: sender.receiverId,
                ),
              );
            });
}

Future invokeSignalR({required Function method, int retrySignalR = 0}) async {
  if (await MySignalR.connected()) {
    method();
    return;
  } else {
    retrySignalR++;
    if (retrySignalR == 3) return;
    return invokeSignalR(method: method, retrySignalR: retrySignalR);
  }
}

void _watchSettlementRule(BuildContext context, String msg) {
  /// When company update partner's settlement rule
  MSettlementData data = MSettlementData.fromJson(jsonDecode(msg));
  if (data.refId == Model.settlementRule?.refId) {
    context.read<SettlementRuleCubit>().updateSettlementRule(data);
    String km = "មានការផ្លាស់ប្តូទៅលើរបៀបបង់ប្រាក់";
    String en = "Settlement has changed";
    showSnackBar(context, message: Globals.langCode == "en" ? en : km);
  }
}

Future initSignalR(BuildContext context) async {
  final _instance = MySignalR();
  await _instance.connect(
    onMessage: (m, message) => onNewMessage(context, m, message),
    statusChange: (s) => onStatusChange(s),
  );
}

sendSignalR({String? detail, required String method, String? id}) {
  switch (method.toLowerCase()) {
    case "updatechat":
      MySignalR.updateChat(detail ?? "");
      break;
    case "chat":
      MySignalR.chat(detail ?? "");
      break;
    case "seen":
      MySignalR.seen(detail ?? "");
      break;
    case "multipleseen":
      MySignalR.multipleSeen(detail ?? "");
      break;
  }
}

Map<String, String>? requestHeader({String? token}) => {
      'Content-Type': 'application/json',
      'Authorization': token ?? AuthConfig.externalToken,
      'oc_device_id': AuthConfig.deviceId,
      'oc_database': AuthConfig.database,
    };

class MySignalR {
  static late SignalR instance;

  connect({
    Function(String status)? statusChange,
    Function(String method, String message)? onMessage,
  }) {
    instance = SignalR(
      '${ApisString.server}/DataHub',
      'DataHub',
      hubMethods: [
        'watchRequest',
        // 'accept',
        // 'requestService',
        // 'giveUp',
        // 'cancel',
        'heading',
        "fixing",
        "close",
        "submitQuotation",
        "approve",
        "rejectPartner",
        "verify",
        "checkHeader",
        "checkAuth",
        "response",
        "watchPartnerRequest",
        "watchPartnerStatus",
        "WathSettlementRule",
        "watchWithdrawalRequest",
        "watchWallet",
        "watchTransaction",
        "partnerShip",
        "updateSvAndCv",
        "rejectRequest",
        "message",
        "chat",
        "updateChat",
        "seen",
        "multipleSeen",
        "gotService",
        "gotAccepted",
        "gotCancel",
        "gotReject",
        "gotApprove",
        "gotCancel",
        "quoteSubmitted",
        "gotPayment",
        "walletUpdate",
        "gotFeedBack",
        "customerGotReject"
      ],
      statusChangeCallback: (ConnectionStatus? s) {
        if (statusChange != null) {
          statusChange(s?.name ?? 'Unknown');
        }
      },
      hubCallback: onMessage,
      transport: Transport.auto,
      headers: requestHeader(),
    );
    instance.connect();
  }

  static void checkAuth(String detail) {
    instance.invokeMethod('checkAuth', arguments: [detail]);
  }

  static void verify() {
    if (Model.userInfo.userId != null)
      instance.invokeMethod('verify', arguments: [
        "${Model.userInfo.loginName}",
        Globals.userType,
        Model.userInfo.referenceCode ?? "",
      ]);
  }

  static void checkHeader(String detail) {
    instance.invokeMethod('checkHeader', arguments: [detail]);
  }

  static void partnership(String detail) {
    instance.invokeMethod('partnerShip', arguments: [detail]);
  }

  static void updateSvAndCv(String detail) {
    instance.invokeMethod('updateSvCv', arguments: [detail]);
  }

  static void updateChat(String detail) {
    instance.invokeMethod('updateChat', arguments: [detail]);
  }

  static void seen(String detail) {
    instance.invokeMethod('seen', arguments: [detail]);
  }

  static void chat(String detail) {
    instance.invokeMethod('chat', arguments: [detail]);
  }

  static void multipleSeen(String detail) {
    instance.invokeMethod('multipleSeen', arguments: [detail]);
  }

  static Future<bool> connected() async {
    return instance.isConnected();
  }

  static Future reconnect() async {
    instance.connect();
  }
}

Future reConnectSignalR() async {
  MySignalR.verify();
}

Future disconnectSignalR() async {
  MySignalR.instance.stop();
}

void _addNewRequest(BuildContext context, {required MRequestService header}) {
  context.read<ServiceRequestBloc>().add(AddServiceRequest(data: [header]));
}

void _showAlert(BuildContext context,
    {required List<String> message,
    required MRequestService header,
    SnackBarStatus snackBarStatus = SnackBarStatus.success}) {
  showSnackBar(
    context,
    message: Globals.langCode == "km" ? message[1] : message[0],
    icon: Icons.construction,
    onTab: () {
      _onClickSnackBar(context, header);
    },
    status: snackBarStatus,
  );
}

_onClickSnackBar(BuildContext context, MRequestService header) {
  context.read<MyNotificationCountCubit>().decreaseRequest();
  Navigator.push(
    context,
    OCSPageTransition(
      to: Globals.userType.toLowerCase() == UserType.customer
          ? CustomerServiceRequestDetail(data: header)
          : PartnerServiceRequestDetail(data: header),
      isFade: true,
      transition: OCSTransitions.LEFT,
    ),
  );
}

void _watchPartnerRequest(BuildContext context, String msg) {
  /// Partner's request update service and coverage
  var _util = OCSUtil.of(context);
  var json = jsonDecode(msg);
  MBusinessRequestList data = MBusinessRequestList.fromJson(json);
  context.read<BusinessBloc>().add(UpdateBusinessRequest(data: data));
  String en =
      "Your request update services and coverages has been ${data.status}";
  String km =
      "ការស្នើសុំបន្ថែមសេវាកម្មនិងតំបន់សេវាកម្មរបស់អ្នកត្រូវបាន${data.status?.toLowerCase() == "approved" ? "អនុញ្ញាត" : "បដិសេដ"}";
  showSnackBar(
    context,
    message: Globals.langCode == "km" ? km : en,
    status: data.status?.toLowerCase() == "approved"
        ? SnackBarStatus.success
        : SnackBarStatus.danger,
    onTab: () {
      _util.navigator.to(BusinessRequest(), transition: OCSTransitions.LEFT);
    },
  );
  if (data.status?.toLowerCase() == "approved")
    context.read<PartnerCubit>().getPartnerDetail();
}

void _watchPartnerStatus(BuildContext context, String msg) {
  var json = jsonDecode(msg);
  MPartnerRequest partnerRequest = MPartnerRequest.fromJson(json["Header"]);
  MPartnerRequestDetail detail = MPartnerRequestDetail.fromJson(json["Detail"]);
  context.read<PartnerCubit>().update(detail: detail, data: [partnerRequest]);
  if (partnerRequest.status?.toLowerCase() == "approved") {
    /// When company approved to be partner
    onAcceptPartner(context);
  } else {
    /// When company rejected to be partner
    onRejectPartner(context);
  }
}

Future onAcceptPartner(BuildContext context) async {
  var _util = OCSUtil.of(context);
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) => WillPopScope(
        child: Dialog(
          child: Parent(
            style: ParentStyle()
              ..padding(all: 15, bottom: 10)
              ..height(440),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                Parent(
                  style: ParentStyle()
                    ..width(200)
                    ..height(180),
                  child: Image.asset('assets/images/maintenance.png'),
                ),
                SizedBox(height: 10),
                Txt(
                  _util.language.key('you-have-been-approved'),
                  style: TxtStyle()
                    ..fontSize(14)
                    ..textAlign.center()
                    ..textColor(OCSColor.text.withOpacity(0.7)),
                ),
                SizedBox(height: 15),
                Txt(
                  _util.language.key('do-you-want-to-switch-to-partner'),
                  style: TxtStyle()
                    ..fontSize(16)
                    ..textAlign.center()
                    ..textColor(OCSColor.text),
                ),
                SizedBox(height: 20),
                BuildButton(
                  title: _util.language.key('switch-now'),
                  fontSize: 14,
                  height: 40,
                  width: 180,
                  onPress: () async {
                    var _pref = await SharedPreferences.getInstance();
                    _pref.setString(Prefs.userType, 'partner');
                    RestartWidget.restartApp(context);
                  },
                ),
                SizedBox(height: 5),
                TextButton(
                  child: Txt(
                    _util.language.key('later'),
                    style: TxtStyle()
                      ..fontSize(14)
                      ..textColor(OCSColor.text.withOpacity(0.7)),
                  ),
                  onPressed: () async {
                    _util.navigator.pop();
                  },
                ),
              ],
            ),
          ),
        ),
        onWillPop: () async {
          _util.navigator.pop();
          return false;
        }),
  );
}

Future onRejectPartner(BuildContext context) async {
  var _util = OCSUtil.of(context);
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) => WillPopScope(
        child: Dialog(
          child: Parent(
            style: ParentStyle()
              ..padding(all: 15, bottom: 10, top: 10)
              ..height(220),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.feedback_outlined,
                  size: 50,
                  color: Color.fromRGBO(216, 23, 0, 1),
                ),
                SizedBox(height: 15),
                Txt(
                  _util.language.key('apply-partner-rejected'),
                  style: TxtStyle()
                    ..fontSize(14)
                    ..textAlign.center()
                    ..textColor(OCSColor.text),
                ),
                SizedBox(height: 15),
                BuildButton(
                  title: _util.language.key('ok'),
                  fontSize: 14,
                  height: 40,
                  width: 180,
                  onPress: () async {
                    _util.navigator.pop();
                  },
                ),
              ],
            ),
          ),
        ),
        onWillPop: () async {
          _util.navigator.pop();
          return false;
        }),
  );
}

Future showSnackBar(
  BuildContext context, {
  String? message,
  Function()? onTab,
  SnackBarStatus? status = SnackBarStatus.success,
  String? title,
  IconData? icon,
}) async {
  Color _color = OCSColor.success;
  switch (status ?? "") {
    case SnackBarStatus.success:
      _color = Color(0xff59ab12);
      break;
    case SnackBarStatus.warning:
      _color = Color(0xffe2a31f);
      break;
    case SnackBarStatus.danger:
      _color = Color(0xffbb1d30);
      break;
    case SnackBarStatus.primary:
      _color = Color(0xff1caae2);
      break;
  }
  await showFlash(
      context: context,
      duration: const Duration(seconds: 5),
      persistent: true,
      builder: (_, controller) {
        return Flash(
          controller: controller,
          backgroundColor: Colors.white,
          brightness: Brightness.light,
          barrierDismissible: false,
          // useSafeArea: isMsg,
          position: FlashPosition.bottom,
          onTap: () {
            if (onTab != null) {
              controller.dismiss();
              onTab();
            }
          },
          behavior: FlashBehavior.floating,
          boxShadows: [
            BoxShadow(blurRadius: 3, color: Colors.black.withOpacity(0.05))
          ],
          borderRadius: BorderRadius.all(Radius.circular(5)),
          margin: EdgeInsets.all(15),

          child: FlashBar(
            padding: const EdgeInsets.all(0),
            content: Parent(
              style: ParentStyle()
                ..background.color(_color)
                ..border(left: 4, color: _color)
                ..padding(all: 15, vertical: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (icon != null) ...[
                    Parent(
                      style: ParentStyle()..margin(top: 1),
                      child: Icon(
                        icon,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                  Expanded(
                    child: Txt(
                      message ?? "",
                      style: TxtStyle()
                        ..fontSize(14)
                        ..textColor(OCSColor.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
}

Future showMessage(
  BuildContext context, {
  String? message,
  Function()? onTab,
  String? title,
  IconData? icon,
  bool showLogo = true,
}) async {
  Color _color = OCSColor.white;
  await showFlash(
      context: context,
      duration: const Duration(seconds: 5),
      persistent: true,
      builder: (_, controller) {
        return Flash(
          controller: controller,
          backgroundColor: Colors.white,
          brightness: Brightness.light,
          barrierDismissible: false,
          useSafeArea: true,
          position: FlashPosition.top,
          onTap: () {
            if (onTab != null) {
              controller.dismiss();
              onTab();
            }
          },
          behavior: FlashBehavior.floating,
          boxShadows: [
            BoxShadow(blurRadius: 3, color: Colors.black.withOpacity(0.05))
          ],
          borderRadius: BorderRadius.all(Radius.circular(5)),
          margin: EdgeInsets.all(15),
          child: FlashBar(
            padding: const EdgeInsets.all(0),
            content: Parent(
              style: ParentStyle()
                ..background.color(_color)
                ..border(left: 4, color: OCSColor.primary)
                ..padding(
                    all: 15, vertical: (title?.isNotEmpty ?? false) ? 10 : 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (showLogo) ...[
                    Parent(
                      style: ParentStyle()..margin(top: 1),
                      child: Image.asset(
                        'assets/logo/logo-red.png',
                        width: 30,
                        height: 30,
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (title?.isNotEmpty ?? false)
                          Txt(
                            title ?? "",
                            style: TxtStyle()
                              ..fontSize(14)
                              ..maxLines(1)
                              ..textOverflow(TextOverflow.ellipsis)
                              ..textColor(OCSColor.text),
                          ),
                        if (message?.isNotEmpty ?? false)
                          Txt(
                            message ?? "",
                            style: TxtStyle()
                              ..fontSize(12)
                              ..maxLines(2)
                              ..textOverflow(TextOverflow.ellipsis)
                              ..textColor(OCSColor.text.withOpacity(0.7)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
}
