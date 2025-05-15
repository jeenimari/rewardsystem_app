// lib/api/small_shop_crawler_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/constants.dart';
import '../models/product.dart';

class SmallShopCrawlerService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // 육식토끼 상품 목록 가져오기
  Future<List<Product>> get6kiProducts({String category = '72', int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.smallShop6ki}?category=$category&page=$page'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print( data );
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('육식토끼 상품 목록 가져오기 오류: $e');
      return [];
    }
  }

  // 육식토끼 상품 상세 정보 가져오기
  Future<Product?> get6kiProductDetail(String url) async {
    try {
      final encodedUrl = Uri.encodeComponent(url);
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.smallShop6kiDetail}?url=$encodedUrl'),
      );

      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      print('육식토끼 상품 상세 정보 가져오기 오류: $e');
      return null;
    }
  }

  // 더베네푸드 상품 목록 가져오기
  Future<List<Product>> getBenefoodProducts({String category = '24', int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.smallShopBenefood}?category=$category&page=$page'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('더베네푸드 상품 목록 가져오기 오류: $e');
      return [];
    }
  }

  // 더베네푸드 상품 상세 정보 가져오기
  Future<Product?> getBenefoodProductDetail(String url) async {
    try {
      final encodedUrl = Uri.encodeComponent(url);
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.smallShopBenefoodDetail}?url=$encodedUrl'),
      );

      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      print('더베네푸드 상품 상세 정보 가져오기 오류: $e');
      return null;
    }
  }

  // 외부 제품 등록 (관리자 기능)
  Future<bool> registerExternalProduct(Product product) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.products}/external'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: jsonEncode({
          'name': product.name,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'productUrl': product.productUrl,
          'vendor': product.vendor,
          'price': product.price,
          'category': product.category,
          'externalProductId': product.externalProductId,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('외부 제품 등록 오류: $e');
      return false;
    }
  }
}