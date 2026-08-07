import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:task_mate/services/base_api_service.dart';

class UserService {
  // Validate current user
  static Future<Map<String, dynamic>> getCurrentUser() async {
    final token = await BaseApiService.getToken();
    if (token == null) return {"success": false, "error": "No token"};

    try {
      final res = await http.get(
        Uri.parse("${BaseApiService.baseUrl}/auth/me"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["success"] == true && data["user"] != null) {
          return {"success": true, "user": data["user"]};
        }
        return {"success": false, "error": "User not found"};
      }

      return {"success": false, "error": "Server returned ${res.statusCode}"};
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  // Get current logged-in user's role via profile endpoint
  static Future<String?> getCurrentUserRole() async {
    try {
      final token = await BaseApiService.getToken();
      if (token == null) return null;
      final res = await http
          .get(
            Uri.parse("${BaseApiService.baseUrl}/auth/profile"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          )
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["success"] == true && data["user"] != null) {
          return data["user"];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> getUsersByRole(String role) async {
    final token = await BaseApiService.getToken();

    final res = await http.get(
      Uri.parse("${BaseApiService.baseUrl}/users/by-role?role=$role"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getUsersByRoles(
    List<String> roles,
  ) async {
    final token = await BaseApiService.getToken();

    final query = roles.map((r) => "roles=$r").join("&");

    final res = await http.get(
      Uri.parse("${BaseApiService.baseUrl}/users/by-roles?$query"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(res.body);
  }

  /// Fetch all Admin users
  static Future<Map<String, dynamic>> getAdmins() async {
    try {
      final token = await BaseApiService.getToken();

      if (token == null) return {"success": false, "error": "No token found"};

      final res = await http.get(
        Uri.parse('${BaseApiService.baseUrl}/auth/admins'),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return {"success": true, "admins": data["admins"] ?? []};
      } else {
        return {
          "success": false,
          "error": "Failed to fetch admins (${res.statusCode})",
        };
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<String?> uploadAvatar(File file) async {
    final token = await BaseApiService.getToken();
    if (token == null) throw Exception("User token not found");

    final request = http.MultipartRequest(
      "POST",
      Uri.parse("${BaseApiService.baseUrl}/auth/upload"),
    );

    request.headers["Authorization"] = "Bearer $token";

    // Attach file
    request.files.add(await http.MultipartFile.fromPath("avatar", file.path));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["url"];
    } else {
      throw Exception("Failed to upload avatar: ${response.body}");
    }
  }

  // show admin / employee
  static Future<List<dynamic>> fetchEmployees() async {
    try {
      final token = await BaseApiService.getToken();

      final res = await http.get(
        Uri.parse("${BaseApiService.baseUrl}/admin/employee"),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data["success"] == true) {
        return data["employees"] ?? [];
      }
      throw Exception(data["error"] ?? "Failed to fetch employees");
    } catch (e) {
      rethrow;
    }
  }

  // delete employee (Admin or Superadmin)
  static Future<bool> deleteEmployee(int empId) async {
    final token = await BaseApiService.getToken();

    if (token == null) return false;

    try {
      final res = await http.post(
        Uri.parse("${BaseApiService.baseUrl}/admin/employee/$empId"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["success"] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Check if user exists by email (Only admin)
  static Future<bool> checkUserByEmail(String email) async {
    try {
      final token = await BaseApiService.getToken();

      final res = await http.post(
        Uri.parse("${BaseApiService.baseUrl}/admin/check_email"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"email": email}),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return data["exists"] == true;
      } else {
        throw Exception(data["error"] ?? "Failed to check email");
      }
    } catch (e) {
      rethrow;
    }
  }
}
