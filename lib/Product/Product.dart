class Product {
  final int id;
  final String title;
  final String description;
  final String price;
  final String imageUrl;
  final String category;

  Product({
    this.id,
    this.title,
    this.description,
    this.price,
    this.imageUrl,
    this.category
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      price: json['price'],
      description: json['description'],
      imageUrl: json['image'],
      category: json['category']
    );
  }
}
