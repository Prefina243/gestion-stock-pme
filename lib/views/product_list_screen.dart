import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/product_model.dart';
import '../../services/firestore_service.dart';
import 'home/product_form_screen.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final service = FirestoreService();

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Veuillez vous connecter.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Liste des produits"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProductFormScreen()),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: service.getProducts(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Erreur de chargement : ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucun produit disponible"));
          }

          final products = snapshot.data!;

          return ListView.separated(
            itemCount: products.length,
            separatorBuilder: (context, index) =>
            const Divider(height: 1, color: Colors.grey),
            itemBuilder: (context, index) {
              final product = products[index];

              return ListTile(
                leading: CircleAvatar(
                  radius: 8,
                  backgroundColor: product.isLowStock
                      ? Colors.redAccent
                      : Colors.greenAccent,
                ),
                title: Text(product.name),
                subtitle: Text(
                    "Prix : ${product.unitPrice.toStringAsFixed(2)} €  |  Qté : ${product.quantity}"),
                onTap: () {
                  // Ouvre le formulaire en mode édition
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductFormScreen(product: product),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await service.deleteProduct(user.uid, product.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                          Text('Produit "${product.name}" supprimé.')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}