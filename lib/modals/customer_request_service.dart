import '/modals/discount.dart';
import '/modals/requestUpdateQuot.dart';

import '/modals/partner.dart';
import '/modals/quotation.dart';
import '/modals/service.dart';

import 'file.dart';

class MServiceRequestFilter {
  final int? id;
  final int? refId;
  final List<String>? code;
  final List<String>? status;
  final int? rateFrom;
  final int? rateTo;
  final String? fromDate;
  final String? toDate;
  final int? partnerId;
  final String? database;
  final String? search;
  final String? orderBy;
  final String? orderDir;
  final int? pages;
  final int? records;

  MServiceRequestFilter({
    this.id,
    this.refId,
    this.code,
    this.status,
    this.rateFrom,
    this.rateTo,
    this.fromDate,
    this.toDate,
    this.partnerId,
    this.database,
    this.search,
    this.orderBy,
    this.orderDir,
    this.pages,
    this.records,
  });

  // from json
  factory MServiceRequestFilter.fromJson(Map<String, dynamic> json) =>
      MServiceRequestFilter(
        id: json["Id"],
        refId: json["RefId"],
        code: json["Code"],
        status: json["Status"],
        rateFrom: json["RateFrom"],
        rateTo: json["RateTo"],
        fromDate: json["FromDate"],
        toDate: json["ToDate"],
        partnerId: json["PartnerId"],
        database: json["Database"],
        search: json["Search"],
        orderBy: json["OrderBy"],
        orderDir: json["OrderDir"],
        pages: json["Pages"],
        records: json["Records"],
      );

  // to json
  Map<String, dynamic> toJson() => {
        "Ids": id == null ? null : [id],
        "CustomerId": refId,
        "Codes": code,
        "Status": ((status?.isEmpty ?? true) || ((status?.length ?? 0) <= 0))
            ? null
            : status,
        "PartnerId": partnerId,
        "Database": database,
        "Search": search,
        "OrderBy": orderBy,
        "OrderDir": orderDir,
        "Pages": pages,
        "Records": records,
      };

  // copy with
  MServiceRequestFilter copyWith({
    int? id,
    int? refId,
    List<String>? code,
    int? serviceId,
    List<String>? status,
    int? rateFrom,
    int? rateTo,
    String? fromDate,
    String? toDate,
    int? partnerId,
    String? database,
    String? search,
    String? orderBy,
    String? orderDir,
    int? pages,
    int? records,
  }) =>
      MServiceRequestFilter(
        id: id ?? this.id,
        refId: refId ?? this.refId,
        code: code ?? this.code,
        status: status ?? this.status,
        rateFrom: rateFrom ?? this.rateFrom,
        rateTo: rateTo ?? this.rateTo,
        fromDate: fromDate ?? this.fromDate,
        toDate: toDate ?? this.toDate,
        partnerId: partnerId ?? this.partnerId,
        database: database ?? this.database,
        search: search ?? this.search,
        orderBy: orderBy ?? this.orderBy,
        orderDir: orderDir ?? this.orderDir,
        pages: pages ?? this.pages,
        records: records ?? this.records,
      );
}

class MServiceUsage {
  final int? id;
  final List<int>? serviceIds;
  final String? targetLocation;
  final String? customerCode;
  final String? lat;
  final String? lng;
  final String? desc;
  final String? contactPhone;
  final String? fixingDate;
  final int? provinceId;
  final int? districtId;

  MServiceUsage({
    this.id,
    this.serviceIds,
    this.targetLocation,
    this.customerCode,
    this.lat,
    this.lng,
    this.desc,
    this.contactPhone,
    this.fixingDate,
    this.provinceId,
    this.districtId,
  });

  // from json
  factory MServiceUsage.fromJson(Map<String, dynamic> json) => MServiceUsage(
        id: json["Id"],
        serviceIds: List<int>.from(json["ServiceIds"].map((x) => x)),
        targetLocation: json["TargetLocation"],
        customerCode: json["CustomerCode"],
        lng: json["Lng"],
        lat: json["Lat"],
        desc: json["Comment"],
        contactPhone: json["ContactPhone"],
        fixingDate: json["FixingDate"],
      );

