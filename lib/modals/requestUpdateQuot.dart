class MRequestUpdateQuot {
  MRequestUpdateQuot({
    this.id,
    this.code,
    this.status,
    this.refId,
    this.quotation,
    this.details,
    this.createdBy,
    this.updatedBy,
    this.createdDate,
    this.updatedDate,
    this.recordCount,
  });

  final int? id;
  final String? code;
  final String? status;
  final int? refId;
  final MMatchQuotation? quotation;
  final List<MQuotUpdateDetail>? details;
  final String? createdBy;
  final String? updatedBy;
  final String? createdDate;
  final String? updatedDate;
  final int? recordCount;

  MRequestUpdateQuot copyWith({
    int? id,
    String? code,
    String? status,
    int? refId,
    MMatchQuotation? quotation,
    List<MQuotUpdateDetail>? details,
    String? createdBy,
    String? updatedBy,
    String? createdDate,
    String? updatedDate,
    int? recordCount,
  }) =>
      MRequestUpdateQuot(
        id: id ?? this.id,
        code: code ?? this.code,
        status: status ?? this.status,
        refId: refId ?? this.refId,
        quotation: quotation ?? this.quotation,
        details: details ?? this.details,
        createdBy: createdBy ?? this.createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
        createdDate: createdDate ?? this.createdDate,
        updatedDate: updatedDate ?? this.updatedDate,
        recordCount: recordCount ?? this.recordCount,
      );

  factory MRequestUpdateQuot.fromJson(Map<String?, dynamic> json) =>
      MRequestUpdateQuot(
        id: json["Id"] == null ? null : json["Id"],
        code: json["Code"] == null ? null : json["Code"],
        status: json["Status"] == null ? null : json["Status"],
        refId: json["RefId"] == null ? null : json["RefId"],
        quotation: json["Quotation"] == null
            ? null
            : MMatchQuotation.fromJson(json["Quotation"]),
        details: json["Details"] == null
            ? null
            : List<MQuotUpdateDetail>.from(
                json["Details"].map((x) => MQuotUpdateDetail.fromJson(x))),
        createdBy: json["CreatedBy"] == null ? null : json["CreatedBy"],
        updatedBy: json["UpdatedBy"] == null ? null : json["UpdatedBy"],
        createdDate: json["CreatedDate"] == null ? null : json["CreatedDate"],
        updatedDate: json["UpdatedDate"] == null ? null : json["UpdatedDate"],
        recordCount: json["RecordCount"] == null ? null : json["RecordCount"],
      );

  Map<String?, dynamic> toJson() => {
        "Id": id == null ? null : id,
        "Code": code == null ? null : code,
        "Status": status == null ? null : status,
        "RefId": refId == null ? null : refId,
        "Quotation": quotation == null ? null : quotation?.toJson(),
        "Details": details == null
            ? null
            : List<dynamic>.from(details!.map((x) => x.toJson())),
        "CreatedBy": createdBy == null ? null : createdBy,
        "UpdatedBy": updatedBy == null ? null : updatedBy,
        "CreatedDate": createdDate == null ? null : createdDate,
        "UpdatedDate": updatedDate == null ? null : updatedDate,
        "RecordCount": recordCount == null ? null : recordCount,
      };
}

class MQuotUpdateDetail {
  MQuotUpdateDetail({
    this.headerId,
    this.quotDetailId,
    this.quantity,
    this.cost,
    this.unitType,
    this.name,
    this.nameEnglish,
    this.itemId,
  });

  final int? headerId;
  final int? quotDetailId;
  final double? quantity;
  final double? cost;
  final String? unitType;
  final String? name;
  final String? nameEnglish;
  final int? itemId;

  MQuotUpdateDetail copyWith({
    int? headerId,
    int? quotDetailId,
    double? quantity,
    double? cost,
    String? unitType,
    int? itemId,
    String? name,
    String? nameEnglish,
  }) =>
      MQuotUpdateDetail(
        headerId: headerId ?? this.headerId,
        quotDetailId: quotDetailId ?? this.quotDetailId,
        quantity: quantity ?? this.quantity,
        cost: cost ?? this.cost,
        unitType: unitType ?? this.unitType,
        itemId: itemId ?? this.itemId,
        name: name ?? this.name,
        nameEnglish: nameEnglish ?? this.nameEnglish,
      );

  factory MQuotUpdateDetail.fromJson(Map<String?, dynamic> json) =>
      MQuotUpdateDetail(
        headerId: json["HeaderId"] == null ? null : json["HeaderId"],
        quotDetailId:
            json["QuotDetailId"] == null ? null : json["QuotDetailId"],
        quantity: json["Quantity"] == null ? null : json["Quantity"],
        cost: json["Cost"] == null ? null : json["Cost"],
        unitType: json["UnitType"] == null ? null : json["UnitType"],
        itemId: json["ItemId"] == null ? null : json["ItemId"],
        name: json["Name"] == null ? null : json["Name"],
        nameEnglish: json["NameEnglish"] == null ? null : json["NameEnglish"],
      );

  Map<String?, dynamic> toJson() => {
        "HeaderId": headerId == null ? null : headerId,
        "QuotDetailId": quotDetailId == null ? null : quotDetailId,
        "Quantity": quantity == null ? null : quantity,
        "Cost": cost == null ? null : cost,
        "UnitType": unitType == null ? null : unitType,
        "ItemId": itemId == null ? null : itemId,
        "Name": name == null ? null : name,
        "NameEnglish": nameEnglish == null ? null : nameEnglish,
      };
}

class MMatchQuotation {
  MMatchQuotation({
    this.id,
    this.refId,
    this.requestId,
    this.code,
    this.description,
    this.status,
    this.vat,
    this.details,
  });

