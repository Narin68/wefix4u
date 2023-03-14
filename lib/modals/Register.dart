import 'dart:convert';

MRegister mRegisterFromJson(String str) => MRegister.fromJson(json.decode(str));

String mRegisterToJson(MRegister data) => json.encode(data.toJson());

class MRegister {
  MRegister({
    this.password,
    this.firstName,
    this.lastName,
    this.phoneNumber,
  });

  final String? password;

  final String? firstName;

  final String? lastName;

  final String? phoneNumber;

  factory MRegister.fromJson(Map<String, dynamic> json) => MRegister(
        password: json["Password"],
        firstName: json["FirstName"],
        lastName: json["LastName"],
        phoneNumber: json["PhoneNumber"],
      );

  Map<String, dynamic> toJson() => {
        "Password": password,
        "FirstName": firstName,
        "LastName": lastName,
        "PhoneNumber": phoneNumber,
      };
}
