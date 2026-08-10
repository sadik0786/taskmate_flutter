import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/core/routes.dart';
import 'package:task_mate/model/leave_apply_request_model.dart';
import 'package:task_mate/model/leave_request_model.dart';
import 'package:task_mate/model/user_request_model.dart';

String get baseUrl => dotenv.env['baseApiUrl'] ?? '';

class ApiHrmsService {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // Common request function
  static Future<http.Response> request(
    String endpoint, {
    String method = "GET",
    Map<String, dynamic>? body,
  }) async {
    final token = await getToken();

    final headers = {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
    late http.Response response;
    try {
      final uri = Uri.parse("$baseUrl$endpoint");
      switch (method) {
        case "POST":
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case "PUT":
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case "DELETE":
          response = await http.delete(uri, headers: headers);
          break;
        default:
          response = await http.get(uri, headers: headers);
      }
    } catch (e) {
      rethrow;
    }
    if (response.statusCode == 401) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Get.offAllNamed(Routes.login);
    }
    return response;
  }

  // employee register
  // static Future<RegisterEmployeeResponse> registerUser(UserRequestModel request) async {
  //   try {
  //     final res = await ApiHrmsService.request(
  //       "/hrms/add-employee",
  //       method: "POST",
  //       body: request.toJson(),
  //     );

  //     final decoded = jsonDecode(res.body);

  //     return RegisterEmployeeResponse.fromJson(decoded);
  //   } catch (e) {
  //     return RegisterEmployeeResponse(success: false, message: e.toString());
  //   }
  // }

  // get all employee
  static Future<List<UserRequestModel>> allEmployee() async {
    final res = await request("/hrms/all-employee");

    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data["success"] == true) {
      return (data["data"] as List)
          .map((e) => UserRequestModel.fromJson(e))
          .toList();
    }

