class MBusinessRequestList {
  final int? refId;
  final String? status;
  final String? reason;
  final int? id;
  final String? createdDate;
  final MPartnerRequestInfo? createdBy;
  final String? updatedDate;
  final dynamic addedServices;
  final dynamic removedServices;
  final dynamic addedCoverages;
  final dynamic removedCoverages;

  MBusinessRequestList({
    this.refId,
    this.status,
    this.reason,
    this.id,
    this.createdDate,
    this.createdBy,
    this.updatedDate,
    this.addedServices,
    this.removedServices,
    this.addedCoverages,
    this.removedCoverages,
  });

  // from json
  factory MBusinessRequestList.fromJson(Map<String, dynamic> json) =>
      MBusinessRequestList(
        refId: json["RefId"],
        status: json["Status"],
        reason: json["Reason"],
        id: json["Id"],
        createdDate: json["CreatedDate"],
        // createdBy: MPartnerRequestInfo.fromMap(json["CreatedBy"]),
        updatedDate: json["UpdatedDate"],
        addedServices: json["AddedServices"],
        removedServices: json["RemovedServices"],
        addedCoverages: json["AddedCoverages"],
        removedCoverages: json["RemovedCoverages"],
      );

  // to json
  Map<String, dynamic> toJson() => {
        "RefId": refId,
        "Status": status,
        "Reason": reason,
        "Id": id,
        "CreatedDate": createdDate,
        "CreatedBy": createdBy,
        "UpdatedDate": updatedDate,
        "AddedServices": addedServices,
        "RemovedServices": removedServices,
        "AddedCoverages": addedCoverages,
        "RemovedCoverages": removedCoverages,
      };

  // copy with
  MBusinessRequestList copyWith({
    int? refId,
    String? status,
    String? reason,
    int? id,
    String? createdDate,
    MPartnerRequestInfo? createdBy,
    String? updatedDate,
    dynamic addedServices,
    dynamic removedServices,
    dynamic addedCoverages,
    dynamic removedCoverages,
  }) =>
      MBusinessRequestList(
        refId: refId ?? this.refId,
        status: status ?? this.status,
        reason: reason ?? this.reason,
        id: id ?? this.id,
        createdDate: createdDate ?? this.createdDate,
        createdBy: createdBy ?? this.createdBy,
        updatedDate: updatedDate ?? this.updatedDate,
        addedServices: addedServices ?? this.addedServices,
        removedServices: removedServices ?? this.removedServices,
        addedCoverages: addedCoverages ?? this.addedCoverages,
        removedCoverages: removedCoverages ?? this.removedCoverages,
      );
}

class MBusinessRequestDetail {
  final int? id;
  final String? status;
  final String? reason;
  final List<MAddedService>? addedServices;
  final List<MAddedService>? removedServices;
  final List<MAddedCoverage>? addedCoverages;
  final List<MAddedCoverage>? removedCoverages;

  MBusinessRequestDetail({
    this.id,
    this.status,
    this.addedServices,
    this.addedCoverages,
    this.removedServices,
    this.removedCoverages,
    this.reason,
  });

