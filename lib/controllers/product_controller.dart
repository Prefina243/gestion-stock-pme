import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart'; // ⚠️ pour accéder à l'instance globale flutterLocalNotificationsPlugin
import '../models/product_model.dart';
import '../models/transaction_model.dart';
import '../services/firestore_service.dart';

class ProductController with ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final List<TransactionModel> _transactions = [];

  bool _loading = false;
  bool get isLoading => _loading;
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);

  /// Identifiant de l'utilisateur actuellement connecté
  String get _userId {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Aucun utilisateur connecté");
    }
    return user.uid;
  }

  /// 🔔 Méthode privée pour afficher une notification locale
  Future<void> _showLowStockNotification(Product product) async {
    const androidDetails = AndroidNotificationDetails(
      'low_stock_channel', // identifiant unique du canal
      'Alertes de stock bas', // nom du canal
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0, // identifiant unique (modifiable si besoin)
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

    // Vérifie le stock à l'ajout
    if (product.isLowStock) {
      await _showLowStockNotification(product);
    }
  }

  /// 🔧 Met à jour un produit et déclenche une notification si stock bas
  Future<void> updateProduct(Product product) async {
    _loading = true;
    notifyListeners();
    await _firestore.updateProduct(_userId, product);
    _loading = false;
    notifyListeners();

    // 🔔 Vérifie le stock après mise à jour
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

  /// Enregistre une transaction (entrée/sortie) et met à jour le stock
  Future<void> recordTransaction({
    required Product product,
    required int quantityChange, // ex : +5 pour entrée, -2 pour sortie
    required String type,        // 'Entrée' ou 'Sortie'
  }) async {
    final userId = _userId;

    // 1️⃣ Crée la transaction dans Firestore
    await FirebaseFirestore.instance
        .collection('users/$userId/transactions')
        .add({
      'productId': product.id,
      'productName': product.name,
      'quantityChange': quantityChange,
      'type': type,
      'date': Timestamp.fromDate(DateTime.now()),
    });

    // 2️⃣ Calcule le nouveau stock
    final newQty = product.quantity + quantityChange;
    final updatedProduct = Product(
      id: product.id,
      name: product.name,
      quantity: newQty,
      minStock: product.minStock,
      unitPrice: product.unitPrice,
      barcode: product.barcode,
    );

    // 3️⃣ Met à jour le produit
    await _firestore.updateProduct(userId, updatedProduct);

    // 4️⃣ Ajoute la transaction à la liste locale
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

    // 5️⃣ Vérifie le stock après transaction → Notification si seuil atteint
    if (updatedProduct.isLowStock) {
      await _showLowStockNotification(updatedProduct);
    }
  }
}