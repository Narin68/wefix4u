import 'dart:convert';

import 'dart:typed_data';

import '/modals/image.dart';

MFile mFileFromJson(String str) => MFile.fromJson(json.decode(str));

String mFileToJson(MFile data) => json.encode(data.toJson());

class MFile {
  MFile({
    this.refId,
    this.extension,
    this.file,
    this.fileType,
    this.refType,
  });

  final int? refId;
  final String? extension;
  final String? refType;
  final Uint8List? file;

  final String? fileType;

  MFile copyWith({
    int? refId,
    String? extension,
    Uint8List? file,
    String? fileType,
    String? refType,
  }) =>
      MFile(
        extension: extension ?? this.extension,
        file: file ?? this.file,
        fileType: fileType ?? this.fileType,
        refId: refId ?? this.refId,
        refType: refType ?? this.refType,
      );

  factory MFile.fromJson(Map<String, dynamic> json) => MFile(
        refId: json["RefId"],
        extension: json["Extension"],
        fileType: json["FileType"],
        refType: json["RefType"],
        file: json["File"],
      );

  Map<String, dynamic> toJson() => {
        "RefId": refId,
        "Extension": extension,
        "FileType": fileType,
        "RefType": refType,
        "File": file,
      };
}

class MFilesDetail {
  final List<String>? imagePathList;
  final List<String>? videoPathList;
  final List<String>? audioPathList;
  final List<String>? docPathList;

  MFilesDetail({
    this.imagePathList,
    this.videoPathList,
    this.audioPathList,
    this.docPathList,
  });

  // from json
  factory MFilesDetail.fromJson(Map<String, dynamic> json) => MFilesDetail(
        imagePathList:
            List<String>.from(json["ImagePathList"].map((x) => x ?? "")),
        videoPathList:
            List<String>.from(json["VideoPathList"].map((x) => x ?? "")),
        audioPathList:
            List<String>.from(json["AudioPathList"].map((x) => x ?? "")),
        docPathList: List<String>.from(json["DocPathList"].map((x) => x ?? "")),
      );

  // to json
  Map<String, dynamic> toJson() => {
        "ImagePathList": List<MImage>.from(imagePathList!.map((x) => x)),
        "VideoPathList": List<MImage>.from(videoPathList!.map((x) => x)),
        "AudioPathList": List<MImage>.from(audioPathList!.map((x) => x)),
        "DocPathList": List<MImage>.from(docPathList!.map((x) => x)),
      };

  // copy with
  MFilesDetail copyWith({
    List<String>? imagePathList,
    List<String>? videoPathList,
    List<String>? audioPathList,
    List<String>? docPathList,
  }) =>
      MFilesDetail(
        imagePathList: imagePathList ?? this.imagePathList,
        videoPathList: videoPathList ?? this.videoPathList,
        audioPathList: audioPathList ?? this.audioPathList,
        docPathList: docPathList ?? this.docPathList,
      );
}

class MApplicationFiles {
  final String? faceImagePath;
  final String? placeImagePath;
  final MFilesDetail? files;

  MApplicationFiles({
    this.faceImagePath,
    this.placeImagePath,
    this.files,
  });

  // from json
  factory MApplicationFiles.fromJson(Map<String, dynamic> json) =>
      MApplicationFiles(
        faceImagePath:
            json["FaceImagePath"] == null ? null : json["FaceImagePath"],
        placeImagePath:
            json["PlaceImagePath"] == null ? null : json["PlaceImagePath"],
        files:
            json["Files"] == null ? null : MFilesDetail.fromJson(json["Files"]),
      );

  // to json
  Map<String, dynamic> toJson() => {
        "FaceImagePath": faceImagePath,
        "PlaceImagePath": placeImagePath,
        "Files": files!.toJson(),
      };

  // copy with
  MApplicationFiles copyWith({
    String? faceImagePath,
    String? placeImagePath,
    MFilesDetail? files,
  }) =>
      MApplicationFiles(
        faceImagePath: faceImagePath ?? this.faceImagePath,
        placeImagePath: placeImagePath ?? this.placeImagePath,
        files: files ?? this.files,
      );
}

class MAttachment {
  final List<String>? imagePathList;
  final List<String>? videoPathList;
  final List<String>? audioPathList;
  final List<String>? docPathList;

  MAttachment({
    this.imagePathList,
    this.videoPathList,
    this.audioPathList,
    this.docPathList,
  });

