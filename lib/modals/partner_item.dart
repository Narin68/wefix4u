class MPartnerServiceItem {
  final int? id;
  final String? name;
  final String? nameEnglish;
  final double? unitPrice;
  final String? unitType;
  final int? partnerId;
  final String? database;
  final String? description;

  MPartnerServiceItem(
      {this.id,
      this.name,
      this.nameEnglish,
      this.unitPrice,
      this.unitType,
      this.partnerId,
      this.database,
      this.description});

  // from json
  factory MPartnerServiceItem.fromJson(Map<String, dynamic> json) =>
      MPartnerServiceItem(
        id: json["Id"],
        name: json["Name"],
        partnerId: json["PartnerId"],
        nameEnglish: json["NameEnglish"],
        unitPrice: json["UnitPrice"],
        unitType: json["UnitType"],
        database: json["Database"],
        description: json["Description"],
      );

  // to json
  Map<String, dynamic> toJson() => {
        "Id": id,
        "Name": name,
        "NameEnglish": nameEnglish,
        "UnitPrice": unitPrice,
        "UnitType": unitType,
        "Description": description,
        "PartnerId": partnerId,
      };

  // copy with
  MPartnerServiceItem copyWith({
    int? id,
    String? name,
    String? nameEnglish,
    double? unitPrice,
    String? unitType,
    int? partnerId,
    String? database,
    String? description,
  }) =>
      MPartnerServiceItem(
        id: id ?? this.id,
        name: name ?? this.name,
        nameEnglish: nameEnglish ?? this.nameEnglish,
        unitPrice: unitPrice ?? this.unitPrice,
        unitType: unitType ?? this.unitType,
        description: description ?? this.description,
        partnerId: partnerId ?? this.partnerId,
        database: database ?? this.database,
      );
}

class MPartnerServiceItemData {
  final int? id;
  final String? name;
  final String? nameEnglish;
  final double? unitPrice;
  final String? unitType;
  final int? partnerId;
  final String? database;
  final String? description;
  final String? createdBy;
  final String? createdDate;
  final String? updatedBy;
  final String? updatedDate;

  MPartnerServiceItemData({
    this.id,
    this.name,
    this.nameEnglish,
    this.unitPrice,
    this.unitType,
    this.partnerId,
    this.database,
    this.description,
    this.createdDate,
    this.createdBy,
    this.updatedDate,
    this.updatedBy,
  });

  // from json
  factory MPartnerServiceItemData.fromJson(Map<String, dynamic> json) =>
      MPartnerServiceItemData(
        id: json["Id"],
        name: json["Name"],
        partnerId: json["PartnerId"],
        nameEnglish: json["NameEnglish"],
        unitPrice: json["UnitPrice"],
        unitType: json["UnitType"],
        description: json["Description"],
        createdBy: json["CreatedBy"],
        createdDate: json["CreatedDate"],
        updatedBy: json["UpdatedBy"],
        updatedDate: json["UpdatedDate"],
      );

  // to json
  Map<String, dynamic> toJson() => {
        "Id": id,
        "Name": name,
        "NameEnglish": nameEnglish,
        "UnitPrice": unitPrice,
        "UnitType": unitType,
        "Description": description,
        "PartnerId": partnerId,
        "CreatedBy": createdBy,
        "CreatedDate": createdDate,
        "UpdatedBy": updatedBy,
        "UpdatedDate": updatedDate,
      };

  // copy with
  MPartnerServiceItemData copyWith({
    int? id,
    String? name,
    String? nameEnglish,
    double? unitPrice,
    String? unitType,
    int? partnerId,
    String? database,
    String? description,
    String? createdBy,
    String? createdDate,
    String? updatedBy,
    String? updatedDate,
  }) =>
      MPartnerServiceItemData(
        id: id ?? this.id,
        name: name ?? this.name,
        nameEnglish: nameEnglish ?? this.nameEnglish,
        unitPrice: unitPrice ?? this.unitPrice,
        unitType: unitType ?? this.unitType,
        description: description ?? this.description,
        partnerId: partnerId ?? this.partnerId,
        database: database ?? this.database,
        createdBy: createdBy ?? this.createdBy,
        createdDate: createdDate ?? this.createdDate,
        updatedBy: updatedBy ?? this.updatedBy,
        updatedDate: updatedDate ?? this.updatedDate,
      );
}
