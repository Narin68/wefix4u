import 'dart:convert';

MSendMessage mSendMessageFromJson(String str) =>
    MSendMessage.fromJson(json.decode(str));

String mSendMessageToJson(MSendMessage data) => json.encode(data.toJson());

class MSendMessage {
  MSendMessage({
    this.id,
    this.sender,
    this.receivers,
    this.requestId,
    this.contentMsg,
    this.contentUrl,
    this.contentType,
    this.direction,
    this.status,
    this.deleteStatus,
    this.download,
  });

  final int? id;
  final String? sender;
  final List<int>? receivers;
  final int? requestId;
  final String? contentMsg;
  final String? contentUrl;
  final String? contentType;
  final String? direction;
  final String? status;
  final String? deleteStatus;
  final String? download;

  MSendMessage copyWith({
    int? id,
    String? sender,
    List<int>? receivers,
    int? requestId,
    String? contentMsg,
    String? contentUrl,
    String? contentType,
    String? direction,
    String? status,
    String? deleteStatus,
    String? download,
  }) =>
      MSendMessage(
        id: id ?? this.id,
        sender: sender ?? this.sender,
        receivers: receivers ?? this.receivers,
        requestId: requestId ?? this.requestId,
        contentMsg: contentMsg ?? this.contentMsg,
        contentUrl: contentUrl ?? this.contentUrl,
        contentType: contentType ?? this.contentType,
        direction: direction ?? this.direction,
        status: status ?? this.status,
        deleteStatus: deleteStatus ?? this.deleteStatus,
        download: download ?? this.download,
      );

  factory MSendMessage.fromJson(Map<String, dynamic> json) => MSendMessage(
        id: json["Id"] == null ? null : json["Id"],
        sender: json["Sender"] == null ? null : json["Sender"],
        receivers: json["Receivers"] == null
            ? null
            : List<int>.from(json["Receivers"].map((x) => x)),
        requestId: json["RequestId"] == null ? null : json["RequestId"],
        contentMsg: json["ContentMsg"] == null ? null : json["ContentMsg"],
        contentUrl: json["ContentUrl"] == null ? null : json["ContentUrl"],
        contentType: json["ContentType"] == null ? null : json["ContentType"],
        direction: json["Direction"] == null ? null : json["Direction"],
        status: json["Status"] == null ? null : json["Status"],
        deleteStatus:
            json["DeleteStatus"] == null ? null : json["DeleteStatus"],
        download: json["Download"] == null ? null : json["Download"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id == null ? null : id,
        "Sender": sender == null ? null : sender,
        "Receivers": receivers == null
            ? null
            : List<dynamic>.from(receivers!.map((x) => x)),
        "RequestId": requestId == null ? null : requestId,
        "ContentMsg": contentMsg == null ? null : contentMsg,
        "ContentUrl": contentUrl == null ? null : contentUrl,
        "ContentType": contentType == null ? null : contentType,
        "Direction": direction == null ? null : direction,
        "Status": status == null ? null : status,
        "DeleteStatus": deleteStatus == null ? null : deleteStatus,
        "Download": download == null ? null : download,
      };
}

class MMessageData {
  MMessageData({
    this.id,
    this.sender,
    this.receivers,
    this.requestId,
    this.contentMsg,
    this.contentUrl,
    this.contentType,
    this.direction,
    this.status,
    this.deleteStatus,
    this.download,
    this.createdBy,
    this.updatedBy,
    this.createdDate,
    this.updatedDate,
    this.completed,
  });

  final int? id;
  final String? sender;
  final List<String>? receivers;
  final int? requestId;
  final String? contentMsg;
  final String? contentUrl;
  final String? contentType;
  final String? direction;
  final String? status;
  final String? deleteStatus;
  final String? download;
  final String? createdBy;
  final String? updatedBy;
  final String? createdDate;
  final String? updatedDate;
  final bool? completed;

