import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';

class ProductProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();

  Stream<List<Product>> getProducts(String userId) {
    return _firestore.getProducts(userId);
  }

  double computeTotalValue(List<Product> products) {
    return products.fold(0, (sum, prod) => sum + prod.unitPrice * prod.quantity);
  }
}