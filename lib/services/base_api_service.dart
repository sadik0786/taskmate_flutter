import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:task_mate/core/routes.dart';

class BaseApiService {
  static String get baseUrl =>
      dotenv.env['baseApiUrl'] ?? "http://taskmateapi.5nance.com/api";

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

  static Future<bool> hasInternetConnection() async {
    if (kIsWeb) return true; // dart:io is not supported on web
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (e) {
      return false;
    }
  }

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
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(const Duration(seconds: 15));
          break;
        case "PUT":
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(const Duration(seconds: 15));
          break;
        case "DELETE":
          response = await http.delete(uri, headers: headers).timeout(const Duration(seconds: 15));
          break;
        default:
          response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 15));
      }
    } catch (e) {
      if (e is SocketException) {
        throw ApiException("Unable to connect to the server. Please check your internet connection or server status.");
      } else if (e is TimeoutException) {
        throw ApiException("The connection timed out. Please try again later.");
      } else if (e is http.ClientException) {
        throw ApiException("Network connection failed. The server might be unreachable.");
      } else {
        throw ApiException("An unexpected error occurred. Please try again.");
      }
    }
    if (response.statusCode == 401) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Get.offAllNamed(Routes.login);
    }
    return response;
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => message;
}
