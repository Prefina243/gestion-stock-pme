import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Product>> getProducts(String userId) {
    return _db
        .collection('users/$userId/products')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Product.fromMap(doc.id, doc.data()))
        .toList());
  }

  Future<void> addProduct(String userId, Product product) async {
    await _db.collection('users/$userId/products').add(product.toMap());
  }

  Future<void> updateProduct(String userId, Product product) async {
    await _db
        .collection('users/$userId/products')
        .doc(product.id)
        .update(product.toMap());
  }

  Future<void> deleteProduct(String userId, String productId) async {
    await _db.collection('users/$userId/products').doc(productId).delete();
  }
}