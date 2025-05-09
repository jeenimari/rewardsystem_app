import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/constants.dart';
import '../models/user.dart';

class AuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // 로그인
  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'pw': password,
        }),
      );

      if (response.statusCode == 200) {
        final token = response.body;
        // 토큰 저장
        await _secureStorage.write(key: AppConstants.tokenKey, value: token);

        // 사용자 정보 가져오기
        final user = await getUserInfo(token);
        if (user != null) {
          await _secureStorage.write(key: AppConstants.userEmailKey, value: user.email);
          await _secureStorage.write(key: AppConstants.userIdKey, value: user.id.toString());
          await _secureStorage.write(key: AppConstants.userNameKey, value: user.uname);
        }

        return token;
      } else {
        return null;
      }
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  // 회원가입
  Future<bool> signUp(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.signup}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uname': name,
          'email': email,
          'pw': password,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Sign up error: $e');
      return false;
    }
  }

  // 로그아웃
  Future<bool> logout() async {
    try {
      final token = await _secureStorage.read(key: AppConstants.tokenKey);
      if (token != null) {
        final response = await http.get(
          Uri.parse('${ApiConstants.baseUrl}${ApiConstants.logout}'),
          headers: {'Authorization': token},
        );

        await _secureStorage.deleteAll();
        return response.statusCode == 204;
      }
      return false;
    } catch (e) {
      print('Logout error: $e');
      return false;
    }
  }

  // 사용자 정보 가져오기
  Future<User?> getUserInfo(String token) async {
    try {
      final userId = await _secureStorage.read(key: AppConstants.userIdKey);
      if (userId == null) return null;

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.userInfo}?id=$userId'),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      print('Get user info error: $e');
      return null;
    }
  }

  // 사용자 정보 업데이트
  Future<User?> updateUserInfo(User user) async {
    try {
      final token = await _secureStorage.read(key: AppConstants.tokenKey);
      if (token == null) return null;

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.userUpdate}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      print('Update user info error: $e');
      return null;
    }
  }

  // 토큰 가져오기
  Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConstants.tokenKey);
  }

  // 현재 로그인 상태 확인
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: AppConstants.tokenKey);
    return token != null;
  }
}