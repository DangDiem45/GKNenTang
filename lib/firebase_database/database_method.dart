// File: lib/firebase_database/database_method.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class DatabaseMethod {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String productsCollection = 'products';
  final Random _random = Random();

  // Generate a random ID
  String generateRandomId(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(_random.nextInt(chars.length)),
      ),
    );
  }

  // Stream to get all products
  Stream<QuerySnapshot> getProductsStream() {
    return _firestore.collection(productsCollection).snapshots();
  }

  // Add a new product with random ID
  Future<String> addProduct({
    required String name,
    required String category,
    required double price,
    required String imageUrl, // Thay String? thành required String để đồng bộ với CreateProduct
  }) async {
    String randomId = generateRandomId(20); // Generate a 20-character random ID

    await _firestore.collection(productsCollection).doc(randomId).set({
      'id': randomId,
      'name': name,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
    });

    return randomId; // Return the generated ID
  }

  // Update an existing product
  Future<void> updateProduct({
    required String docId,
    required String name,
    required String category,
    required double price,
    required String imageUrl, // Thay String? thành required String
  }) async {
    await _firestore.collection(productsCollection).doc(docId).update({
      'name': name,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
    });
  }

  // Delete a product
  Future<void> deleteProduct(String docId) async {
    await _firestore.collection(productsCollection).doc(docId).delete();
  }
}