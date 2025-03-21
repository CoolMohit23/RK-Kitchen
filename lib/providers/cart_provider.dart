import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import '../models/menu_item.dart';

class CartProvider with ChangeNotifier {
  // Private field to store cart items
  List<CartItem> _items = [];
  
  // The key we'll use to store cart data in shared preferences
  static const String _cartKey = 'cart_data';

  // Constructor - loads data from shared preferences when created
  CartProvider() {
    _loadCartFromPrefs();
  }

  // Getter to access a copy of cart items
  List<CartItem> get items => [..._items];

  // Get total number of items in cart
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  // Get total price of all items in cart
  double get totalAmount => _items.fold(
      0.0, (sum, item) => sum + (item.menuItem.price * item.quantity));

  // Load cart data from shared preferences
  Future<void> _loadCartFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getString(_cartKey);
      
      if (cartData != null) {
        // Convert from JSON string to List<CartItem>
        final decodedData = json.decode(cartData) as List<dynamic>;
        _items = decodedData
            .map((item) => CartItem.fromJson(item))
            .toList();
        
        // Notify listeners that the cart data has changed
        notifyListeners();
      }
    } catch (e) {
      // Handle any errors that might occur
      print('Error loading cart data: $e');
    }
  }

  // Save cart data to shared preferences
  Future<void> _saveCartToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Convert cart items to a JSON string
      final cartData = json.encode(
        _items.map((item) => item.toJson()).toList(),
      );
      
      // Save to shared preferences
      await prefs.setString(_cartKey, cartData);
    } catch (e) {
      // Handle any errors that might occur
      print('Error saving cart data: $e');
    }
  }

  // Add an item to the cart
  void addItem(MenuItem menuItem) {
    // Check if the item already exists in the cart
    final existingItemIndex = _items.indexWhere(
      (cartItem) => cartItem.menuItem.id == menuItem.id,
    );

    if (existingItemIndex >= 0) {
      // Item exists, increment quantity
      _items[existingItemIndex].quantity += 1;
    } else {
      // Item doesn't exist, add new cart item
      _items.add(
        CartItem(
          menuItem: menuItem,
        ),
      );
    }
    
    // Notify listeners about the change
    notifyListeners();
    
    // Save changes to shared preferences
    _saveCartToPrefs();
  }

  // Remove an item from the cart
  void removeItem(String menuItemId) {
    _items.removeWhere((cartItem) => cartItem.menuItem.id == menuItemId);
    notifyListeners();
    _saveCartToPrefs();
  }

  // Reduce quantity of an item in the cart
  void removeSingleItem(String menuItemId) {
    final existingItemIndex = _items.indexWhere(
      (cartItem) => cartItem.menuItem.id == menuItemId,
    );

    if (existingItemIndex >= 0) {
      if (_items[existingItemIndex].quantity > 1) {
        _items[existingItemIndex].quantity -= 1;
      } else {
        _items.removeAt(existingItemIndex);
      }
      notifyListeners();
      _saveCartToPrefs();
    }
  }

  // Clear the cart
  void clear() {
    _items.clear();
    notifyListeners();
    _saveCartToPrefs();
  }
}