  final int? id;
  final int? refId;
  final int? requestId;
  final String? code;
  final String? description;
  final String? status;
  final double? vat;
  final List<MMatchQuotationDetail>? details;

  MMatchQuotation copyWith({
    int? id,
    int? refId,
    int? requestId,
    String? code,
    String? description,
    String? status,
    double? vat,
    List<MMatchQuotationDetail>? details,
  }) =>
      MMatchQuotation(
        id: id ?? this.id,
        refId: refId ?? this.refId,
        requestId: requestId ?? this.requestId,
        code: code ?? this.code,
        description: description ?? this.description,
        status: status ?? this.status,
        vat: vat ?? this.vat,
        details: details ?? this.details,
      );

  factory MMatchQuotation.fromJson(Map<String?, dynamic> json) =>
      MMatchQuotation(
        id: json["Id"] == null ? null : json["Id"],
        refId: json["RefId"] == null ? null : json["RefId"],
        requestId: json["RequestId"] == null ? null : json["RequestId"],
        code: json["Code"] == null ? null : json["Code"],
        description: json["Description"] == null ? null : json["Description"],
        status: json["Status"] == null ? null : json["Status"],
        vat: json["Vat"] == null ? null : json["Vat"],
        details: json["Details"] == null
            ? null
            : List<MMatchQuotationDetail>.from(
                json["Details"].map((x) => MMatchQuotationDetail.fromJson(x))),
      );

  Map<String?, dynamic> toJson() => {
        "Id": id == null ? null : id,
        "RefId": refId == null ? null : refId,
        "RequestId": requestId == null ? null : requestId,
        "Code": code == null ? null : code,
        "Description": description == null ? null : description,
        "Status": status == null ? null : status,
        "Vat": vat == null ? null : vat,
        "Details": details == null
            ? null
            : List<dynamic>.from(details!.map((x) => x.toJson())),
      };
}

class MMatchQuotationDetail {
  MMatchQuotationDetail({
    this.id,
    this.quotationId,
    this.itemId,
    this.name,
    this.nameEnglish,
    this.quantity,
    this.cost,
    this.unitType,
  });

  final int? id;
  final int? quotationId;
  final int? itemId;
  final String? name;
  final String? nameEnglish;
  final double? quantity;
  final double? cost;
  final String? unitType;

  MMatchQuotationDetail copyWith({
    int? id,
    int? quotationId,
    int? itemId,
    String? name,
    String? nameEnglish,
    double? quantity,
    double? cost,
    String? unitType,
  }) =>
      MMatchQuotationDetail(
        id: id ?? this.id,
        quotationId: quotationId ?? this.quotationId,
        itemId: itemId ?? this.itemId,
        name: name ?? this.name,
        nameEnglish: nameEnglish ?? this.nameEnglish,
        quantity: quantity ?? this.quantity,
        cost: cost ?? this.cost,
        unitType: unitType ?? this.unitType,
      );

  factory MMatchQuotationDetail.fromJson(Map<String?, dynamic> json) =>
      MMatchQuotationDetail(
        id: json["Id"] == null ? null : json["Id"],
        quotationId: json["QuotationId"] == null ? null : json["QuotationId"],
        itemId: json["ItemId"] == null ? null : json["ItemId"],
        name: json["Name"] == null ? null : json["Name"],
        nameEnglish: json["NameEnglish"] == null ? null : json["NameEnglish"],
        quantity: json["Quantity"] == null ? null : json["Quantity"],
        cost: json["Cost"] == null ? null : json["Cost"],
        unitType: json["UnitType"] == null ? null : json["UnitType"],
      );

  Map<String?, dynamic> toJson() => {
        "Id": id == null ? null : id,
        "QuotationId": quotationId == null ? null : quotationId,
        "ItemId": itemId == null ? null : itemId,
        "Name": name == null ? null : name,
        "NameEnglish": nameEnglish == null ? null : nameEnglish,
        "Quantity": quantity == null ? null : quantity,
        "Cost": cost == null ? null : cost,
        "UnitType": unitType == null ? null : unitType,
      };
}

class MSubmitUpdateQuot {
  MSubmitUpdateQuot({
    this.id,
    this.code,
    this.status,
    this.refId,
    this.quotationId,
    this.details,
  });

  final int? id;
  final String? code;
  final String? status;
  final int? refId;
  final int? quotationId;
  final List<MQuotUpdateDetail>? details;

  MSubmitUpdateQuot copyWith({
    int? id,
    String? code,
    String? status,
    int? refId,
    int? quotationId,
    List<MQuotUpdateDetail>? details,
  }) =>
      MSubmitUpdateQuot(
        id: id ?? this.id,
        code: code ?? this.code,
        status: status ?? this.status,
        refId: refId ?? this.refId,
        quotationId: quotationId ?? this.quotationId,
        details: details ?? this.details,
      );

  factory MSubmitUpdateQuot.fromJson(Map<String, dynamic> json) =>
      MSubmitUpdateQuot(
        id: json["Id"] == null ? null : json["Id"],
        code: json["Code"] == null ? null : json["Code"],
        status: json["Status"] == null ? null : json["Status"],
        refId: json["RefId"] == null ? null : json["RefId"],
        quotationId: json["QuotationId"] == null ? null : json["QuotationId"],
        details: json["Details"] == null
            ? null
            : List<MQuotUpdateDetail>.from(
                json["Details"].map((x) => MQuotUpdateDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Id": id == null ? null : id,
        "Code": code == null ? null : code,
        "Status": status == null ? null : status,
        "RefId": refId == null ? null : refId,
        "QuotationId": quotationId == null ? null : quotationId,
        "Details": details == null
            ? null
            : List<dynamic>.from(details!.map((x) => x.toJson())),
      };
}
