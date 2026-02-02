class UserRequestModel {
  final int? id;
  final String? profileImage;
  final String name;
  final String email;
  final String? mobile;
  final String passwordHash;
  final int? roleId;
  final int? reportingId;
  final String? createdAt;
  final int? createdBy;
  final String? updatedAt;
  final int? updatedBy;

  UserRequestModel({
    this.id,
    this.profileImage,
    required this.name,
    required this.email,
    this.mobile,
    required this.passwordHash,
    this.roleId,
    this.reportingId,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
  });

  factory UserRequestModel.fromJson(Map<String, dynamic> json) {
    return UserRequestModel(
      id: json["ID"],
      profileImage: json["ProfileImage"],
      name: json["Name"],
      email: json["Email"],
      mobile: json["Mobile"],
      passwordHash: json["PasswordHash"],
      roleId: json["RoleID"],
      reportingId: json["ReportingID"],
      createdAt: json["CreatedAt"],
      createdBy: json["CreatedBy"],
      updatedAt: json["UpdatedAt"],
      updatedBy: json["UpdatedBy"],
    );
  }
}
