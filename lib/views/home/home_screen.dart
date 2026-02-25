import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
        title: Text(
          'Gestion Stock PME',
          style: GoogleFonts.poppins(
            color: Colors.indigo[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Tooltip(
            message: 'Tableau de bord',
            child: IconButton(
              icon: const Icon(Icons.pie_chart_outline),
              color: Colors.indigo[700],
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                );
              },
            ),
          ),
          Tooltip(
            message: 'Liste des produits',
            child: IconButton(
              icon: const Icon(Icons.inventory_2_outlined),
              color: Colors.indigo[700],
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductListScreen()),
                );
              },
            ),
          ),
          Tooltip(
            message: 'Déconnexion',
            child: IconButton(
              icon: const Icon(Icons.logout),
              color: Colors.redAccent,
              onPressed: () => FirebaseAuth.instance.signOut(),
            ),
          ),
        ],
      ),


      body: StreamBuilder(
        stream: provider.getProducts(user.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Erreur de chargement',
                  style: TextStyle(color: Colors.red)),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.indigo),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Aucun produit enregistré.\nAjoute-en un pour commencer !',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final products = snapshot.data!;
          final stockValue = provider.computeTotalValue(products);

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo[100],
                      child: const Icon(Icons.attach_money,
                          color: Colors.indigo),
                    ),
                    title: Text(
                      'Valeur totale du stock',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo[900],
                      ),
                    ),
                    subtitle: Text(
                      '${stockValue.toStringAsFixed(2)} FC',
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ProductTile(
                        product: products[i],
                        userId: user.uid,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),


      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Nouveau produit',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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