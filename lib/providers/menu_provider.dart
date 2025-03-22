import 'package:flutter/foundation.dart';
import '../models/menu_item.dart';
import '../services/firebase_service.dart';

class MenuProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<MenuItem> _menuItems = [];
  bool _isLoading = false;
  String _error = '';

  // Getters
  List<MenuItem> get menuItems => [..._menuItems];
  bool get isLoading => _isLoading;
  String get error => _error;

  // Get all categories + 'All' option
  List<String> get categories {
    final categorySet = _menuItems.map((item) => item.category).toSet();
    return ['All', ...categorySet];
  }

  // Get items by category
  List<MenuItem> getItemsByCategory(String category) {
    if (category == 'All') {
      return menuItems;
    }
    return menuItems.where((item) => item.category == category).toList();
  }

  // Fetch menu items from Firestore
  Future<void> fetchMenuItems() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final snapshot = await _firebaseService.menuCollection.get();
      
      _menuItems = snapshot.docs.map((doc) {
        return MenuItem.fromFirestore(
          doc.id, 
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load menu items. Please try again later.';
      print('Error fetching menu items: $e');
      notifyListeners();
    }
  }

  // Add a menu item to Firestore (admin functionality)
  Future<void> addMenuItem(MenuItem item) async {
    try {
      await _firebaseService.menuCollection.add(item.toFirestore());
      await fetchMenuItems(); // Refresh the list
    } catch (e) {
      _error = 'Failed to add menu item.';
      print('Error adding menu item: $e');
      notifyListeners();
    }
  }
}