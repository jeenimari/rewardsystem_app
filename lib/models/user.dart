//백엔드의 DTO 클래스를 기반으로 Flutter 앱에서 사용할 모델 클래스

class User {
  final int id;
  final String email;
  final String uname;
  final int pointBalance;
  final String? role;

  User({
    required this.id,
    required this.email,
    required this.uname,
    this.pointBalance = 0,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      uname: json['uname'],
      pointBalance: json['pointBalance'] ?? 0,
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'uname': uname,
      'pointBalance': pointBalance,
      'role': role,
    };
  }
}