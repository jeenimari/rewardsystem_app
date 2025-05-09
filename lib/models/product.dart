class Product {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final String productUrl;
  final String vendor;
  final String price;
  final String category;
  final String? externalProductId;
  final int viewCount;
  final String registeredBy;
  final double averageRating;
  final int reviewCount;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.productUrl,
    required this.vendor,
    required this.price,
    required this.category,
    this.externalProductId,
    this.viewCount = 0,
    required this.registeredBy,
    this.averageRating = 0.0,
    this.reviewCount = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      productUrl: json['productUrl'],
      vendor: json['vendor'],
      price: json['price'],
      category: json['category'],
      externalProductId: json['externalProductId'],
      viewCount: json['viewCount'] ?? 0,
      registeredBy: json['registeredBy'],
      averageRating: json['averageRating'] != null
          ? double.parse(json['averageRating'].toString())
          : 0.0,
      reviewCount: json['reviewCount'] ?? 0,
    );
  }
}