class MSettlementFilter {
  final int? id;
  final int? refId;
  final int? recordCount;
  final String? refType;
  final String? ruleType;
  final String? routine;
  final String? walletRoutine;
  final double? toPercentage;
  final double? fromPercentage;
  final double? toFee;
  final double? fromFee;
  final int? fromWalletDuration;
  final int? toWalletDuration;

  MSettlementFilter({
    this.id,
    this.refId,
    this.recordCount,
    this.refType,
    this.routine,
    this.ruleType,
    this.walletRoutine,
    this.toPercentage,
    this.fromPercentage,
    this.toFee,
    this.fromFee,
    this.fromWalletDuration,
    this.toWalletDuration,
  });

  // from json
  factory MSettlementFilter.fromJson(Map<String, dynamic> json) =>
      MSettlementFilter(
        id: json["Id"],
        refId: json["RefId"],
        recordCount: json["RecordCount"],
        refType: json["RefType"],
        ruleType: json["RuleType"],
        routine: json["Routine"],
        walletRoutine: json["WalletRoutine"],
        toPercentage: json["ToPercentage"],
        fromPercentage: json["FromPercentage"],
        fromWalletDuration: json["FromWalletDuration"],
        toWalletDuration: json["ToWalletDuration"],
      );

  // to json
  Map<String, dynamic> toJson() => {
        "Id": id,
        "RefId": refId,
        "RecordCount": recordCount,
        "RefType": refType,
        "RuleType": ruleType,
        "Routine": routine,
        "WalletRoutine": walletRoutine,
        "ToPercentage": toPercentage,
        "FromPercentage": fromPercentage,
        "FromWalletDuration": fromWalletDuration,
        "FromFee": fromFee,
        "ToFee": toFee,
        "ToWalletDuration": toWalletDuration,
      };

  // copy with
  MSettlementFilter copyWith({
    int? id,
    int? refId,
    int? recordCount,
    String? refType,
    String? ruleType,
    String? routine,
    String? walletRoutine,
    double? toPercentage,
    double? fromPercentage,
    double? toFee,
    double? fromFee,
    int? fromWalletDuration,
    int? toWalletDuration,
  }) =>
      MSettlementFilter(
        id: id ?? this.id,
        refId: refId ?? this.refId,
        recordCount: recordCount ?? this.recordCount,
        refType: refType ?? this.refType,
        ruleType: ruleType ?? this.ruleType,
        routine: routine ?? this.routine,
        walletRoutine: walletRoutine ?? this.walletRoutine,
        toPercentage: toPercentage ?? this.toPercentage,
        fromPercentage: fromPercentage ?? this.fromPercentage,
        toFee: toFee ?? this.toFee,
        fromFee: fromFee ?? this.fromFee,
        fromWalletDuration: fromWalletDuration ?? this.fromWalletDuration,
        toWalletDuration: toWalletDuration ?? this.toWalletDuration,
      );
}

class MSettlementData {
  final int? id;
  final int? refId;
  final String? refType;
  final String? ruleType;
  final String? createdDate;
  final String? createdBy;
  final String? updatedDate;
  final int? recordCount;
  final double? percentage;
  final String? routine;
  final String? walletRoutine;
  final double? walletDuration;

  MSettlementData({
    this.id,
    this.refId,
    this.refType,
    this.ruleType,
    this.createdDate,
    this.createdBy,
    this.updatedDate,
    this.recordCount,
    this.percentage,
    this.routine,
    this.walletRoutine,
    this.walletDuration,
  });

  // from json
  factory MSettlementData.fromJson(Map<String, dynamic> json) =>
      MSettlementData(
        id: json["Id"],
        refId: json["RefId"],
        refType: json["RefType"],
        ruleType: json["RuleType"],
        createdDate: json["CreatedDate"],
        createdBy: json["CreatedBy"],
        updatedDate: json["UpdatedDate"],
        recordCount: json["RecordCount"],
        percentage: json["Percentage"].toDouble(),
        routine: json["Routine"],
        walletRoutine: json["WalletRoutine"],
        walletDuration: json["WalletDuration"].toDouble(),
      );

  // to json
  Map<String, dynamic> toJson() => {
        "Id": id,
        "RefId": refId,
        "RefType": refType,
        "RuleType": ruleType,
        "CreatedDate": createdDate,
        "CreatedBy": createdBy,
        "UpdatedDate": updatedDate,
        "RecordCount": recordCount,
        "Percentage": percentage,
        "Routine": routine,
        "WalletRoutine": walletRoutine,
        "WalletDuration": walletDuration,
      };

  // copy with
  MSettlementData copyWith({
    int? id,
    int? refId,
    String? refType,
    String? ruleType,
    String? createdDate,
    String? createdBy,
    String? updatedDate,
    int? recordCount,
    double? percentage,
    String? routine,
    String? walletRoutine,
    double? walletDuration,
  }) =>
      MSettlementData(
        id: id ?? this.id,
        refId: refId ?? this.refId,
        refType: refType ?? this.refType,
        ruleType: ruleType ?? this.ruleType,
        createdDate: createdDate ?? this.createdDate,
        createdBy: createdBy ?? this.createdBy,
        updatedDate: updatedDate ?? this.updatedDate,
        recordCount: recordCount ?? this.recordCount,
        percentage: percentage ?? this.percentage,
        routine: routine ?? this.routine,
        walletRoutine: walletRoutine ?? this.walletRoutine,
        walletDuration: walletDuration ?? this.walletDuration,
      );
}
