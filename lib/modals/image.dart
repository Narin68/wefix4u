class MImage {
  final int? id;
  final String? path;
  final String? fullPath;
  final String? name;
  final String? extension;
  final String? description;
  final String? type;
  final String? referenceType;
  final int? referenceId;
  final String? referenceCode;
  final String? createdBy;
  final String? createdDate;
  final String? updatedBy;
  final String? updatedDate;

  MImage({
    this.id,
    this.path,
    this.fullPath,
    this.name,
    this.extension,
    this.description,
    this.type,
    this.referenceType,
    this.referenceId,
    this.referenceCode,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
  });

  // from json
  factory MImage.fromJson(Map<String, dynamic> json) => MImage(
        id: json["Id"],
        path: json["Path"],
        fullPath: json["FullPath"],
        name: json["Name"],
        extension: json["Extension"],
        description: json["Description"],
        type: json["Type"],
        referenceType: json["ReferenceType"],
        referenceId: json["ReferenceId"],
        referenceCode: json["ReferenceCode"],
        createdBy: json["CreatedBy"],
        createdDate: json["CreatedDate"],
        updatedBy: json["UpdatedBy"],
        updatedDate: json["UpdatedDate"],
      );

  // to json
  Map<String, dynamic> toJson() => {
        "Id": id,
        "Path": path,
        "FullPath": fullPath,
        "Name": name,
        "Extension": extension,
        "Description": description,
        "Type": type,
        "ReferenceType": referenceType,
        "ReferenceId": referenceId,
        "ReferenceCode": referenceCode,
        "CreatedBy": createdBy,
        "CreatedDate": createdDate,
        "UpdatedBy": updatedBy,
        "UpdatedDate": updatedDate,
      };

  // copy with
  MImage copyWith({
    int? id,
    String? path,
    String? fullPath,
    String? name,
    String? extension,
    String? description,
    String? type,
    String? referenceType,
    int? referenceId,
    String? referenceCode,
    String? createdBy,
    String? createdDate,
    String? updatedBy,
    String? updatedDate,
  }) =>
      MImage(
        id: id ?? this.id,
        path: path ?? this.path,
        fullPath: fullPath ?? this.fullPath,
        name: name ?? this.name,
        extension: extension ?? this.extension,
        description: description ?? this.description,
        type: type ?? this.type,
        referenceType: referenceType ?? this.referenceType,
        referenceId: referenceId ?? this.referenceId,
        referenceCode: referenceCode ?? this.referenceCode,
        createdBy: createdBy ?? this.createdBy,
        createdDate: createdDate ?? this.createdDate,
        updatedBy: updatedBy ?? this.updatedBy,
        updatedDate: updatedDate ?? this.updatedDate,
      );
}
