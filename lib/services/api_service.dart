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



 /* Future<List<User>> getUsers(String token) async {
    try {
      dio.options.headers['authorization'] = 'Bearer $token';
      final response = await dio.get('$baseUrl/auth/users');

      if (response.statusCode == 200) {
        final List<dynamic> usersJson = response.data;
        return usersJson.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load users');
      }
    } on DioError catch (e) { // Changed from DioException to DioError
      print('DioError: ${e.message}');
      print('DioError response: ${e.response?.data}');
      throw Exception('Failed to load users: ${e.message}');
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load users: $e');
    }
  }*/

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
  Future<PaginatedResponse<User>> getUsers({
    required String token,
    int page = 1,
    int limit = 10,
    String? search,
    String? role,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
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
        return PaginatedResponse.fromJson(
          response.data,
              (json) => User.fromJson(json),
        );
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Failed to load users: $e');
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

}