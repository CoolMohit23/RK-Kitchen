import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class FirebaseService {
  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Firestore collections
  final CollectionReference ordersCollection = 
      FirebaseFirestore.instance.collection('orders');
  final CollectionReference menuCollection = 
      FirebaseFirestore.instance.collection('menu_items');

  // Initialize Firebase
  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized successfully');
    } catch (e) {
      print('Error initializing Firebase: $e');
    }
  }
}