  // from json
  factory MAttachment.fromJson(Map<String, dynamic> json) => MAttachment(
        imagePathList: List<String>.from(json["Images"].map((x) => x ?? "")),
        videoPathList: List<String>.from(json["Videos"].map((x) => x ?? "")),
        audioPathList: List<String>.from(json["Audios"].map((x) => x ?? "")),
        docPathList: List<String>.from(json["Docs"].map((x) => x ?? "")),
      );

  // to json
  Map<String, dynamic> toJson() => {
        "ImagePathList": List<MImage>.from(imagePathList!.map((x) => x)),
        "VideoPathList": List<MImage>.from(videoPathList!.map((x) => x)),
        "AudioPathList": List<MImage>.from(audioPathList!.map((x) => x)),
        "DocPathList": List<MImage>.from(docPathList!.map((x) => x)),
      };

  // copy with
  MAttachment copyWith({
    List<String>? imagePathList,
    List<String>? videoPathList,
    List<String>? audioPathList,
    List<String>? docPathList,
  }) =>
      MAttachment(
        imagePathList: imagePathList ?? this.imagePathList,
        videoPathList: videoPathList ?? this.videoPathList,
        audioPathList: audioPathList ?? this.audioPathList,
        docPathList: docPathList ?? this.docPathList,
      );
}

class MFileUpload {
  final String? dbCode;
  final String? status;
  final String? name;
  final String? fileName;
  final String? filePath;
  final String? folderPath;
  final String? extension;
  final String? message;
  final String? hostName;
  final bool? isSuccess;

  MFileUpload({
    this.dbCode,
    this.status,
    this.name,
    this.fileName,
    this.filePath,
    this.folderPath,
    this.extension,
    this.message,
    this.hostName,
    this.isSuccess,
  });

  // from json
  factory MFileUpload.fromJson(Map<String, dynamic> json) => MFileUpload(
        dbCode: json["DbCode"],
        status: json["Status"],
        name: json["Name"],
        fileName: json["FileName"],
        filePath: json["FilePath"],
        folderPath: json["FolderPath"],
        extension: json["Extension"],
        message: json["Message"],
        hostName: json["HostName"],
        isSuccess: json["IsSuccess"],
      );

  // to json
  Map<String, dynamic> toJson() => {
        "DbCode": dbCode,
        "Status": status,
        "Name": name,
        "FileName": fileName,
        "FilePath": filePath,
        "FolderPath": folderPath,
        "Extension": extension,
        "Message": message,
        "HostName": hostName,
        "IsSuccess": isSuccess,
      };

  // copy with
  MFileUpload copyWith({
    String? dbCode,
    String? status,
    String? name,
    String? fileName,
    String? filePath,
    String? folderPath,
    String? extension,
    String? message,
    String? hostName,
    bool? isSuccess,
  }) =>
      MFileUpload(
        dbCode: dbCode ?? this.dbCode,
        status: status ?? this.status,
        name: name ?? this.name,
        fileName: fileName ?? this.fileName,
        filePath: filePath ?? this.filePath,
        folderPath: folderPath ?? this.folderPath,
        extension: extension ?? this.extension,
        message: message ?? this.message,
        hostName: hostName ?? this.hostName,
        isSuccess: isSuccess ?? this.isSuccess,
      );
}

class MSaveFileToDb {
  MSaveFileToDb({
    this.refId,
    this.refType,
    this.files,
  });

  final int? refId;
  final String? refType;
  final List<MFileUpload>? files;

  MSaveFileToDb copyWith({
    int? refId,
    String? refType,
    List<MFileUpload>? files,
  }) =>
      MSaveFileToDb(
          refId: refId ?? this.refId,
          refType: refType ?? this.refType,
          files: files ?? this.files);

  factory MSaveFileToDb.fromJson(Map<String, dynamic> json) => MSaveFileToDb(
      refId: json["RefId"],
      refType: json["RefType"],
      files: (json["Files"] ?? [])
          .map<MFileUpload>((x) => MFileUpload.fromJson(x)));

  Map<String, dynamic> toJson() => {
        "RefId": refId,
        "RefType": refType,
        "Files": List<MFileUpload>.from(files!.map((x) => x))
      };
}

class MSaveFile {
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

  MSaveFile({
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

  MSaveFile copyWith({
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
      MSaveFile(
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

  factory MSaveFile.fromJson(Map<String, dynamic> json) => MSaveFile(
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
}
