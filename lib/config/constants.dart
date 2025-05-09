class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8080'; // Android Emulator에서 localhost:8080에 접근하기 위한 IP

  // API 엔드포인트
  static const String login = '/user/login';
  static const String signup = '/user/signup';
  static const String logout = '/user/logout';
  static const String userInfo = '/user/info';
  static const String userUpdate = '/user/update';

  static const String products = '/products';
  static const String productsByCategory = '/products/category';
  static const String productsByVendor = '/products/vendor';
  static const String productsSearch = '/products/search';
  static const String popularProducts = '/products/popular';
  static const String recentProducts = '/products/recent';

  static const String reviews = '/reviews';
  static const String reviewsByProduct = '/reviews/product';
  static const String reviewsByUser = '/reviews/user';

  static const String challenges = '/challenge/check';
  static const String challengeDetail = '/challenge/detailcheck';
  static const String challengeParticipate = '/challenge/participate';
  static const String myChallenges = '/challenge/my';
}

class AppConstants {
  static const String tokenKey = 'auth_token';
  static const String userEmailKey = 'user_email';
  static const String userIdKey = 'user_id';
  static const String userNameKey = 'user_name';
}