class MAddressFilter {
  MAddressFilter({
    this.referenceId,
    this.id,
    this.code,
    this.type,
    this.status,
    this.database,
    this.orderBy,
    this.orderDir,
    this.pages,
    this.records,
    this.search,
  });

  final int? referenceId;
  final int? id;
  final String? code;
  final String? type;
  final String? status;
  final String? database;
  final String? orderBy;
  final String? orderDir;
  final int? pages;
  final int? records;
  final String? search;

  MAddressFilter copyWith({
    int? referenceId,
    int? id,
    String? code,
    String? type,
    String? status,
    String? database,
    String? orderBy,
    String? orderDir,
    int? pages,
    int? records,
    String? search,
  }) =>
      MAddressFilter(
          referenceId: referenceId ?? this.referenceId,
          id: id ?? this.id,
          code: code ?? this.code,
          type: type ?? this.type,
          status: status ?? this.status,
          database: database ?? this.database,
          orderBy: orderBy ?? this.orderBy,
          orderDir: orderDir ?? this.orderDir,
          pages: pages ?? this.pages,
          records: records ?? this.records,
          search: search ?? this.search);

  factory MAddressFilter.fromJson(Map<String, dynamic> json) => MAddressFilter(
        referenceId: json["ReferenceId"],
        id: json["Id"],
        code: json["Code"],
        type: json["Type"],
        status: json["Status"],
        database: json["Database"],
        orderBy: json["OrderBy"],
        orderDir: json["OrderDir"],
        pages: json["Pages"],
        records: json["Records"],
        search: json["Search"],
      );

  Map<String, dynamic> toJson() => {
        "ReferenceId": referenceId,
        "Id": id,
        "Code": code,
        "Type": type,
        "Status": status,
        "Database": database,
        "OrderBy": orderBy,
        "OrderDir": orderDir,
        "Pages": pages,
        "Records": records,
        "Search": search,
      };
}
