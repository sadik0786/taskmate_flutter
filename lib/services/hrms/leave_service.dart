import 'dart:convert';
import 'package:task_mate/model/leave_apply_request_model.dart';
import 'package:task_mate/model/leave_request_model.dart';
import 'package:task_mate/services/base_api_service.dart';

class LeaveService {
  static Future<List<dynamic>> fetchAllLeaveTypes({
    int? financialYearId,
    int? employeeId,
  }) async {
    String url = "/hrms/leave-types";
    List<String> queryParams = [];
    if (financialYearId != null) {
      queryParams.add("financialYearId=$financialYearId");
    }
    if (employeeId != null) queryParams.add("employeeId=$employeeId");

    if (queryParams.isNotEmpty) {
      url += "?${queryParams.join('&')}";
    }
    final res = await BaseApiService.request(url);
    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data["success"] == true) {
      return data["data"] ?? [];
    }
    throw Exception(data["error"] ?? "Failed to fetch leave types");
  }

  static Future<List<LeaveRequestModel>> fetchMyLeaves({
    int? financialYearId,
  }) async {
    String url = "/hrms/my-leaves";
    if (financialYearId != null) {
      url += "?financialYearId=$financialYearId";
    }
    final res = await BaseApiService.request(url);
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

  static Future<List<LeaveRequestModel>> fetchOtherLeaveRequest({
    int? financialYearId,
  }) async {
    String url = "/hrms/other-leaves-request";
    if (financialYearId != null) {
      url += "?financialYearId=$financialYearId";
    }
    final res = await BaseApiService.request(url);
    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data["success"] == true) {
      return (data["data"] as List)
          .map((e) => LeaveRequestModel.fromJson(e))
          .toList();
    }
    throw Exception(data["message"] ?? "Failed to fetch leaves");
  }

  static Future<List<LeaveRequestModel>> fetchAllLeaveReport({
    int? financialYearId,
  }) async {
    String url = "/hrms/all-leaves-report";
    if (financialYearId != null) {
      url += "?financialYearId=$financialYearId";
    }
    final res = await BaseApiService.request(url);
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
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> carryForwardLeave({
    required int userId,
    required int leaveTypeId,
    required int fromFinancialYearId,
    required int toFinancialYearId,
    required int carriedForwardDays,
  }) async {
    try {
      final res = await BaseApiService.request(
        "/hrms/carry-forward-leave",
        method: "POST",
        body: {
          "userId": userId,
          "leaveTypeId": leaveTypeId,
          "fromFinancialYearId": fromFinancialYearId,
          "toFinancialYearId": toFinancialYearId,
          "carriedForwardDays": carriedForwardDays,
        },
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data["success"] == true) {
        return data;
      }
      return {
        "success": false,
        "message": data["message"] ?? "Failed to carry forward leave",
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString().replaceAll("Exception: ", ""),
      };
    }
  }
}
