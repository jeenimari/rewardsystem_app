import 'package:flutter/material.dart';
import '../api/product_service.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();

  List<Product> _allProducts = [];
  List<Product> _popularProducts = [];
  List<Product> _recentProducts = [];
  Product? _selectedProduct;
  bool _isLoading = false;
  String? _error;

  List<Product> get allProducts => _allProducts;
  List<Product> get popularProducts => _popularProducts;
  List<Product> get recentProducts => _recentProducts;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 초기 데이터 로드
  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 병렬로 데이터 로드
      final results = await Future.wait([
        _productService.getAllProducts(),
        _productService.getPopularProducts(),
        _productService.getRecentProducts(10),
      ]);

      _allProducts = results[0];
      _popularProducts = results[1];
      _recentProducts = results[2];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 제품 상세 정보 로드
  Future<void> loadProductDetail(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedProduct = await _productService.getProductDetail(id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 카테고리별 제품 검색
  Future<List<Product>> searchByCategory(String category) async {
    _isLoading = true;
    notifyListeners();

    try {
      final products = await _productService.getProductsByCategory(category);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return products;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // 벤더별 제품 검색
  Future<List<Product>> searchByVendor(String vendor) async {
    _isLoading = true;
    notifyListeners();

    try {
      final products = await _productService.getProductsByVendor(vendor);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return products;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // 키워드 검색
  Future<List<Product>> searchProducts(String keyword) async {
    _isLoading = true;
    notifyListeners();

    try {
      final products = await _productService.searchProducts(keyword);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return products;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // 외부 제품 등록 (관리자 기능)
  Future<bool> registerExternalProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _productService.registerExternalProduct(product);
      if (result) {
        await loadInitialData(); // 데이터 새로고침
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