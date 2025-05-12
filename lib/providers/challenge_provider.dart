import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/challenge.dart';
import '../config/constants.dart';

class ChallengeProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  List<Challenge> _allChallenges = [];
  List<Challenge> _myChallenges = [];
  Challenge? _selectedChallenge;
  bool _isLoading = false;
  String? _error;

  List<Challenge> get allChallenges => _allChallenges;
  List<Challenge> get myChallenges => _myChallenges;
  Challenge? get selectedChallenge => _selectedChallenge;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 챌린지 목록 로드
  Future<void> loadChallenges() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 실제 API 호출
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/challenge/check'),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final List<dynamic> data = jsonDecode(response.body);
        _allChallenges = data.map((json) => Challenge.fromJson(json)).toList();
      } else {
        // 테스트 데이터 (실제 API 응답이 없을 경우)
        _allChallenges = [
          Challenge(
            cno: 1,
            title: '첫 리뷰 작성하기',
            content: '첫 번째 제품 리뷰를 작성해보세요.',
            type: 'REVIEW',
            rewardPoints: 100,
            status: 'ACTIVE',
          ),
          Challenge(
            cno: 2,
            title: '게임 미션 완료하기',
            content: '간단한 게임을 플레이하고 미션을 완료하세요.',
            type: 'GAME',
            rewardPoints: 150,
            status: 'ACTIVE',
          ),
        ];
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
      print('챌린지 목록 로드 오류: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 내 챌린지 목록 로드
  Future<void> loadMyChallenges() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _secureStorage.read(key: AppConstants.tokenKey);
      if (token == null) {
        _myChallenges = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      // 실제 API 호출
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/challenge/my'),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final List<dynamic> data = jsonDecode(response.body);
        _myChallenges = data.map((json) => Challenge.fromJson(json)).toList();
      } else {
        _myChallenges = [];
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
      print('내 챌린지 목록 로드 오류: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 챌린지 상세 정보 로드
  Future<void> loadChallengeDetail(int cno) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 실제 API 호출
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/challenge/detailcheck?cno=$cno'),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final dynamic data = jsonDecode(response.body);
        _selectedChallenge = Challenge.fromJson(data);
      } else {
        // 테스트 데이터
        _selectedChallenge = _allChallenges.firstWhere(
              (challenge) => challenge.cno == cno,
          orElse: () => Challenge(
            cno: cno,
            title: '챌린지 $cno',
            content: '챌린지 내용입니다.',
            type: 'REVIEW',
            rewardPoints: 100,
            status: 'ACTIVE',
          ),
        );
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
      print('챌린지 상세 정보 로드 오류: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 챌린지 등록 (관리자 전용)
  Future<bool> registerChallenge(Challenge challenge) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _secureStorage.read(key: AppConstants.tokenKey);
      if (token == null) return false;

      // 실제 API 호출
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/challenge/register'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: jsonEncode({
          'title': challenge.title,
          'content': challenge.content,
          'type': challenge.type,
          'rewardPoints': challenge.rewardPoints,
          'status': challenge.status,
        }),
      );

      final success = response.statusCode == 200 || response.statusCode == 201;

      if (success) {
        // 등록 성공 시 챌린지 목록 새로고침
        await loadChallenges();
      } else {
        _error = '챌린지 등록에 실패했습니다. 상태 코드: ${response.statusCode}';
        print('챌린지 등록 실패: $_error');
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      print('챌린지 등록 오류: $_error');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 챌린지 참여
  Future<bool> participateChallenge(int cno) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _secureStorage.read(key: AppConstants.tokenKey);
      if (token == null) return false;

      // 실제 API 호출
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/challenge/participate?cno=$cno'),
        headers: {'Authorization': token},
      );

      final success = response.statusCode == 200;

      if (success) {
        // 참여 성공 시 내 챌린지 목록 새로고침
        await loadMyChallenges();

        // 현재 선택된 챌린지가 있다면 내 챌린지 목록에 추가
        if (_selectedChallenge != null && _selectedChallenge!.cno == cno) {
          if (!_myChallenges.any((c) => c.cno == cno)) {
            _myChallenges.add(_selectedChallenge!);
          }
        }
      } else {
        _error = '챌린지 참여에 실패했습니다.';
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

  // 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}