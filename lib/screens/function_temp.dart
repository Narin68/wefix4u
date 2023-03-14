import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:ocs_util/ocs_util.dart';

import '../blocs/wallet/wallet_cubit.dart';
import '../globals.dart';
import '../modals/customer_request_service.dart';

ImagePicker _picker = ImagePicker();

Future<LocationData?> getLocation() async {
  try {
    var _location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();

    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await _location.hasPermission();

    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    var location = await _location.getLocation();

    return location;
  } catch (e) {
    print('[Get location error] $e');
    return null;
  }
}

Future requestLocation() async {
  var _location = Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  _serviceEnabled = await _location.serviceEnabled();

  if (!_serviceEnabled) {
    _serviceEnabled = await _location.requestService();
  }

  _permissionGranted = await _location.hasPermission();

  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await _location.requestPermission();
  }
}

Future<List<XFile>?> getMultiImageByGallery() async {
  final List<XFile>? images = await _picker.pickMultiImage(
    maxWidth: 1100,
    maxHeight: 1100,
    imageQuality: 95,
  );
  if (images != null) return images;
  return null;
}

Future<XFile?> getImageByGallery() async {
  var image = await _picker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 1000,
    maxHeight: 1000,
    imageQuality: 100,
  );
  if (image != null) return image;
  return null;
}

Future<XFile?> getImageByTakeCamera() async {
  final XFile? image = await _picker.pickImage(
    maxWidth: 1100,
    maxHeight: 1100,
    imageQuality: 95,
    source: ImageSource.camera,
  );
  if (image != null) return image;
  return null;
}

Future<XFile?> getVideoByGallery() async {
  final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
  if (video != null) {
    return video;
  }
  return null;
}

Future<XFile?> getVideoByTakeCamera() async {
  final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
  if (video != null) return video;
  return null;
}

Future<FilePickerResult?> getFile() async {
  FilePickerResult? file = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: [
      'jpg',
      'pdf',
      'doc',
      'docx',
      'xlsx',
      'xls',
      'png',
      'jpeg',
    ],
  );
  if (file != null) return file;
  return null;
}

void checkRequestStatus(
    {required MRequestService header,
    required Function(String status, Color color, String btnName) func}) {
  Color _color = Colors.white;
  String _btnName = "";
  String _status = "";
  String _enquiring = 'enquiring';
  String _issuing = "issuing";
  String _createQuot = "create-quotation";
  String _heading = "heading";
  String _fixing = "fixing";
  String _closeService = "close-service";
  // print(header.status);
  switch (header.status?.toLowerCase()) {
    case "pending":
      _btnName = 'accept';
      _color = Style.statusColors[0];
      _status = _enquiring;
      break;
    case "approved":
      _color = Style.statusColors[4];
      _status = 'confirmed';
      _btnName = _heading;
      break;
    case "done":
      _color = Style.statusColors[2];
      _status = 'done';
      break;
    case "failed":
      _color = Style.statusColors[1];
      _status = 'rejected';
      break;
    case "given up":
      _color = Style.statusColors[1];
      _status = 'given-up';
      break;
    case "rejected":
      _color = Style.statusColors[1];
      _status = 'rejected';
      break;
    case "accepted":
      // print(header.code);
      _color = Style.statusColors[3];
      _status = _issuing;
      _btnName = _createQuot;
      break;
    case "quote submitted":
      // print(header.code);
      _color = Style.statusColors[3];
      _status = "quot-submit";
      _btnName = '';
      break;
    case "heading":
      _color = Style.statusColors[7];
      _status = _heading;
      _btnName = "fix";
      break;
    case "fixing":
      _color = Style.statusColors[8];
      _status = _fixing;
      _btnName = _closeService;
      break;
    case "closed":
      _color = Style.statusColors[6];
      _btnName = '';
      // if (header.invoiceStatus != null &&
      //     header.invoiceStatus?.toLowerCase() == "paid") {
      //   /// status closed & customer already paid
      //   _status = 'paid';
      //   _color = Style.statusColors[2];
      // } else {
      /// status closed
      _status = 'closed';
      // }
      break;
    case "canceled":
      _color = Style.statusColors[5];
      _status = 'canceled';
      break;

    case "awaiting feedback":
      _color = Style.statusColors[0];
      _status = 'wait-to-feedback';
      break;
  }

  func(_status, _color, _btnName);
}

