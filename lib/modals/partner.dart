import '/modals/quotation.dart';
import '/modals/address.dart';
import '/modals/customer.dart';
import '/modals/file.dart';
import '/modals/service.dart';

class MPartnerRequest {
  final int? id;
  final int? customerId;
  final String? customerCode;
  final String? customerName;
  final String? customerNameEnglish;
  final int? workExperience;
  final String? businessName;
  final String? businessNameEnglish;
  final String? businessAddress;
  final String? businessAddressEnglish;
  final String? businessPhone1;
  final String? businessPhone2;
  final String? businessEmail;
  final String? status;

  MPartnerRequest({
    this.id,
    this.customerId,
    this.customerCode,
    this.customerName,
    this.customerNameEnglish,
    this.workExperience,
    this.businessName,
    this.businessNameEnglish,
    this.businessAddress,
    this.businessAddressEnglish,
    this.businessPhone1,
    this.businessPhone2,
    this.businessEmail,
    this.status,
  });

  // from json
  factory MPartnerRequest.fromJson(Map<String, dynamic> json) =>
      MPartnerRequest(
        id: json["Id"],
        customerId: json["CustomerId"],
        customerCode: json["CustomerCode"],
        customerName: json["CustomerName"],
        customerNameEnglish: json["CustomerNameEnglish"],
        workExperience: json["WorkExperience"],
        businessName: json["BusinessName"],
        businessNameEnglish: json["BusinessNameEnglish"],
        businessAddress: json["BusinessAddress"],
        businessAddressEnglish: json["BusinessAddressEnglish"],
        businessPhone1: json["BusinessPhone1"],
        businessPhone2: json["BusinessPhone2"],
        businessEmail: json["BusinuessEmail"],
        status: json["Status"],
      );

  // to json
  Map<String, dynamic> toJson() => {
        "Id": id,
        "CustomerId": customerId,
        "CustomerCode": customerCode,
        "CustomerName": customerName,
        "CustomerNameEnglish": customerNameEnglish,
        "WorkExperience": workExperience,
        "BusinessName": businessName,
        "BusinessNameEnglish": businessNameEnglish,
        "BusinessAddress": businessAddress,
        "BusinessAddressEnglish": businessAddressEnglish,
        "BusinessPhone1": businessPhone1,
        "BusinessPhone2": businessPhone2,
        "BusinessEmail": businessEmail,
        "Status": status,
      };

  // copy with
  MPartnerRequest copyWith({
    int? id,
    int? customerId,
    String? customerCode,
    String? customerName,
    String? customerNameEnglish,
    int? workExperience,
    String? businessName,
    String? businessNameEnglish,
    String? businessAddress,
    String? businessAddressEnglish,
    String? businessPhone1,
    String? businessPhone2,
    String? businessEmail,
    String? status,
  }) =>
      MPartnerRequest(
        id: id ?? this.id,
        customerId: customerId ?? this.customerId,
        customerCode: customerCode ?? this.customerCode,
        customerName: customerName ?? this.customerName,
        customerNameEnglish: customerNameEnglish ?? this.customerNameEnglish,
        workExperience: workExperience ?? this.workExperience,
        businessName: businessName ?? this.businessName,
        businessNameEnglish: businessNameEnglish ?? this.businessNameEnglish,
        businessAddress: businessAddress ?? this.businessAddress,
        businessAddressEnglish:
            businessAddressEnglish ?? this.businessAddressEnglish,
        businessPhone1: businessPhone1 ?? this.businessPhone1,
        businessPhone2: businessPhone2 ?? this.businessPhone2,
        businessEmail: businessEmail ?? this.businessEmail,
        status: status ?? this.status,
      );
}

class MPartnerRequestDetail {
  final String? latLong;
  final MMyCustomer? customer;
  final List<MAddress>? coverage;
  final List<MService>? services;
  final MApplicationFiles? applicationFiles;

  MPartnerRequestDetail({
    this.latLong,
    this.customer,
    this.coverage,
    this.services,
    this.applicationFiles,
  });

