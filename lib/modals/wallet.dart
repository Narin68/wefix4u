class MWalletData {
  final int? id;
  final String? code;
  final String? owner;
  final String? ownerType;
  final double? balance;
  final double? earning;
  final double? pending;
  final String? status;
  final String? bankAccount;
  final String? accountName;
  final String? bankName;
  final String? description;

  MWalletData({
    this.id,
    this.code,
    this.owner,
    this.ownerType,
    this.balance,
    this.earning,
    this.status,
    this.bankName,
    this.accountName,
    this.bankAccount,
    this.description,
    this.pending,
  });

  // from json
  factory MWalletData.fromJson(Map<String, dynamic> json) => MWalletData(
        id: json["Id"],
        code: json["Code"],
        owner: json["Owner"],
        ownerType: json["OwnerType"],
        balance: json["Balance"] == null ? 0 : json["Balance"].toDouble(),
        pending: json["Pending"] == null ? 0 : json["Pending"].toDouble(),
        bankAccount: json["BankAccount"],
        accountName: json["BankAccountName"],
        bankName: json["BankName"],
        description: json["Description"],
        earning: json["Earning"] == null ? 0 : json["Earning"].toDouble(),
        status: json["Status"],
      );

  // to json
  Map<String, dynamic> toJson() => {
        "Id": id,
        "Code": code,
        "Owner": owner,
        "OwnerType": ownerType,
        "Balance": balance,
        "Pending": pending,
        "BankAccount": bankAccount,
        "BankAccountName": accountName,
        "BankName": bankName,
        "Description": description,
        "Earning": earning,
        "Status": status,
      };

  // copy with
  MWalletData copyWith({
    int? id,
    String? code,
    String? owner,
    String? ownerType,
    double? balance,
    double? pending,
    double? earning,
    String? status,
    String? bankAccount,
    String? accountName,
    String? bankName,
    String? description,
  }) =>
      MWalletData(
        id: id ?? this.id,
        code: code ?? this.code,
        owner: owner ?? this.owner,
        ownerType: ownerType ?? this.ownerType,
        balance: balance ?? this.balance,
        pending: pending ?? this.pending,
        bankAccount: bankAccount ?? this.bankAccount,
        accountName: accountName ?? this.accountName,
        bankName: bankName ?? this.bankName,
        description: description ?? this.description,
        earning: earning ?? this.earning,
        status: status ?? this.status,
      );
}
