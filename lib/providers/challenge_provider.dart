import 'package:flutter/material.dart';
import '../api/challenge_service.dart';
import '../models/challenge.dart';

class ChallengeProvider with ChangeNotifier {
  final ChallengeService _challengeService = ChallengeService();

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
      _allChallenges = await _challengeService.getChallenges();
      _error = null;
    } catch (e) {
      _error = e.toString();
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
      _myChallenges = await _challengeService.getMyChallenges();
      _error = null;
    } catch (e) {
      _error = e.toString();
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
      _selectedChallenge = await _challengeService.getChallengeDetail(cno);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 챌린지 참여
  Future<bool> participateChallenge(int cno) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _challengeService.participateChallenge(cno);
      if (result) {
        // 챌린지 참여가 성공하면 내 챌린지 리스트 리로드
        await loadMyChallenges();
      }
      _error = null;
      _isLoading = false;
      notifyListeners();
      return result;
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