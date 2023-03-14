class MWalletTransactionData {
  MWalletTransactionData({
    this.walletId,
    this.walletCode,
    this.walletOwnerId,
    this.walletOwner,
    this.walletOwnerType,
    this.bankAccount,
    this.bankName,
    this.bankAccountName,
    this.walletStatus,
    this.earning,
    this.balance,
    this.id,
    this.invoiceCode,
    this.code,
    this.requestCode,
    this.transactionType,
    this.description,
    this.approveDescription,
    this.amount,
    this.attachmentUrl,
    this.refId,
    this.status,
    this.createdBy,
    this.updatedBy,
    this.createdDate,
    this.updatedDate,
    this.recordCount,
  });

  final int? walletId;
  final String? walletCode;
  final int? walletOwnerId;
  final String? walletOwner;
  final String? walletOwnerType;
  final String? bankAccount;
  final String? bankName;
  final String? bankAccountName;
  final String? walletStatus;
  final double? earning;
  final double? balance;
  final int? id;
  final String? invoiceCode;
  final String? code;
  final String? requestCode;
  final String? transactionType;
  final String? description;
  final String? approveDescription;
  final double? amount;
  final String? attachmentUrl;
  final int? refId;
  final String? status;
  final String? createdBy;
  final String? updatedBy;
  final String? createdDate;
  final dynamic updatedDate;
  final int? recordCount;

  MWalletTransactionData copyWith({
    int? walletId,
    String? walletCode,
    int? walletOwnerId,
    String? walletOwner,
    String? walletOwnerType,
    String? bankAccount,
    String? bankName,
    String? bankAccountName,
    String? walletStatus,
    double? earning,
    double? balance,
    int? id,
    String? invoiceCode,
    String? code,
    String? requestCode,
    String? transactionType,
    String? description,
    String? approveDescription,
    double? amount,
    String? attachmentUrl,
    int? refId,
    String? status,
    String? createdBy,
    String? updatedBy,
    String? createdDate,
    dynamic updatedDate,
    int? recordCount,
  }) =>
      MWalletTransactionData(
        walletId: walletId ?? this.walletId,
        walletCode: walletCode ?? this.walletCode,
        walletOwnerId: walletOwnerId ?? this.walletOwnerId,
        walletOwner: walletOwner ?? this.walletOwner,
        walletOwnerType: walletOwnerType ?? this.walletOwnerType,
        bankAccount: bankAccount ?? this.bankAccount,
        bankName: bankName ?? this.bankName,
        bankAccountName: bankAccountName ?? this.bankAccountName,
        walletStatus: walletStatus ?? this.walletStatus,
        earning: earning ?? this.earning,
        balance: balance ?? this.balance,
        id: id ?? this.id,
        invoiceCode: invoiceCode ?? this.invoiceCode,
        code: code ?? this.code,
        requestCode: requestCode ?? this.requestCode,
        transactionType: transactionType ?? this.transactionType,
        description: description ?? this.description,
        approveDescription: approveDescription ?? this.approveDescription,
        amount: amount ?? this.amount,
        attachmentUrl: attachmentUrl ?? this.attachmentUrl,
        refId: refId ?? this.refId,
        status: status ?? this.status,
        createdBy: createdBy ?? this.createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
        createdDate: createdDate ?? this.createdDate,
        updatedDate: updatedDate ?? this.updatedDate,
        recordCount: recordCount ?? this.recordCount,
      );

  factory MWalletTransactionData.fromJson(Map<String, dynamic> json) =>
      MWalletTransactionData(
        walletId: json["WalletId"],
        walletCode: json["WalletCode"],
        walletOwnerId: json["WalletOwnerId"],
        walletOwner: json["WalletOwner"],
        walletOwnerType: json["WalletOwnerType"],
        bankAccount: json["BankAccount"],
        bankName: json["BankName"],
        bankAccountName: json["BankAccountName"],
        walletStatus: json["WalletStatus"],
        earning: json["Earning"]?.toDouble(),
        balance: json["Balance"]?.toDouble(),
        id: json["Id"],
        invoiceCode: json["InvoiceCode"],
        code: json["Code"],
        requestCode: json["RequestCode"],
        transactionType: json["TransactionType"],
        description: json["Description"],
        approveDescription: json["ApproveDescription"],
        amount: json["Amount"]?.toDouble(),
        attachmentUrl: json["AttachmentUrl"],
        refId: json["RefId"],
        status: json["Status"],
        createdBy: json["CreatedBy"],
        updatedBy: json["UpdatedBy"],
        createdDate: json["CreatedDate"],
        updatedDate: json["UpdatedDate"],
        recordCount: json["RecordCount"],
      );

  Map<String, dynamic> toJson() => {
        "WalletId": walletId,
        "WalletCode": walletCode,
        "WalletOwnerId": walletOwnerId,
        "WalletOwner": walletOwner,
        "WalletOwnerType": walletOwnerType,
        "BankAccount": bankAccount,
        "BankName": bankName,
        "BankAccountName": bankAccountName,
        "WalletStatus": walletStatus,
        "Earning": earning,
        "Balance": balance,
        "Id": id,
        "InvoiceCode": invoiceCode,
        "Code": code,
        "RequestCode": requestCode,
        "TransactionType": transactionType,
        "Description": description,
        "ApproveDescription": approveDescription,
        "Amount": amount,
        "AttachmentUrl": attachmentUrl,
        "RefId": refId,
        "Status": status,
        "CreatedBy": createdBy,
        "UpdatedBy": updatedBy,
        "CreatedDate": createdDate,
        "UpdatedDate": updatedDate,
        "RecordCount": recordCount,
      };
}
