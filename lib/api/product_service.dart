import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/constants.dart';
import '../models/product.dart';

class ProductService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // 전체 제품 목록 가져오기
  Future<List<Product>> getAllProducts() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.products}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Get all products error: $e');
      return [];
    }
  }

  // 제품 상세 정보 가져오기
  Future<Product?> getProductDetail(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.products}/$id'),
      );

      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      print('Get product detail error: $e');
      return null;
    }
  }

  // 카테고리별 제품 목록 가져오기
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.productsByCategory}/$category'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Get products by category error: $e');
      return [];
    }
  }

  // 벤더별 제품 목록 가져오기
  Future<List<Product>> getProductsByVendor(String vendor) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.productsByVendor}/$vendor'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Get products by vendor error: $e');
      return [];
    }
  }

  // 제품 검색
  Future<List<Product>> searchProducts(String keyword) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.productsSearch}?keyword=$keyword'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Search products error: $e');
      return [];
    }
  }

  // 인기 제품 목록 가져오기
  Future<List<Product>> getPopularProducts() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.popularProducts}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Get popular products error: $e');
      return [];
    }
  }

  // 최근 제품 목록 가져오기
  Future<List<Product>> getRecentProducts(int count) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.recentProducts}?count=$count'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Get recent products error: $e');
      return [];
    }
  }

  // 외부 제품 등록 (관리자 기능)
  Future<bool> registerExternalProduct(Product product) async {
    try {
      final token = await _secureStorage.read(key: AppConstants.tokenKey);
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
      print('Register external product error: $e');
      return false;
    }
  }
}