  factory MPartnerRequestDetail.fromJson(Map<String, dynamic> json) =>
      MPartnerRequestDetail(
        latLong: json["LatLong"],
        customer: json["Customer"] != null
            ? MMyCustomer.fromJson(json["Customer"])
            : null,
        coverage: List<MAddress>.from(
            json["Coverage"].map((x) => MAddress.fromJson(x))),
        services: List<MService>.from(
            json["Services"].map((x) => MService.fromJson(x))),
        applicationFiles: json["ApplicationFiles"] == null
            ? null
            : MApplicationFiles.fromJson(json["ApplicationFiles"]),
      );

  Map<String, dynamic> toJson() => {
        "LatLong": latLong,
        "Customer": customer!.toJson(),
        "Coverage": List<MAddress>.from(coverage!.map((x) => x)),
        "Services": List<MService>.from(services!.map((x) => x)),
        "ApplicationFiles": applicationFiles,
      };

  MPartnerRequestDetail copyWith({
    String? latLong,
    MMyCustomer? customer,
    List<MAddress>? coverage,
    List<MService>? services,
    MApplicationFiles? applicationFiles,
  }) =>
      MPartnerRequestDetail(
        latLong: latLong ?? this.latLong,
        customer: customer ?? this.customer,
        coverage: coverage ?? this.coverage,
        services: services ?? this.services,
        applicationFiles: applicationFiles ?? this.applicationFiles,
      );
}

class MPartner {
  final int? id;
  final String? approvedBy;
  final String? approvedDate;
  final String? businessAddress;
  final String? businessEmail;
  final String? businessName;
  final String? businessNameEnglish;
  final String? businessPhone1;
  final String? businessPhone2;
  final String? code;
  final String? status;

  final String? createdBy;
  final String? createdDate;
  final String? updatedBy;
  final String? updatedDate;
  final int? recordCount;
  final int? workExperience;
  final String? latLong;
  final MApplicationFiles? applicationFiles;

  MPartner({
    this.id,
    this.approvedBy,
    this.approvedDate,
    this.businessAddress,
    this.businessEmail,
    this.businessName,
    this.businessNameEnglish,
    this.businessPhone1,
    this.businessPhone2,
    this.code,
    this.createdBy,
    this.createdDate,
    this.status,
    this.updatedBy,
    this.updatedDate,
    this.recordCount,
    this.workExperience,
    this.latLong,
    this.applicationFiles,
  });

  // from json
  factory MPartner.fromJson(Map<String, dynamic> json) => MPartner(
        id: json["Id"],
        approvedBy: json["ApprovedBy"],
        approvedDate: json["ApprovedDate"],
        businessAddress: json["BusinessAddress"],
        businessEmail: json["BusinessEmail"],
        businessName: json["BusinessName"],
        businessNameEnglish: json["BusinessNameEnglish"],
        businessPhone1: json["BusinessPhone1"],
        businessPhone2: json["BusinessPhone2"],
        code: json["Code"],
        createdBy: json["CreatedBy"],
        createdDate: json["CreatedDate"],
        status: json["Status"],
        updatedBy: json["UpdatedBy"],
        updatedDate: json["UpdatedDate"],
        recordCount: json["RecordCount"],
        workExperience: json["WorkExperience"],
        latLong: json["LatLong"],
        applicationFiles: json["ApplicationFiles"] == null
            ? null
            : MApplicationFiles.fromJson(json["ApplicationFiles"]),
      );

  // to json
  Map<String, dynamic> toJson() => {
        "Id": id,
        "ApprovedBy": approvedBy,
        "ApprovedDate": approvedDate,
        "BusinessAddress": businessAddress,
        "BusinessEmail": businessEmail,
        "BusinessName": businessName,
        "BusinessNameEnglish": businessNameEnglish,
        "BusinessPhone1": businessPhone1,
        "BusinessPhone2": businessPhone2,
        "Code": code,
        "CreatedBy": createdBy,
        "CreatedDate": createdDate,
        "Status": status,
        "UpdatedBy": updatedBy,
        "UpdatedDate": updatedDate,
        "RecordCount": recordCount,
        "WorkExperience": workExperience,
        "LatLong": latLong,
        "ApplicationFiles": applicationFiles,
      };

