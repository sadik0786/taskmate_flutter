class LeaveApplyRequestModel {
  // final int userId;
  final int leaveTypeId;
  final String fromDate;
  final String toDate;
  final double days;
  final int sessionDay;
  final String reason;

  LeaveApplyRequestModel({
    // required this.userId,
    required this.leaveTypeId,
    required this.fromDate,
    required this.toDate,
    required this.days,
    required this.sessionDay,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
    // "userId": userId,
    "leaveTypeId": leaveTypeId,
    "fromDate": fromDate,
    "toDate": toDate,
    "days": days,
    "sessionDay": sessionDay,
    "reason": reason,
  };
}
