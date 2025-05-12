import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/user.dart';
import '../config/constants.dart';

class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  // 초기화 메서드
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 저장된 토큰이 있는지 확인
      final token = await _secureStorage.read(key: AppConstants.tokenKey);

      if (token != null) {
        // 토큰이 있으면 사용자 정보 가져오기
        await refreshUserInfo();
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 로그인 메서드
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 실제로는 API 호출로 로그인 처리
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'pw': password,
        }),
      );

      if (response.statusCode == 200) {
        final token = response.body;
        await _secureStorage.write(key: AppConstants.tokenKey, value: token);

        // 테스트용 사용자 정보 설정 (실제로는 API에서 가져와야 함)
        _user = User(
          id: 1,
          email: email,
          uname: '사용자',
          pointBalance: 100,
          role: email.contains('admin') ? 'ADMIN' : 'USER', // 이메일에 admin이 포함되면 관리자로 설정
        );

        // 사용자 ID 저장
        await _secureStorage.write(key: AppConstants.userIdKey, value: _user!.id.toString());
        await _secureStorage.write(key: AppConstants.userEmailKey, value: _user!.email);
        await _secureStorage.write(key: AppConstants.userNameKey, value: _user!.uname);
        // 역할 정보도 저장
        await _secureStorage.write(key: 'user_role', value: _user!.role ?? 'USER');

        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = '로그인에 실패했습니다.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 회원가입 메서드
  Future<bool> signUp(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/user/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uname': name,
          'email': email,
          'pw': password,
        }),
      );

      final success = response.statusCode == 201;

      _isLoading = false;
      if (!success) {
        _error = '회원가입에 실패했습니다.';
      } else {
        _error = null;
      }
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 사용자 정보 새로고침
  Future<void> refreshUserInfo() async {
    try {
      final token = await _secureStorage.read(key: AppConstants.tokenKey);
      if (token == null) return;

      // 저장된 이메일 가져오기 (role 확인용)
      final savedEmail = await _secureStorage.read(key: AppConstants.userEmailKey);

      // 사용자 ID 가져오기
      final userIdStr = await _secureStorage.read(key: AppConstants.userIdKey);
      if (userIdStr == null) {
        // 사용자 ID가 없으면 테스트용 사용자 정보 설정
        if (savedEmail != null) {
          _user = User(
            id: 1,
            email: savedEmail,
            uname: await _secureStorage.read(key: AppConstants.userNameKey) ?? '사용자',
            pointBalance: 100,
            role: savedEmail.contains('admin') ? 'ADMIN' : 'USER', // 이메일에 admin이 포함되면 관리자 유지
          );
          await _secureStorage.write(key: AppConstants.userIdKey, value: _user!.id.toString());
        }
        return;
      }

      final userId = int.parse(userIdStr);

      // 실제 API 호출
      try {
        final response = await http.get(
          Uri.parse('${ApiConstants.baseUrl}/user/info?id=$userId'),
          headers: {'Authorization': token},
        );

        if (response.statusCode == 200) {
          final userData = jsonDecode(response.body);
          _user = User.fromJson(userData);

          // 만약 API에서 역할 정보가 없거나 빈 문자열이면 이메일을 기준으로 역할 할당
          if (_user!.role == null || _user!.role!.isEmpty) {
            _user = User(
              id: _user!.id,
              email: _user!.email,
              uname: _user!.uname,
              pointBalance: _user!.pointBalance,
              role: _user!.email.contains('admin') ? 'ADMIN' : 'USER',
            );
          }

          notifyListeners();
        } else {
          // API 호출이 실패하면 로컬 데이터로 복원
          if (savedEmail != null) {
            _user = User(
              id: userId,
              email: savedEmail,
              uname: await _secureStorage.read(key: AppConstants.userNameKey) ?? '사용자',
              pointBalance: 100,
              role: savedEmail.contains('admin') ? 'ADMIN' : 'USER',
            );
          }
        }
      } catch (e) {
        print('API 호출 오류: $e');
        // 오류 발생 시 로컬 데이터로 복원
        if (savedEmail != null) {
          _user = User(
            id: userId,
            email: savedEmail,
            uname: await _secureStorage.read(key: AppConstants.userNameKey) ?? '사용자',
            pointBalance: 100,
            role: savedEmail.contains('admin') ? 'ADMIN' : 'USER',
          );
        }
      }
    } catch (e) {
      print('Error refreshing user info: $e');
    }
  }

  // 사용자 정보 업데이트
  Future<bool> updateUserInfo(User updatedUser) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _secureStorage.read(key: AppConstants.tokenKey);
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/user/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: jsonEncode(updatedUser.toJson()),
      );

      final success = response.statusCode == 200;

      if (success) {
        if (response.body.isNotEmpty) {
          final userData = jsonDecode(response.body);
          _user = User.fromJson(userData);
        } else {
          // 응답이 비어있는 경우, 업데이트된 사용자 정보 사용
          _user = updatedUser;
        }
      } else {
        _error = '사용자 정보 업데이트에 실패했습니다.';
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 로그아웃
  Future<bool> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _secureStorage.read(key: AppConstants.tokenKey);
      if (token != null) {
        try {
          await http.get(
            Uri.parse('${ApiConstants.baseUrl}/user/logout'),
            headers: {'Authorization': token},
          );
        } catch (e) {
          print('로그아웃 API 호출 오류: $e');
        }
      }

      // 로컬 저장소 정리
      await _secureStorage.deleteAll();
      _user = null;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 사용자 설정
  Future<void> setUser(User user) async {
    _user = user;
    notifyListeners();
  }

  // 로딩 상태 설정
  void setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  // 에러 설정
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}