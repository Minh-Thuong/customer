class Category {
  final String id;
  final String name;
  final String? profileImage;
  final String? cloudinaryImageId;

  Category({
    required this.id,
    required this.name,
    this.profileImage,
    this.cloudinaryImageId,
  });

  // Hàm khởi tạo từ JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      profileImage: json['profileImage'],
      cloudinaryImageId: json['cloudinaryImageId'],
    );
  }
}

