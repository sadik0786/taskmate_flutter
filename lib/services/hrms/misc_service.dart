import 'dart:convert';
import 'package:task_mate/model/user_request_model.dart';
import 'package:task_mate/services/base_api_service.dart';

class MiscService {
  static Future<List<UserRequestModel>> allEmployee() async {
    final res = await BaseApiService.request("/hrms/all-employee");
    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data["success"] == true) {
      return (data["data"] as List)
          .map((e) => UserRequestModel.fromJson(e))
          .toList();
    }
    throw Exception(data["error"] ?? "Failed to fetch employee");
  }

  static Future<List<dynamic>> fetchMyPayslips() async {
    final res = await BaseApiService.request("/hrms/my-payslips");
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data["success"] == true) {
      return data["data"] as List;
    }
    throw Exception(data["message"] ?? "Failed to fetch payslips");
  }

  static Future<List<dynamic>> fetchTodayEvents() async {
    try {
      final res = await BaseApiService.request("/hrms/today-events");
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data["success"] == true) {
        return data["data"] as List;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> fetchHolidays() async {
    final res = await BaseApiService.request("/hrms/holidays");
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data["success"] == true) {
      return data["data"] as List;
    }
    throw Exception(data["message"] ?? "Failed to fetch holidays");
  }
}
