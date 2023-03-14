class MInvoiceData {
  MInvoiceData({
    this.id,
    this.code,
    this.description,
    this.status,
    this.amount,
    this.discountPercent,
    this.discountAmount,
    this.vatPercent,
    this.vatAmount,
    this.total,
    this.depositPercent,
    this.depositAmount,
    this.balance,
    this.discountCode,
    this.discountType,
    this.invoiceType,
    this.paymentDescription,
    this.paidDate,
    this.requestId,
    this.requestCode,
    this.quotationId,
    this.quotationCode,
    this.customerId,
    this.customerCode,
    this.customerName,
    this.customerNameEnglish,
    this.customerPhone,
    this.customerAddress,
    this.customerAddressEnglish,
    this.partnerId,
    this.partnerCode,
    this.partnerName,
    this.partnerNameEnglish,
    this.partnerPhone,
    this.partnerAddress,
    this.partnerAddressEnglish,
    this.items,
    this.createdBy,
    this.updatedBy,
    this.createdDate,
    this.updatedDate,
    this.recordCount,
  });

  final int? id;
  final String? code;
  final String? description;
  final String? status;
  final double? amount;
  final double? discountPercent;
  final double? discountAmount;
  final double? vatPercent;
  final double? vatAmount;
  final double? total;
  final double? depositPercent;
  final double? depositAmount;
  final double? balance;
  final String? discountCode;
  final String? discountType;
  final String? invoiceType;
  final String? paymentDescription;
  final String? paidDate;
  final int? requestId;
  final String? requestCode;
  final int? quotationId;
  final String? quotationCode;
  final int? customerId;
  final String? customerCode;
  final String? customerName;
  final String? customerNameEnglish;
  final String? customerPhone;
  final String? customerAddress;
  final String? customerAddressEnglish;
  final int? partnerId;
  final String? partnerCode;
  final String? partnerName;
  final String? partnerNameEnglish;
  final String? partnerPhone;
  final String? partnerAddress;
  final String? partnerAddressEnglish;
  final List<MInvoiceItem>? items;
  final String? createdBy;
  final String? updatedBy;
  final String? createdDate;
  final String? updatedDate;
  final int? recordCount;

  MInvoiceData copyWith({
    int? id,
    String? code,
    String? description,
    String? status,
    double? amount,
    double? discountPercent,
    double? discountAmount,
    double? vatPercent,
    double? vatAmount,
    double? total,
    double? depositPercent,
    double? depositAmount,
    double? balance,
    String? discountCode,
    String? discountType,
    String? invoiceType,
    String? paymentDescription,
    String? paidDate,
    int? requestId,
    String? requestCode,
    int? quotationId,
    String? quotationCode,
    int? customerId,
    String? customerCode,
    String? customerName,
    String? customerNameEnglish,
    String? customerPhone,
    String? customerAddress,
    String? customerAddressEnglish,
    int? partnerId,
    String? partnerCode,
    String? partnerName,
    String? partnerNameEnglish,
    String? partnerPhone,
    String? partnerAddress,
    String? partnerAddressEnglish,
    List<MInvoiceItem>? items,
    String? createdBy,
    String? updatedBy,
    String? createdDate,
    String? updatedDate,
    int? recordCount,
  }) =>
      MInvoiceData(
        id: id ?? this.id,
        code: code ?? this.code,
        description: description ?? this.description,
        status: status ?? this.status,
        amount: amount ?? this.amount,
        discountPercent: discountPercent ?? this.discountPercent,
        discountAmount: discountAmount ?? this.discountAmount,
        vatPercent: vatPercent ?? this.vatPercent,
        vatAmount: vatAmount ?? this.vatAmount,
        total: total ?? this.total,
        depositPercent: depositPercent ?? this.depositPercent,
        depositAmount: depositAmount ?? this.depositAmount,
        balance: balance ?? this.balance,
        discountCode: discountCode ?? this.discountCode,
        discountType: discountType ?? this.discountType,
        invoiceType: invoiceType ?? this.invoiceType,
        paymentDescription: paymentDescription ?? this.paymentDescription,
        paidDate: paidDate ?? this.paidDate,
        requestId: requestId ?? this.requestId,
        requestCode: requestCode ?? this.requestCode,
        quotationId: quotationId ?? this.quotationId,
        quotationCode: quotationCode ?? this.quotationCode,
        customerId: customerId ?? this.customerId,
        customerCode: customerCode ?? this.customerCode,
        customerName: customerName ?? this.customerName,
        customerNameEnglish: customerNameEnglish ?? this.customerNameEnglish,
        customerPhone: customerPhone ?? this.customerPhone,
        customerAddress: customerAddress ?? this.customerAddress,
        customerAddressEnglish:
            customerAddressEnglish ?? this.customerAddressEnglish,
        partnerId: partnerId ?? this.partnerId,
        partnerCode: partnerCode ?? this.partnerCode,
        partnerName: partnerName ?? this.partnerName,
        partnerNameEnglish: partnerNameEnglish ?? this.partnerNameEnglish,
        partnerPhone: partnerPhone ?? this.partnerPhone,
        partnerAddress: partnerAddress ?? this.partnerAddress,
        partnerAddressEnglish:
            partnerAddressEnglish ?? this.partnerAddressEnglish,
        items: items ?? this.items,
        createdBy: createdBy ?? this.createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
        createdDate: createdDate ?? this.createdDate,
        updatedDate: updatedDate ?? this.updatedDate,
        recordCount: recordCount ?? this.recordCount,
      );

  factory MInvoiceData.fromJson(Map<String, dynamic> json) => MInvoiceData(
        id: json["Id"],
        code: json["Code"],
        description: json["Description"],
        status: json["Status"],
        amount: json["Amount"]?.toDouble(),
        discountPercent: json["DiscountPercent"]?.toDouble(),
        discountAmount: json["DiscountAmount"]?.toDouble(),
        vatPercent: json["VATPercent"]?.toDouble(),
        vatAmount: json["VATAmount"]?.toDouble(),
        total: json["Total"]?.toDouble(),
        depositPercent: json["DepositPercent"]?.toDouble(),
        depositAmount: json["DepositAmount"]?.toDouble(),
        balance: json["Balance"]?.toDouble(),
        discountCode: json["DiscountCode"],
        discountType: json["DiscountType"],
        invoiceType: json["InvoiceType"],
        paymentDescription: json["PaymentDescription"],
        paidDate: json["PAID_DATE"],
        requestId: json["RequestId"],
        requestCode: json["RequestCode"],
        quotationId: json["QuotationId"],
        quotationCode: json["QuotationCode"],
        customerId: json["CustomerId"],
        customerCode: json["CustomerCode"],
        customerName: json["CustomerName"],
        customerNameEnglish: json["CustomerNameEnglish"],
        customerPhone: json["CustomerPhone"],
        customerAddress: json["CustomerAddress"],
        customerAddressEnglish: json["CustomerAddressEnglish"],
        partnerId: json["PartnerId"],
        partnerCode: json["PartnerCode"],
        partnerName: json["PartnerName"],
        partnerNameEnglish: json["PartnerNameEnglish"],
        partnerPhone: json["PartnerPhone"],
        partnerAddress: json["PartnerAddress"],
        partnerAddressEnglish: json["PartnerAddressEnglish"],
        items: json["Items"] == null
            ? []
            : List<MInvoiceItem>.from(
                json["Items"]!.map((x) => MInvoiceItem.fromJson(x))),
        createdBy: json["CreatedBy"],
        updatedBy: json["UpdatedBy"],
        createdDate: json["CreatedDate"],
        updatedDate: json["UpdatedDate"],
        recordCount: json["RecordCount"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "Code": code,
        "Description": description,
        "Status": status,
        "Amount": amount,
        "DiscountPercent": discountPercent,
        "DiscountAmount": discountAmount,
        "VATPercent": vatPercent,
        "VATAmount": vatAmount,
        "Total": total,
        "DepositPercent": depositPercent,
        "DepositAmount": depositAmount,
        "Balance": balance,
        "DiscountCode": discountCode,
        "DiscountType": discountType,
        "InvoiceType": invoiceType,
        "PaymentDescription": paymentDescription,
        "PAID_DATE": paidDate,
        "RequestId": requestId,
        "RequestCode": requestCode,
        "QuotationId": quotationId,
        "QuotationCode": quotationCode,
        "CustomerId": customerId,
        "CustomerCode": customerCode,
        "CustomerName": customerName,
        "CustomerNameEnglish": customerNameEnglish,
        "CustomerPhone": customerPhone,
        "CustomerAddress": customerAddress,
        "CustomerAddressEnglish": customerAddressEnglish,
        "PartnerId": partnerId,
        "PartnerCode": partnerCode,
        "PartnerName": partnerName,
        "PartnerNameEnglish": partnerNameEnglish,
        "PartnerPhone": partnerPhone,
        "PartnerAddress": partnerAddress,
        "PartnerAddressEnglish": partnerAddressEnglish,
        "Items": items == null ? [] : List<dynamic>.from(items!.map((x) => x)),
        "CreatedBy": createdBy,
        "UpdatedBy": updatedBy,
        "CreatedDate": createdDate,
        "UpdatedDate": updatedDate,
        "RecordCount": recordCount,
      };
}

class MInvoiceItem {
  MInvoiceItem({
    this.id,
    this.itemId,
    this.itemName,
    this.itemNameEnglish,
    this.unitType,
    this.quantity,
    this.price,
    this.amount,
    this.discountPercent,
    this.discountAmount,
    this.total,
  });

  final int? id;
  final int? itemId;
  final String? itemName;
  final String? itemNameEnglish;
  final String? unitType;
  final double? quantity;
  final double? price;
  final double? amount;
  final double? discountPercent;
  final double? discountAmount;
  final double? total;

  MInvoiceItem copyWith({
    int? id,
    int? itemId,
    String? itemName,
    String? itemNameEnglish,
    String? unitType,
    double? quantity,
    double? price,
    double? amount,
    double? discountPercent,
    double? discountAmount,
    double? total,
  }) =>
      MInvoiceItem(
        id: id ?? this.id,
        itemId: itemId ?? this.itemId,
        itemName: itemName ?? this.itemName,
        itemNameEnglish: itemNameEnglish ?? this.itemNameEnglish,
        unitType: unitType ?? this.unitType,
        quantity: quantity ?? this.quantity,
        price: price ?? this.price,
        amount: amount ?? this.amount,
        discountPercent: discountPercent ?? this.discountPercent,
        discountAmount: discountAmount ?? this.discountAmount,
        total: total ?? this.total,
      );

  factory MInvoiceItem.fromJson(Map<String, dynamic> json) => MInvoiceItem(
        id: json["Id"],
        itemId: json["ItemId"],
        itemName: json["ItemName"],
        itemNameEnglish: json["ItemNameEnglish"],
        unitType: json["UnitType"],
        quantity: json["Quantity"]?.toDouble(),
        price: json["Price"]?.toDouble(),
        amount: json["Amount"]?.toDouble(),
        discountPercent: json["DiscountPercent"]?.toDouble(),
        discountAmount: json["DiscountAmount"]?.toDouble(),
        total: json["Total"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "ItemId": itemId,
        "ItemName": itemName,
        "ItemNameEnglish": itemNameEnglish,
        "UnitType": unitType,
        "Quantity": quantity,
        "Price": price,
        "Amount": amount,
        "DiscountPercent": discountPercent,
        "DiscountAmount": discountAmount,
        "Total": total,
      };
}
