import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ocs_auth/ocs_auth.dart';
import 'modals/customer_request_service.dart';
import 'modals/partner_item.dart';
import 'modals/quotation.dart';
import 'modals/service_category.dart';
import 'modals/address.dart';
import 'modals/apply_partner.dart';
import 'modals/customer.dart';
import 'modals/partner.dart';
import 'modals/settlement_rule.dart';
import 'modals/wallet.dart';

class Globals {
  static String fbToken = "";

  static String exToken =
      "basic NTQxZmM5NjUtYmM1Ny00ODkyLWJkYTktZTJjN2M3YTNlZmFlOjI5MDVmZmQ1LTJkY2MtNGE1Ni05YTFiLWJmN2YzMGJhY2ViZDI=";

  // static String exToken =
  //     "basic NTQxZmM5NjUtYmM1Ny00ODkyLWJkYTktZTJjN2M3YTNlZmFlOjI5MDVmZmQ1LTJkY2MtNGE1Ni05YTFiLWJmN2YzMGJhY2ViZDI=";
  static String userType = '';
  static String userAvatarImage = 'assets/images/user.jpeg';
  static double paddingImage = 15;
  static double padding = 10;
  static String firebaseServer = "https://firebasestorage.googleapis.com";
  static double maxScreen = 500;
  static String langCode = "en";
  static bool hasAuth = false;
  static bool isRequestService = false;
  static bool isFromLogin = false;
  static int navIndex = -1;
  static String databaseName = "B17";
  static int tabRequestStatusIndex = 0;
  static String requestFilterStatus = "";
  static bool inMessagePage = false;
  static int requestId = 0;
}

class ApisString {
  static String webServer = '';
  static String server = '';

  /// Api Region & Address list
  static String coverageList = "/api/region/list";
  static String addressList = "/api/address/get";

  /// Api Update
  static String updateCustomer = '/api/customer/update';
  static String customerList = "/api/customer/list";

  /// Api Service
  static String serviceList = '/api/service/list';

  /// Apis Partner
  static String partnerAll = '/api/partner/all';
  static String partnerRead = '/api/partner/read';
  static String partnerList = '/api/partner/list';
  static String updatePartner = '/api/partner/update';

  /// Apis Partner Request
  static String applyPartner = '/api/partner/apply';
  static String partnerRequest = '/api/request/partnerapplicationrequests';
  static String partnerRequestDetail =
      '/api/request/partnerapplicationrequestdetail';

  static String serviceCateList = '/api/servicecategory/list';
  static String uploadFile = '/api/file/upload';
  static String uploadVideo = '/api/file/uploadvideo';

  /// Apis Request Service
  static String requestService = '/api/request/service';
  static String checkAvailabilityService = '/api/request/check';
  static String getProvinceId = '/api/request/getprovince?targetaddress=';
  static String serviceRequestList = '/api/request/list';
  static String giveUpCustomerRequest = '/api/request/giveup';
  static String acceptCustomerRequest = '/api/requst/accept';
  static String cancelServiceRequest = '/api/request/cancel';
  static String headingService = '/api/request/heading';
  static String fixingService = '/api/request/fixing';
  static String closeService = '/api/request/close';
  static String submitQuot = '/api/partner/submitquotation';
  static String serviceRequestDetail = '/api/request/detail';
  static String approvePartnerOnRequest = '/api/request/approve';
  static String feedbackRequest = '/api/request/feedback';
  static String rejectPartner = '/api/request/rejectpartner';
  static String requestLogList = '/api/request/log/list';

  /// Apis Partner Item
  static String createPartnerItem = '/api/partner/createitem';
  static String updatePartnerItem = '/api/partner/updateitem';
  static String listPartnerItem = '/api/partner/itemlist';
  static String deletePartnerItem = '/api/partner/deleteitem';

  static String saveFileToDb = '/api/file/savetodb';
  static String newsAndPromotionList = '/api/newspromo/list';

  /// Apis Update Coverage
  static String updateCovAndServ =
      '/api/partner/request/updatecoverageandservice';
  static String updateCovAndServList =
      '/api/partner/request/updatecoverageandservicelist';
  static String updateCovAndServDetail =
      '/api/partner/request/updatecoverageandservicedetail';

  /// Apis Invoice
  static String invoiceList = "/api/invoice/list";
  static String invoiceDetail = "/api/invoice/read";
  static String quotationList = "/api/quotation/list";
  static String quotationRead = "/api/quotation/read";

  /// Apis SettlementRule
  static String settlementList = "/api/settlementrule/list";
  static String readSettlementRefId = "/api/settlementrule/readbyref";

  /// Apis Wallet
  static String getWallet = "/api/wallet/read";
  static String createWallet = "/api/wallet/create";
  static String updateWallet = "/api/wallet/update";
  static String walletList = "/api/wallet/list";
  static String getUserWallet = "/api/wallet/mywallet";

  /// Apis Wallet Transaction
  static String walletTransactionList = "/api/wallettransaction/list";
  static String walletTransactionRead = "/api/wallettransaction/read";
  static String walletTransactionCreate = "/api/wallettransaction/create";

