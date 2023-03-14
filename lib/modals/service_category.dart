import 'dart:convert';

class MServiceCate {
  final int? id;
  final String? code;
  final String? name;
  final String? nameEnglish;
  final String? description;
  final String? descriptionEnglish;
  final String? status;
  final int? imageId;
  final String? imagePath;
  final String? createdBy;
  final String? updatedBy;
  final String? createdDate;
  final String? updatedDate;
  final int? recordCount;
  final bool? select;

  MServiceCate({
    this.id,
    this.code,
    this.name,
    this.nameEnglish,
    this.description,
    this.descriptionEnglish,
    this.status,
    this.imageId,
    this.imagePath,
    this.createdBy,
    this.updatedBy,
    this.createdDate,
    this.updatedDate,
    this.recordCount,
    this.select = false,
  });

  // from json
  factory MServiceCate.fromJson(Map<String, dynamic> json) => MServiceCate(
        id: json["Id"],
        code: json["Code"],
        name: json["Name"],
        nameEnglish: json["NameEnglish"],
        description: json["Description"],
        descriptionEnglish: json["DescriptionEnglish"],
        status: json["Status"],
        imageId: json["ImageId"],
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
        "Description": description,
        "DescriptionEnglish": descriptionEnglish,
        "Status": status,
        "ImageId": imageId,
        "ImagePath": imagePath,
        "CreatedBy": createdBy,
        "UpdatedBy": updatedBy,
        "CreatedDate": createdDate,
        "UpdatedDate": updatedDate,
        "RecordCount": recordCount,
      };

  // copy with
  MServiceCate copyWith({
    int? id,
    String? code,
    String? name,
    String? nameEnglish,
    String? description,
    String? descriptionEnglish,
    String? status,
    int? imageId,
    String? imagePath,
    String? createdBy,
    String? updatedBy,
    String? createdDate,
    String? updatedDate,
    int? recordCount,
    bool? select,
  }) =>
      MServiceCate(
        id: id ?? this.id,
        code: code ?? this.code,
        name: name ?? this.name,
        nameEnglish: nameEnglish ?? this.nameEnglish,
        description: description ?? this.description,
        descriptionEnglish: descriptionEnglish ?? this.descriptionEnglish,
        status: status ?? this.status,
        imageId: imageId ?? this.imageId,
        imagePath: imagePath ?? this.imagePath,
        createdBy: createdBy ?? this.createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
        createdDate: createdDate ?? this.createdDate,
        updatedDate: updatedDate ?? this.updatedDate,
        recordCount: recordCount ?? this.recordCount,
        select: select ?? this.select,
      );

  static Map<String, dynamic> toMap(MServiceCate data) => {
        "Id": data.id,
        "Code": data.code,
        "Name": data.name,
        "NameEnglish": data.nameEnglish,
        "Description": data.description,
        "DescriptionEnglish": data.descriptionEnglish,
        "Status": data.status,
        "ImageId": data.imageId,
        "ImagePath": data.imagePath,
        "CreatedBy": data.createdBy,
        "UpdatedBy": data.updatedBy,
        "CreatedDate": data.createdDate,
        "UpdatedDate": data.updatedDate,
        "RecordCount": data.recordCount,
      };

  static String encode(List<MServiceCate> data) => json.encode(
        data.map<Map<String, dynamic>>((e) => MServiceCate.toMap(e)).toList(),
      );

  static List<MServiceCate> decode(String musics) =>
      (json.decode(musics) as List<dynamic>)
          .map<MServiceCate>((item) => MServiceCate.fromJson(item))
          .toList();
}
