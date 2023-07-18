import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  static String apiUrl = 'http://192.168.100.6:1212/api/v1';
  static String imageURL = 'http://api-kasir.taxacode.com/api/v1';

  static Future<bool> login(String username, String password) async {
    // Lakukan request ke API

    Map data = {'username': username, 'password': password};

    //encode Map to JSON
    var body = json.encode(data);
    final response = await http.post(
      Uri.parse('$apiUrl/login'),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    // Cek respon dari API
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final token = responseData['data'];

      // Simpan token JWT menggunakan shared_preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', token);
      return true; // Login berhasil
    } else {
      return false; // Login gagal
    }
  }

  static Future<String?> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('${apiUrl}/$endpoint');
    final token = await getToken();
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });
    return response;
  }

  static Future<http.Response> post(
      String endpoint, Map<String, dynamic> payload) async {
    String payloadJson = json.encode(payload);
    print(payloadJson);
    final url = Uri.parse('${apiUrl}/$endpoint');
    final token = await getToken();
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: payloadJson,
    );
    return response;
  }

  static Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }
}
