import '../models/cart_item.dart';

class Order {
  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime dateTime;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final String deliveryOption;
  final String status;

  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.dateTime,
    required this.customerName,
    required this.customerPhone,
    this.deliveryAddress = '',
    required this.deliveryOption,
    this.status = 'Pending',
  });

  // Convert Order to a Map (for storing in shared preferences)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'dateTime': dateTime.toIso8601String(),
      'customerName': customerName,
      'customerPhone': customerPhone,
      'deliveryAddress': deliveryAddress,
      'deliveryOption': deliveryOption,
      'status': status,
    };
  }

  // Create an Order from a Map (for retrieving from shared preferences)
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: json['totalAmount'] as double,
      dateTime: DateTime.parse(json['dateTime'] as String),
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String,
      deliveryAddress: json['deliveryAddress'] as String,
      deliveryOption: json['deliveryOption'] as String,
      status: json['status'] as String,
    );
  }
}