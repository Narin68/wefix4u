import '/modals/service.dart';

class MRequestLogList {
  final String? createdDate;
  final String? createdBy;
  final String? customerActionDate;
  final String? customerCode;
  final String? customerName;
  final String? customerNameEnglish;
  final int? id;
  final List<MPartnerRequestLog>? partners;
  final int? recordCount;
  final String? reqCode;
  final String? reqDate;
  final String? requestLocation;
  final List<MService>? services;
  final String? updatedBy;
  final String? updatedDate;
  final String? status;

  MRequestLogList({
    this.createdDate,
    this.createdBy,
    this.customerActionDate,
    this.customerCode,
    this.customerName,
    this.customerNameEnglish,
    this.id,
    this.partners,
    this.recordCount,
    this.reqCode,
    this.reqDate,
    this.requestLocation,
    this.services,
    this.updatedBy,
    this.updatedDate,
    this.status,
  });

  // from json
  factory MRequestLogList.fromJson(Map<String, dynamic> json) =>
      MRequestLogList(
        createdDate: json["CreatedDate"],
        createdBy: json["CreatedBy"],
        customerActionDate: json["CustomerActionDate"],
        customerCode: json["CustomerCode"],
        customerName: json["CustomerName"],
        customerNameEnglish: json["CustomerNameEnglish"],
        id: json["Id"],
        partners: (json["Partners"] ?? [])
            .map<MPartnerRequestLog>((x) => MPartnerRequestLog.fromJson(x))
            .toList(),
        recordCount: json["RecordCount"],
        reqCode: json["ReqCode"],
        reqDate: json["ReqDate"],
        requestLocation: json["RequestLocation"],
        services: json["Services"]
            .map<MService>((x) => MService.fromJson(x))
            .toList(),
        updatedBy: json["UpdatedBy"],
        updatedDate: json["UpdatedDate"],
        status: json["Status"],
      );

  // to json
  Map<String, dynamic> toJson() => {
        "CreatedDate": createdDate,
        "CreatedBy": createdBy,
        "CustomerActionDate": customerActionDate,
        "CustomerCode": customerCode,
        "CustomerName": customerName,
        "CustomerNameEnglish": customerNameEnglish,
        "Id": id,
        "Partner": partners,
        "RecordCount": recordCount,
        "ReqCode": reqCode,
        "ReqDate": reqDate,
        "RequestLocation": requestLocation,
        "Services": services,
        "UpdatedBy": updatedBy,
        "UpdatedDate": updatedDate,
        "Status": status,
      };

  // copy with
  MRequestLogList copyWith({
    String? createdDate,
    String? createdBy,
    String? customerActionDate,
    String? customerCode,
    String? customerName,
    String? customerNameEnglish,
    int? id,
    List<MPartnerRequestLog>? partners,
    int? recordCount,
    String? reqCode,
    String? reqDate,
    String? requestLocation,
    List<MService>? services,
    String? updatedBy,
    String? updatedDate,
    String? status,
  }) =>
      MRequestLogList(
        createdDate: createdDate ?? this.createdDate,
        createdBy: createdBy ?? this.createdBy,
        customerActionDate: customerActionDate ?? this.customerActionDate,
        customerCode: customerCode ?? this.customerCode,
        customerName: customerName ?? this.customerName,
        customerNameEnglish: customerNameEnglish ?? this.customerNameEnglish,
        id: id ?? this.id,
        partners: partners ?? this.partners,
        recordCount: recordCount ?? this.recordCount,
        reqCode: reqCode ?? this.reqCode,
        reqDate: reqDate ?? this.reqDate,
        requestLocation: requestLocation ?? this.requestLocation,
        services: services ?? this.services,
        updatedBy: updatedBy ?? this.updatedBy,
        updatedDate: updatedDate ?? this.updatedDate,
        status: status ?? this.status,
      );
}

class MPartnerRequestLog {
  final String? actionDate;
  final String? partnerName;
  final String? partnerNameEnglish;
  final int? id;
  final String? partnerCode;

  MPartnerRequestLog({
    this.actionDate,
    this.partnerName,
    this.partnerNameEnglish,
    this.id,
    this.partnerCode,
  });

  // from json
  factory MPartnerRequestLog.fromJson(Map<String, dynamic> json) =>
      MPartnerRequestLog(
        actionDate: json["ActionDate"],
        partnerName: json["PartnerName"],
        partnerNameEnglish: json["PartnerNameEnglish"],
        id: json["Id"],
        partnerCode: json["PartnerCode"],
      );

  // to json
  Map<String, dynamic> toJson() => {
        "ActionDate": actionDate,
        "PartnerName": partnerName,
        "PartnerNameEnglish": partnerNameEnglish,
        "Id": id,
        "PartnerCode": partnerCode,
      };

  // copy with
  MPartnerRequestLog copyWith({
    String? actionDate,
    String? partnerName,
    String? partnerNameEnglish,
    int? id,
    String? partnerCode,
  }) =>
      MPartnerRequestLog(
        actionDate: actionDate ?? this.actionDate,
        partnerName: partnerName ?? this.partnerName,
        partnerNameEnglish: partnerNameEnglish ?? this.partnerNameEnglish,
        id: id ?? this.id,
        partnerCode: partnerCode ?? this.partnerCode,
      );
}
