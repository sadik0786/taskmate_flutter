import 'dart:convert';

RegisterResponseModel registerResponseModelFromJson(String str) =>
    RegisterResponseModel.fromJson(json.decode(str));

String registerResponseModelToJson(RegisterResponseModel data) => json.encode(data.toJson());

class RegisterResponseModel {
  bool? success;
  Employee? employee;

  RegisterResponseModel({this.success, this.employee});

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) => RegisterResponseModel(
    success: json["success"],
    employee: json["employee"] == null ? null : Employee.fromJson(json["employee"]),
  );

  Map<String, dynamic> toJson() => {"success": success, "employee": employee?.toJson()};
}

class Employee {
  int? id;
  String? name;
  String? email;
  String? mobile;
  int? roleId;
  int? reportingId;
  int? createdBy;
  DateTime? createdAt;

  Employee({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.roleId,
    this.reportingId,
    this.createdBy,
    this.createdAt,
  });

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
    id: json["ID"],
    name: json["Name"],
    email: json["Email"],
    mobile: json["Mobile"],
    roleId: json["RoleID"],
    reportingId: json["ReportingID"],
    createdBy: json["CreatedBy"],
    createdAt: json["CreatedAt"] == null ? null : DateTime.parse(json["CreatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "ID": id,
    "Name": name,
    "Email": email,
    "Mobile": mobile,
    "RoleID": roleId,
    "ReportingID": reportingId,
    "CreatedBy": createdBy,
    "CreatedAt": createdAt?.toIso8601String(),
  };
}
