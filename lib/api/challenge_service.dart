import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/constants.dart';
import '../models/challenge.dart';

class ChallengeService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // 챌린지 목록 가져오기
  Future<List<Challenge>> getChallenges() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.challenges}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Challenge.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Get challenges error: $e');
      return [];
    }
  }

  // 챌린지 상세 정보 가져오기
  Future<Challenge?> getChallengeDetail(int cno) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.challengeDetail}?cno=$cno'),
      );

      if (response.statusCode == 200) {
        return Challenge.fromJson(jsonDecode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      print('Get challenge detail error: $e');
      return null;
    }
  }
  // 챌린지 참여하기
  Future<bool> participateChallenge(int cno) async {
    try {
      final token = await _secureStorage.read(key: AppConstants.tokenKey);
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.challengeParticipate}?cno=$cno'),
        headers: {'Authorization': token},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Participate challenge error: $e');
      return false;
    }
  }

  // 내 챌린지 목록 가져오기
  Future<List<Challenge>> getMyChallenges() async {
    try {
      final token = await _secureStorage.read(key: AppConstants.tokenKey);
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.myChallenges}'),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Challenge.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Get my challenges error: $e');
      return [];
    }
  }
}