  // to json
  Map<String, dynamic> toJson() => {
        "Id": id,
        "ServiceIds": List<int>.from(serviceIds!.map((x) => x)),
        "TargetLocation": targetLocation,
        "CustomerCode": customerCode,
        "Lng": lng,
        "Lat": lat,
        "Comment": desc,
        "ContactPhone": contactPhone,
        "FixingDate": fixingDate,
        "ProvinceId": provinceId,
        "DistrictId": districtId,
      };

  // copy with
  MServiceUsage copyWith(
          {int? id,
          List<int>? serviceIds,
          String? targetLocation,
          String? customerCode,
          String? lat,
          String? lng,
          String? desc,
          String? contactPhone,
          String? fixingDate,
          int? provinceId,
          int? districtId}) =>
      MServiceUsage(
        id: id ?? this.id,
        serviceIds: serviceIds ?? this.serviceIds,
        targetLocation: targetLocation ?? this.targetLocation,
        customerCode: customerCode ?? this.customerCode,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        desc: desc ?? this.desc,
        contactPhone: contactPhone ?? this.contactPhone,
        fixingDate: fixingDate ?? this.fixingDate,
        provinceId: provinceId ?? this.provinceId,
        districtId: districtId ?? this.districtId,
      );
}

class MRequestService {
  final int? id;
  final String? code;
  final String? customerName;
  final String? customerNameEnglish;
  final String? customerCode;
  final String? customerImage;
  final int? customerId;
  final String? customerPhone;
  final String? targetLocation;
  final String? approvedDate;
  final String? partnerName;
  final String? partnerNameEnglish;
  final int? partnerId;
  final String? finishedDate;
  final String? status;
  final String? lat;
  final String? lng;
  final MCustomQuot? quot;
  final double? rating;
  final int? recordCount;
  final String? createdBy;
  final String? createdDate;
  final String? updatedBy;
  final String? updatedDate;
  final String? desc;
  final String? comment;
  final String? contactPhone;
  final String? invoiceStatus;
  final String? rejectedReason;
  final String? arrivalTime;
  final String? fixingDate;
  final String? lateReason;

  MRequestService({
    this.id,
    this.code,
    this.customerName,
    this.customerNameEnglish,
    this.customerCode,
    this.customerImage,
    this.customerId,
    this.customerPhone,
    this.targetLocation,
    this.approvedDate,
    this.partnerName,
    this.partnerNameEnglish,
    this.partnerId,
    this.finishedDate,
    this.lat,
    this.lng,
    this.status,
    this.quot,
    this.rating,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
    this.recordCount,
    this.contactPhone,
    this.desc,
    this.comment,
    this.invoiceStatus,
    this.rejectedReason,
    this.arrivalTime,
    this.fixingDate,
    this.lateReason,
  });

  // from json
  factory MRequestService.fromJson(Map<String, dynamic> json) =>
      MRequestService(
        id: json["Id"],
        code: json["Code"],
        customerImage: json["CustomerImage"],
        customerName: json["CustomerName"],
        customerNameEnglish: json["CustomerNameEnglish"],
        customerCode: json["CustomerCode"],
        customerId: json["CustomerId"],
        customerPhone: json["CustomerPhone"],
        targetLocation: json["TargetLocation"],
        approvedDate: json["ApprovedDate"],
        partnerName: json["PartnerName"] != null ? json["PartnerName"] : "",
        partnerNameEnglish: json["PartnerNameEnglish"] != null
            ? json["PartnerNameEnglish"]
            : "",
        partnerId: json["PartnerId"] != null ? json["PartnerId"] : "",
        finishedDate: json["FinishedDate"],
        status: json["Status"],
        quot: json["Quot"] != null
            ? MCustomQuot.fromJson(json["Quot"])
            : MCustomQuot(),
        rating: json["Rating"].toDouble(),
        recordCount: json["RecordCount"],
        lat: json["Lat"],
        lng: json["Lng"],
        createdBy: json["CreatedBy"],
        createdDate: json["CreatedDate"],
        updatedDate: json["UpdatedDate"],
        updatedBy: json["UpdatedBy"],
        desc: json["Description"] ?? "",
        comment: json["Comment"] ?? "",
        contactPhone: json["ContactPhone"] ?? "",
        invoiceStatus: json["InvoiceStatus"] ?? "",
        rejectedReason: json["RejectedReason"] ?? "",
        arrivalTime: json["ArrivalTime"] ?? "",
        fixingDate: json["FixingDate"] ?? "",
        lateReason: json["LateReason"] ?? "",
      );

