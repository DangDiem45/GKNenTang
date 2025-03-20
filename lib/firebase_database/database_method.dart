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

  Stream<QuerySnapshot> getProductsStream() {
    return _firestore.collection(productsCollection).snapshots();
  }

  Future<String> addProduct({
    required String name,
    required String category,
    required double price,
    required String imageUrl,
  }) async {
    String randomId = generateRandomId(20); 

    await _firestore.collection(productsCollection).doc(randomId).set({
      'id': randomId,
      'name': name,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
    });

    return randomId; 
  }

  Future<void> updateProduct({
    required String docId,
    required String name,
    required String category,
    required double price,
    required String imageUrl,
  }) async {
    await _firestore.collection(productsCollection).doc(docId).update({
      'name': name,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
    });
  }

  Future<void> deleteProduct(String docId) async {
    await _firestore.collection(productsCollection).doc(docId).delete();
  }
}