    throw Exception(data["error"] ?? "Failed to fetch employee");
  }

  static Future<List<dynamic>> fetchMyPayslips() async {
    final res = await request("/hrms/my-payslips");
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data["success"] == true) {
      return data["data"] as List;
    }
    throw Exception(data["message"] ?? "Failed to fetch payslips");
  }

  static Future<List<dynamic>> fetchTodayEvents() async {
    try {
      final res = await request("/hrms/today-events");
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data["success"] == true) {
        return data["data"] as List;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // get all leaves type
  static Future<List<dynamic>> fetchAllLeaveTypes() async {
    final res = await request("/hrms/leave-types");
    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data["success"] == true) {
      return data["data"] ?? [];
    }
    throw Exception(data["error"] ?? "Failed to fetch leave");
  }

  // get all my leave
  static Future<List<LeaveRequestModel>> fetchMyLeaves() async {
    final res = await request("/hrms/my-leaves");
    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data["success"] == true) {
      return (data["data"] as List)
          .map((e) => LeaveRequestModel.fromJson(e))
          .toList();
    }
    throw Exception(data["error"] ?? "Failed to fetch leaves");
  }

  // apply leave request
  static Future<Map<String, dynamic>> applyLeave(
    LeaveApplyRequestModel request,
  ) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {"success": false, "error": "No token found"};
      }

      final res = await ApiHrmsService.request(
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

  // get all other leave request
  static Future<List<LeaveRequestModel>> fetchOtherLeaveRequest() async {
    final res = await request("/hrms/other-leaves-request");
    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data["success"] == true) {
      return (data["data"] as List)
          .map((e) => LeaveRequestModel.fromJson(e))
          .toList();
    }
    throw Exception(data["message"] ?? "Failed to fetch leaves");
  }

  // get all leaves report (Pending, Approved, Rejected)
  static Future<List<LeaveRequestModel>> fetchAllLeaveReport() async {
    final res = await request("/hrms/all-leaves-report");
    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data["success"] == true) {
      return (data["data"] as List)
          .map((e) => LeaveRequestModel.fromJson(e))
          .toList();
    }
    throw Exception(data["message"] ?? "Failed to fetch all leaves report");
  }

  // get today's leaves for HR/Manager
  static Future<List<LeaveRequestModel>> fetchTodayLeaves() async {
    final res = await request("/hrms/today-leaves");
    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data["success"] == true) {
      return (data["data"] as List)
          .map((e) => LeaveRequestModel.fromJson(e))
          .toList();
    }
    throw Exception(data["message"] ?? "Failed to fetch today leaves");
  }

  // approve / reject leave by HR or SuperAdmin
  static Future<Map<String, dynamic>> updateLeaveStatus(
    int leaveId,
    String status, {
    String? hrReason,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {"success": false, "error": "No token found"};
      }

      final res = await ApiHrmsService.request(
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

  // cancel pending leave by employee
  static Future<Map<String, dynamic>> cancelLeave(int leaveId) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {"success": false, "error": "No token found"};
      }

      final res = await ApiHrmsService.request(
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

  // ======================== PHASE 2 & 3 ========================

  static Future<List<dynamic>> fetchHolidays() async {
    final res = await request("/hrms/holidays");
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data["success"] == true) {
      return data["data"] as List;
    }
    throw Exception(data["message"] ?? "Failed to fetch holidays");
  }

  static Future<Map<String, dynamic>> punchIn() async {
    try {
      final res = await request("/hrms/attendance/punch-in", method: "POST");
      return jsonDecode(res.body);
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> punchOut() async {
    try {
      final res = await request("/hrms/attendance/punch-out", method: "POST");
      return jsonDecode(res.body);
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>?> fetchTodayAttendance() async {
    final res = await request("/hrms/attendance/today");
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data["success"] == true) {
      return data["data"]; // could be null if no punch in
    }
    return null;
  }

  static Future<List<dynamic>> fetchAttendanceHistory(
    String? startDate,
    String? endDate,
  ) async {
    String query = "";
    if (startDate != null && endDate != null) {
      query = "?startDate=$startDate&endDate=$endDate";
    }
    final res = await request("/hrms/attendance/history$query");
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data["success"] == true) {
      return data["data"] as List;
    }
    throw Exception(data["message"] ?? "Failed to fetch attendance history");
  }

  // ================= ADMIN REPORT & REGULARIZATION =================

  static Future<List<dynamic>> getAdminAttendanceReport(String? date) async {
    String url = "/hrms/attendance/admin-report";
    if (date != null) {
      url += "?date=$date";
    }
    final res = await request(url);
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data["success"] == true) {
      return data["data"] as List;
    }
    throw Exception(data["message"] ?? "Failed to fetch admin report");
  }

  static Future<Map<String, dynamic>> applyRegularization({
    required String targetDate,
    required String reason,
    String? requestedCheckIn,
    String? requestedCheckOut,
  }) async {
    try {
      final res = await request(
        "/hrms/attendance/regularize",
        method: "POST",
        body: {
          "targetDate": targetDate,
          "reason": reason,
          "requestedCheckIn": requestedCheckIn,
          "requestedCheckOut": requestedCheckOut,
        },
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<List<dynamic>> getMyRegularizations() async {
    final res = await request("/hrms/attendance/regularize/my-requests");
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data["success"] == true) {
      return data["data"] as List;
    }
    throw Exception(data["message"] ?? "Failed to fetch regularizations");
  }

  static Future<List<dynamic>> getPendingRegularizations() async {
    final res = await request("/hrms/attendance/regularize/pending");
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data["success"] == true) {
      return data["data"] as List;
    }
    throw Exception(data["message"] ?? "Failed to fetch pending regularizations");
  }

  static Future<Map<String, dynamic>> updateRegularizationStatus(
      int reqId, String status, String hrReason) async {
    try {
      final res = await request(
        "/hrms/attendance/regularize/status",
        method: "PUT",
        body: {
          "reqId": reqId,
          "status": status,
          "hrReason": hrReason,
        },
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }
}
