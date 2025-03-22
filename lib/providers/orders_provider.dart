import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/cart_item.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';  // Add this import

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

  // Convert Order to a Map for local storage
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

  // Convert Order to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
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

  // Create an Order from a Map (for local storage)
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

  // Create an Order from a Firestore document
  factory Order.fromFirestore(String documentId, Map<String, dynamic> data) {
    return Order(
      id: documentId,
      cartItems: (data['cartItems'] as List)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: data['totalAmount'] as double,
      dateTime: DateTime.parse(data['dateTime']),
      customerName: data['customerName'],
      customerPhone: data['customerPhone'],
      deliveryOption: data['deliveryOption'],
      deliveryAddress: data['deliveryAddress'],
      status: data['status'],
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
  final FirebaseService _firebaseService = FirebaseService();  // Add this

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
    _listenToFirestoreOrders(); // Add this to listen for real-time updates
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

  // Listen to real-time updates from Firestore
  void _listenToFirestoreOrders() {
    _firebaseService.ordersCollection
        .orderBy('dateTime', descending: true)
        .snapshots()
        .listen((snapshot) {
      try {
        _orders = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Order.fromFirestore(doc.id, data);
        }).toList();
        
        _saveOrders(); // Update local storage with Firestore data
        notifyListeners();
      } catch (e) {
        print('Error listening to Firestore orders: $e');
      }
    });
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
  Future<void> addOrder({
    required List<CartItem> cartItems,
    required double totalAmount,
    required String customerName,
    required String customerPhone,
    required String deliveryOption,
    required String deliveryAddress,
  }) async {
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
    
    // Add to local list
    _orders.insert(0, newOrder); // Add new order at the beginning
    
    // Save to local storage
    _saveOrders();
    notifyListeners();
    
    // Save to Firestore
    try {
      await _firebaseService.ordersCollection.doc(newOrder.id).set(
        newOrder.toFirestore(),
      );
    } catch (e) {
      print('Error saving order to Firestore: $e');
      // In a real app, you might want to show an error to the user
      // or implement retry logic
    }
  }

  // Update order status (now updates both local and Firestore)
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
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
      
      // Update local storage
      _orders[orderIndex] = updatedOrder;
      _saveOrders();
      notifyListeners();
      
      // Update Firestore
      try {
        await _firebaseService.ordersCollection.doc(orderId).update({
          'status': newStatus
        });
      } catch (e) {
        print('Error updating order status in Firestore: $e');
      }
    }
  }

  // Get a specific order by ID
  Order? getOrderById(String id) {
    return _orders.firstWhere((order) => order.id == id, orElse: () => null as Order);
  }

  // Clear all orders (for testing) - now also clears from Firestore
  Future<void> clearOrders() async {
    // Clear local storage
    _orders = [];
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('orders');
    
    notifyListeners();
    
    // Note: Be very careful with this in production!
    // This would delete all orders for all users
    // In a real app, you'd want to limit this to the current user's orders
    // and probably add additional safeguards
    
    /* Uncomment to enable clearing from Firestore (USE WITH CAUTION)
    try {
      final batch = FirebaseFirestore.instance.batch();
      final snapshots = await _firebaseService.ordersCollection.get();
      
      for (var doc in snapshots.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      print('Error clearing orders from Firestore: $e');
    }
    */
  }
}