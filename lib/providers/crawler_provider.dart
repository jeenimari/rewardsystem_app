// // lib/providers/crawler_provider.dart
// import 'package:flutter/material.dart';
// import '../api/crawler_service.dart';
// import '../models/product.dart';
//
// class CrawlerProvider with ChangeNotifier {
//   final CrawlerService _crawlerService = CrawlerService();
//
//   List<Product> _searchedProducts = [];
//   bool _isLoading = false;
//   String? _error;
//   String _currentPlatform = 'all'; // 'all', 'coupang', 'naver', 'gmarket'
//
//   List<Product> get searchedProducts => _searchedProducts;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   String get currentPlatform => _currentPlatform;
//
//   // 플랫폼 설정
//   void setPlatform(String platform) {
//     _currentPlatform = platform;
//     notifyListeners();
//   }
//
//   // 키워드 검색 - 백엔드의 Jsoup 크롤러 API 사용
//   // 참고: 백엔드에서는 Selenium에서 Jsoup으로 구현이 변경되었지만
//   // API 엔드포인트는 동일하게 유지되어 코드 변경이 필요하지 않음
//   Future<void> searchProducts(String keyword) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();
//
//     try {
//       switch (_currentPlatform) {
//         case 'coupang':
//           _searchedProducts = await _crawlerService.crawlCoupangProducts(keyword, 1);
//           break;
//         case 'naver':
//           _searchedProducts = await _crawlerService.crawlNaverProducts(keyword, 1);
//           break;
//         case 'gmarket':
//           _searchedProducts = await _crawlerService.crawlGmarketProducts(keyword, 1);
//           break;
//         default:
//           _searchedProducts = await _crawlerService.searchAllPlatforms(keyword, 'all');
//       }
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   // 외부 제품 등록 (관리자 기능)
//   Future<bool> registerExternalProduct(Product product) async {
//     _isLoading = true;
//     notifyListeners();
//
//     try {
//       final result = await _crawlerService.registerExternalProduct(product);
//       _isLoading = false;
//       notifyListeners();
//       return result;
//     } catch (e) {
//       _error = e.toString();
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }
//
//   // 에러 초기화
//   void clearError() {
//     _error = null;
//     notifyListeners();
//   }
// }