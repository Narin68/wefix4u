class MService {
  final int? id;

  final String? code;

  final String? name;

  final String? nameEnglish;

  final String? serviceCateName;

  final String? serviceCateNameEnglish;

  final String? serviceCateCode;

  final String? description;

  final String? descriptionEnglish;

  final String? status;

  final String? imagePath;

  final String? createdBy;

  final String? updatedBy;

  final String? createdDate;

  final String? updatedDate;

  final int? recordCount;

  MService({
    this.id,
    this.code,
    this.name,
    this.nameEnglish,
    this.serviceCateName,
    this.serviceCateNameEnglish,
    this.serviceCateCode,
    this.description,
    this.descriptionEnglish,
    this.status,
    this.imagePath,
    this.createdBy,
    this.updatedBy,
    this.createdDate,
    this.updatedDate,
    this.recordCount,
  });

  // from json
  factory MService.fromJson(Map<String, dynamic> json) => MService(
        id: json["Id"],
        code: json["Code"],
        name: json["Name"],
        nameEnglish: json["NameEnglish"],
        serviceCateName: json["ServiceCateName"],
        serviceCateNameEnglish: json["ServiceCateNameEnglish"],
        serviceCateCode: json["ServiceCateCode"],
        description: json["Description"],
        descriptionEnglish: json["DescriptionEnglish"],
        status: json["Status"],
        imagePath: json["ImagePath"],
        createdBy: json["CreatedBy"],
        updatedBy: json["UpdatedBy"],
        createdDate: json["CreatedDate"],
        updatedDate: json["UpdatedDate"],
        recordCount: json["RecordCount"],
      );

  // to json
  Map<String, dynamic> toJson() => {
        "Id": id,
        "Code": code,
        "Name": name,
        "NameEnglish": nameEnglish,
        "ServiceCateName": serviceCateName,
        "ServiceCateNameEnglish": serviceCateNameEnglish,
        "ServiceCateCode": serviceCateCode,
        "Description": description,
        "DescriptionEnglish": descriptionEnglish,
        "Status": status,
        "ImagePath": imagePath,
        "CreatedBy": createdBy,
        "UpdatedBy": updatedBy,
        "CreatedDate": createdDate,
        "UpdatedDate": updatedDate,
        "RecordCount": recordCount,
      };

  // copy with
  MService copyWith({
    int? id,
    String? code,
    String? name,
    String? nameEnglish,
    String? serviceCateName,
    String? serviceCateNameEnglish,
    String? serviceCateCode,
    String? description,
    String? descriptionEnglish,
    String? status,
    String? imagePath,
    String? createdBy,
    String? updatedBy,
    String? createdDate,
    String? updatedDate,
    int? recordCount,
  }) =>
      MService(
        id: id ?? this.id,
        code: code ?? this.code,
        name: name ?? this.name,
        nameEnglish: nameEnglish ?? this.nameEnglish,
        serviceCateName: serviceCateName ?? this.serviceCateName,
        serviceCateNameEnglish:
            serviceCateNameEnglish ?? this.serviceCateNameEnglish,
        serviceCateCode: serviceCateCode ?? this.serviceCateCode,
        description: description ?? this.description,
        descriptionEnglish: descriptionEnglish ?? this.descriptionEnglish,
        status: status ?? this.status,
        imagePath: imagePath ?? this.imagePath,
        createdBy: createdBy ?? this.createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
        createdDate: createdDate ?? this.createdDate,
        updatedDate: updatedDate ?? this.updatedDate,
        recordCount: recordCount ?? this.recordCount,
      );
}
