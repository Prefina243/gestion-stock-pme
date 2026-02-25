import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; //  pour le format monétaire
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


    final currencyFormat = NumberFormat.currency(
      locale: 'fr_CD',
      symbol: 'FC',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        title: Text(
          "Liste des produits",
          style: GoogleFonts.poppins(
            color: Colors.indigo[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.indigo),
            tooltip: "Ajouter un produit",
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
            return const Center(
              child: CircularProgressIndicator(color: Colors.indigo),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erreur de chargement : ${snapshot.error}',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "Aucun produit disponible",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            );
          }

          final products = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final product = products[index];
              final formattedPrice =
              currencyFormat.format(product.unitPrice);

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 10,
                    backgroundColor: product.isLowStock
                        ? Colors.redAccent
                        : Colors.indigoAccent,
                    child: const Icon(Icons.inventory_2,
                        size: 18, color: Colors.white),
                  ),
                  title: Text(
                    product.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo[900],
                    ),
                  ),
                  subtitle: Text(
                    "Prix : $formattedPrice  |  Qté : ${product.quantity}",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductFormScreen(product: product),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: "Supprimer",
                    onPressed: () async {
                      await service.deleteProduct(user.uid, product.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.redAccent,
                            content: Text(
                                'Produit "${product.name}" supprimé.'),
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}