  // copy with
  MPartner copyWith({
    int? id,
    String? approvedBy,
    String? approvedDate,
    String? businessAddress,
    String? businessEmail,
    String? businessName,
    String? businessNameEnglish,
    String? businessPhone1,
    String? businessPhone2,
    String? code,
    String? createdBy,
    String? createdDate,
    String? status,
    String? updatedBy,
    String? updatedDate,
    int? recordCount,
    int? workExperience,
    String? latLong,
    MApplicationFiles? applicationFiles,
  }) =>
      MPartner(
        id: id ?? this.id,
        approvedBy: approvedBy ?? this.approvedBy,
        approvedDate: approvedDate ?? this.approvedDate,
        businessAddress: businessAddress ?? this.businessAddress,
        businessEmail: businessEmail ?? this.businessEmail,
        businessName: businessName ?? this.businessName,
        businessNameEnglish: businessNameEnglish ?? this.businessNameEnglish,
        businessPhone1: businessPhone1 ?? this.businessPhone1,
        businessPhone2: businessPhone2 ?? this.businessPhone2,
        code: code ?? this.code,
        createdBy: createdBy ?? this.createdBy,
        createdDate: createdDate ?? this.createdDate,
        status: status ?? this.status,
        updatedBy: updatedBy ?? this.updatedBy,
        updatedDate: updatedDate ?? this.updatedDate,
        recordCount: recordCount ?? this.recordCount,
        workExperience: workExperience ?? this.workExperience,
        latLong: latLong ?? this.latLong,
        applicationFiles: applicationFiles ?? this.applicationFiles,
      );
}

class MCustomPartner {
  final int? partnerId;
  final String? partnerCode;
  final String? partnerName;
  final String? partnerNameEnglish;
  final String? image;
  final String? partnerAddress;
  final String? partnerAddressEnglish;
  final String? partnerPhone;
  final int? invoiceId;
  final String? invoiceCode;
  final String? acceptedDate;

  MCustomPartner({
    this.acceptedDate,
    this.partnerId,
    this.partnerCode,
    this.partnerName,
    this.partnerNameEnglish,
    this.image,
    this.partnerAddress,
    this.partnerAddressEnglish,
    this.partnerPhone,
    this.invoiceId,
    this.invoiceCode,
  });

  // from json
  factory MCustomPartner.fromJson(Map<String, dynamic> json) => MCustomPartner(
        acceptedDate: json["AcceptedDate"],
        partnerId: json["PartnerId"],
        partnerCode: json["PartnerCode"],
        partnerName: json["PartnerName"],
        image: json["Image"],
        partnerAddress: json["PartnerAddress"],
        partnerAddressEnglish: json["PartnerAddressEnglish"],
        partnerPhone: json["PartnerPhone"],
        partnerNameEnglish: json["PartnerNameEnglish"],
        invoiceId: json["InvoiceId"],
        invoiceCode: (json["InvoiceCode"] ?? ""),
      );

  // to json
  Map<String, dynamic> toJson() => {
        "AcceptedDate": acceptedDate,
        "PartnerId": partnerId,
        "PartnerCode": partnerCode,
        "PartnerName": partnerName,
        "Image": image,
        "PartnerPhone": partnerPhone,
        "PartnerAddress": partnerAddress,
        "PartnerAddressEnglish": partnerAddressEnglish,
        "PartnerNameEnglish": partnerNameEnglish,
        "InvoiceId": invoiceId,
        "InvoiceCode": invoiceCode,
      };

  // copy with
  MCustomPartner copyWith({
    String? acceptedDate,
    int? partnerId,
    String? partnerCode,
    String? partnerName,
    String? partnerNameEnglish,
    String? partnerAddress,
    String? partnerAddressEnglish,
    String? image,
    String? partnerPhone,
    int? invoiceId,
    String? invoiceCode,
  }) =>
      MCustomPartner(
        partnerId: partnerId ?? this.partnerId,
        acceptedDate: acceptedDate ?? this.acceptedDate,
        partnerCode: partnerCode ?? this.partnerCode,
        partnerName: partnerName ?? this.partnerName,
        partnerNameEnglish: partnerNameEnglish ?? this.partnerNameEnglish,
        image: image ?? this.image,
        partnerAddress: partnerAddress ?? this.partnerAddress,
        partnerAddressEnglish:
            partnerAddressEnglish ?? this.partnerAddressEnglish,
        partnerPhone: partnerPhone ?? this.partnerPhone,
        invoiceCode: invoiceCode ?? this.invoiceCode,
        invoiceId: invoiceId ?? this.invoiceId,
      );
}

