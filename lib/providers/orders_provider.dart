import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/cart_item.dart';
import 'package:intl/intl.dart';

class Order {
  final String id;
  final List<CartItem> cartItems;
  final double totalAmount;
  final DateTime dateTime;
  final String customerName;
  final String customerPhone;
  final String deliveryOption;
  final String deliveryAddress;
  final String status;

  Order({
    required this.id,
    required this.cartItems,
    required this.totalAmount,
    required this.dateTime,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryOption,
    required this.deliveryAddress,
    this.status = 'Pending',  // Default status is Pending
  });

  // Convert Order to a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cartItems': cartItems.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'dateTime': dateTime.toIso8601String(),
      'customerName': customerName,
      'customerPhone': customerPhone,
      'deliveryOption': deliveryOption,
      'deliveryAddress': deliveryAddress,
      'status': status,
    };
  }

  // Create an Order from a Map
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      cartItems: (json['cartItems'] as List)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: json['totalAmount'] as double,
      dateTime: DateTime.parse(json['dateTime']),
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      deliveryOption: json['deliveryOption'],
      deliveryAddress: json['deliveryAddress'],
      status: json['status'],
    );
  }

  // Get formatted date
  String get formattedDate {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }
  
  // Get order items count
  int get itemCount {
    return cartItems.fold(0, (sum, item) => sum + item.quantity);
  }
}

class OrdersProvider with ChangeNotifier {
  List<Order> _orders = [];

  // Getter for a copy of orders
  List<Order> get orders {
    return [..._orders];
  }

  // Get orders count
  int get orderCount {
    return _orders.length;
  }

  // Constructor loads orders when created
  OrdersProvider() {
    _loadOrders();
  }

  // Load orders from SharedPreferences
  Future<void> _loadOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load orders if they exist
      if (prefs.containsKey('orders')) {
        final ordersData = json.decode(prefs.getString('orders') ?? '[]') as List<dynamic>;
        _orders = ordersData
            .map((orderData) => Order.fromJson(orderData as Map<String, dynamic>))
            .toList();
        
        // Sort orders by date (newest first)
        _orders.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        
        notifyListeners();
      }
    } catch (e) {
      // Handle any errors
      print('Error loading orders: $e');
    }
  }

  // Save orders to SharedPreferences
  Future<void> _saveOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final ordersData = json.encode(
        _orders.map((order) => order.toJson()).toList(),
      );
      
      await prefs.setString('orders', ordersData);
    } catch (e) {
      // Handle any errors
      print('Error saving orders: $e');
    }
  }

  // Add a new order
  void addOrder({
    required List<CartItem> cartItems,
    required double totalAmount,
    required String customerName,
    required String customerPhone,
    required String deliveryOption,
    required String deliveryAddress,
  }) {
    final newOrder = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cartItems: cartItems,
      totalAmount: totalAmount,
      dateTime: DateTime.now(),
      customerName: customerName,
      customerPhone: customerPhone,
      deliveryOption: deliveryOption,
      deliveryAddress: deliveryAddress,
    );
    
    _orders.insert(0, newOrder); // Add new order at the beginning
    _saveOrders();
    notifyListeners();
  }

  // Update order status
  void updateOrderStatus(String orderId, String newStatus) {
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex >= 0) {
      final updatedOrder = Order(
        id: _orders[orderIndex].id,
        cartItems: _orders[orderIndex].cartItems,
        totalAmount: _orders[orderIndex].totalAmount,
        dateTime: _orders[orderIndex].dateTime,
        customerName: _orders[orderIndex].customerName,
        customerPhone: _orders[orderIndex].customerPhone,
        deliveryOption: _orders[orderIndex].deliveryOption,
        deliveryAddress: _orders[orderIndex].deliveryAddress,
        status: newStatus,
      );
      
      _orders[orderIndex] = updatedOrder;
      _saveOrders();
      notifyListeners();
    }
  }

  // Get a specific order by ID
  Order? getOrderById(String id) {
    return _orders.firstWhere((order) => order.id == id, orElse: () => null as Order);
  }

  // Clear all orders (for testing)
  Future<void> clearOrders() async {
    _orders = [];
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('orders');
    
    notifyListeners();
  }
}