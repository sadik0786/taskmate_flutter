import 'dart:convert';

RegisterRequestModel registerRequestModelFromJson(String str) =>
    RegisterRequestModel.fromJson(json.decode(str));

String registerRequestModelToJson(RegisterRequestModel data) => json.encode(data.toJson());

class RegisterRequestModel {
  final String name;
  final String email;
  final String mobile;
  final String password;
  final int roleId;
  final int? reportingId;

  RegisterRequestModel({
    required this.name,
    required this.email,
    required this.mobile,
    required this.password,
    required this.roleId,
    this.reportingId,
  });

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) {
    return RegisterRequestModel(
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      mobile: json["mobile"] ?? "",
      password: json["password"] ?? "",
      roleId: json["roleId"] ?? 0,
      reportingId: json["reportingId"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "mobile": mobile,
      "password": password,
      "roleId": roleId,
      if (reportingId != null) "reportingId": reportingId,
    };
  }
}
