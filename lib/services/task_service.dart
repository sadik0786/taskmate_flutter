import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:task_mate/services/base_api_service.dart';

class TaskService {
  // NEW: Get Tasks with Hierarchy
  static Future<Map<String, dynamic>> getTasks() async {
    try {
      final token = await BaseApiService.getToken();
      if (token == null) {
        return {"success": false, "error": "Authentication required"};
      }

      final res = await http
          .get(
            Uri.parse("${BaseApiService.baseUrl}/tasks"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
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
      final token = await BaseApiService.getToken();
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

      final res = await http.post(
        Uri.parse("${BaseApiService.baseUrl}/task/addTask"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(taskData),
      );

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
      final token = await BaseApiService.getToken();
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
      final url = Uri.parse("${BaseApiService.baseUrl}/task/updateTask/$taskId");
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
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
      final token = await BaseApiService.getToken();

      if (token == null) {
        return {"success": false, "error": "Authentication required"};
      }

      final res = await http.post(
        Uri.parse("${BaseApiService.baseUrl}/task/deleteTask/$taskId"),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return data;
      } else {
        return {
          "success": false,
          "error": data["error"] ?? "Failed to delete task",
        };
      }
    } catch (e) {
      return {"success": false, "error": "Network error: ${e.toString()}"};
    }
  }

  // get task admin / employee
  static Future<List<dynamic>> fetchTasks() async {
    try {
      final token = await BaseApiService.getToken();

      if (token == null) return [];

      final res = await http.get(
        Uri.parse("${BaseApiService.baseUrl}/task/getTask"),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data["success"] == true) {
        final tasks = data["tasks"] ?? [];

        return tasks.map<Map<String, dynamic>>((task) {
          return {
            "id": task["id"]?.toString() ?? "",
            "project": task["project"]?.toString() ?? "Unknown Project",
            "subProject":
                task["subProject"]?.toString() ?? "Unknown Sub Project",
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
      return [];
    }
  }

  static Future<List<dynamic>> fetchTasksByEmployee(int empId) async {
    final token = await BaseApiService.getToken();

    final res = await http.get(
      Uri.parse("${BaseApiService.baseUrl}/admin/emp_tasks/$empId"),
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
    final token = await BaseApiService.getToken();

    final res = await http.get(
      Uri.parse("${BaseApiService.baseUrl}/admin/all_task_emp"),
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
    final token = await BaseApiService.getToken();

    final res = await http.get(
      Uri.parse("${BaseApiService.baseUrl}/admin/all_task_admin"),
      headers: {"Authorization": "Bearer ${token ?? ''}"},
    );
    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data["success"] == true) {
      return data["tasks"] ?? [];
    } else {
      throw Exception(data["error"] ?? "Failed to fetch admin tasks");
    }
  }
}
