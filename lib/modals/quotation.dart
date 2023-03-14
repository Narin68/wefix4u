import 'dart:math';

import 'discount.dart';

class MQuotationDetail {
  final String? description;
  final String? cost;
  final String? unitPrice;
  final String? quantity;

  MQuotationDetail({
    this.description,
    this.cost,
    this.unitPrice,
    this.quantity,
  });

  // from json
  factory MQuotationDetail.fromJson(Map<String, dynamic> json) =>
      MQuotationDetail(
        description: json["Description"],
        cost: json["Cost"],
        unitPrice: json["UnitPrice"],
        quantity: json["Quantity"],
      );

  // to json
  Map<String, dynamic> toJson() => {
        "Description": description,
        "Cost": cost,
        "UnitPrice": unitPrice,
        "Quantity": quantity,
      };

  // copy with
  MQuotationDetail copyWith({
    String? description,
    String? cost,
    String? unitPrice,
    String? quantity,
  }) =>
      MQuotationDetail(
        description: description ?? this.description,
        cost: cost ?? this.cost,
        unitPrice: unitPrice ?? this.unitPrice,
        quantity: quantity ?? this.quantity,
      );
}

class MQuotation {
  final int? id;
  final int? requestId;
  final String? code;
  final List<MItemQuotation>? items;
  final double? vat;
  final double? cost;
  final double? qty;
  final String? status;
  final String? desc;
  final String? createdBy;
  final String? createdDate;
  final String? updatedBy;
  final String? updatedDate;
  final MDiscount? quotDiscount;
  final double? discountPer;
  final double? discountAmount;
  final bool? isDisPercent;

  MQuotation({
    this.id,
    this.requestId,
    this.code,
    this.items,
    this.vat,
    this.cost,
    this.qty,
    this.status,
    this.desc,
    this.createdBy,
    this.updatedBy,
    this.createdDate,
    this.updatedDate,
    this.quotDiscount,
    this.discountAmount,
    this.isDisPercent,
    this.discountPer,
  });

  // from json
  factory MQuotation.fromJson(Map<String, dynamic> json) => MQuotation(
        id: json["Id"],
        requestId: json["RequestId"],
        code: json["Code"],
        status: json["Status"],
        items: json["Items"] != null
            ? (json["Items"] ?? [])
                .map<MItemQuotation>((x) => MItemQuotation.fromJson(x))
                .toList()
            : json["Details"] != null
                ? (json["Items"] ?? [])
                    .map<MItemQuotation>((x) => MItemQuotation.fromJson(x))
                    .toList()
                : null,
        vat: json["Vat"],
        cost: json["Cost"],
        qty: json["Qty"],
        desc: json["Description"],
        createdBy: json["CreatedBy"],
        updatedBy: json["UpdatedBy"],
        createdDate: json["CreatedDate"],
        updatedDate: json["UpdatedDate"],
        quotDiscount: json["QuotDiscount"] == null
            ? null
            : MDiscount.fromJson(json["QuotDiscount"]),
      );

  // to json
  Map<String, dynamic> toJson() => {
        "Id": id,
        "RequestId": requestId,
        "Code": code,
        "Items": List.from(items!.map((x) => x)),
        "Vat": vat,
        "Cost": cost,
        "Qty": qty,
        "Status": status,
        "Description": desc,
        "CreatedBy": createdBy,
        "UpdatedBy": updatedBy,
        "CreatedDate": createdDate,
        "UpdatedDate": updatedDate,
        "QuotDiscount": quotDiscount?.toJson(),
      };

  // copy with
  MQuotation copyWith({
    int? id,
    int? requestId,
    String? code,
    List<MItemQuotation>? items,
    double? vat,
    double? cost,
    double? qty,
    String? status,
    String? desc,
    String? createdBy,
    String? updatedBy,
    String? createdDate,
    String? updatedDate,
    MDiscount? quotDiscount,
    double? discountPer,
    double? discountAmount,
    bool? isDisPercent,
  }) =>
      MQuotation(
        id: id ?? this.id,
        requestId: requestId ?? this.requestId,
        code: code ?? this.code,
        items: items ?? this.items,
        vat: vat ?? this.vat,
        cost: cost ?? this.cost,
        qty: qty ?? this.qty,
        status: status ?? this.status,
        desc: desc ?? this.desc,
        createdBy: createdBy ?? this.createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
        createdDate: createdDate ?? this.createdDate,
        updatedDate: updatedDate ?? this.updatedDate,
        quotDiscount: quotDiscount ?? this.quotDiscount,
        discountAmount: discountAmount ?? this.discountAmount,
        discountPer: discountPer ?? this.discountPer,
        isDisPercent: isDisPercent ?? this.isDisPercent,
      );
}

