import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ReservationService {
  final String baseUrl = "http://10.0.2.2:5000/api/reservations";

  /// Lấy tất cả reservation của user hiện tại
  Future<List<Map<String, dynamic>>> getMyReservations() async {
    final token = await AuthService().getToken();

    if (token == null) {
      print("DEBUG: No token found, user not logged in");
      return []; // hoặc throw Exception nếu muốn bắt lỗi
    }

    final res = await http.get(
      Uri.parse("$baseUrl/my"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      print(
          "DEBUG RESERVATION SERVICE ERROR: statusCode=${res.statusCode}, body=${res.body}");
      throw Exception("Failed to load reservations");
    }
  }
}