  // to json
  Map<String, dynamic> toJson() => {
        "Id": id,
        "Code": code,
        "CustomerName": customerName,
        "CustomerImage": customerImage,
        "CustomerNameEnglish": customerNameEnglish,
        "CustomerCode": customerCode,
        "CustomerId": customerId,
        "CustomerPhone": customerPhone,
        "TargetLocation": targetLocation,
        "ApprovedDate": approvedDate,
        "PartnerName": partnerName,
        "PartnerNameEnglish": partnerNameEnglish,
        "PartnerId": partnerId,
        "FinishedDate": finishedDate,
        "Rating": rating,
        "Status": status,
        "Lat": lat,
        "Lng": lng,
        "Quot": quot,
        "CreatedBy": createdBy,
        "CreatedDate": createdDate,
        "UpdatedDate": updatedDate,
        "UpdatedBy": updatedBy,
        "Description": desc,
        "Comment": comment,
        "ContactPhone": contactPhone,
        "RecordCount": recordCount,
        "InvoiceStatus": invoiceStatus,
        "RejectedReason": rejectedReason,
        "ArrivalTime": arrivalTime,
        "LateReason": lateReason,
      };

  // copy with
  MRequestService copyWith({
    int? id,
    String? code,
    int? customerId,
    String? customerImage,
    String? customerName,
    String? customerNameEnglish,
    String? customerPhone,
    String? customerCode,
    String? targetLocation,
    String? approvedDate,
    String? partnerName,
    String? partnerNameEnglish,
    int? partnerId,
    String? finishedDate,
    String? status,
    String? lat,
    String? lng,
    MCustomQuot? quot,
    double? rating,
    int? recordCount,
    String? createdBy,
    String? createdDate,
    String? updatedBy,
    String? updatedDate,
    String? contactPhone,
    String? desc,
    String? comment,
    String? invoiceStatus,
    String? rejectedReason,
    String? arrivalTime,
    String? fixingDate,
    String? lateReason,
  }) =>
      MRequestService(
        id: id ?? this.id,
        code: code ?? this.code,
        customerId: customerId ?? this.customerId,
        customerImage: customerImage ?? this.customerImage,
        customerName: customerName ?? this.customerName,
        customerNameEnglish: customerNameEnglish ?? this.customerNameEnglish,
        customerCode: customerCode ?? this.customerCode,
        customerPhone: customerPhone ?? this.customerPhone,
        targetLocation: targetLocation ?? this.targetLocation,
        approvedDate: approvedDate ?? this.approvedDate,
        partnerName: partnerName ?? this.partnerName,
        partnerNameEnglish: partnerNameEnglish ?? this.partnerNameEnglish,
        partnerId: partnerId ?? this.partnerId,
        finishedDate: finishedDate ?? this.finishedDate,
        status: status ?? this.status,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        quot: quot ?? this.quot,
        rating: rating ?? this.rating,
        createdBy: createdBy ?? this.createdBy,
        createdDate: createdDate ?? this.createdDate,
        updatedBy: updatedBy ?? this.updatedBy,
        updatedDate: updatedDate ?? this.updatedDate,
        desc: desc ?? this.desc,
        comment: comment ?? this.comment,
        contactPhone: contactPhone ?? this.contactPhone,
        recordCount: recordCount ?? this.recordCount,
        invoiceStatus: invoiceStatus ?? this.invoiceStatus,
        rejectedReason: rejectedReason ?? this.rejectedReason,
        arrivalTime: arrivalTime ?? this.arrivalTime,
        fixingDate: fixingDate ?? this.fixingDate,
        lateReason: lateReason ?? this.lateReason,
      );
}