class MCustomQuot {
  final String? createdDate;
  final String? quotStatus;

  MCustomQuot({
    this.createdDate,
    this.quotStatus,
  });

  // from json
  factory MCustomQuot.fromJson(Map<String, dynamic> json) => MCustomQuot(
        createdDate: json["CreatedDate"],
        quotStatus: json["QuotStatus"],
      );

  // to json
  Map<String, dynamic> toJson() => {
        "CreatedDate": createdDate,
        "Status": quotStatus,
      };

  // copy with
  MCustomQuot copyWith({
    String? createdDate,
    String? quotStatus,
  }) =>
      MCustomQuot(
        createdDate: createdDate ?? this.createdDate,
        quotStatus: quotStatus ?? this.quotStatus,
      );
}

class MPartnerQuotList {
  final int? refId;
  final String? status;
  final int? id;
  final String? createdDate;
  final String? createdBy;
  final String? updatedDate;
  final int? recordCount;
  final String? description;
  final List<MItemQuotation>? item;
  final double? vat;
  final double? cost;
  final int? requestId;
  final String? code;
  final MDiscount? quotDiscount;

  MPartnerQuotList({
    this.refId,
    this.status,
    this.id,
    this.createdDate,
    this.createdBy,
    this.updatedDate,
    this.recordCount,
    this.description,
    this.item,
    this.vat,
    this.cost,
    this.requestId,
    this.code,
    this.quotDiscount,
  });

  // from json
  factory MPartnerQuotList.fromJson(Map<String, dynamic> json) =>
      MPartnerQuotList(
        refId: json["RefId"],
        status: json["Status"],
        id: json["Id"],
        createdDate: json["CreatedDate"],
        createdBy: json["CreatedBy"],
        updatedDate: json["UpdatedDate"],
        recordCount: json["RecordCount"],
        description: json["Description"],
        item: json["Item"],
        vat: json["Vat"],
        cost: json["Cost"],
        requestId: json["RequestId"],
        code: json["Code"],
        quotDiscount: json["QuotDiscount"] != null
            ? MDiscount.fromJson(json["QuotDiscount"])
            : null,
      );

  // to json
  Map<String, dynamic> toJson() => {
        "RefId": refId,
        "Status": status,
        "Id": id,
        "CreatedDate": createdDate,
        "CreatedBy": createdBy,
        "UpdatedDate": updatedDate,
        "RecordCount": recordCount,
        "Description": description,
        "Item": item,
        "Vat": vat,
        "Cost": cost,
        "RequestId": requestId,
        "Code": code,
        "QuotDiscount": quotDiscount?.toJson(),
      };

  // copy with
  MPartnerQuotList copyWith({
    int? refId,
    String? status,
    int? id,
    String? createdDate,
    String? createdBy,
    String? updatedDate,
    int? recordCount,
    String? description,
    List<MItemQuotation>? item,
    double? vat,
    double? cost,
    int? requestId,
    String? code,
    MDiscount? quotDiscount,
  }) =>
      MPartnerQuotList(
        refId: refId ?? this.refId,
        status: status ?? this.status,
        id: id ?? this.id,
        createdDate: createdDate ?? this.createdDate,
        createdBy: createdBy ?? this.createdBy,
        updatedDate: updatedDate ?? this.updatedDate,
        recordCount: recordCount ?? this.recordCount,
        description: description ?? this.description,
        item: item ?? this.item,
        vat: vat ?? this.vat,
        cost: cost ?? this.cost,
        requestId: requestId ?? this.requestId,
        code: code ?? this.code,
        quotDiscount: quotDiscount ?? this.quotDiscount,
      );
}

class MSubmitQuotData {
  MSubmitQuotData({
    this.id,
    this.code,
    this.requestId,
    this.customerId,
    this.partnerId,
    this.description,
    this.amount,
    this.discountPercent,
    this.discountAmount,
    this.vatPercent,
    this.vatAmount,
    this.total,
    this.requireDeposit,
    this.depositPercent,
    this.depositAmount,
    this.balance,
    this.items,
    this.isDisPercent,
  });

