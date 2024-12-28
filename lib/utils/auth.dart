import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthResponse {
  final bool success;
  final String message;

  AuthResponse({required this.success, required this.message});
}

class AuthService {
  final String baseUrl = 'http://10.0.2.2:5000/api';

  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // Method to store the token
  Future<void> storeToken(String token) async {
    await secureStorage.write(key: 'access_token', value: token);
  }

  // Method to retrieve the token
  Future<String?> getToken() async {
    return await secureStorage.read(key: 'access_token');
  }

  // Method to clear the token
  Future<void> clearStoredToken() async {
    await secureStorage.delete(key: 'access_token');
  }

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? farmName,
    String? farmLocation,
    int? acreage,
  }) async {
    final Uri apiUrl = Uri.parse('$baseUrl/register');

    try {
      final response = await http.post(
        apiUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'name': name,
          'email': email,
          'phone_number': phone,
          'password': password,
          'farm_name': farmName,
          'location': farmLocation,
          'total_acreage': acreage,
        }),
      );

      if (response.statusCode == 201) {
        return AuthResponse(
            success: true,
            message: 'Registration successful. Proceed to login');
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body)['error'];
        return AuthResponse(
            success: false, message: error ?? 'Invalid data provided');
      } else if (response.statusCode == 409) {
        final error = jsonDecode(response.body)['error'];
        return AuthResponse(
            success: false,
            message: error ?? 'Email or phone number already exists');
      } else {
        return AuthResponse(success: false, message: 'An error occurred');
      }
    } catch (e) {
      return AuthResponse(success: false, message: 'An error occurred');
    }
  }

  Future<AuthResponse> login(String email, String password) async {
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
        await storeToken(data['access_token']);
        return AuthResponse(success: true, message: 'Login successful');
      } else if (response.statusCode == 401) {
        return AuthResponse(success: false, message: 'Invalid credentials');
      } else {
        return AuthResponse(success: false, message: 'An error occurredxx');
      }
    } catch (e) {
      return AuthResponse(success: false, message: 'An error occurred');
    }
  }

  Future<AuthResponse> logout() async {
    final Uri apiUrl = Uri.parse('$baseUrl/logout');

    try {
      // Retrieve token from secure storage
      final token = await getToken();

      if (token == null) {
        return AuthResponse(success: false, message: 'No token found');
      }

      final response = await http.post(
        apiUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await clearStoredToken();
        return AuthResponse(success: true, message: 'Logout successful');
      } else {
        final error = jsonDecode(response.body)['error'];
        return AuthResponse(success: false, message: error ?? 'An error occurred');
      }
    } catch (e) {
      return AuthResponse(success: false, message: 'An error occurred');
    }
  }
}
