// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/core/routes.dart';

class ApiService {
  static const baseUrl = "http://taskmateapi.5nance.com/api"; // uat server

  /// ------------------- Token Management -------------------
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<int?> getLoggedInUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("userId");
  }

  /// ------------------- Internet Check -------------------
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // Test if your server is reachable
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/")).timeout(Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      print("Connection test failed: $e");
      return false;
    }
  }

  /// ------------------- Common API Call Handler -------------------
  // In your ApiService class, update the _handleRequest method:

  static Future<Map<String, dynamic>> _handleRequest(Future<http.Response> request) async {
    Map<String, dynamic> parseResponse(String body) {
      try {
        // Handle empty response
        if (body.isEmpty) {
          return {"success": false, "error": "Empty response from server"};
        }

        // Handle plain text responses like "Bad Request"
        if (!body.trim().startsWith('{') && !body.trim().startsWith('[')) {
          return {"success": false, "error": "Server error: $body", "rawResponse": body};
        }

        final data = jsonDecode(body);
        if (data is Map<String, dynamic>) return data;

        return {"success": false, "error": "Invalid response format"};
      } catch (e) {
        print("❌ JSON Parse Error: $e");
        print("📄 Raw response body: '$body'");
        return {"success": false, "error": "Network error: $e", "rawResponse": body};
      }
    }

    try {
      if (!await hasInternetConnection()) {
        return {"success": false, "error": "No internet connection. Please check your network."};
      }

      final res = await request.timeout(const Duration(seconds: 15));

      print("🔹 API Response Status: ${res.statusCode}");
      print("🔹 API Response Headers: ${res.headers}");
      print("🔹 API Response Body: '${res.body}'");

      final data = parseResponse(res.body);

      switch (res.statusCode) {
        case 200:
        case 201:
          return data;

        case 400:
          print("❌ Bad Request - Full details:");
          print("   - URL: ${res.request?.url}");
          print("   - Method: ${res.request?.method}");
          if (res.request?.headers != null) {
            final safeHeaders = Map<String, String>.from(res.request!.headers);
            safeHeaders['Authorization'] = 'Bearer ***';
            print("   - Headers: $safeHeaders");
          }

          // Return the parsed error or raw response
          final errorMsg = data['error'] ?? data['message'] ?? "Invalid request parameters";
          return {"success": false, "error": errorMsg, "statusCode": 400};

        case 401:
          await clearToken();
          Get.offAllNamed(Routes.login);
          return {"success": false, "error": "Session expired. Please login again."};

        case 403:
          return {"success": false, "error": "Access denied. Insufficient permissions."};

        case 404:
          return {"success": false, "error": "Resource not found."};

        case 500:
          return {"success": false, "error": "Server error. Please try again later."};

        default:
          return {
            "success": false,
            "error": data['error'] ?? "Unexpected error occurred (${res.statusCode})",
            "statusCode": res.statusCode,
          };
      }
    } on SocketException catch (e) {
      print("Socket Exception: $e");
      return {"success": false, "error": "No internet connection. Please check your network."};
    } on TimeoutException catch (e) {
      print("Timeout Exception: $e");
      return {"success": false, "error": "Request timed out. Please try again."};
    } on http.ClientException catch (e) {
      print("HTTP Client Exception: $e");
      return {"success": false, "error": "Network error. Please check your connection."};
    } catch (e) {
      print("Unexpected Error in _handleRequest: $e");
      return {"success": false, "error": "Something went wrong: ${e.toString()}"};
    }
  }

  static void _logRequest(
    String method,
    String url,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) {
    print("🔹 API Request:");
    print("   - Method: $method");
    print("   - URL: $url");
    if (body != null) {
      print("   - Body: ${jsonEncode(body)}");
    }
    if (headers != null) {
      final safeHeaders = Map.from(headers);
      safeHeaders['Authorization'] = 'Bearer ***'; // Hide token in logs
      print("   - Headers: $safeHeaders");
    }
  }

  /// ------------------- Auth APIs -------------------
  static Future<Map<String, dynamic>> getCurrentUser() async {
    final token = await getToken();
    if (token == null) {
      return {"success": false, "error": "User not logged in."};
    }

    return _handleRequest(
      http.get(Uri.parse("$baseUrl/auth/me"), headers: {"Authorization": "Bearer $token"}),
    );
  }

  static Future<Map<String, dynamic>> getRoles() async {
    final token = await getToken();
    if (token == null) {
      return {"success": false, "error": "Authentication required"};
    }

    return _handleRequest(
      http.get(
        Uri.parse("$baseUrl/auth/roles"),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
      ),
    );
  }

  static Future<Map<String, dynamic>> checkEmailExists(String email) async {
    final token = await getToken();
    if (token == null) {
      return {"success": false, "error": "Authentication required"};
    }

    return _handleRequest(
      http.post(
        Uri.parse("$baseUrl/auth/checkemail"),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
        body: jsonEncode({"email": email}),
      ),
    );
  }

  static Future<Map<String, dynamic>> getAdmins() async {
    final token = await getToken();
    if (token == null) {
      return {"success": false, "error": "Authentication required"};
    }

    return _handleRequest(
      http.get(Uri.parse("$baseUrl/auth/admins"), headers: {"Authorization": "Bearer $token"}),
    );
  }

  static Future<Map<String, dynamic>> registerEmployee(
    String name,
    String email,
    String password,
    int roleId, {
    String? mobile,
    int? reportingId,
  }) async {
    final token = await getToken();
    if (token == null) {
      return {"success": false, "error": "Authentication required"};
    }

    final body = {
      "name": name,
      "email": email,
      "password": password,
      "roleId": roleId,
      if (mobile != null && mobile.isNotEmpty) "mobile": mobile,
      if (reportingId != null) "reportingId": reportingId,
    };

    return _handleRequest(
      http.post(
        Uri.parse("$baseUrl/auth/register"),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
        body: jsonEncode(body),
      ),
    );
  }

  static Future<Map<String, dynamic>> updateMobile(String mobile) async {
    final token = await getToken();
    if (token == null) {
      return {"success": false, "error": "Authentication required"};
    }

    return _handleRequest(
      http.post(
        Uri.parse("$baseUrl/auth/mobileUpdate"),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
        body: jsonEncode({"mobile": mobile}),
      ),
    );
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = '$baseUrl/auth/login';

    // Log the full request details
    print("🔹 Making login request to: $url");
    print("🔹 Request body: ${{'email': email, 'password': '***'}}");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'email': email.trim(), 'password': password.trim()}),
      );

      print("🔹 Response status: ${response.statusCode}");
      print("🔹 Response headers: ${response.headers}");
      print("🔹 Response body: '${response.body}'");

      // Handle non-JSON responses
      if (response.statusCode == 400) {
        return {
          "success": false,
          "error": "Invalid credentials or server configuration issue",
          "statusCode": 400,
          "rawResponse": response.body,
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['token'] != null) {
        return {"success": true, "token": data['token'], "user": data['user'] ?? data};
      } else {
        return {
          "success": false,
          "error": data['error'] ?? data['message'] ?? 'Login failed',
          "statusCode": response.statusCode,
        };
      }
    } catch (e) {
      print("❌ Login request failed: $e");
      return {"success": false, "error": "Network error: $e"};
    }
  }

  static Future<String?> getCurrentUserRole() async {
    final token = await getToken();
    if (token == null) return null;

    final data = await _handleRequest(
      http.get(
        Uri.parse("$baseUrl/auth/profile"),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
      ),
    );

    if (data['success'] == true && data['user'] != null) {
      return (data["user"]["roleName"] ?? data["user"]["role"] ?? "").toString().toLowerCase();
    }

    return null;
  }

  /// ------------------- User Management -------------------
  static Future<Map<String, dynamic>> getUsers() async {
    final token = await getToken();
    if (token == null) {
      return {"success": false, "error": "Authentication required"};
    }

    return _handleRequest(
      http.get(
        Uri.parse("$baseUrl/users"),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
      ),
    );
  }

  /// ------------------- Task Management -------------------
  static Future<Map<String, dynamic>> getTasks() async {
    final token = await getToken();
    if (token == null) {
      return {"success": false, "error": "Authentication required"};
    }

    return _handleRequest(
      http.get(
        Uri.parse("$baseUrl/tasks"),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
      ),
    );
  }

  static Future<Map<String, dynamic>> createTask({
    required int projectId,
    required int subProjectId,
    required String title,
    required String taskDetails,
    required String mode,
    required String status,
    required String startDate,
    required String endDate,
    required int createdBy,
  }) async {
    final token = await getToken();
    if (token == null) {
      return {"success": false, "error": "Authentication required"};
    }

    final taskData = {
      "ProjectID": projectId,
      "SubProjectID": subProjectId,
      "title": title.trim(),
      "taskDetails": taskDetails.trim(),
      "mode": mode,
      "status": status,
      "startDate": startDate,
      "endDate": endDate,
      "CreatedBy": createdBy,
    };

    return _handleRequest(
      http.post(
        Uri.parse("$baseUrl/task/addTask"),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
        body: jsonEncode(taskData),
      ),
    );
  }

  static Future<Map<String, dynamic>> updateTask({
    required int taskId,
    required int projectId,
    required int subProjectId,
    required String title,
    required String taskDetails,
    required String mode,
    required String status,
    required String startDate,
    required String endDate,
  }) async {
    final token = await getToken();
    if (token == null) {
      return {"success": false, "error": "Authentication required"};
    }

    final updateTaskData = {
      "ProjectID": projectId,
      "SubProjectID": subProjectId,
      "title": title,
      "taskDetails": taskDetails,
      "mode": mode,
      "status": status,
      "startDate": startDate,
      "endDate": endDate,
    };

    return _handleRequest(
      http.post(
        Uri.parse("$baseUrl/task/updateTask/$taskId"),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
        body: jsonEncode(updateTaskData),
      ),
    );
  }

  static Future<Map<String, dynamic>> deleteTask(int taskId) async {
    final token = await getToken();
    if (token == null) {
      return {"success": false, "error": "Authentication required"};
    }

    return _handleRequest(
      http.post(
        Uri.parse("$baseUrl/task/deleteTask/$taskId"),
        headers: {"Authorization": "Bearer $token"},
      ),
    );
  }

  static Future<Map<String, dynamic>> fetchTasks() async {
    final token = await getToken();
    if (token == null) {
      return {"success": false, "error": "Authentication required"};
    }

    return _handleRequest(
      http.get(Uri.parse("$baseUrl/task/getTask"), headers: {"Authorization": "Bearer $token"}),
    );
  }

  /// ------------------- Profile Management -------------------
  static Future<Map<String, dynamic>> uploadAvatar(File file) async {
    final token = await getToken();
    if (token == null) {
      return {"success": false, "error": "Authentication required"};
    }

    try {
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      return _handleRequest(
        http.post(
          Uri.parse("$baseUrl/auth/upload"),
          headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
          body: jsonEncode({"avatar": base64Image}),
        ),
      );
    } catch (e) {
      return {"success": false, "error": "Failed to upload avatar: ${e.toString()}"};
    }
  }

  /// ------------------- Admin APIs -------------------
  static Future<Map<String, dynamic>> fetchEmployees() async {
    final token = await getToken();
    if (token == null) {
      return {"success": false, "error": "Authentication required"};
    }

    return _handleRequest(
      http.get(Uri.parse("$baseUrl/admin/employee"), headers: {"Authorization": "Bearer $token"}),
    );
  }

  // FIXED: Changed from POST to DELETE
  static Future<Map<String, dynamic>> deleteEmployee(int empId) async {
    final token = await getToken();
    if (token == null) {
      return {"success": false, "error": "Authentication required"};
    }

    return _handleRequest(
      http.delete(
        // ← CORRECTED: Changed from .post to .delete
        Uri.parse("$baseUrl/admin/employee/$empId"),
        headers: {"Authorization": "Bearer $token"},
      ),
    );
  }

  static Future<Map<String, dynamic>> checkUserByEmail(String email) async {
    final token = await getToken();
    if (token == null) {
      return {"success": false, "error": "Authentication required"};
    }

    return _handleRequest(
      http.post(
        Uri.parse("$baseUrl/admin/check_email"),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
        body: jsonEncode({"email": email}),
      ),
    );
  }

  static Future<Map<String, dynamic>> changePassword(String email, String newPassword) async {
    final token = await getToken();
    if (token == null) {
      return {"success": false, "error": "Authentication required"};
    }

    return _handleRequest(
      http.post(
        Uri.parse("$baseUrl/admin/reset_password"),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
        body: jsonEncode({"email": email, "newPassword": newPassword}),
      ),
    );
  }

  static Future<Map<String, dynamic>> addProject(String projectName) async {
    final token = await getToken();
    if (token == null) {
      return {"success": false, "error": "Authentication required"};
    }

    return _handleRequest(
      http.post(
        Uri.parse("$baseUrl/admin/addProject"),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
        body: jsonEncode({"projectName": projectName}),
      ),
    );
  }

  static Future<Map<String, dynamic>> fetchProjects() async {
    final token = await getToken();
    if (token == null) {
      return {"success": false, "error": "Authentication required"};
    }

    return _handleRequest(
      http.get(
        Uri.parse("$baseUrl/admin/listProject"),
        headers: {"Authorization": "Bearer $token"},
      ),
    );
  }

  static Future<Map<String, dynamic>> addSubProject({
    required int projectId,
    required String subProjectName,
  }) async {
    final token = await getToken();
    if (token == null) {
      return {"success": false, "error": "Authentication required"};
    }

    return _handleRequest(
      http.post(
        Uri.parse("$baseUrl/admin/addSubProject"),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
        body: jsonEncode({"projectId": projectId, "subProjectName": subProjectName}),
      ),
    );
  }

  static Future<Map<String, dynamic>> fetchSubProjects() async {
    final token = await getToken();
    if (token == null) {
      return {"success": false, "error": "Authentication required"};
    }

    return _handleRequest(
      http.get(
        Uri.parse("$baseUrl/admin/listSubProject"),
        headers: {"Authorization": "Bearer $token"},
      ),
    );
  }

  static Future<Map<String, dynamic>> fetchTasksByEmployee(int empId) async {
    final token = await getToken();
    if (token == null) {
      return {"success": false, "error": "Authentication required"};
    }

    return _handleRequest(
      http.get(
        Uri.parse("$baseUrl/admin/emp_tasks/$empId"),
        headers: {"Authorization": "Bearer $token"},
      ),
    );
  }

  static Future<Map<String, dynamic>> fetchAllTasksByEmployee() async {
    final token = await getToken();
    if (token == null) {
      return {"success": false, "error": "Authentication required"};
    }

    return _handleRequest(
      http.get(
        Uri.parse("$baseUrl/admin/all_task_emp"),
        headers: {"Authorization": "Bearer $token"},
      ),
    );
  }

  static Future<Map<String, dynamic>> fetchAllAdminTasks() async {
    final token = await getToken();
    if (token == null) {
      return {"success": false, "error": "Authentication required"};
    }

    return _handleRequest(
      http.get(
        Uri.parse("$baseUrl/admin/all_task_admin"),
        headers: {"Authorization": "Bearer $token"},
      ),
    );
  }

  /// ------------------- Public APIs -------------------
  static Future<Map<String, dynamic>> forgotPasswordRequest(String email) async {
    return _handleRequest(
      http.post(
        Uri.parse("$baseUrl/auth/forgot_password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      ),
    );
  }

  static Future<Map<String, dynamic>> resetPasswordSelf(String email, String newPassword) async {
    return _handleRequest(
      http.post(
        Uri.parse("$baseUrl/auth/reset_password_self"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "newPassword": newPassword}),
      ),
    );
  }
}