class MServiceRequestDetail {
  final int? requestId;
  final String? requestCode;
  final int? customerId;
  final String? customerName;
  final String? customerNameEnglish;
  final String? customerCode;
  final String? customerEmail;
  final String? userImage;
  final List<MAcceptedPartner>? acceptedPartners;
  final MCustomPartner? approvedPartner;
  final MAttachment? attachment;
  final List<MService>? services;
  final String? createdBy;
  final String? updatedBy;
  final String? createdDate;
  final String? updatedDate;
  final int? recordCount;
  final bool? userDeleted;
  final MDiscountCode? promoDiscount;
  final MRequestUpdateQuot? quotUpdateRequest;

  MServiceRequestDetail({
    this.requestId,
    this.requestCode,
    this.customerId,
    this.customerName,
    this.customerNameEnglish,
    this.customerCode,
    this.customerEmail,
    this.userImage,
    this.acceptedPartners,
    this.approvedPartner,
    this.attachment,
    this.services,
    this.createdBy,
    this.updatedBy,
    this.createdDate,
    this.updatedDate,
    this.recordCount,
    this.userDeleted,
    this.promoDiscount,
    this.quotUpdateRequest,
  });

  // from json
  factory MServiceRequestDetail.fromJson(Map<String, dynamic> json) =>
      MServiceRequestDetail(
        requestId: json["RequestId"] != null ? json["RequestId"] : null,
        requestCode: json["RequestCode"] != null ? json["RequestCode"] : null,
        customerId: json["CustomerId"] != null ? json["CustomerId"] : null,
        customerName:
            json["CustomerName"] != null ? json["CustomerName"] : null,
        customerNameEnglish: json["CustomerNameEnglish"] != null
            ? json["CustomerNameEnglish"]
            : null,
        customerCode:
            json["CustomerCode"] != null ? json["CustomerCode"] : null,
        customerEmail:
            json["CustomerEmail"] != null ? json["CustomerEmail"] : null,
        userImage: json["UserImage"] != null ? json["UserImage"] : null,
        acceptedPartners: (json["Partners"] ?? [])
            .map<MAcceptedPartner>((x) => MAcceptedPartner.fromJson(x))
            .toList(),
        approvedPartner: json["ApprovedPartner"] == null
            ? null
            : MCustomPartner.fromJson(json["ApprovedPartner"]),
        attachment: (json["Attachment"] != null
            ? MAttachment.fromJson(json["Attachment"])
            : MAttachment()),
        services: json["Services"] != null
            ? json["Services"]
                .map<MService>((x) => MService.fromJson(x))
                .toList()
            : [],
        createdBy: json["CreatedBy"] != null ? json["CreatedBy"] : null,
        updatedBy: json["UpdatedBy"] != null ? json["UpdatedBy"] : null,
        createdDate: json["CreatedDate"] != null ? json["CreatedDate"] : null,
        updatedDate: json["UpdatedDate"] != null ? json["UpdatedDate"] : null,
        recordCount: json["RecordCount"] != null ? json["RecordCount"] : null,
        userDeleted: json["UserDeleted"] != null ? json["UserDeleted"] : null,
        promoDiscount: json["PromoDiscount"] == null
            ? null
            : MDiscountCode.fromJson(json["PromoDiscount"]),
      );

