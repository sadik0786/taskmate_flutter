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

final String baseUrl = dotenv.env['baseApiUrl'] ?? '';

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
          response = await http.post(uri, headers: headers, body: jsonEncode(body));
          break;
        case "PUT":
          response = await http.put(uri, headers: headers, body: jsonEncode(body));
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
      return (data["data"] as List).map((e) => UserRequestModel.fromJson(e)).toList();
    }

    throw Exception(data["error"] ?? "Failed to fetch employee");
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
      return (data["data"] as List).map((e) => LeaveRequestModel.fromJson(e)).toList();
    }
    throw Exception(data["error"] ?? "Failed to fetch leaves");
  }

  // apply leave request
  static Future<Map<String, dynamic>> applyLeave(LeaveApplyRequestModel request) async {
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
      return (data["data"] as List).map((e) => LeaveRequestModel.fromJson(e)).toList();
    }
    throw Exception(data["message"] ?? "Failed to fetch leaves");
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

  ///
}
