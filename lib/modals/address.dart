class MAddress {
  MAddress({
    this.id,
    this.code,
    this.name,
    this.nameEnglish,
    this.description,
    this.status,
    this.referenceId,
    this.type,
    this.database,
    this.createdBy,
    this.updatedBy,
    this.createdDate,
    this.updatedDate,
    this.recordCount,
    this.selected,
    this.someSelected,
  });

  final int? id;
  final String? code;
  final String? name;
  final String? nameEnglish;
  final String? description;
  final String? status;
  final int? referenceId;
  final String? type;
  final String? database;
  final String? createdBy;
  final String? updatedBy;
  final String? createdDate;
  final String? updatedDate;
  final int? recordCount;
  final bool? selected;
  final bool? someSelected;

  MAddress copyWith({
    int? id,
    String? code,
    String? name,
    String? nameEnglish,
    String? description,
    String? status,
    int? referenceId,
    String? type,
    String? database,
    String? createdBy,
    String? updatedBy,
    String? createdDate,
    String? updatedDate,
    int? recordCount,
    bool? selected,
    bool? someSelected,
  }) =>
      MAddress(
        id: id ?? this.id,
        code: code ?? this.code,
        name: name ?? this.name,
        nameEnglish: nameEnglish ?? this.nameEnglish,
        description: description ?? this.description,
        status: status ?? this.status,
        referenceId: referenceId ?? this.referenceId,
        type: type ?? this.type,
        database: database ?? this.database,
        createdBy: createdBy ?? this.createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
        createdDate: createdDate ?? this.createdDate,
        updatedDate: updatedDate ?? this.updatedDate,
        recordCount: recordCount ?? this.recordCount,
        selected: selected ?? this.selected,
        someSelected: someSelected ?? this.someSelected,
      );

  factory MAddress.fromJson(Map<String, dynamic> json) => MAddress(
        id: json["Id"],
        code: json["Code"],
        name: json["Name"],
        nameEnglish: json["NameEnglish"],
        description: json["Description"],
        status: json["Status"],
        referenceId: json["ReferenceId"],
        type: json["Type"],
        database: json["Database"],
        createdBy: json["CreatedBy"],
        updatedBy: json["UpdatedBy"],
        createdDate: json["CreatedDate"],
        updatedDate: json["UpdatedDate"],
        recordCount: json["RecordCount"],
        selected: false,
        someSelected: false,
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "Code": code,
        "Name": name,
        "NameEnglish": nameEnglish,
        "Description": description,
        "Status": status,
        "ReferenceId": referenceId,
        "Type": type,
        "Database": database,
        "CreatedBy": createdBy,
        "UpdatedBy": updatedBy,
        "CreatedDate": createdDate,
        "UpdatedDate": updatedDate,
        "RecordCount": recordCount,
        "Selected": selected,
        "SomeSelected": someSelected,
      };
}
