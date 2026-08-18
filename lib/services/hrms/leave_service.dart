import 'dart:convert';
import 'package:task_mate/model/leave_apply_request_model.dart';
import 'package:task_mate/model/leave_request_model.dart';
import 'package:task_mate/services/base_api_service.dart';

class LeaveService {
  static Future<List<dynamic>> fetchAllLeaveTypes() async {
    final res = await BaseApiService.request("/hrms/leave-types");
    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data["success"] == true) {
      return data["data"] ?? [];
    }
    throw Exception(data["error"] ?? "Failed to fetch leave types");
  }

  static Future<List<LeaveRequestModel>> fetchMyLeaves() async {
    final res = await BaseApiService.request("/hrms/my-leaves");
    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data["success"] == true) {
      return (data["data"] as List)
          .map((e) => LeaveRequestModel.fromJson(e))
          .toList();
    }
    throw Exception(data["error"] ?? "Failed to fetch leaves");
  }

  static Future<Map<String, dynamic>> applyLeave(
    LeaveApplyRequestModel request,
  ) async {
    try {
      final token = await BaseApiService.getToken();
      if (token == null) {
        return {"success": false, "error": "No token found"};
      }

      final res = await BaseApiService.request(
        "/hrms/leave-apply",
        method: "POST",
        body: request.toJson(),
      );

      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data["success"] == true) {
        return data;
      }
      throw Exception(data["message"] ?? "Failed to apply leave");
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<List<LeaveRequestModel>> fetchOtherLeaveRequest() async {
    final res = await BaseApiService.request("/hrms/other-leaves-request");
    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data["success"] == true) {
      return (data["data"] as List)
          .map((e) => LeaveRequestModel.fromJson(e))
          .toList();
    }
    throw Exception(data["message"] ?? "Failed to fetch leaves");
  }

  static Future<List<LeaveRequestModel>> fetchAllLeaveReport() async {
    final res = await BaseApiService.request("/hrms/all-leaves-report");
    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data["success"] == true) {
      return (data["data"] as List)
          .map((e) => LeaveRequestModel.fromJson(e))
          .toList();
    }
    throw Exception(data["message"] ?? "Failed to fetch all leaves report");
  }

  static Future<List<LeaveRequestModel>> fetchTodayLeaves() async {
    final res = await BaseApiService.request("/hrms/today-leaves");
    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data["success"] == true) {
      return (data["data"] as List)
          .map((e) => LeaveRequestModel.fromJson(e))
          .toList();
    }
    throw Exception(data["message"] ?? "Failed to fetch today leaves");
  }

  static Future<Map<String, dynamic>> updateLeaveStatus(
    int leaveId,
    String status, {
    String? hrReason,
  }) async {
    try {
      final token = await BaseApiService.getToken();
      if (token == null) {
        return {"success": false, "error": "No token found"};
      }

      final res = await BaseApiService.request(
        "/hrms/update-leave-status",
        method: "PUT",
        body: {"leaveId": leaveId, "status": status, "hrReason": hrReason},
      );

      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data["success"] == true) {
        return data;
      }
      throw Exception(data["message"] ?? "Failed to update status");
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> cancelLeave(int leaveId) async {
    try {
      final token = await BaseApiService.getToken();
      if (token == null) {
        return {"success": false, "error": "No token found"};
      }

      final res = await BaseApiService.request(
        "/hrms/leave-cancel/$leaveId",
        method: "DELETE",
      );

      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data["success"] == true) {
        return data;
      }
      throw Exception(data["message"] ?? "Failed to cancel leave");
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }
}
