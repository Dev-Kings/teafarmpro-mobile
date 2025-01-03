import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:teafarm_pro/models/labour.dart';

class APIResponse {
  final bool success;
  final String message;

  APIResponse({required this.success, required this.message});
}

class DataResponse extends APIResponse {
  final List<dynamic> data;

  DataResponse(
      {required super.success, required super.message, required this.data});
}

class APIService {
  final String baseUrl = 'http://10.0.2.2:5000/api';

  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // Method to store the token
  Future<void> storeUserAndToken(String key, String token) async {
    await secureStorage.write(key: key, value: token);
  }

  // Method to retrieve the access token
  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: 'access_token');
  }

  // Method to retrieve the refresh token
  Future<String> getRefreshToken() async {
    return await secureStorage.read(key: 'refresh_token') ?? '';
  }

  // Method to clear the token
  Future<void> clearStoredToken() async {
    await secureStorage.delete(key: 'access_token');
    await secureStorage.delete(key: 'refresh_token');
  }

  Future<APIResponse> register({
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
        return APIResponse(
            success: true,
            message: 'Registration successful. Proceed to login');
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body)['error'];
        return APIResponse(
            success: false, message: error ?? 'Invalid data provided');
      } else if (response.statusCode == 409) {
        final error = jsonDecode(response.body)['error'];
        return APIResponse(
            success: false,
            message: error ?? 'Email or phone number already exists');
      } else {
        return APIResponse(success: false, message: 'An error occurred');
      }
    } catch (e) {
      return APIResponse(success: false, message: 'An error occurred');
    }
  }

  Future<APIResponse> login(String email, String password) async {
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
        await storeUserAndToken('access_token', data['access_token']);
        await storeUserAndToken('refresh_token', data['refresh_token']);
        await storeUserAndToken('username', data['username']);
        return APIResponse(success: true, message: 'Login successful');
      } else if (response.statusCode == 401) {
        return APIResponse(success: false, message: 'Invalid credentials');
      } else {
        return APIResponse(success: false, message: 'An error occurred');
      }
    } catch (e) {
      return APIResponse(success: false, message: 'An error occurred');
    }
  }

  Future<APIResponse> saveLabour({
    required String labourType,
    required String description,
    String? id, // Optional parameter for editing
  }) async {
    final token = await getAccessToken();
    final Uri apiUrl = id != null
        ? Uri.parse('$baseUrl/labours/$id') // Endpoint for editing labour
        : Uri.parse('$baseUrl/labours'); // Endpoint for creating labour

    try {
      final response = await (id != null
          ? http.put(
              // Use PUT for editing
              apiUrl,
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode(<String, String>{
                'id': id,
                'type': labourType,
                'description': description,
              }),
            )
          : http.post(
              // Use POST for creating
              apiUrl,
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode(<String, String>{
                'type': labourType,
                'description': description,
              }),
            ));

      print(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return APIResponse(
            success: true,
            message: id != null ? 'Labour updated' : 'Labour created');
      } else if (response.statusCode == 404) {
        return APIResponse(success: false, message: 'Labour not found');
      } else if (response.statusCode == 409) {
        return APIResponse(success: false, message: 'Labour already exists');
      } else if (response.statusCode == 400) {
        return APIResponse(success: false, message: 'Labour type is required');
      } else if (response.statusCode == 401) {
        String refreshToken = await getRefreshToken();
        String newAccessToken = await refreshAccessToken(refreshToken);
        if (newAccessToken.isNotEmpty) {
          await storeUserAndToken('access_token', newAccessToken);
          return saveLabour(
              labourType: labourType, description: description, id: id);
        } else {
          return APIResponse(
              success: false,
              message: 'Invalid token. Logout then login again');
        }
      } else {
        return APIResponse(success: false, message: 'An error occurred');
      }
    } catch (e) {
      return APIResponse(success: false, message: 'An error occurred');
    }
  }

  Future<DataResponse> getLabours() async {
    final token = await getAccessToken();
    final Uri apiUrl = Uri.parse('$baseUrl/labours');

    try {
      final response = await http.get(
        apiUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<Labour> labourList = data['labours']
            .map<Labour>((labour) => Labour.fromJson(labour))
            .toList();

        return DataResponse(
            success: true, message: 'Success', data: labourList);
      } else if (response.statusCode == 401) {
        String refreshToken = await getRefreshToken();
        String newAccessToken = await refreshAccessToken(refreshToken);
        if (newAccessToken.isNotEmpty) {
          await storeUserAndToken('access_token', newAccessToken);
          return getLabours();
        } else {
          return DataResponse(
              success: false,
              message: 'Invalid token. Logout then login again',
              data: []);
        }
      } else {
        return DataResponse(
            success: false, message: 'An error occurred', data: []);
      }
    } catch (e) {
      return DataResponse(
          success: false, message: 'An error occurred', data: []);
    }
  }

  Future<String> refreshAccessToken(String refreshToken) async {
    final Uri apiUrl = Uri.parse('$baseUrl/refresh');

    try {
      final response = await http.post(
        apiUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $refreshToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['access_token'];
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
  }

  Future<APIResponse> deleteLabour(String? id) async {
    final token = await getAccessToken();
    final Uri apiUrl = Uri.parse('$baseUrl/labours/$id');

    try {
      final response = await http.delete(
        apiUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return APIResponse(success: true, message: 'Labour deleted');
      } else if (response.statusCode == 404) {
        return APIResponse(success: false, message: 'Labour not found');
      } else if (response.statusCode == 401) {
        String refreshToken = await getRefreshToken();
        String newAccessToken = await refreshAccessToken(refreshToken);
        if (newAccessToken.isNotEmpty) {
          await storeUserAndToken('access_token', newAccessToken);
          return deleteLabour(id);
        } else {
          return APIResponse(
              success: false,
              message: 'Invalid token. Logout then login again');
        }
      } else {
        return APIResponse(success: false, message: 'An error occurred');
      }
    } catch (e) {
      return APIResponse(success: false, message: 'An error occurred');
    }
  }

  Future<APIResponse> logout() async {
    final Uri apiUrl = Uri.parse('$baseUrl/logout');

    try {
      // Retrieve token from secure storage
      final token = await getAccessToken();

      if (token == null) {
        return APIResponse(success: false, message: 'No token found');
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
        return APIResponse(success: true, message: 'Logout successful');
      } else if (response.statusCode == 401) {
        await clearStoredToken();
        return APIResponse(success: false, message: 'Invalid token');
      } else {
        final error = jsonDecode(response.body)['error'];
        return APIResponse(
            success: false, message: error ?? 'An error occurred');
      }
    } catch (e) {
      return APIResponse(success: false, message: 'An error occurred');
    }
  }
}