  // to json
  Map<String, dynamic> toJson() => {
        "RequestId": requestId,
        "RequestCode": requestCode,
        "CustomerName": customerName,
        "CustomerId": customerId,
        "CustomerNameEnglish": customerNameEnglish,
        "CustomerCode": customerCode,
        "CustomerEmail": customerEmail,
        "UserImage": userImage,
        "AcceptedPartners": acceptedPartners,
        "ApprovedPartner": approvedPartner,
        "Attachment": attachment,
        "Services": services,
        "CreatedBy": createdBy,
        "UpdatedBy": updatedBy,
        "CreatedDate": createdDate,
        "UpdatedDate": updatedDate,
        "RecordCount": recordCount,
        "UserDeleted": userDeleted,
        "PromoDiscount": promoDiscount?.toJson(),
        "QuotUpdateRequest": quotUpdateRequest?.toJson(),
      };

  // copy with
  MServiceRequestDetail copyWith({
    int? requestId,
    String? requestCode,
    String? feedbackComment,
    double? feedbackRating,
    int? customerId,
    String? customerName,
    String? customerNameEnglish,
    String? customerCode,
    String? customerEmail,
    String? userImage,
    List<MAcceptedPartner>? acceptedPartners,
    MCustomPartner? approvedPartner,
    MAttachment? attachment,
    List<MService>? services,
    String? createdBy,
    String? updatedBy,
    String? createdDate,
    String? updatedDate,
    int? recordCount,
    bool? userDeleted,
    String? fixingDate,
    String? arrivalTime,
    String? lateReason,
    MDiscountCode? promoDiscount,
    MRequestUpdateQuot? quotUpdateRequest,
  }) =>
      MServiceRequestDetail(
        requestId: requestId ?? this.requestId,
        requestCode: requestCode ?? this.requestCode,
        customerId: customerId ?? this.customerId,
        customerName: customerName ?? this.customerName,
        customerNameEnglish: customerNameEnglish ?? this.customerNameEnglish,
        customerCode: customerCode ?? this.customerCode,
        customerEmail: customerEmail ?? this.customerEmail,
        userImage: userImage ?? this.userImage,
        acceptedPartners: acceptedPartners ?? this.acceptedPartners,
        approvedPartner: approvedPartner ?? this.approvedPartner,
        attachment: attachment ?? this.attachment,
        services: services ?? this.services,
        createdBy: createdBy ?? this.createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
        createdDate: createdDate ?? this.createdDate,
        updatedDate: updatedDate ?? this.updatedDate,
        recordCount: recordCount ?? this.recordCount,
        userDeleted: userDeleted ?? this.userDeleted,
        promoDiscount: promoDiscount ?? this.promoDiscount,
        quotUpdateRequest: quotUpdateRequest ?? this.quotUpdateRequest,
      );
}

class MSubmitQuot {
  final int? id;
  final int? requestId;
  final String? customerCode;
  final int? customerId;
  final int? partnerId;
  final double? vat;
  final List<MItemQuotation>? items;
  final MDiscount? quotDiscount;
  final String? description;

  MSubmitQuot({
    this.requestId,
    this.customerCode,
    this.vat,
    this.items,
    this.description,
    this.quotDiscount,
    this.id,
    this.customerId,
    this.partnerId,
  });

  // to json
  Map<String, dynamic> toJson() => {
        "RequestId": requestId,
        "Id": id,
        "CustomerCode": customerCode,
        "CustomerId": customerId,
        "PartnerId": partnerId,
        "Description": description,
        "Vat": vat,
        "QuotDiscount": quotDiscount?.toJson(),
        "Items": List<MItemQuotation>.from(items!.map((x) => x)),
      };

  // copy with
  MSubmitQuot copyWith({
    int? requestId,
    int? id,
    String? customerCode,
    double? vat,
    String? description,
    List<MItemQuotation>? items,
    MDiscount? quotDiscount,
  }) =>
      MSubmitQuot(
        id: id ?? this.id,
        requestId: requestId ?? this.requestId,
        customerCode: customerCode ?? this.customerCode,
        description: description ?? this.description,
        vat: vat ?? this.vat,
        items: items ?? this.items,
        quotDiscount: quotDiscount ?? this.quotDiscount,
      );
}
