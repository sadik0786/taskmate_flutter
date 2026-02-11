import 'dart:convert';

List<LeaveTypeModel> leaveTypeModelFromJson(String str) =>
    List<LeaveTypeModel>.from(json.decode(str).map((x) => LeaveTypeModel.fromJson(x)));

String leaveTypeModelToJson(List<LeaveTypeModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LeaveTypeModel {
  int? id;
  String? leaveName;
  int? leaveCount;

  LeaveTypeModel({this.id, this.leaveName, this.leaveCount});

  factory LeaveTypeModel.fromJson(Map<String, dynamic> json) =>
      LeaveTypeModel(id: json["Id"], leaveName: json["LeaveName"], leaveCount: json["LeaveCount"]);

  Map<String, dynamic> toJson() => {"Id": id, "LeaveName": leaveName, "LeaveCount": leaveCount};
}
