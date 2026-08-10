class LeaveRequestModel {
  final int id;
  final int userId;
  final String employeeName;
  final String employeeRole;
  final String leaveTypeName;
  final String fromDate;
  final String toDate;
  final double totalDays;
  final int sessionDay;
  final String? reason;
  final String status;

  LeaveRequestModel({
    required this.id,
    required this.userId,
    required this.employeeName,
    required this.employeeRole,
    required this.leaveTypeName,
    required this.fromDate,
    required this.toDate,
    required this.totalDays,
    required this.sessionDay,
    this.reason,
    required this.status,
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestModel(
      id: json['Id'],
      userId: json['UserTaskMateAppId'] ?? 0,
      employeeName: json['EmployeeName'] ?? "Unknown",
      employeeRole: json['EmployeeRole'] ?? "Employee",
      leaveTypeName: json['LeaveName'],
      fromDate: json['FromDate'],
      toDate: json['ToDate'],
      totalDays: (json['TotalDays'] as num).toDouble(),
      sessionDay: json['SessionDay'] ?? 0,
      reason: json['Reason'] ?? '',
      status: json['Status'],
    );
  }
  LeaveRequestModel copyWith({String? status}) {
    return LeaveRequestModel(
      id: id,
      userId: userId,
      employeeName: employeeName,
      employeeRole: employeeRole,
      leaveTypeName: leaveTypeName,
      fromDate: fromDate,
      toDate: toDate,
      totalDays: totalDays,
      sessionDay: sessionDay,
      reason: reason,
      status: status ?? this.status,
    );
  }
}
