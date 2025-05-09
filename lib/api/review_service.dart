import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/constants.dart';
import '../models/review.dart';

class ReviewService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // 리뷰 작성
  Future<bool> createReview(Review review) async {
    try {
      final token = await _secureStorage.read(key: AppConstants.tokenKey);
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.reviews}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: jsonEncode({
          'productId': review.productId,
          'rcontent': review.rcontent,
          'rating': review.rating,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Create review error: $e');
      return false;
    }
  }

  // 제품별 리뷰 목록 가져오기
  Future<List<Review>> getProductReviews(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.reviewsByProduct}/$productId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Review.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Get product reviews error: $e');
      return [];
    }
  }

  // 사용자 작성 리뷰 목록 가져오기
  Future<List<Review>> getUserReviews() async {
    try {
      final token = await _secureStorage.read(key: AppConstants.tokenKey);
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.reviewsByUser}'),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Review.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Get user reviews error: $e');
      return [];
    }
  }

  // 리뷰 수정
  Future<bool> updateReview(Review review) async {
    try {
      final token = await _secureStorage.read(key: AppConstants.tokenKey);
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.reviews}/${review.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: jsonEncode({
          'productId': review.productId,
          'rcontent': review.rcontent,
          'rating': review.rating,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Update review error: $e');
      return false;
    }
  }

  // 리뷰 삭제
  Future<bool> deleteReview(int reviewId) async {
    try {
      final token = await _secureStorage.read(key: AppConstants.tokenKey);
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.reviews}/$reviewId'),
        headers: {'Authorization': token},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Delete review error: $e');
      return false;
    }
  }
}