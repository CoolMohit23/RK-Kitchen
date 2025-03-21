class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  // Convert a MenuItem to a Map (for storing in shared preferences)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
    };
  }

  // Create a MenuItem from a Map (for retrieving from shared preferences)
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    // Handle potential type issues with price
    double priceValue;
    if (json['price'] is int) {
      priceValue = (json['price'] as int).toDouble();
    } else if (json['price'] is String) {
      priceValue = double.parse(json['price']);
    } else {
      priceValue = json['price'] as double;
    }

    return MenuItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: priceValue,
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
    );
  }
}