// class MAcceptedPartner {
//   final MCustomPartner? partner;
//   final MQuotation? quotation;
//
//   MAcceptedPartner({
//     this.partner,
//     this.quotation,
//   });
//
//   // from json
//   factory MAcceptedPartner.fromJson(Map<String, dynamic> json) =>
//       MAcceptedPartner(
//         partner: MCustomPartner.fromJson(json["Partner"]),
//         quotation: json["Quotation"] == null
//             ? null
//             : MQuotation.fromJson(json["Quotation"]),
//       );
//
//   // to json
//   Map<String, dynamic> toJson() => {
//         "Partner": partner,
//         "Quotation": quotation,
//       };
//
//   // copy with
//   MAcceptedPartner copyWith({
//     MCustomPartner? partnerId,
//     MQuotation? quotation,
//   }) =>
//       MAcceptedPartner(
//         partner: partner ?? this.partner,
//         quotation: quotation ?? this.quotation,
//       );
// }

// To parse this JSON data, do
//
//     final mAcceptedPartner = mAcceptedPartnerFromJson(jsonString);

class MAcceptedPartner {
  MAcceptedPartner({
    this.partnerId,
    this.partnerCode,
    this.partnerName,
    this.partnerNameEnglish,
    this.partnerAddress,
    this.partnerAddressEnglish,
    this.partnerPhone,
    this.image,
    this.status,
    this.acceptedDate,
    this.quotationId,
    this.quotationCode,
    this.quotationAmount,
  });

  final int? partnerId;
  final String? partnerCode;
  final String? partnerName;
  final String? partnerNameEnglish;
  final String? partnerAddress;
  final String? partnerAddressEnglish;
  final String? partnerPhone;
  final String? image;
  final String? status;
  final dynamic acceptedDate;
  final int? quotationId;
  final String? quotationCode;
  final double? quotationAmount;

  MAcceptedPartner copyWith({
    int? partnerId,
    String? partnerCode,
    String? partnerName,
    String? partnerNameEnglish,
    String? partnerAddress,
    String? partnerAddressEnglish,
    String? partnerPhone,
    String? image,
    String? status,
    dynamic acceptedDate,
    int? quotationId,
    String? quotationCode,
    double? quotationAmount,
  }) =>
      MAcceptedPartner(
        partnerId: partnerId ?? this.partnerId,
        partnerCode: partnerCode ?? this.partnerCode,
        partnerName: partnerName ?? this.partnerName,
        partnerNameEnglish: partnerNameEnglish ?? this.partnerNameEnglish,
        partnerAddress: partnerAddress ?? this.partnerAddress,
        partnerAddressEnglish:
            partnerAddressEnglish ?? this.partnerAddressEnglish,
        partnerPhone: partnerPhone ?? this.partnerPhone,
        image: image ?? this.image,
        status: status ?? this.status,
        acceptedDate: acceptedDate ?? this.acceptedDate,
        quotationId: quotationId ?? this.quotationId,
        quotationCode: quotationCode ?? this.quotationCode,
        quotationAmount: quotationAmount ?? this.quotationAmount,
      );

  factory MAcceptedPartner.fromJson(Map<String, dynamic> json) =>
      MAcceptedPartner(
        partnerId: json["PartnerId"],
        partnerCode: json["PartnerCode"],
        partnerName: json["PartnerName"],
        partnerNameEnglish: json["PartnerNameEnglish"],
        partnerAddress: json["PartnerAddress"],
        partnerAddressEnglish: json["PartnerAddressEnglish"],
        partnerPhone: json["PartnerPhone"],
        image: json["Image"],
        status: json["Status"],
        acceptedDate: json["AcceptedDate"],
        quotationId: json["QuotationId"],
        quotationCode: json["QuotationCode"],
        quotationAmount: json["QuotationAmount"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "PartnerId": partnerId,
        "PartnerCode": partnerCode,
        "PartnerName": partnerName,
        "PartnerNameEnglish": partnerNameEnglish,
        "PartnerAddress": partnerAddress,
        "PartnerAddressEnglish": partnerAddressEnglish,
        "PartnerPhone": partnerPhone,
        "Image": image,
        "Status": status,
        "AcceptedDate": acceptedDate,
        "QuotationId": quotationId,
        "QuotationCode": quotationCode,
        "QuotationAmount": quotationAmount,
      };
}
