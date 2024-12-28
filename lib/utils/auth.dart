import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class LoginResponse {
  final bool success;
  final String message;

  LoginResponse({required this.success, required this.message});
}

class AuthService {
  final String baseUrl = 'http://10.0.2.2:5000/api';
  final storage = const FlutterSecureStorage();

  Future<LoginResponse> login(String email, String password) async {
    final Uri apiUrl = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        apiUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        // Save the token to the storage
        await storage.write(key: 'token', value: data['access_token']);
        return LoginResponse(success: true, message: 'Login successful');
      } else if (response.statusCode == 401) {
        return LoginResponse(success: false, message: 'Invalid credentials');
      } else {
        return LoginResponse(success: false, message: 'An error occurred');
      }
    } catch (e) {
      return LoginResponse(success: false, message: 'An error occurred');
    }
  }
}
