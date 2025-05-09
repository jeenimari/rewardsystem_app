import 'package:flutter/material.dart';
import '../api/auth_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  // 초기화
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _authService.getToken();
      if (token != null) {
        _user = await _authService.getUserInfo(token);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 로그인
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _authService.login(email, password);
      if (token != null) {
        _user = await _authService.getUserInfo(token);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = '로그인에 실패했습니다. 이메일과 비밀번호를 확인해주세요.';
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

  // 회원가입
  Future<bool> signUp(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.signUp(name, email, password);
      _isLoading = false;
      if (!result) {
        _error = '회원가입에 실패했습니다. 다시 시도해주세요.';
      }
      notifyListeners();
      return result;
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
      final result = await _authService.logout();
      _isLoading = false;
      if (result) {
        _user = null;
      } else {
        _error = '로그아웃에 실패했습니다.';
      }
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 사용자 정보 새로고침
  Future<void> refreshUserInfo() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _authService.getToken();
      if (token != null) {
        _user = await _authService.getUserInfo(token);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 사용자 정보 업데이트
  Future<bool> updateUserInfo(User updatedUser) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.updateUserInfo(updatedUser);
      _isLoading = false;

      if (result != null) {
        _user = result;
        notifyListeners();
        return true;
      } else {
        _error = '정보 업데이트에 실패했습니다.';
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

  // 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}