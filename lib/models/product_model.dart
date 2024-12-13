class Product {
  final String name;
  final String description;
  final String price;
  final String? image;

  Product({
    required this.name,
    required this.description,
    this.price = 'N/A',
    this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Safely handle the images array
    String? imageUrl;
    if (json['images'] != null &&
        json['images'] is List &&
        (json['images'] as List).isNotEmpty) {
      imageUrl = json['images'][0]['url'];
    }

    return Product(
      name: json['name'] ?? 'N/A',
      description: json['description'] ?? 'N/A',
      price: json['price'] ?? 'N/A',
      image: imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'image': image,
    };
  }
}
