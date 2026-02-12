class EmployeeModel {
  final int id;
  final String name;
  final String email;
  final String mobile;
  final int roleId;
  final int reportingId;
  final int createdBy;
  final DateTime createdAt;

  EmployeeModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.roleId,
    required this.reportingId,
    required this.createdBy,
    required this.createdAt,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json["ID"] ?? 0,
      name: json["Name"] ?? "",
      email: json["Email"] ?? "",
      mobile: json["Mobile"] ?? "",
      roleId: json["RoleID"] ?? 0,
      reportingId: json["ReportingID"] ?? 0,
      createdBy: json["CreatedBy"] ?? 0,
      createdAt: DateTime.parse(json["CreatedAt"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "ID": id,
      "Name": name,
      "Email": email,
      "Mobile": mobile,
      "RoleID": roleId,
      "ReportingID": reportingId,
      "CreatedBy": createdBy,
      "CreatedAt": createdAt.toIso8601String(),
    };
  }
}
