class Review {
  final int id;
  final String userId;
  final int productId;
  final String rcontent;
  final int rating;
  final bool rewarded;
  final String? userName;
  final String? productName;

  Review({
    required this.id,
    required this.userId,
    required this.productId,
    required this.rcontent,
    required this.rating,
    required this.rewarded,
    this.userName,
    this.productName,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userId: json['userId'],
      productId: json['productId'],
      rcontent: json['rcontent'],
      rating: json['rating'],
      rewarded: json['rewarded'] ?? false,
      userName: json['userName'],
      productName: json['productName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'rcontent': rcontent,
      'rating': rating,
      'rewarded': rewarded,
    };
  }
}