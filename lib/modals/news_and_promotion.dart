class MNewsAndPromotionFilter {
  final int? id;
  final bool? posting;
  final int? pages;
  final int? records;
  final String? orderDir;
  final String? orderBy;

  MNewsAndPromotionFilter({
    this.id,
    this.posting,
    this.pages,
    this.records,
    this.orderDir,
    this.orderBy,
  });

  // from json
  factory MNewsAndPromotionFilter.fromJson(Map<String, dynamic> json) =>
      MNewsAndPromotionFilter(
        id: json["Id"],
        posting: json["Posting"],
        pages: json["Pages"],
        records: json["Records"],
        orderDir: json["OrderDir"],
        orderBy: json["OrderBy"],
      );

  // to json
  Map<String, dynamic> toJson() => {
        "Id": id,
        "Posting": posting,
        "Pages": pages,
        "Records": records,
        "OrderDir": orderDir,
        "OrderBy": orderBy,
      };

  // copy with
  MNewsAndPromotionFilter copyWith({
    int? id,
    bool? posting,
    int? pages,
    int? records,
    String? orderDir,
    String? orderBy,
  }) =>
      MNewsAndPromotionFilter(
        id: id ?? this.id,
        posting: posting ?? this.posting,
        pages: pages ?? this.pages,
        records: records ?? this.records,
        orderDir: orderDir ?? this.orderDir,
        orderBy: orderBy ?? this.orderBy,
      );
}

class MNewsAndPromotion {
  final int? id;
  final String? title;
  final String? content;
  final String? image;
  final int? imageId;
  final bool? posting;
  final String? createdBy;
  final String? updatedBy;
  final String? createdDate;
  final String? updatedDate;
  final int? recordCount;

  MNewsAndPromotion({
    this.id,
    this.title,
    this.content,
    this.image,
    this.imageId,
    this.posting,
    this.createdBy,
    this.updatedBy,
    this.createdDate,
    this.updatedDate,
    this.recordCount,
  });

  // from json
  factory MNewsAndPromotion.fromJson(Map<String, dynamic> json) =>
      MNewsAndPromotion(
        id: json["Id"],
        title: json["Title"],
        content: json["Content"],
        image: json["Image"],
        imageId: json["ImageId"],
        posting: json["Posting"],
        createdBy: json["CreatedBy"],
        updatedBy: json["UpdatedBy"],
        createdDate: json["CreatedDate"],
        updatedDate: json["UpdatedDate"],
        recordCount: json["RecordCount"],
      );

  // to json
  Map<String, dynamic> toJson() => {
        "Id": id,
        "Title": title,
        "Content": content,
        "Image": image,
        "ImageId": imageId,
        "Posting": posting,
        "CreatedBy": createdBy,
        "UpdatedBy": updatedBy,
        "CreatedDate": createdDate,
        "UpdatedDate": updatedDate,
        "RecordCount": recordCount,
      };

  // copy with
  MNewsAndPromotion copyWith({
    int? id,
    String? title,
    String? content,
    String? image,
    int? imageId,
    bool? posting,
    String? createdBy,
    String? updatedBy,
    String? createdDate,
    String? updatedDate,
    int? recordCount,
  }) =>
      MNewsAndPromotion(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        image: image ?? this.image,
        imageId: imageId ?? this.imageId,
        posting: posting ?? this.posting,
        createdBy: createdBy ?? this.createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
        createdDate: createdDate ?? this.createdDate,
        updatedDate: updatedDate ?? this.updatedDate,
        recordCount: recordCount ?? this.recordCount,
      );
}
