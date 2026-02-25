import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<void> addProduct(Product product) async {
    await _firestore.collection('products').add(product.toMap());
  }


  Stream<List<Product>> getProducts() {
    return _firestore.collection('products').snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => Product.fromMap(doc.id, doc.data()))
          .toList(),
    );
  }


  Future<void> updateProduct(Product product) async {
    await _firestore
        .collection('products')
        .doc(product.id)
        .update(product.toMap());
  }


  Future<void> deleteProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
  }
}
