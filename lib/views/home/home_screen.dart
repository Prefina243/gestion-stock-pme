import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../widgets/product_tile.dart';
import 'product_form_screen.dart';
import '../product_list_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Utilisateur non connecté")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion Stock PME'),
        actions: [
          // 🔹 Bouton vers le tableau de bord
          IconButton(
            icon: const Icon(Icons.pie_chart_outline),
            tooltip: 'Tableau de bord',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            },
          ),

          // 🔹 Bouton vers la liste complète des produits
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined),
            tooltip: 'Liste des produits',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductListScreen()),
              );
            },
          ),

          // 🔹 Bouton de déconnexion
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),

      // ✅ Corps principal : aperçu rapide des produits de l'utilisateur
      body: StreamBuilder(
        stream: provider.getProducts(user.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erreur de chargement'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!;
          final stockValue = provider.computeTotalValue(products);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Valeur totale du stock : ${stockValue.toStringAsFixed(2)} €',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (_, i) => ProductTile(
                    product: products[i],
                    userId: user.uid,
                  ),
                ),
              ),
            ],
          );
        },
      ),

      // 🔹 Bouton flottant pour ajouter un produit
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.add),
        label: const Text('Nouveau produit'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductFormScreen()),
          );
        },
      ),
    );
  }
}