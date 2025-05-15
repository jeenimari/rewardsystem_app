// lib/providers/small_shop_provider.dart
import 'package:flutter/material.dart';
import '../api/small_shop_crawler_service.dart';
import '../models/product.dart';

class SmallShopProvider with ChangeNotifier {
  final SmallShopCrawlerService _smallShopService = SmallShopCrawlerService();

  List<Product> _sixkiProducts = [];
  List<Product> _benefoodProducts = [];
  Product? _selectedProduct;
  bool _isLoading = false;
  String? _error;
  String _currentShop = '6ki'; // '6ki' 또는 'benefood'
  String _currentCategory = '72'; // 기본 카테고리

  List<Product> get sixkiProducts => _sixkiProducts;
  List<Product> get benefoodProducts => _benefoodProducts;
  List<Product> get currentProducts => _currentShop == '6ki' ? _sixkiProducts : _benefoodProducts;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentShop => _currentShop;
  String get currentCategory => _currentCategory;

  void setShop(String shop) {
    _currentShop = shop;
    notifyListeners();
  }

  void setCategory(String category) {
    _currentCategory = category;
    notifyListeners();
  }

  // 6ki 상품 로드
  Future<void> load6kiProducts({String? category, int page = 1}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final products = await _smallShopService.get6kiProducts(
        category: category ?? _currentCategory,
        page: page,
      );
      print( products );
      _sixkiProducts = products;
      print( _sixkiProducts );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Benefood 상품 로드
  Future<void> loadBenefoodProducts({String? category, int page = 1}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final products = await _smallShopService.getBenefoodProducts(
        category: category ?? _currentCategory,
        page: page,
      );
      _benefoodProducts = products;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 현재 선택된 샵의 상품 로드
  Future<void> loadCurrentShopProducts({String? category, int page = 1}) async {
    if (_currentShop == '6ki') {
      await load6kiProducts(category: category, page: page);
    } else {
      await loadBenefoodProducts(category: category, page: page);
    }
  }

  // 상품 상세 정보 로드
  Future<void> loadProductDetail(String url) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_currentShop == '6ki') {
        _selectedProduct = await _smallShopService.get6kiProductDetail(url);
      } else {
        _selectedProduct = await _smallShopService.getBenefoodProductDetail(url);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 외부 제품 등록 (관리자 기능)
  Future<bool> registerExternalProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _smallShopService.registerExternalProduct(product);
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