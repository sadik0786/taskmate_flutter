import 'dart:convert';
import 'package:task_mate/services/base_api_service.dart';

class RegularizationService {
  static Future<Map<String, dynamic>> applyRegularization({
    required String targetDate,
    required String reason,
    String? requestedCheckIn,
    String? requestedCheckOut,
  }) async {
    try {
      final res = await BaseApiService.request(
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
    final res = await BaseApiService.request("/hrms/attendance/regularize/my-requests");
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data["success"] == true) {
      return data["data"] as List;
    }
    throw Exception(data["message"] ?? "Failed to fetch regularizations");
  }

  static Future<List<dynamic>> getPendingRegularizations() async {
    final res = await BaseApiService.request("/hrms/attendance/regularize/pending");
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data["success"] == true) {
      return data["data"] as List;
    }
    throw Exception(
      data["message"] ?? "Failed to fetch pending regularizations",
    );
  }

  static Future<Map<String, dynamic>> updateRegularizationStatus(
    int reqId,
    String status,
    String hrReason,
  ) async {
    try {
      final res = await BaseApiService.request(
        "/hrms/attendance/regularize/status",
        method: "PUT",
        body: {"reqId": reqId, "status": status, "hrReason": hrReason},
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }
}
