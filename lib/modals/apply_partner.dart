// To parse this JSON data, do
//
//     final mApplyPartner = mApplyPartnerFromJson(jsonString);

import 'dart:convert';

import 'dart:typed_data';

import 'file.dart';

String mApplyPartnerToJson(MApplyPartner data) => json.encode(data.toJson());

class MApplyPartner {
  MApplyPartner({
    this.id,
    this.refId,
    this.refCode,
    this.code,
    this.businessName,
    this.businessNameEnglish,
    this.workExperience,
    this.businessPhone1,
    this.businessPhone2,
    this.businessAddress,
    this.businessAddressEnglish,
    this.latLong,
    this.businessEmail,
    this.status,
    this.coverageIds,
    this.serviceIds,
    this.faceImage,
    this.placeImage,
    this.files,
  });

  final int? id;
  final int? refId;
  final String? refCode;
  final String? code;
  final String? businessName;
  final String? businessNameEnglish;
  final int? workExperience;
  final String? businessPhone1;
  final String? businessPhone2;
  final String? businessAddress;
  final String? businessAddressEnglish;
  final String? latLong;
  final String? businessEmail;
  final String? status;
  final List<int>? coverageIds;
  final List<int>? serviceIds;
  final Uint8List? faceImage;
  final Uint8List? placeImage;
  final List<MFile>? files;

  MApplyPartner copyWith({
    int? id,
    int? refId,
    String? refCode,
    String? code,
    String? businessName,
    String? businessNameEnglish,
    int? workExperience,
    String? businessPhone1,
    String? businessPhone2,
    String? businessAddress,
    String? businessAddressEnglish,
    String? latLong,
    String? businessEmail,
    String? status,
    List<int>? addressInfoIds,
    List<int>? serviceIds,
    Uint8List? faceImage,
    Uint8List? placeImage,
    List<MFile>? files,
  }) =>
      MApplyPartner(
        id: id ?? this.id,
        refId: refId ?? this.refId,
        refCode: refCode ?? this.refCode,
        code: code ?? this.code,
        businessName: businessName ?? this.businessName,
        businessNameEnglish: businessNameEnglish ?? this.businessNameEnglish,
        workExperience: workExperience ?? this.workExperience,
        businessPhone1: businessPhone1 ?? this.businessPhone1,
        businessPhone2: businessPhone2 ?? this.businessPhone2,
        businessAddress: businessAddress ?? this.businessAddress,
        businessAddressEnglish:
            businessAddressEnglish ?? this.businessAddressEnglish,
        latLong: latLong ?? this.latLong,
        businessEmail: businessEmail ?? this.businessEmail,
        status: status ?? this.status,
        coverageIds: addressInfoIds ?? this.coverageIds,
        serviceIds: serviceIds ?? this.serviceIds,
        faceImage: faceImage ?? this.faceImage,
        placeImage: placeImage ?? this.placeImage,
        files: files ?? this.files,
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "RefId": refId,
        "RefCode": refCode,
        "Code": code,
        "BusinessName": businessName,
        "BusinessNameEnglish": businessNameEnglish,
        "WorkExperience": workExperience,
        "BusinessPhone1": businessPhone1,
        "BusinessPhone2": businessPhone2,
        "BusinessAddress": businessAddress,
        "BusinessAddressEnglish": businessAddressEnglish,
        "LatLong": latLong,
        "BusinessEmail": businessEmail,
        "Status": status,
        "CoverageIds": List<int>.from(coverageIds!.map((x) => x)),
        "ServiceIds": List<int>.from(serviceIds!.map((x) => x)),
        "FaceImage": faceImage,
        "PlaceImage": placeImage,
        "Files": List<MFile>.from(files!.map((x) => x)),
      };
}
