import 'dart:convert';

LoginRequestModel loginRequestModelFromJson(String str) =>
    LoginRequestModel.fromJson(json.decode(str));

String loginRequestModelToJson(LoginRequestModel data) => json.encode(data.toJson());

class LoginRequestModel {
  final String email;
  final String password;

  LoginRequestModel({required this.email, required this.password});

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) {
    return LoginRequestModel(email: json["email"] ?? "", password: json["password"] ?? "");
  }

  Map<String, dynamic> toJson() {
    return {"email": email, "password": password};
  }
}
