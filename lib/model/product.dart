class Product {
  String? id;
  String? name;
  String? description;
  double? price;
  double? sale;
  int? stock;
  String? profileImage;
  String? cloudinaryImageId;
  String? categoryId;

  Product({
    this.id,
    this.name,
    this.description,
    this.price,
    this.sale,
    this.stock,
    this.profileImage,
    this.cloudinaryImageId,
    this.categoryId,
  });

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    price = json['price'];
    sale = json['sale'];
    stock = json['stock'];
    profileImage = json['profileImage'];
    cloudinaryImageId = json['cloudinaryImageId'];
    categoryId = json['categoryId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['price'] = price;
    data['sale'] = sale;
    data['stock'] = stock;
    data['profileImage'] = profileImage;
    data['cloudinaryImageId'] = cloudinaryImageId;
    data['categoryId'] = categoryId;
    return data;
  }

// Định nghĩa phương thức toString() để hiển thị đối tượng dễ đọc hơn
  @override
  String toString() {
    return 'Product{id: $id, name: $name, description: $description, price: $price, sale: $sale, stock: $stock, profileImage: $profileImage, cloudinaryImageId: $cloudinaryImageId, categoryId: $categoryId}';
  }
}
