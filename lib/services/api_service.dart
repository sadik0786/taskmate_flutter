// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/core/routes.dart';

class ApiService {
  // static const baseUrl = "http://10.0.2.2:5000/api"; // Android Emulator
  // static const baseUrl = "http://192.168.1.117:5000/api"; // office wi-fi
  // static const baseUrl = "http://10.117.30.58:5000/api"; // mobile network
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
    } on SocketException catch (_) {
      return false;
    } on Exception {
      return false;
    }
  }

  // Validate current user
  static Future<Map<String, dynamic>> getCurrentUser() async {
    final token = await getToken();
    if (token == null) return {"success": false, "error": "No token"};

    try {
      final res = await http.get(
        Uri.parse("$baseUrl/auth/me"),
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

  // GET roles (server already filters based on logged-in user's role)
  static Future<Map<String, dynamic>> getRoles() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {"success": false, "error": "Authentication required"};
      }

      final res = await http
          .get(
            Uri.parse("$baseUrl/auth/roles"),
            headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return data;
      } else {
        return {
          "success": false,
          "error": data['error'] ?? "Failed to fetch roles (${res.statusCode})",
        };
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> checkEmailExists(String email) async {
    try {
      final token = await getToken();

      if (token == null) return {"success": false, "error": "No token found"};

      final res = await http.post(
        Uri.parse("$baseUrl/auth/checkemail"),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
        body: jsonEncode({"email": email}),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return {
          "success": true,
          "emailExists": data['emailExists'] ?? false,
          "message": data['message'],
        };
      } else {
        return {
          "success": false,
          "error": data['error'] ?? "Email check failed (${res.statusCode})",
        };
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  /// Fetch all Admin users
  static Future<Map<String, dynamic>> getAdmins() async {
    try {
      final token = await getToken();

      if (token == null) return {"success": false, "error": "No token found"};

      final res = await http.get(
        Uri.parse('$baseUrl/auth/admins'),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return {"success": true, "admins": data["admins"] ?? []};
      } else {
        return {"success": false, "error": "Failed to fetch admins (${res.statusCode})"};
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  // Register employee/admin
  static Future<Map<String, dynamic>> registerEmployee(
    String name,
    String email,
    String password,
    int roleId, {
    String? mobile,
    int? reportingId,
  }) async {
    try {
      final token = await getToken();
      // print('TOKEN: $token');

      if (token == null) return {"success": false, "error": "No token found"};

      final body = {
        "name": name,
        "email": email,
        "password": password,
        "roleId": roleId,
        if (mobile != null && mobile.isNotEmpty) "mobile": mobile,
        if (reportingId != null) "reportingId": reportingId,
      };

      final res = await http.post(
        Uri.parse("$baseUrl/auth/register"),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
        body: jsonEncode(body),
      );

      // print('STATUS CODE: ${res.statusCode}'); // Add this
      print('RESPONSE: ${res.body}');

      final data = jsonDecode(res.body);

      if (data["success"] == true) {
        return {"success": true, ...data};
      } else {
        return {
          "success": false,
          "error": data['error'] ?? "Registration failed (${res.statusCode})",
        };
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  //update mobile
  static Future<bool> updateMobile(String mobile) async {
    try {
      final token = await getToken();

      final res = await http.post(
        Uri.parse("$baseUrl/auth/mobileUpdate"),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
        body: jsonEncode({"mobile": mobile}),
      );
      return res.statusCode == 200;
    } catch (e) {
      print("updateMobile error: $e");
      return false;
    }
  }

  // Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {

      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(res.body);

      if (data["success"] == true) {
        if (data['token'] != null && data['user'] != null) {
          print('TOKEN: ${data['token']}');
          await saveToken(data['token']);

          final prefs = await SharedPreferences.getInstance();
          final user = data['user'];

          // Save all hierarchy information
          await prefs.setInt('userId', user['id'] ?? 0);
          await prefs.setString('name', user['name'] ?? '');
          await prefs.setString('email', user['email'] ?? '');
          await prefs.setString('mobile', user['mobile'] ?? '');
          await prefs.setInt('roleId', user['roleId'] ?? 0);
          await prefs.setString('role', (user['role'] ?? '').toString().toLowerCase());
          return {'success': true, 'token': data['token'], 'user': data['user']};
        } else {
          return {'success': false, 'error': data['error'] ?? 'Invalid response from server'};
        }
      } else {
        return {
          'success': false,
          'error': data['message'] ?? data['error'] ?? 'Login failed (${res.statusCode})',
        };

      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Get current logged-in user's role via profile endpoint
  static Future<String?> getCurrentUserRole() async {
    final token = await ApiService.getToken();
    if (token == null) return null;
    try {
      // final token = await getToken();
      // if (token == null) return null;

      final res = await http
          .get(
            Uri.parse("$baseUrl/auth/profile"),
            headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
          )
          .timeout(const Duration(seconds: 10));

      // if (res.statusCode == 200) {
      //   final data = jsonDecode(res.body);
      //   return (data["user"]?["roleName"] ?? data["user"]?["role"] ?? "").toString().toLowerCase();
      // }
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

  //

  // NEW: Get Users with Hierarchy
  static Future<Map<String, dynamic>> getUsers() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {"success": false, "error": "Authentication required"};
      }

      final res = await http
          .get(
            Uri.parse("$baseUrl/users"),
            headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return data;
      } else {
        return {
          "success": false,
          "error": data['error'] ?? "Failed to fetch users (${res.statusCode})",
        };
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  // NEW: Get Tasks with Hierarchy
  static Future<Map<String, dynamic>> getTasks() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {"success": false, "error": "Authentication required"};
      }

      final res = await http
          .get(
            Uri.parse("$baseUrl/tasks"),
            headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return data;
      } else {
        return {
          "success": false,
          "error": data['error'] ?? "Failed to fetch tasks (${res.statusCode})",
        };
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  // NEW: Create Task
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
    try {
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
      print("📤 Sent from Flutter: ${jsonEncode(taskData)}");

      final res = await http.post(
        Uri.parse("$baseUrl/task/addTask"),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
        body: jsonEncode(taskData),
      );
      print("📥 Response status: ${res.statusCode}");
      print("📥 Response body: ${res.body}");

      return jsonDecode(res.body);
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  // Update an existing task
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
    try {
      final token = await getToken();
      if (token == null) {
        return {"success": false, "error": "Authentication required"};
      }
      final updateTaskData = {
        // "taskId": taskId,
        "ProjectID": projectId,
        "SubProjectID": subProjectId,
        "title": title,
        "taskDetails": taskDetails,
        "mode": mode,
        "status": status,
        "startDate": startDate,
        "endDate": endDate,
      };
      print("📤 Sent from Flutter: ${jsonEncode(updateTaskData)}");
      final url = Uri.parse("$baseUrl/task/updateTask/$taskId");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
        body: jsonEncode(updateTaskData),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return {
          "success": false,
          "error": "Failed to update task. Status code: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  // Delete task
  static Future<Map<String, dynamic>> deleteTask(int taskId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        return {"success": false, "error": "Authentication required"};
      }

      final res = await http.post(
        Uri.parse("$baseUrl/task/deleteTask/$taskId"),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return data;
      } else {
        return {"success": false, "error": data["error"] ?? "Failed to delete task"};
      }
    } catch (e) {
      print("❌ deleteTask error: $e");
      return {"success": false, "error": "Network error: ${e.toString()}"};
    }
  }

  // get task admin / employee
  static Future<List<dynamic>> fetchTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) return [];

      final res = await http.get(
        Uri.parse("$baseUrl/task/getTask"),
        headers: {"Authorization": "Bearer $token"},
      );

      print("📥 Tasks API Response status: ${res.statusCode}");

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data["success"] == true) {
        final tasks = data["tasks"] ?? [];

        print("✅ Successfully loaded ${tasks.length} tasks");

        return tasks.map<Map<String, dynamic>>((task) {
          return {
            "id": task["id"]?.toString() ?? "",
            "project": task["project"]?.toString() ?? "Unknown Project",
            "subProject": task["subProject"]?.toString() ?? "Unknown Sub Project",
            "title": task["title"]?.toString() ?? "",
            "description": task["description"]?.toString() ?? "",
            "mode": task["mode"]?.toString() ?? "",
            "status": task["status"]?.toString() ?? "",
            "startTime": task["startTime"]?.toString() ?? "",
            "endTime": task["endTime"]?.toString() ?? "",
            "createdAt": task["createdAt"]?.toString() ?? "",
            "projectId": task["projectId"],
            "subProjectId": task["subProjectId"],
            "userId": task["userId"],
            "userName": task["userName"]?.toString() ?? "",
            "userEmail": task["userEmail"]?.toString() ?? "",
          };
        }).toList();
      } else {
        throw Exception(data["error"] ?? "Failed to fetch tasks");
      }
    } catch (e) {
      print("❌ Error fetching tasks: $e");
      return [];
    }
  }

  // 🔑 Common request function
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
    http.Response response;
    try {
      if (method == "POST") {
        response = await http.post(
          Uri.parse("$baseUrl$endpoint"),
          headers: headers,
          body: jsonEncode(body),
        );
      } else if (method == "PUT") {
        response = await http.post(
          Uri.parse("$baseUrl$endpoint"),
          headers: headers,
          body: jsonEncode(body),
        );
      } else if (method == "DELETE") {
        response = await http.post(Uri.parse("$baseUrl$endpoint"), headers: headers);
      } else {
        response = await http.get(Uri.parse("$baseUrl$endpoint"), headers: headers);
      }
    } catch (e) {
      rethrow; // Network error etc.
    }
    // Check for expired/invalid token
    if (response.statusCode == 401) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Get.offAllNamed(Routes.login); // redirect to login
    }
    return response;
  }

  /*--------------------
   Employee APIs
   --------------------*/
  // add profile photo
  static Future<String?> uploadAvatar(File file) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) throw Exception("User token not found");

    final request = http.MultipartRequest("POST", Uri.parse("$baseUrl/auth/upload"));

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

  /*--------------------
  ----------------------
   API - only for admin start 
   --------------------
   --------------------
   */
  // show admin / employee
  static Future<List<dynamic>> fetchEmployees() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final res = await http.get(
        Uri.parse("$baseUrl/admin/employee"),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data["success"] == true) {
        return data["employees"] ?? [];
      }
      throw Exception(data["error"] ?? "Failed to fetch employees");
    } catch (e) {
      print("Error fetching employees: $e");
      rethrow;
    }
  }

  // delete employee (Admin or Superadmin)
  static Future<bool> deleteEmployee(int empId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) return false;

    try {
      final res = await http.post(
        Uri.parse("$baseUrl/admin/employee/$empId"),
        headers: {"Authorization": "Bearer $token"},
      );
      print("Delete response: ${res.statusCode} -> ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["success"] == true;
      } else {
        final data = jsonDecode(res.body);
        print("Delete failed: ${data["error"]}");
      }
      return false;
    } catch (e) {
      print("Delete employee  error: $e");
      return false;
    }
  }

  // Check if user exists by email (Only admin)
  static Future<bool> checkUserByEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final res = await http.post(
        Uri.parse("$baseUrl/admin/check_email"),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
        body: jsonEncode({"email": email}),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return data["exists"] == true;
      } else {
        throw Exception(data["error"] ?? "Failed to check email");
      }
    } catch (e) {
      print("Error checking email: $e");
      rethrow;
    }
  }

  // Change password (Only admin)
  static Future<Map<String, dynamic>> changePassword(String email, String newPassword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final res = await http.post(
        Uri.parse("$baseUrl/admin/reset_password"),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
        body: jsonEncode({"email": email, "newPassword": newPassword}),
      );
      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return data;
      } else {
        throw Exception(data["error"] ?? "Failed to reset password");
      }
    } catch (e) {
      print("Error changing password: $e");
      rethrow;
    }
  }

  // Add project  (Only admin)
  static Future<Map<String, dynamic>> addProject(String projectName) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.post(
      Uri.parse("$baseUrl/admin/addProject"),
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
      body: jsonEncode({"projectName": projectName}),
    );
    return jsonDecode(res.body);
  }

  // Get all projects
  static Future<List<dynamic>> fetchProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("$baseUrl/admin/listProject"),
      headers: {"Authorization": "Bearer $token"},
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data["success"] == true) {
      // return data["projects"] ?? [];
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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.post(
      Uri.parse("$baseUrl/admin/addSubProject"),
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
      body: jsonEncode({"projectId": projectId, "subProjectName": subProjectName}),
    );
    return jsonDecode(res.body);
  }

  // Get all sub projects
  static Future<List<dynamic>> fetchSubProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final url = "$baseUrl/admin/listSubProject";
      // print("🌐 Calling SubProjects API: $url");
      // print("🔑 Token available: ${token != null && token.isNotEmpty}");

      final res = await http.get(Uri.parse(url), headers: {"Authorization": "Bearer $token"});
      // print("📡 Response status: ${res.statusCode}");
      // print("📡 Response headers: ${res.headers}");
      // print("📡 Response body: ${res.body}");
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["success"] == true) {
          // print("✅ SubProjects fetched successfully: ${data["subProjects"]?.length ?? 0} items");
          return List<Map<String, dynamic>>.from(data["subProjects"] ?? []);
        } else {
          throw Exception(data["error"] ?? "API returned success: false");
        }
      } else {
        throw Exception("HTTP ${res.statusCode}: ${res.body}");
      }
    } catch (e) {
      print("❌ fetchSubProjects error: $e");
      rethrow;
    }
  }

  // show employee task (Only admin)
  static Future<List<dynamic>> fetchTasksByEmployee(int empId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      // Uri.parse("$baseUrl/admin/emp_tasks/$empId"),
      Uri.parse("$baseUrl/admin/emp_tasks/$empId"),
      headers: {"Authorization": "Bearer ${token ?? ''}"},
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data["success"] == true) {
      return data["tasks"] ?? [];
    } else {
      throw Exception(data["error"] ?? "Failed to fetch tasks");
    }
  }

  // show all employee task (Only admin)
  static Future<List<dynamic>> fetchAllTasksByEmployee() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("$baseUrl/admin/all_task_emp"),
      headers: {"Authorization": "Bearer ${token ?? ''}"},
    );
    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data["success"] == true) {
      return data["tasks"] ?? [];
    } else {
      throw Exception(data["error"] ?? "Failed to fetch tasks");
    }
  }

  // show all admin tasks (Only Superadmin)
  static Future<List<dynamic>> fetchAllAdminTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("$baseUrl/admin/all_task_admin"),
      headers: {"Authorization": "Bearer ${token ?? ''}"},
    );
    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data["success"] == true) {
      return data["tasks"] ?? [];
    } else {
      throw Exception(data["error"] ?? "Failed to fetch admin tasks");
    }
  }

  // For Self-service forgot password
  static Future<Map<String, dynamic>> forgotPasswordRequest(String email) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/auth/forgot_password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      final data = jsonDecode(res.body);
      return data;
    } catch (e) {
      print("Error in forgotPasswordRequest: $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> resetPasswordSelf(String email, String newPassword) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/auth/reset_password_self"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "newPassword": newPassword}),
      );

      final data = jsonDecode(res.body);
      return data;
    } catch (e) {
      print("Error in resetPasswordSelf: $e");
      rethrow;
    }
  }
}