  MMessageData copyWith({
    int? id,
    String? sender,
    List<String>? receivers,
    int? requestId,
    String? contentMsg,
    String? contentUrl,
    String? contentType,
    String? direction,
    String? status,
    String? deleteStatus,
    String? download,
    String? createdBy,
    String? updatedBy,
    String? createdDate,
    String? updatedDate,
    bool? completed,
  }) =>
      MMessageData(
        id: id ?? this.id,
        sender: sender ?? this.sender,
        receivers: receivers ?? this.receivers,
        requestId: requestId ?? this.requestId,
        contentMsg: contentMsg ?? this.contentMsg,
        contentUrl: contentUrl ?? this.contentUrl,
        contentType: contentType ?? this.contentType,
        direction: direction ?? this.direction,
        status: status ?? this.status,
        deleteStatus: deleteStatus ?? this.deleteStatus,
        download: download ?? this.download,
        createdBy: createdBy ?? this.createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
        createdDate: createdDate ?? this.createdDate,
        updatedDate: updatedDate ?? this.updatedDate,
        completed: completed ?? this.completed,
      );

  factory MMessageData.fromJson(Map<String, dynamic> json) => MMessageData(
        id: json["Id"] == null ? null : json["Id"],
        sender: json["Sender"] == null ? null : json["Sender"],
        receivers: json["Receivers"] == null
            ? null
            : List<String>.from(json["Receivers"].map((x) => x)),
        requestId: json["RequestId"] == null ? null : json["RequestId"],
        contentMsg: json["ContentMsg"] == null ? null : json["ContentMsg"],
        contentUrl: json["ContentUrl"] == null ? null : json["ContentUrl"],
        contentType: json["ContentType"] == null ? null : json["ContentType"],
        direction: json["Direction"] == null ? null : json["Direction"],
        status: json["Status"] == null ? null : json["Status"],
        deleteStatus:
            json["DeleteStatus"] == null ? null : json["DeleteStatus"],
        download: json["Download"] == null ? null : json["Download"],
        createdBy: json["CreatedBy"],
        updatedBy: json["UpdatedBy"],
        createdDate: json["CreatedDate"],
        updatedDate: json["UpdatedDate"],
        completed: json["Completed"] == null ? true : json["Completed"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id == null ? null : id,
        "Sender": sender == null ? null : sender,
        "Receivers": receivers == null
            ? null
            : List<dynamic>.from(receivers!.map((x) => x)),
        "RequestId": requestId == null ? null : requestId,
        "ContentMsg": contentMsg == null ? null : contentMsg,
        "ContentUrl": contentUrl == null ? null : contentUrl,
        "ContentType": contentType == null ? null : contentType,
        "Direction": direction == null ? null : direction,
        "Status": status == null ? null : status,
        "DeleteStatus": deleteStatus == null ? null : deleteStatus,
        "Download": download == null ? null : download,
        "Completed": completed == null ? null : completed,
        "CreatedBy": createdBy == null ? null : createdBy,
        "CreatedDate": createdDate == null ? null : createdDate,
        "UpdatedDate": updatedDate == null ? null : updatedDate,
        "UpdatedBy": updatedBy == null ? null : updatedBy,
        "Complete": completed == null ? null : completed,
      };
}

class MReceiver {
  MReceiver({
    this.receiverName,
    this.receiverNameEnglish,
    this.receiverId,
    this.receiverType,
    this.receiverImage,
  });

  final String? receiverName;
  final String? receiverNameEnglish;
  final int? receiverId;
  final String? receiverType;
  final String? receiverImage;

  MReceiver copyWith({
    String? receiverName,
    String? receiverNameEnglish,
    int? receiverId,
    String? receiverType,
    String? receiverImage,
  }) =>
      MReceiver(
        receiverName: receiverName ?? this.receiverName,
        receiverNameEnglish: receiverNameEnglish ?? this.receiverNameEnglish,
        receiverId: receiverId ?? this.receiverId,
        receiverType: receiverType ?? this.receiverType,
        receiverImage: receiverImage ?? this.receiverImage,
      );

  factory MReceiver.fromJson(Map<String, dynamic> json) => MReceiver(
        receiverName: json["ReceiverName"],
        receiverNameEnglish: json["ReceiverNameEnglish"],
        receiverId: json["ReceiverId"],
        receiverType: json["ReceiverType"],
        receiverImage: json["ReceiverImage"],
      );

  Map<String, dynamic> toJson() => {
        "ReceiverName": receiverName,
        "ReceiverNameEnglish": receiverNameEnglish,
        "ReceiverId": receiverId,
        "ReceiverType": receiverType,
        "ReceiverImage": receiverImage,
      };
}
