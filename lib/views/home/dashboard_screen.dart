import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final provider = Provider.of<ProductProvider>(context, listen: false);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Aucun utilisateur connecté')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de bord')),
      body: StreamBuilder<List<Product>>(
        stream: provider.getProducts(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun produit enregistré.'));
          }

          final products = snapshot.data!;
          final totalValue = provider.computeTotalValue(products);
          final lowStockCount = products.where((p) => p.isLowStock).length;
          final normal = products.length - lowStockCount;

          final sections = [
            PieChartSectionData(
              color: Colors.green,
              value: normal.toDouble(),
              title: 'OK\n$normal',
              radius: 60,
              titleStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              color: Colors.redAccent,
              value: lowStockCount.toDouble(),
              title: 'Bas\n$lowStockCount',
              radius: 60,
              titleStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      'Produits : ${products.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                        'Valeur totale : ${totalValue.toStringAsFixed(2)} €\nProduits critiques : $lowStockCount'),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Répartition du stock',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 40,
                      sectionsSpace: 5,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}