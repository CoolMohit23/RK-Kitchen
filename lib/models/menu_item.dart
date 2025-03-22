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

  // Convert to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
    };
  }

  // Create a MenuItem from a Firestore document
factory MenuItem.fromFirestore(String documentId, Map<String, dynamic> data) {
  // Handle potential type issues with price
  double priceValue = 0.0;
  if (data['price'] is int) {
    priceValue = (data['price'] as int).toDouble();
  } else if (data['price'] is double) {
    priceValue = data['price'] as double;
  } else if (data['price'] is String) {
    priceValue = double.tryParse(data['price'] as String) ?? 0.0;
  }

  return MenuItem(
    id: documentId,
    name: data['name'] as String? ?? 'Unknown Item',
    description: data['description'] as String? ?? 'No description available',
    price: priceValue,
    imageUrl: data['imageUrl'] as String? ?? 'https://via.placeholder.com/150?text=No+Image',
    category: data['category'] as String? ?? 'Uncategorized',
  );
}
  // Keep existing methods
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