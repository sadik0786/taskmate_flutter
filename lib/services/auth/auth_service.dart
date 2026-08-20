import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:task_mate/model/auth/login_request_model.dart';
import 'package:task_mate/model/auth/login_response_model.dart';
import 'package:task_mate/model/auth/register_request_model.dart';
import 'package:task_mate/model/auth/register_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/services/base_api_service.dart';

class AuthService {
  // GET roles (server already filters based on logged-in user's role)
  static Future<Map<String, dynamic>> getRoles() async {
    try {
      final token = await BaseApiService.getToken();
      if (token == null) {
        return {"success": false, "error": "Authentication required"};
      }

      final res = await http
          .get(
            Uri.parse("${BaseApiService.baseUrl}/auth/roles"),
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
          "error": data['error'] ?? "Failed to fetch roles (${res.statusCode})",
        };
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> checkEmailExists(String email) async {
    try {
      final token = await BaseApiService.getToken();

      if (token == null) return {"success": false, "error": "No token found"};

      final res = await http.post(
        Uri.parse("${BaseApiService.baseUrl}/auth/checkemail"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
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

  // Register employee/admin
  static Future<RegisterResponseModel> registerEmployee(
    RegisterRequestModel request,
  ) async {
    try {
      final token = await BaseApiService.getToken();

      if (token == null) {
        return RegisterResponseModel(success: false);
      }

      final res = await http.post(
        Uri.parse("${BaseApiService.baseUrl}/auth/register"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(request.toJson()),
      );

      final data = jsonDecode(res.body);
      return RegisterResponseModel.fromJson(data);
    } catch (e) {
      String errorStr = e.toString().toLowerCase();
      String errorMessage =
          "Network error: An unexpected error occurred. ($errorStr)";

      if (e is SocketException ||
          errorStr.contains("socketexception") ||
          errorStr.contains("connection refused") ||
          errorStr.contains("failed host lookup")) {
        errorMessage =
            "Unable to connect to the server. Please check your internet connection or server status.";
      } else if (e is TimeoutException || errorStr.contains("timeout")) {
        errorMessage = "The connection timed out. Please try again later.";
      } else if (e is FormatException ||
          errorStr.contains("formatexception") ||
          errorStr.contains("doctype") ||
          errorStr.contains("syntaxerror") ||
          errorStr.contains("unexpected character")) {
        errorMessage =
            "Server is currently offline or returning invalid data. Please try again later.";
      } else if (e is http.ClientException ||
          errorStr.contains("xmlhttprequest") ||
          errorStr.contains("clientexception")) {
        errorMessage =
            "Network connection failed. The server might be unreachable.";
      }

      return RegisterResponseModel(success: false, message: errorMessage);
    }
  }

  // update mobile
  static Future<bool> updateMobile(String mobile) async {
    try {
      final token = await BaseApiService.getToken();

      final res = await http.post(
        Uri.parse("${BaseApiService.baseUrl}/auth/mobileUpdate"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"mobile": mobile}),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Login
  static Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final res = await http
          .post(
            Uri.parse('${BaseApiService.baseUrl}/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(res.body);
      final loginResponse = LoginResponseModel.fromJson(data);

      if (loginResponse.success == true &&
          loginResponse.token != null &&
          loginResponse.user != null) {
        await BaseApiService.saveToken(loginResponse.token!);

        final prefs = await SharedPreferences.getInstance();

        await prefs.setInt('userId', loginResponse.user!.id ?? 0);
        await prefs.setString('name', loginResponse.user!.name ?? '');
        await prefs.setString('email', loginResponse.user!.email ?? '');
        await prefs.setString('mobile', loginResponse.user!.mobile ?? '');
        await prefs.setInt('roleId', loginResponse.user!.roleId ?? 0);
        await prefs.setString(
          'role',
          loginResponse.user!.role?.toLowerCase() ?? '',
        );

        return loginResponse;
      } else {
        return LoginResponseModel(
          success: false,
          message: loginResponse.message ?? "Login failed",
        );
      }
    } catch (e) {
      String errorStr = e.toString().toLowerCase();
      String errorMessage =
          "Network error: An unexpected error occurred. ($errorStr)";

      if (e is SocketException ||
          errorStr.contains("socketexception") ||
          errorStr.contains("connection refused") ||
          errorStr.contains("failed host lookup")) {
        errorMessage =
            "Unable to connect to the server. Please check your internet connection or server status.";
      } else if (e is TimeoutException || errorStr.contains("timeout")) {
        errorMessage = "The connection timed out. Please try again later.";
      } else if (e is FormatException ||
          errorStr.contains("formatexception") ||
          errorStr.contains("doctype") ||
          errorStr.contains("syntaxerror") ||
          errorStr.contains("unexpected character")) {
        errorMessage =
            "Server is currently offline or returning invalid data. Please try again later.";
      } else if (e is http.ClientException ||
          errorStr.contains("xmlhttprequest") ||
          errorStr.contains("clientexception")) {
        errorMessage =
            "Network connection failed. The server might be unreachable.";
      }

      return LoginResponseModel(success: false, message: errorMessage);
    }
  }

  static Future<Map<String, dynamic>> loginold(
    String email,
    String password,
  ) async {
    try {
      final res = await http
          .post(
            Uri.parse('${BaseApiService.baseUrl}/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(res.body);

      if (data["success"] == true) {
        if (data['token'] != null && data['user'] != null) {
          await BaseApiService.saveToken(data['token']);

          final prefs = await SharedPreferences.getInstance();
          final user = data['user'];

          await prefs.setInt('userId', user['id'] ?? 0);
          await prefs.setString('name', user['name'] ?? '');
          await prefs.setString('email', user['email'] ?? '');
          await prefs.setString('mobile', user['mobile'] ?? '');
          await prefs.setInt('roleId', user['roleId'] ?? 0);
          await prefs.setString(
            'role',
            (user['role'] ?? '').toString().toLowerCase(),
          );
          return {
            'success': true,
            'token': data['token'],
            'user': data['user'],
          };
        } else {
          return {
            'success': false,
            'error': data['error'] ?? 'Invalid response from server',
          };
        }
      } else {
        return {
          'success': false,
          'error':
              data['message'] ??
              data['error'] ??
              'Login failed (${res.statusCode})',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // For Self-service forgot password
  static Future<Map<String, dynamic>> forgotPasswordRequest(
    String email,
  ) async {
    try {
      final res = await http.post(
        Uri.parse("${BaseApiService.baseUrl}/auth/forgot_password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );
      final data = jsonDecode(res.body);
      return data;
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  static Future<Map<String, dynamic>> resetPasswordSelf(
    String email,
    String newPassword,
  ) async {
    try {
      final res = await http.post(
        Uri.parse("${BaseApiService.baseUrl}/auth/reset_password_self"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "newPassword": newPassword}),
      );
      final data = jsonDecode(res.body);
      return data;
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  // Change password (Only admin)
  static Future<Map<String, dynamic>> changePassword(
    String email,
    String newPassword,
  ) async {
    try {
      final token = await BaseApiService.getToken();
      if (token == null) return {"success": false, "error": "No token found"};

      final res = await http.post(
        Uri.parse("${BaseApiService.baseUrl}/admin/reset_password"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"email": email, "newPassword": newPassword}),
      );
      final data = jsonDecode(res.body);
      return data;
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }
}
