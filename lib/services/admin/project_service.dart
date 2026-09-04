import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:task_mate/services/base_api_service.dart';

class ProjectService {
  static Future<Map<String, dynamic>> addProject(String projectName) async {
    final token = await BaseApiService.getToken();

    final res = await http.post(
      Uri.parse("${BaseApiService.baseUrl}/admin/addProject"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"projectName": projectName}),
    );
    return jsonDecode(res.body);
  }

  // Get all projects
  static Future<List<dynamic>> fetchProjects() async {
    final token = await BaseApiService.getToken();

    final res = await http.get(
      Uri.parse("${BaseApiService.baseUrl}/admin/listProject"),
      headers: {"Authorization": "Bearer $token"},
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data["success"] == true) {
      return List<Map<String, dynamic>>.from(data["projects"]);
    } else {
      throw Exception(data["error"] ?? "Failed to fetch projects");
    }
  }

  // Add sub project  (Only admin)
  static Future<Map<String, dynamic>> addSubProject({
    required int projectId,
    required String subProjectName,
  }) async {
    final token = await BaseApiService.getToken();

    final res = await http.post(
      Uri.parse("${BaseApiService.baseUrl}/admin/addSubProject"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "projectId": projectId,
        "subProjectName": subProjectName,
      }),
    );
    try {
      return jsonDecode(res.body);
    } catch (e) {
      return {
        "success": false,
        "error": "Server error: ${res.statusCode} ${res.body}",
      };
    }
  }

  // Get all sub projects
  static Future<List<dynamic>> fetchSubProjects() async {
    try {
      final token = await BaseApiService.getToken();

      final url = "${BaseApiService.baseUrl}/admin/listSubProject";

      final res = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["success"] == true) {
          return List<Map<String, dynamic>>.from(data["subProjects"] ?? []);
        } else {
          throw Exception(data["error"] ?? "API returned success: false");
        }
      } else {
        throw Exception("HTTP ${res.statusCode}: ${res.body}");
      }
    } catch (e) {
      rethrow;
    }
  }
}
