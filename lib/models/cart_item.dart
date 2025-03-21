import 'menu_item.dart';

class CartItem {
  final MenuItem menuItem;
  int quantity;

  CartItem({
    required this.menuItem,
    this.quantity = 1,
  });

  double get totalPrice => menuItem.price * quantity;

  // Convert a CartItem to a Map (for storing in shared preferences)
  Map<String, dynamic> toJson() {
    return {
      'menuItem': menuItem.toJson(),
      'quantity': quantity,
    };
  }

  // Create a CartItem from a Map (for retrieving from shared preferences)
  factory CartItem.fromJson(Map<String, dynamic> json) {
    // Handle potential type issues with quantity
    int quantityValue;
    if (json['quantity'] is double) {
      quantityValue = (json['quantity'] as double).toInt();
    } else if (json['quantity'] is String) {
      quantityValue = int.parse(json['quantity']);
    } else {
      quantityValue = json['quantity'] as int;
    }

    return CartItem(
      menuItem: MenuItem.fromJson(json['menuItem'] as Map<String, dynamic>),
      quantity: quantityValue,
    );
  }
}