  factory MBusinessRequestDetail.fromMap(Map<String, dynamic> json) =>
      MBusinessRequestDetail(
        id: json['Id'],
        status: json['Status'],
        reason: json['Reason'],
        addedServices: (json['AddedServices'] ?? [])
            .map<MAddedService>((e) => MAddedService.fromMap(e))
            .toList(),
        removedServices: (json['RemovedServices'] ?? [])
            .map<MAddedService>((e) => MAddedService.fromMap(e))
            .toList(),
        addedCoverages: (json['AddedCoverages'] ?? [])
            .map<MAddedCoverage>((e) => MAddedCoverage.fromMap(e))
            .toList(),
        removedCoverages: (json['RemovedCoverages'] ?? [])
            .map<MAddedCoverage>((e) => MAddedCoverage.fromMap(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        "Id": this.id,
        "Status": this.status,
        "Reason": this.reason,
        "AddedServices":
            List<MAddedService>.from(this.addedServices!.map((e) => e)),
        "RemovedServices":
            List<MAddedService>.from(this.removedServices!.map((e) => e)),
        "AddedCoverages":
            List<MAddedCoverage>.from((this.addedCoverages!.map((e) => e))),
        "RemovedCoverages":
            List<MAddedCoverage>.from(this.removedCoverages!.map((e) => e)),
      };

  MBusinessRequestDetail copyWith({
    int? id,
    String? status,
    String? reason,
    List<MAddedService>? addedServices,
    List<MAddedService>? removedServices,
    List<MAddedCoverage>? addedCoverages,
    List<MAddedCoverage>? removedCoverages,
  }) =>
      MBusinessRequestDetail(
        id: id ?? this.id,
        status: status ?? this.status,
        reason: reason ?? this.reason,
        removedCoverages: removedCoverages ?? this.removedCoverages,
        addedCoverages: addedCoverages ?? this.addedCoverages,
        removedServices: removedServices ?? this.removedServices,
        addedServices: addedServices ?? this.addedServices,
      );
}

class MAddedService {
  final int? id;
  final int? categoryId;
  final String? categoryName;
  final String? categoryNameEnglish;
  final String? serviceNameEnglish;
  final String? serviceName;
  final String? image;

  MAddedService({
    this.id,
    this.categoryId,
    this.categoryName,
    this.categoryNameEnglish,
    this.image,
    this.serviceName,
    this.serviceNameEnglish,
  });

  factory MAddedService.fromMap(Map<String, dynamic> json) => MAddedService(
        id: json['Id'],
        categoryId: json['CategoryId'],
        categoryName: json['CategoryName'],
        categoryNameEnglish: json['CategoryNameEnglish'],
        image: json['Image'],
        serviceName: json['ServiceName'],
        serviceNameEnglish: json['ServiceNameEnglish'],
      );

  Map<String, dynamic> toJson() => {
        "Id": this.id,
        "CategoryId": this.categoryId,
        "CategoryName": this.categoryName,
        "CategoryNameEnglish": this.categoryNameEnglish,
        "Image": this.image,
        "ServiceName": this.serviceName,
        "ServiceNameEnglish": this.serviceNameEnglish,
      };

  MAddedService copyWith({
    int? id,
    int? categoryId,
    String? categoryName,
    String? categoryNameEnglish,
    String? serviceNameEnglish,
    String? serviceName,
    String? image,
  }) =>
      MAddedService(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        categoryName: categoryName ?? this.categoryName,
        categoryNameEnglish: categoryNameEnglish ?? this.categoryNameEnglish,
        image: image ?? this.image,
        serviceNameEnglish: serviceNameEnglish ?? this.serviceNameEnglish,
        serviceName: serviceName ?? this.serviceName,
      );
}

class MAddedCoverage {
  final int? id;
  final String? addressName;
  final String? addressNameEnglish;
  final String? addressType;

  MAddedCoverage(
      {this.id, this.addressName, this.addressNameEnglish, this.addressType});

  factory MAddedCoverage.fromMap(Map<String, dynamic> json) => MAddedCoverage(
        id: json["Id"],
        addressName: json['AddressName'],
        addressNameEnglish: json['AddressNameEnglish'],
        addressType: json['AddressType'],
      );

  Map<String, dynamic> toJson() => {
        "Id": this.id,
        "AddressName": this.addressName,
        "AddressNameEnglish": this.addressNameEnglish,
        "AddressType": this.addressType,
      };

  MAddedCoverage copyWith({
    int? id,
    String? addressName,
    String? addressNameEnglish,
    String? addressType,
  }) =>
      MAddedCoverage(
        id: id ?? this.id,
        addressName: addressName ?? this.addressName,
        addressNameEnglish: addressNameEnglish ?? this.addressNameEnglish,
        addressType: addressType ?? this.addressType,
      );
}

class MPartnerRequestInfo {
  final String? userName;
  final String? firstName;
  final String? lastName;

  MPartnerRequestInfo({
    this.firstName,
    this.lastName,
    this.userName,
  });

  factory MPartnerRequestInfo.fromMap(Map<String, dynamic> json) =>
      MPartnerRequestInfo(
        firstName: json['FirstName'],
        lastName: json["LastName"],
        userName: json["UserName"],
      );

  MPartnerRequestInfo copyWith({
    String? userName,
    String? FirstName,
    String? LastName,
  }) =>
      MPartnerRequestInfo(
        userName: userName ?? this.userName,
        lastName: lastName ?? this.lastName,
        firstName: firstName ?? this.firstName,
      );
}
