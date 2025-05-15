// // lib/api/crawler_service.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import '../config/constants.dart';
// import '../models/product.dart';
//
// class CrawlerService {
//   final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
//
//   // 쿠팡 상품 크롤링 - Jsoup 백엔드 API 호출
//   // 백엔드에서는 Selenium에서 Jsoup으로 변경되었지만 API 엔드포인트는 동일함
//   Future<List<Product>> crawlCoupangProducts(String keyword, int? page) async {
//     try {
//       final response = await http.get(
//         Uri.parse('${ApiConstants.baseUrl}${ApiConstants.crawlerCoupang}?keyword=$keyword&page=${page??1}'),
//       );
//
//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         return data.map((json) => Product.fromJson(json)).toList();
//       } else {
//         return [];
//       }
//     } catch (e) {
//       print('Crawl Coupang products error: $e');
//       return [];
//     }
//   }
//
//   // 네이버 상품 크롤링 - Jsoup 백엔드 API 호출
//   Future<List<Product>> crawlNaverProducts(String keyword, int? page) async {
//     try {
//       final response = await http.get(
//         Uri.parse('${ApiConstants.baseUrl}${ApiConstants.crawlerNaver}?keyword=$keyword&page=${page??1}'),
//       );
//
//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         return data.map((json) => Product.fromJson(json)).toList();
//       } else {
//         return [];
//       }
//     } catch (e) {
//       print('Crawl Naver products error: $e');
//       return [];
//     }
//   }
//
//   // G마켓 상품 크롤링 - Jsoup 백엔드 API 호출
//   Future<List<Product>> crawlGmarketProducts(String keyword, int? page) async {
//     try {
//       final response = await http.get(
//         Uri.parse('${ApiConstants.baseUrl}${ApiConstants.crawlerGmarket}?keyword=$keyword&page=${page??1}'),
//       );
//
//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         return data.map((json) => Product.fromJson(json)).toList();
//       } else {
//         return [];
//       }
//     } catch (e) {
//       print('Crawl Gmarket products error: $e');
//       return [];
//     }
//   }
//
//   // 통합 검색 (여러 플랫폼 동시 검색) - Jsoup 백엔드 API 호출
//   Future<List<Product>> searchAllPlatforms(String keyword, String platform) async {
//     try {
//       // 참고: 백엔드에서는 Jsoup으로 구현되었지만 API 경로는 동일함
//       final response = await http.get(
//         Uri.parse('${ApiConstants.baseUrl}${ApiConstants.crawlerSearch}?keyword=$keyword&platform=$platform'),
//       );
//
//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         return data.map((json) => Product.fromJson(json)).toList();
//       } else {
//         return [];
//       }
//     } catch (e) {
//       print('Search all platforms error: $e');
//       return [];
//     }
//   }
//
//   // 외부 제품 등록 (관리자 기능)
//   Future<bool> registerExternalProduct(Product product) async {
//     try {
//       final token = await _secureStorage.read(key: AppConstants.tokenKey);
//       if (token == null) return false;
//
//       final response = await http.post(
//         Uri.parse('${ApiConstants.baseUrl}${ApiConstants.products}/external'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': token,
//         },
//         body: jsonEncode({
//           'name': product.name,
//           'description': product.description,
//           'imageUrl': product.imageUrl,
//           'productUrl': product.productUrl,
//           'vendor': product.vendor,
//           'price': product.price,
//           'category': product.category,
//           'externalProductId': product.externalProductId,
//         }),
//       );
//
//       return response.statusCode == 201;
//     } catch (e) {
//       print('Register external product error: $e');
//       return false;
//     }
//   }
// }