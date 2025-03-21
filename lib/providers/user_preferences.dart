import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserPreferences with ChangeNotifier {
  String _userName = '';
  String _phoneNumber = '';
  String _address = '';
  String _preferredDeliveryOption = 'Delivery'; // Default to 'Delivery'

  // Getters
  String get userName => _userName;
  String get phoneNumber => _phoneNumber;
  String get address => _address;
  String get preferredDeliveryOption => _preferredDeliveryOption;
  
  // Constructor loads preferences when created
  UserPreferences() {
    _loadPreferences();
  }

  // Load user preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load user data if it exists
      if (prefs.containsKey('userData')) {
        final userData = json.decode(prefs.getString('userData') ?? '{}') as Map<String, dynamic>;
        _userName = userData['userName'] ?? '';
        _phoneNumber = userData['phoneNumber'] ?? '';
        _address = userData['address'] ?? '';
        _preferredDeliveryOption = userData['preferredDeliveryOption'] ?? 'Delivery';
        
        notifyListeners();
      }
    } catch (e) {
      // Handle any errors
      print('Error loading user preferences: $e');
    }
  }

  // Save user preferences to SharedPreferences
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final userData = json.encode({
        'userName': _userName,
        'phoneNumber': _phoneNumber,
        'address': _address,
        'preferredDeliveryOption': _preferredDeliveryOption,
      });
      
      await prefs.setString('userData', userData);
    } catch (e) {
      // Handle any errors
      print('Error saving user preferences: $e');
    }
  }

  // Methods to update user preferences
  void updateUserInfo({
    String? userName,
    String? phoneNumber,
    String? address,
    String? preferredDeliveryOption,
  }) {
    if (userName != null) _userName = userName;
    if (phoneNumber != null) _phoneNumber = phoneNumber;
    if (address != null) _address = address;
    if (preferredDeliveryOption != null) _preferredDeliveryOption = preferredDeliveryOption;
    
    _savePreferences();
    notifyListeners();
  }

  // Clear user preferences
  Future<void> clearUserPreferences() async {
    _userName = '';
    _phoneNumber = '';
    _address = '';
    _preferredDeliveryOption = 'Delivery';
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
    
    notifyListeners();
  }

  // Check if user has saved their information
  bool get hasUserInfo => _userName.isNotEmpty && _phoneNumber.isNotEmpty;
}