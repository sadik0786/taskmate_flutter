import 'dart:convert';
import 'package:task_mate/services/base_api_service.dart';

class AttendanceService {
  static Future<Map<String, dynamic>> punchIn() async {
    try {
      final res = await BaseApiService.request("/hrms/attendance/punch-in", method: "POST");
      return jsonDecode(res.body);
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> punchOut() async {
    try {
      final res = await BaseApiService.request("/hrms/attendance/punch-out", method: "POST");
      return jsonDecode(res.body);
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> takeBreak() async {
    try {
      final res = await BaseApiService.request("/hrms/attendance/take-break", method: "POST");
      return jsonDecode(res.body);
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> endBreak() async {
    try {
      final res = await BaseApiService.request("/hrms/attendance/end-break", method: "POST");
      return jsonDecode(res.body);
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>?> fetchTodayAttendance() async {
    final res = await BaseApiService.request("/hrms/attendance/today");
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
    final res = await BaseApiService.request("/hrms/attendance/history$query");
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data["success"] == true) {
      return data["data"] as List;
    }
    throw Exception(data["message"] ?? "Failed to fetch attendance history");
  }

  static Future<List<dynamic>> getAdminAttendanceReport(String? date) async {
    String url = "/hrms/attendance/admin-report";
    if (date != null) {
      url += "?date=$date";
    }
    final res = await BaseApiService.request(url);
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data["success"] == true) {
      return data["data"] as List;
    }
    throw Exception(data["message"] ?? "Failed to fetch admin report");
  }
}
