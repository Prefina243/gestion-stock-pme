import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';
import '../models/product_model.dart';
import '../models/transaction_model.dart';
import '../services/firestore_service.dart';

class ProductController with ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final List<TransactionModel> _transactions = [];

  bool _loading = false;
  bool get isLoading => _loading;
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);

  String get _userId {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Aucun utilisateur connecté");
    }
    return user.uid;
  }

  Future<void> _showLowStockNotification(Product product) async {
    const androidDetails = AndroidNotificationDetails(
      'low_stock_channel',
      'Alertes de stock bas',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Stock bas',
      'Le produit "${product.name}" atteint un niveau critique !',
      notificationDetails,
    );
  }

  Future<void> addProduct(Product product) async {
    _loading = true;
    notifyListeners();
    await _firestore.addProduct(_userId, product);
    _loading = false;
    notifyListeners();


    if (product.isLowStock) {
      await _showLowStockNotification(product);
    }
  }

  Future<void> updateProduct(Product product) async {
    _loading = true;
    notifyListeners();
    await _firestore.updateProduct(_userId, product);
    _loading = false;
    notifyListeners();

    if (product.isLowStock) {
      await _showLowStockNotification(product);
    }
  }

  Future<void> deleteProduct(Product product) async {
    _loading = true;
    notifyListeners();
    await _firestore.deleteProduct(_userId, product.id);
    _loading = false;
    notifyListeners();
  }

  Future<void> recordTransaction({
    required Product product,
    required int quantityChange,
    required String type,
  }) async {
    final userId = _userId;

    await FirebaseFirestore.instance
        .collection('users/$userId/transactions')
        .add({
      'productId': product.id,
      'productName': product.name,
      'quantityChange': quantityChange,
      'type': type,
      'date': Timestamp.fromDate(DateTime.now()),
    });

    final newQty = product.quantity + quantityChange;
    final updatedProduct = Product(
      id: product.id,
      name: product.name,
      quantity: newQty,
      minStock: product.minStock,
      unitPrice: product.unitPrice,
      barcode: product.barcode,
    );

    await _firestore.updateProduct(userId, updatedProduct);

    _transactions.add(
      TransactionModel(
        productId: product.id,
        productName: product.name,
        quantityChange: quantityChange,
        type: type,
        date: DateTime.now(),
      ),
    );

    notifyListeners();

    if (updatedProduct.isLowStock) {
      await _showLowStockNotification(updatedProduct);
    }
  }
}