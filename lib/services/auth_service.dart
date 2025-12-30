import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "http://10.0.2.2:5000/api/users";

  // ===================== REGISTER =====================
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    String phone = '',
  }) async {
    final url = Uri.parse("$baseUrl/register");

    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'phone': phone,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body);
      } else {
        return {
          'success': false,
          'msg': jsonDecode(res.body)['msg'] ?? 'Registration failed'
        };
      }
    } catch (e) {
      return {'success': false, 'msg': e.toString()};
    }
  }

  // ===================== LOGIN =====================
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/login");

    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        if (data['token'] != null) {
          // Lưu token vào SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['token']);
        }

        return data;
      } else {
        return {
          'success': false,
          'msg': jsonDecode(res.body)['msg'] ?? 'Login failed'
        };
      }
    } catch (e) {
      return {'success': false, 'msg': e.toString()};
    }
  }

  // ===================== GET CURRENT USER =====================
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return {'success': false, 'msg': 'No token found'};

      final url = Uri.parse("$baseUrl/me");
      final res = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        return {
          'success': false,
          'msg': jsonDecode(res.body)['msg'] ?? 'Failed to fetch user'
        };
      }
    } catch (e) {
      return {'success': false, 'msg': e.toString()};
    }
  }

  // ===================== LOGOUT =====================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // ===================== HELPER: CHECK LOGIN =====================
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null;

  }
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // trả về token hoặc null
  }
}
// ===================== GET TOKEN =====================

