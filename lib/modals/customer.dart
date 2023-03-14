class MMyCustomer {
  MMyCustomer({
    this.id,
    this.code,
    this.name,
    this.nameEnglish,
    this.gender,
    this.dateOfBirth,
    this.nationalityId,
    this.phone1,
    this.phone2,
    this.email,
    this.address,
    this.postalCode,
    this.countryId,
    this.provinceId,
    this.communeId,
    this.districtId,
    this.villageId,
    this.peopleIdCard,
    this.passportNo,
    this.accountId,
    this.status,
    this.database,
    this.userName,
    this.dateNow,
    this.latLong,
    this.targetBranch,
  });

  final int? id;

  final String? code;

  final String? name;

  final String? nameEnglish;

  final String? gender;

  final String? dateOfBirth;

  final int? nationalityId;

  final String? phone1;

  final String? phone2;

  final String? email;

  final String? address;

  final String? postalCode;

  final int? countryId;

  final int? provinceId;

  final int? communeId;

  final int? districtId;

  final int? villageId;

  final String? peopleIdCard;

  final String? passportNo;

  final int? accountId;

  final int? targetBranch;

  final bool? status;

  final String? database;

  final String? userName;

  final String? dateNow;

  final String? latLong;

  MMyCustomer copyWith({
    int? id,
    String? code,
    String? name,
    String? nameEnglish,
    String? gender,
    String? dateOfBirth,
    int? nationalityId,
    String? phone1,
    String? phone2,
    String? email,
    String? address,
    String? postalCode,
    int? countryId,
    int? provinceId,
    int? communeId,
    int? districtId,
    int? targetBranch,
    int? villageId,
    String? peopleIdCard,
    String? passportNo,
    int? accountId,
    bool? status,
    String? database,
    String? userName,
    String? dateNow,
    String? latLong,
  }) =>
      MMyCustomer(
        id: id ?? this.id,
        code: code ?? this.code,
        name: name ?? this.name,
        nameEnglish: nameEnglish ?? this.nameEnglish,
        gender: gender ?? this.gender,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        nationalityId: nationalityId ?? this.nationalityId,
        phone1: phone1 ?? this.phone1,
        phone2: phone2 ?? this.phone2,
        email: email ?? this.email,
        address: address ?? this.address,
        postalCode: postalCode ?? this.postalCode,
        countryId: countryId ?? this.countryId,
        provinceId: provinceId ?? this.provinceId,
        communeId: communeId ?? this.communeId,
        districtId: districtId ?? this.districtId,
        villageId: villageId ?? this.villageId,
        peopleIdCard: peopleIdCard ?? this.peopleIdCard,
        passportNo: passportNo ?? this.passportNo,
        accountId: accountId ?? this.accountId,
        status: status ?? this.status,
        database: database ?? this.database,
        userName: userName ?? this.userName,
        dateNow: dateNow ?? this.dateNow,
        latLong: latLong ?? this.latLong,
        targetBranch: targetBranch ?? this.targetBranch,
      );

  factory MMyCustomer.fromJson(Map<String, dynamic> json) => MMyCustomer(
        id: json["Id"],
        code: json["Code"],
        name: json["Name"],
        nameEnglish: json["NameEnglish"],
        gender: json["Gender"],
        dateOfBirth: json["DateOfBirth"],
        nationalityId: json["NationalityId"],
        phone1: json["Phone1"],
        phone2: json["Phone2"],
        email: json["Email"],
        address: json["Address"],
        postalCode: json["PostalCode"],
        countryId: json["CountryId"],
        provinceId: json["ProvinceId"],
        communeId: json["CommuneId"],
        districtId: json["DistrictId"],
        villageId: json["VillageId"],
        peopleIdCard: json["PeopleIDCard"],
        passportNo: json["PassportNo"],
        accountId: json["AccountId"],
        status: json["Status"],
        database: json["Database"],
        userName: json["UserName"],
        dateNow: json["DateNow"],
        latLong: json["LatLong"],
        targetBranch: json["TargetBranch"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "Code": code,
        "Name": name,
        "NameEnglish": nameEnglish,
        "Gender": gender,
        "DateOfBirth": dateOfBirth,
        "NationalityId": nationalityId,
        "Phone1": phone1,
        "Phone2": phone2,
        "Email": email,
        "Address": address,
        "PostalCode": postalCode,
        "CountryId": countryId,
        "ProvinceId": provinceId,
        "CommuneId": communeId,
        "DistrictId": districtId,
        "VillageId": villageId,
        "PeopleIDCard": peopleIdCard,
        "PassportNo": passportNo,
        "AccountId": accountId,
        "Status": status,
        "Database": database,
        "UserName": userName,
        "DateNow": dateNow,
        "LatLong": latLong,
        "TargetBranch": targetBranch,
      };
}

class MMyCustomerFilter {
  MMyCustomerFilter({
    this.id,
    this.code,
    this.status,
    this.provinceId,
    this.districtId,
    this.communeId,
    this.villageId,
    this.countryId,
    this.database,
    this.orderBy,
    this.orderDir,
    this.pages,
    this.records,
    this.search,
  });

  final int? id;

  final String? code;

  final bool? status;

  final int? provinceId;

  final int? districtId;

  final int? communeId;

  final int? villageId;

  final int? countryId;

  final String? database;

  final String? orderBy;

  final String? orderDir;

  final int? pages;

  final int? records;

  final String? search;

  MMyCustomerFilter copyWith({
    int? id,
    String? code,
    bool? status,
    int? provinceId,
    int? districtId,
    int? communeId,
    int? villageId,
    int? countryId,
    String? database,
    String? orderBy,
    String? orderDir,
    int? pages,
    int? records,
    String? search,
  }) =>
      MMyCustomerFilter(
        id: id ?? this.id,
        code: code ?? this.code,
        status: status ?? this.status,
        provinceId: provinceId ?? this.provinceId,
        districtId: districtId ?? this.districtId,
        communeId: communeId ?? this.communeId,
        villageId: villageId ?? this.villageId,
        countryId: countryId ?? this.countryId,
        database: database ?? this.database,
        orderBy: orderBy ?? this.orderBy,
        orderDir: orderDir ?? this.orderDir,
        pages: pages ?? this.pages,
        records: records ?? this.records,
        search: search ?? this.search,
      );

  factory MMyCustomerFilter.fromJson(Map<String, dynamic> json) =>
      MMyCustomerFilter(
        id: json["ID"],
        code: json["Code"],
        status: json["Status"],
        provinceId: json["ProvinceID"],
        districtId: json["DistrictID"],
        communeId: json["CommuneID"],
        villageId: json["VillageID"],
        countryId: json["CountryID"],
        database: json["Database"],
        orderBy: json["OrderBy"],
        orderDir: json["OrderDir"],
        pages: json["Pages"],
        records: json["Records"],
        search: json["Search"],
      );

  Map<String, dynamic> toJson() => {
        "ID": id,
        "Code": code,
        "Status": status,
        "ProvinceID": provinceId,
        "DistrictID": districtId,
        "CommuneID": communeId,
        "VillageID": villageId,
        "CountryID": countryId,
        "Database": database,
        "OrderBy": orderBy,
        "OrderDir": orderDir,
        "Pages": pages,
        "Records": records,
        "Search": search,
      };
}