  final int? id;
  final String? code;
  final int? requestId;
  final int? customerId;
  final int? partnerId;
  final String? description;
  final double? amount;
  final double? discountPercent;
  final double? discountAmount;
  final double? vatPercent;
  final double? vatAmount;
  final double? total;
  final bool? requireDeposit;
  final bool? isDisPercent;
  final double? depositPercent;
  final double? depositAmount;
  final double? balance;
  final List<MItemQuotation>? items;

  MSubmitQuotData copyWith({
    int? id,
    String? code,
    int? requestId,
    int? customerId,
    int? partnerId,
    String? description,
    double? amount,
    double? discountPercent,
    double? discountAmount,
    double? vatPercent,
    double? vatAmount,
    double? total,
    bool? requireDeposit,
    bool? isDisPercent,
    double? depositPercent,
    double? depositAmount,
    double? balance,
    List<MItemQuotation>? items,
  }) =>
      MSubmitQuotData(
        id: id ?? this.id,
        code: code ?? this.code,
        requestId: requestId ?? this.requestId,
        customerId: customerId ?? this.customerId,
        partnerId: partnerId ?? this.partnerId,
        description: description ?? this.description,
        amount: amount ?? this.amount,
        discountPercent: discountPercent ?? this.discountPercent,
        discountAmount: discountAmount ?? this.discountAmount,
        vatPercent: vatPercent ?? this.vatPercent,
        vatAmount: vatAmount ?? this.vatAmount,
        total: total ?? this.total,
        requireDeposit: requireDeposit ?? this.requireDeposit,
        isDisPercent: isDisPercent ?? this.isDisPercent,
        depositPercent: depositPercent ?? this.depositPercent,
        depositAmount: depositAmount ?? this.depositAmount,
        balance: balance ?? this.balance,
        items: items ?? this.items,
      );