  /// Withdrawal
  static String withdrawalRequest = "/api/wallettransaction/withdraw";
  static String withdrawalRequestList = "/api/wallet/list";

  /// discount api
  static String createDiscountCode = "/api/discount/create";
  static String getDiscountCode = "/api/discount/list";
  static String updateDiscountCode = "/api/discount/update";

  /// Request update invoice
  static String getInvoiceUpdateRequest = "/api/quotupdatereq/list";
  static String updateInvoice = "/api/quotupdatereq/update";
  static String requestUpdateInvoice = "/api/quotupdatereq/create";
  static String allowRequest = "/api/quotupdatereq/allow";
  static String rejectQuotUpdate = "/api/quotupdatereq/reject";
  static String allowQuotUpdate = "/api/quotupdatereq/allow";
  static String approveQuotUpdate = "/api/quotupdatereq/approve";

  /// Quotation
  static String createQuotation = '/api/quotation/create';
  static String updateQuot = '/api/quotation/update';
  static String rejectQuot = '/api/quotation/reject';
  static String approveQuot = '/api/quotation/Approve';

  /// Message Api
  static String sendMessage = "/api/chat/send";
  static String updateMessage = "/api/chat/update";
  static String deleteMessage = "/api/chat/delete";
  static String seenMessage = "/api/chat/seen";
  static String multiSeenMessage = "/api/chat/multipleseen";
  static String listMessage = "/api/chat/list";
  static String countMessage = "/api/chat/countunseen";
  static String getReceiver = "/api/chat/getreceiver";
  static String getSender = "/api/chat/getsender";
}

class Prefs {
  static String langCode = "OCS-LANG-CODE";
  static String usedLogin = 'USED_LOGIN';
  static String currUser = 'CURR_USER';
  static String currCustomer = 'CURR_CUSTOMER';
  static String userType = 'USER_TYPE';
  static String customerInfo = 'CUSTOMER_INFO';
  static String partnerInfo = 'PARTNER_INFO';
  static String walletInfo = 'WALLET_INFO';
  static String ServiceCatList = 'SERVICE_CATEGORIES';
}

class GoogleApiKey {
  static String googleApiKey = "AIzaSyDBaR-oqzfazH-bDWkObJFZ_alfGt0E_08";
}

class UserType {
  static String customer = "customer";
  static String partner = "partner";
}

class RequestStatus {
  static String quoteSubmitted = "QUOTE SUBMITTED";
  static String accepted = 'ACCEPTED';
  static String pending = 'PENDING';
  static String closed = "CLOSED";
  static String heading = "HEADING";
  static String fixing = "FIXING";
  static String done = "DONE";
  static String approved = "APPROVED";
  static String canceled = "CANCELED";
  static String rejected = "REJECTED";
  static String giveUp = "GIVEN UP";
  static String waitingFeedback = "AWAITING FEEDBACK";
}

class Style {
  static double titleSize = 16;
  static double subTitleSize = 14;
  static double subTextSize = 12;
  static double borderWidth = 1.5;
  static List<Color> statusColors = [
    Colors.orange, //Pending 0
    Colors.red, // Fail 1
    Colors.green, // done 2
    Colors.blue, // Accept 3
    Color.fromRGBO(39, 174, 96, 1), //  Approved 4
    Color.fromRGBO(81, 90, 90, 1), // Cancel 5
    Color.fromRGBO(104, 136, 139, 1), // Closed 6
    Color.fromRGBO(22, 134, 131, 1), // heading 7
    Color.fromRGBO(144, 75, 28, 1), // fixing 8
  ];
}

class ApplyPartnerDataModel {
  static MApplyPartner mApplyPartner = MApplyPartner();
  static List<PlatformFile> files = [];
  static XFile? businessImage;
  static XFile? profileImage;
  static List<int> coverage = [];
  static String businessAddress = '';
  static String businessAddressEnglish = '';
  static String businessName = '';
  static String businessNameEng = '';
  static String businessPhone1 = '';
  static String businessPhone2 = '';
  static String businessEmail = '';
  static String workExperience = '';
  static String latLong = '';
  static double? lat;
  static double? long;
  static List<MAddress> checkedAddress = [];
  static List<int> coverageIds = [];
}

class ApplyServiceModel {
  static List<XFile> images = [];
  static List<XFile> videos = [];
  static String address = '';
  static String phone = '';
  static String phone1 = '';
  static String description = '';
  static String pinMap = '';
  static List<Uint8List> thumbnail = [];
  static List<Map> audios = [];
  static DateTime? date;
  static DateTime? time;
  static int? provinceId;
}

class Model {
  static List<MServiceCate> servicesCate = [];
  static MSubmitQuotData? quotationDetail = MSubmitQuotData();
  static MUserInfo userInfo = MUserInfo();
  static MPartner partner = MPartner();
  static MWalletData? userWallet;
  static MSettlementData? settlementRule;
  static MMyCustomer customer = MMyCustomer();
  static List<MPartnerServiceItemData> partnerItems = [];
  static MPartnerRequest? partnerRequest;
  static List<MRequestService> requestServices = [];
  static String phone = '';
}
