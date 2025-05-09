import 'package:flutter/material.dart';
import '../api/review_service.dart';
import '../models/review.dart';

class ReviewProvider with ChangeNotifier {
  final ReviewService _reviewService = ReviewService();

  List<Review> _productReviews = [];
  List<Review> _userReviews = [];
  bool _isLoading = false;
  String? _error;

  List<Review> get productReviews => _productReviews;
  List<Review> get userReviews => _userReviews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 제품별 리뷰 로드
  Future<void> loadProductReviews(int productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _productReviews = await _reviewService.getProductReviews(productId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 사용자 리뷰 로드
  Future<void> loadUserReviews() async {
    _isLoading = true;
    notifyListeners();

    try {
      _userReviews = await _reviewService.getUserReviews();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 리뷰 작성
  Future<bool> createReview(Review review) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _reviewService.createReview(review);
      if (result) {
        // 리뷰가 성공적으로 작성되면 해당 제품의 리뷰 리스트 리로드
        await loadProductReviews(review.productId);
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

  // 리뷰 수정
  Future<bool> updateReview(Review review) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _reviewService.updateReview(review);
      if (result) {
        // 리뷰가 성공적으로 수정되면 리뷰 리스트 리로드
        await loadProductReviews(review.productId);
        await loadUserReviews();
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

  // 리뷰 삭제
  Future<bool> deleteReview(int reviewId, int productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _reviewService.deleteReview(reviewId);
      if (result) {
        // 리뷰가 성공적으로 삭제되면 리뷰 리스트 리로드
        await loadProductReviews(productId);
        await loadUserReviews();
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