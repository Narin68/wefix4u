// To parse this JSON data, do
//
//     final mDiscount = mDiscountFromJson(jsonString);

import 'dart:convert';

MDiscount mDiscountFromJson(String str) => MDiscount.fromJson(json.decode(str));

String mDiscountToJson(MDiscount data) => json.encode(data.toJson());

class MDiscount {
  MDiscount({
    this.discount,
    this.discountBy,
    this.discountRule,
  });

  final String? discountBy;
  final double? discount;
  final int? discountRule;

  MDiscount copyWith({
    double? discount,
    String? discountBy,
    int? discountRule,
  }) =>
      MDiscount(
        discount: discount ?? this.discount,
        discountBy: discountBy ?? this.discountBy,
        discountRule: discountRule ?? this.discountRule,
      );

  factory MDiscount.fromJson(Map<String, dynamic> json) => MDiscount(
        discount: json["Discount"].toDouble(),
        discountBy: json["DiscountBy"],
        discountRule: json["DiscountRule"],
      );

  Map<String, dynamic> toJson() => {
        "Discount": discount,
        "DiscountBy": discountBy,
        "DiscountRule": discountRule,
      };
}

class MDiscountCode {
  MDiscountCode({
    this.id,
    this.code,
    this.discount,
    this.discountBy,
    this.discountRule,
    this.createdBy,
    this.updatedBy,
    this.createdDate,
    this.updatedDate,
    this.recordCount,
    this.refId,
  });

  final int? id;
  final String? code;
  final double? discount;
  final String? discountBy;
  final int? discountRule;
  final String? createdBy;
  final String? updatedBy;
  final String? createdDate;
  final String? updatedDate;
  final int? recordCount;
  final int? refId;

  MDiscountCode copyWith({
    int? id,
    String? code,
    double? discount,
    String? discountBy,
    int? discountRule,
    String? createdBy,
    String? updatedBy,
    String? createdDate,
    String? updatedDate,
    int? recordCount,
    int? refId,
  }) =>
      MDiscountCode(
        id: id ?? this.id,
        code: code ?? this.code,
        discount: discount ?? this.discount,
        discountBy: discountBy ?? this.discountBy,
        discountRule: discountRule ?? this.discountRule,
        createdBy: createdBy ?? this.createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
        createdDate: createdDate ?? this.createdDate,
        updatedDate: updatedDate ?? this.updatedDate,
        recordCount: recordCount ?? this.recordCount,
        refId: refId ?? this.refId,
      );

  factory MDiscountCode.fromJson(Map<String, dynamic> json) => MDiscountCode(
        id: json["Id"] == null ? null : json["Id"],
        code: json["Code"] == null ? null : json["Code"],
        discount: json["Discount"] == null ? null : json["Discount"],
        discountBy: json["DiscountBy"] == null ? null : json["DiscountBy"],
        discountRule:
            json["DiscountRule"] == null ? null : json["DiscountRule"],
        createdBy: json["CreatedBy"] == null ? null : json["CreatedBy"],
        updatedBy: json["UpdatedBy"] == null ? null : json["UpdatedBy"],
        createdDate: json["CreatedDate"] == null ? null : json["CreatedDate"],
        updatedDate: json["UpdatedDate"] == null ? null : json["UpdatedDate"],
        recordCount: json["RecordCount"] == null ? null : json["RecordCount"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id == null ? null : id,
        "Code": code == null ? null : code,
        "Discount": discount == null ? null : discount,
        "DiscountBy": discountBy == null ? null : discountBy,
        "DiscountRule": discountRule == null ? null : discountRule,
        "CreatedBy": createdBy == null ? null : createdBy,
        "UpdatedBy": updatedBy == null ? null : updatedBy,
        "CreatedDate": createdDate == null ? null : createdDate,
        "UpdatedDate": updatedDate == null ? null : updatedDate,
        "RecordCount": recordCount == null ? null : recordCount,
        "RefId": refId == null ? null : refId,
      };
}
