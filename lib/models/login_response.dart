// lib/models/login_response.dart
class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final bool isFirstLogin;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.isFirstLogin,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      // Handle both possible field names for access token
      accessToken: json['accestoken'] ?? json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      userId: json['userId'] ?? '',
      isFirstLogin: json['isFirstLogin'] ?? false,
    );
  }
}