  factory MSubmitQuotData.fromJson(Map<String, dynamic> json) =>
      MSubmitQuotData(
        id: json["Id"],
        code: json["Code"],
        requestId: json["RequestId"],
        customerId: json["CustomerId"],
        partnerId: json["PartnerId"],
        description: json["Description"],
        amount: json["Amount"]?.toDouble(),
        discountPercent: json["DiscountPercent"]?.toDouble(),
        discountAmount: json["DiscountAmount"]?.toDouble(),
        vatPercent: json["VatPercent"]?.toDouble(),
        vatAmount: json["VatAmount"]?.toDouble(),
        total: json["Total"]?.toDouble(),
        requireDeposit: json["RequireDeposit"],
        isDisPercent: (json["DiscountPercent"] != null &&
                json["DiscountPercent"]?.toDouble() > 0)
            ? true
            : false,
        depositPercent: json["DepositPercent"]?.toDouble(),
        depositAmount: json["DepositAmount"]?.toDouble(),
        balance: json["Balance"]?.toDouble(),
        items: json["Items"] == null
            ? []
            : List<MItemQuotation>.from(
                json["Items"]!.map((x) => MItemQuotation.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "Code": code,
        "RequestId": requestId,
        "CustomerId": customerId,
        "PartnerId": partnerId,
        "Description": description,
        "Amount": amount,
        "DiscountPercent": discountPercent,
        "DiscountAmount": discountAmount,
        "VatPercent": vatPercent,
        "VatAmount": vatAmount,
        "Total": total,
        "RequireDeposit": requireDeposit,
        "IsDisPercent": isDisPercent,
        "DepositPercent": depositPercent,
        "DepositAmount": depositAmount,
        "Balance": balance,
        "Items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
      };
}

class MItemQuotation {
  final int? id;
  final String? name;
  final String? nameEnglish;
  final double? unitPrice;
  final String? unitType;
  final double? qty;
  final double? cost;
  final double? discountPer;
  final double? discountAmount;
  final bool? isDisPercent;

  final MDiscount? itemDiscount;
  final bool? selected;
  final double? total;

  MItemQuotation({
    this.id,
    this.name,
    this.nameEnglish,
    this.unitPrice,
    this.unitType,
    this.qty,
    this.cost,
    this.discountAmount,
    this.isDisPercent,
    this.discountPer,
    this.itemDiscount,
    this.selected,
    this.total,
  });

  // from json
  factory MItemQuotation.fromJson(Map<String, dynamic> json) => MItemQuotation(
        id: json["Id"],
        name: json["Name"],
        nameEnglish: json["NameEnglish"],
        unitPrice: json["UnitPrice"],
        unitType: json["UnitType"],
        qty: json["Quantity"],
        cost: json["Amount"],
        total: json["Total"],
        discountPer: json["DiscountPercent"],
        discountAmount: json["DiscountAmount"],
        itemDiscount: (json["DiscountPercentage"] == null ||
                    json["DiscountPercentage"]?.toDouble() == 0) ||
                (json["DiscountAmount"] == null ||
                    json["DiscountAmount"]?.toDouble() == 0)
            ? null
            : MDiscount(
                discount: (json["DiscountPercentage"] != null &&
                        json["DiscountPercentage"]?.toDouble > 0)
                    ? json["DiscountPercentage"]
                    : (json["DiscountAmount"] != null &&
                            json["DiscountAmount"]?.toDouble > 0)
                        ? json["DiscountAmount"]
                        : 0,
                discountBy: (json["DiscountPercentage"] != null &&
                        json["DiscountPercentage"]?.toDouble > 0)
                    ? "P"
                    : (json["DiscountAmount"] != null &&
                            json["DiscountAmount"]?.toDouble > 0)
                        ? "A"
                        : ""),
      );

  // to json
  Map<String, dynamic> toJson() => {
        "Id": id,
        "Name": name,
        "NameEnglish": nameEnglish,
        "UnitPrice": unitPrice,
        "UnitType": unitType,
        "Quantity": qty,
        "Amount": cost,
        "DiscountPercent": discountPer,
        "DiscountAmount": discountAmount,
        "RequireSave": selected,
        "Total": this.total,
        // "ItemDiscount": itemDiscount?.toJson(),
      };

  // copy with
  MItemQuotation copyWith({
    int? id,
    String? name,
    String? nameEnglish,
    double? unitPrice,
    String? unitType,
    double? qty,
    double? cost,
    double? total,
    double? discountPer,
    double? discountAmount,
    MDiscount? itemDiscount,
    bool? isDisPercent,
    bool? selected,
  }) =>
      MItemQuotation(
        id: id ?? this.id,
        name: name ?? this.name,
        nameEnglish: nameEnglish ?? this.nameEnglish,
        unitPrice: unitPrice ?? this.unitPrice,
        unitType: unitType ?? this.unitType,
        total: total ?? this.total,
        qty: qty ?? this.qty,
        cost: cost ?? this.cost,
        discountAmount: discountAmount ?? this.discountAmount,
        discountPer: discountPer ?? this.discountPer,
        itemDiscount: itemDiscount ?? this.itemDiscount,
        isDisPercent: isDisPercent ?? this.isDisPercent,
        selected: selected ?? this.selected,
      );
}

class MQuotationData {
  MQuotationData({
    this.id,
    this.code,
    this.requestId,
    this.partnerId,
    this.partnerName,
    this.partnerNameEnglish,
    this.customerId,
    this.customerCode,
    this.customerName,
    this.customerNameEnglish,
    this.description,
    this.status,
    this.amount,
    this.discountPercent,
    this.discountAmount,
    this.vatPercent,
    this.vatAmount,
    this.total,
    this.requireDeposit,
    this.depositPercent,
    this.depositAmount,
    this.balance,
    this.items,
    this.createdBy,
    this.updatedBy,
    this.createdDate,
    this.updatedDate,
    this.recordCount,
  });

  final int? id;
  final String? code;
  final int? requestId;
  final int? partnerId;
  final String? partnerName;
  final String? partnerNameEnglish;
  final int? customerId;
  final String? customerCode;
  final String? customerName;
  final String? customerNameEnglish;
  final String? description;
  final String? status;
  final double? amount;
  final double? discountPercent;
  final double? discountAmount;
  final double? vatPercent;
  final double? vatAmount;
  final double? total;
  final bool? requireDeposit;
  final double? depositPercent;
  final double? depositAmount;
  final double? balance;
  final List<MItemQuotation>? items;
  final String? createdBy;
  final String? updatedBy;
  final String? createdDate;
  final String? updatedDate;
  final int? recordCount;

  MQuotationData copyWith({
    int? id,
    String? code,
    int? requestId,
    int? partnerId,
    String? partnerName,
    String? partnerNameEnglish,
    int? customerId,
    String? customerCode,
    String? customerName,
    String? customerNameEnglish,
    String? description,
    String? status,
    double? amount,
    double? discountPercent,
    double? discountAmount,
    double? vatPercent,
    double? vatAmount,
    double? total,
    bool? requireDeposit,
    double? depositPercent,
    double? depositAmount,
    double? balance,
    List<MItemQuotation>? items,
    String? createdBy,
    String? updatedBy,
    String? createdDate,
    String? updatedDate,
    int? recordCount,
  }) =>
      MQuotationData(
        id: id ?? this.id,
        code: code ?? this.code,
        requestId: requestId ?? this.requestId,
        partnerId: partnerId ?? this.partnerId,
        partnerName: partnerName ?? this.partnerName,
        partnerNameEnglish: partnerNameEnglish ?? this.partnerNameEnglish,
        customerId: customerId ?? this.customerId,
        customerCode: customerCode ?? this.customerCode,
        customerName: customerName ?? this.customerName,
        customerNameEnglish: customerNameEnglish ?? this.customerNameEnglish,
        description: description ?? this.description,
        status: status ?? this.status,
        amount: amount ?? this.amount,
        discountPercent: discountPercent ?? this.discountPercent,
        discountAmount: discountAmount ?? this.discountAmount,
        vatPercent: vatPercent ?? this.vatPercent,
        vatAmount: vatAmount ?? this.vatAmount,
        total: total ?? this.total,
        requireDeposit: requireDeposit ?? this.requireDeposit,
        depositPercent: depositPercent ?? this.depositPercent,
        depositAmount: depositAmount ?? this.depositAmount,
        balance: balance ?? this.balance,
        items: items ?? this.items,
        createdBy: createdBy ?? this.createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
        createdDate: createdDate ?? this.createdDate,
        updatedDate: updatedDate ?? this.updatedDate,
        recordCount: recordCount ?? this.recordCount,
      );

  factory MQuotationData.fromJson(Map<String, dynamic> json) => MQuotationData(
        id: json["Id"],
        code: json["Code"],
        requestId: json["RequestId"],
        partnerId: json["PartnerId"],
        partnerName: json["PartnerName"],
        partnerNameEnglish: json["PartnerNameEnglish"],
        customerId: json["CustomerId"],
        customerCode: json["CustomerCode"],
        customerName: json["CustomerName"],
        customerNameEnglish: json["CustomerNameEnglish"],
        description: json["Description"],
        status: json["Status"],
        amount: json["Amount"]?.toDouble(),
        discountPercent: json["DiscountPercent"]?.toDouble(),
        discountAmount: json["DiscountAmount"]?.toDouble(),
        vatPercent: json["VatPercent"]?.toDouble(),
        vatAmount: json["VatAmount"]?.toDouble(),
        total: json["Total"]?.toDouble(),
        requireDeposit: json["RequireDeposit"],
        depositPercent: json["DepositPercent"]?.toDouble(),
        depositAmount: json["DepositAmount"]?.toDouble(),
        balance: json["Balance"]?.toDouble(),
        items: json["Items"] == null
            ? []
            : List<MItemQuotation>.from(
                json["Items"]!.map((x) => MItemQuotation.fromJson(x))),
        createdBy: json["CreatedBy"],
        updatedBy: json["UpdatedBy"],
        createdDate: json["CreatedDate"],
        updatedDate: json["UpdatedDate"],
        recordCount: json["RecordCount"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "Code": code,
        "RequestId": requestId,
        "PartnerId": partnerId,
        "PartnerName": partnerName,
        "PartnerNameEnglish": partnerNameEnglish,
        "CustomerId": customerId,
        "CustomerCode": customerCode,
        "CustomerName": customerName,
        "CustomerNameEnglish": customerNameEnglish,
        "Description": description,
        "Status": status,
        "Amount": amount,
        "DiscountPercent": discountPercent,
        "DiscountAmount": discountAmount,
        "VatPercent": vatPercent,
        "VatAmount": vatAmount,
        "Total": total,
        "RequireDeposit": requireDeposit,
        "DepositPercent": depositPercent,
        "DepositAmount": depositAmount,
        "Balance": balance,
        "Items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
        "CreatedBy": createdBy,
        "UpdatedBy": updatedBy,
        "CreatedDate": createdDate,
        "UpdatedDate": updatedDate,
        "RecordCount": recordCount,
      };
}
