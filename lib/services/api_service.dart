// lib/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/dashboard_stats.dart';
import '../models/login_response.dart';
import '../models/paginated_response.dart';
import '../models/user.dart';

class ApiService {
  final String baseUrl = kIsWeb
      ? 'http://localhost:3000'
      : 'http://10.0.2.2:3000';

  final dio = Dio(); // or your actual backend URL

// In api_service.dart
  // In api_service.dart
  Future<void> signUp(String name, String email, String password) async {
    try {
      print('Attempting to signup at: $baseUrl/auth/createadmin');
      print('With data - Name: $name, Email: $email');

      final response = await dio.post(
        '$baseUrl/auth/createadmin',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
        options: Options(
          validateStatus: (status) => true,
          followRedirects: false,
          responseType: ResponseType.json,
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode != 201) {
        final error = response.data;
        throw Exception(error['message'] ?? 'Registration failed');
      }
    } on DioError catch (e) {
      print('Signup Error Details:');
      print('Error Type: ${e.type}');
      print('Error Message: ${e.message}');
      print('Base URL: $baseUrl');
      print('Error Response: ${e.response?.data}');

      if (e.response?.statusCode == 400) {
        // Handle specific error cases from your backend
        final errorMessage = e.response?.data['message'] ?? 'Email already in use';
        throw Exception(errorMessage);
      }

      throw Exception('Registration failed: ${e.message}');
    } catch (e) {
      print('Unexpected error during signup: $e');
      throw Exception('An unexpected error occurred during registration');
    }
  }
  Future<DashboardStats> getDashboardStats(String token) async {
    try {
      dio.options.headers['authorization'] = 'Bearer $token';
      final response = await dio.get('$baseUrl/admin/dashboard-stats');
      return DashboardStats.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load dashboard stats');
    }
  }

  Future<void> updateUserStatus(String token, String userId,
      bool isActive) async {
    try {
      dio.options.headers['authorization'] = 'Bearer $token';
      final response = await dio.put(
        '$baseUrl/auth/update-account-status',
        data: {
          'userId': userId,
          'isActive': isActive,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update user status');
      }
    } on DioError catch (e) { // Changed from DioException to DioError
      print('DioError: ${e.message}');
      print('DioError response: ${e.response?.data}');

      if (e.response?.statusCode == 403) {
        throw Exception('Permission denied. Admin privileges required');
      } else {
        throw Exception('Failed to update user status: ${e.message}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to update user status: $e');
    }
  }



  Future<List<User>> getUsers({
    required String token,
    String? search,
    String? role,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    try {
      final queryParams = {
        if (search != null && search.isNotEmpty) 'search': search,
        if (role != null && role.isNotEmpty) 'role': role,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      final response = await dio.get(
        '$baseUrl/auth/users',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> usersJson = response.data;
        return usersJson.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }
// lib/services/api_service.dart
  Future<LoginResponse> login(String email, String password) async {
    try {
      print('Attempting to connect to: $baseUrl/auth/login');
      print('With credentials - Email: $email');

      final response = await dio.post(
        '$baseUrl/auth/login',
        data: {
          'email': email,
          'password': password,
        },
        options: Options(
          validateStatus: (status) => true,
          followRedirects: false,
          responseType: ResponseType.json,
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 201) {
        return LoginResponse.fromJson(response.data);
      } else {
        throw Exception('Invalid response: ${response.data}');
      }
    } on DioError catch (e) {
      print('Connection Error Details:');
      print('Error Type: ${e.type}');
      print('Error Message: ${e.message}');
      print('Base URL: $baseUrl');
      print('Error Response: ${e.response}');

      throw Exception('Connection failed: ${e.message}');
    }
  }


  Future<void> updateUserRole(String token, String userId, String newRole) async {
    try {
      final response = await dio.put(
        '$baseUrl/auth/update-user-role',
        data: {
          'userId': userId,
          'role': newRole,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update user role');
      }
    } catch (e) {
      throw Exception('Failed to update user role: ${e.toString()}');
    }
  }

  Future<String> requestPasswordReset(String email) async {
    final response = await dio.post('/auth/forgot-password', data: {
      'email': email,
    });
    return response.data['resetToken'];
  }

  Future<String> verifyResetCode(String resetToken, String code) async {
    final response = await dio.post('/auth/verify-reset-code', data: {
      'resetToken': resetToken,
      'code': code,
    });
    return response.data['verifiedToken'];
  }

  Future<void> resetPassword(String verifiedToken, String newPassword) async {
    await dio.post('/auth/reset-password', data: {
      'verifiedToken': verifiedToken,
      'newPassword': newPassword,
    });
  }
}