void checkCusRequestStatus(
    {required MRequestService header,
    required Function(String status, Color color, String subStatus) func}) {
  Color _color = Colors.white;
  String _status = "";
  String _headingSoon = "heading-soon";
  String _heading = "heading";
  String _fixing = "fixing";
  String _fix = "fix";
  String _subStatus = '';

  switch (header.status?.toLowerCase()) {
    case "pending":
      _color = Style.statusColors[0];
      _status = 'request-sent';
      break;
    case "created":
      _color = Style.statusColors[0];
      _status = 'request-sent';
      break;
    case "approved":
      _color = Style.statusColors[4];
      _status = 'confirmed';
      _subStatus = 'confirmed';
      break;
    case "done":
      _color = Style.statusColors[2];
      _status = 'done';
      _subStatus = 'done';

      break;
    case "heading":
      _color = Style.statusColors[7];
      _status = _headingSoon;
      _subStatus = _heading;
      break;
    case "accepted":
      _status = 'accepted';
      _subStatus = "accepted";
      _color = Style.statusColors[3];
      break;
    case "fixing":
      _color = Style.statusColors[8];
      _status = _fixing;
      _subStatus = _fix;
      break;
    case "closed":
      _color = Style.statusColors[0];

      _status = 'wait-to-pay';
      _subStatus = "closed";
      break;
    case "failed":
      _color = Style.statusColors[1];
      _status = 'failed';
      _subStatus = 'failed';
      break;
    case "rejected":
      _color = Style.statusColors[1];
      _status = 'rejected';
      _subStatus = 'rejected';
      break;
    case "canceled":
      _color = Style.statusColors[5];
      _status = 'canceled';
      _subStatus = 'canceled';
      break;

    case "awaiting feedback":
      _color = Style.statusColors[0];
      _status = 'wait-to-feedback';

      break;
  }
  func(_status, _color, _subStatus);
}

Future checkWallet(BuildContext context) async {
  if (Model.userWallet?.id != null)
    context.read<WalletCubit>().addWallet(Model.userWallet!);
  else
    context.read<WalletCubit>().getByRef();
}

void clearApplyPartnerData() {
  ApplyPartnerDataModel.files = [];
  ApplyPartnerDataModel.businessImage = null;
  ApplyPartnerDataModel.profileImage = null;
  ApplyPartnerDataModel.businessName = "";
  ApplyPartnerDataModel.businessNameEng = "";
  ApplyPartnerDataModel.businessEmail = "";
  ApplyPartnerDataModel.businessPhone2 = "";
  ApplyPartnerDataModel.businessPhone1 = "";
  ApplyPartnerDataModel.workExperience = "";
  ApplyPartnerDataModel.coverage = [];
  ApplyPartnerDataModel.businessAddress = "";
  ApplyPartnerDataModel.lat = null;
  ApplyPartnerDataModel.long = null;
  ApplyPartnerDataModel.latLong = '';
  ApplyPartnerDataModel.businessAddressEnglish = '';
  ApplyPartnerDataModel.checkedAddress = [];
  ApplyPartnerDataModel.coverageIds = [];
}

void clearApplyServiceModel() {
  ApplyServiceModel.thumbnail = [];
  ApplyServiceModel.address = '';
  ApplyServiceModel.audios = [];
  ApplyServiceModel.phone = '';
  ApplyServiceModel.videos = [];
  ApplyServiceModel.images = [];
  ApplyServiceModel.pinMap = '';
  ApplyServiceModel.description = '';
  ApplyPartnerDataModel.lat = null;
  ApplyPartnerDataModel.long = null;
  ApplyServiceModel.phone = '';
  ApplyServiceModel.time = null;
  ApplyServiceModel.date = null;
  ApplyServiceModel.provinceId = null;
}

String formatPhoneNumber(String phoneNumber) {
  if (phoneNumber.isEmpty || phoneNumber.length <= 3) return "";
  if (phoneNumber.contains("+855"))
    phoneNumber = phoneNumber.replaceFirst('+855', '0');
  String formattedPhoneNumber = phoneNumber.substring(0, 3) +
      "-" +
      (phoneNumber.length >= 3 && phoneNumber.length >= 6
          ? phoneNumber.substring(3, 6)
          : "") +
      "-" +
      (phoneNumber.length >= 6
          ? phoneNumber.substring(6, phoneNumber.length)
          : "");

  return formattedPhoneNumber;
}
