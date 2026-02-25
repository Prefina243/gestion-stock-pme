import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // ✅ import pour le format monétaire
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


    final currencyFormat = NumberFormat.currency(
      locale: 'fr_CD',
      symbol: 'FC',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Tableau de bord',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.indigo[800],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
      ),
      body: StreamBuilder<List<Product>>(
        stream: provider.getProducts(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.indigo),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Aucun produit enregistré.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final products = snapshot.data!;
          final totalValue = provider.computeTotalValue(products);
          final lowStockCount = products.where((p) => p.isLowStock).length;
          final normal = products.length - lowStockCount;


          final totalValueFormatted = currencyFormat.format(totalValue);

          final sections = [
            PieChartSectionData(
              color: Colors.indigoAccent,
              value: normal.toDouble(),
              title: 'OK\n$normal',
              radius: 70,
              titleStyle: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            PieChartSectionData(
              color: Colors.redAccent,
              value: lowStockCount.toDouble(),
              title: 'Bas\n$lowStockCount',
              radius: 70,
              titleStyle: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo[100],
                      child:
                      const Icon(Icons.inventory_2, color: Colors.indigo),
                    ),
                    title: Text(
                      'Produits enregistrés : ${products.length}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo[900],
                      ),
                    ),
                    subtitle: Text(
                      'Valeur totale : $totalValueFormatted\n'
                          'Produits critiques : $lowStockCount',
                      style: GoogleFonts.poppins(color: Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  'Répartition du stock',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.indigo[900],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  height: 300,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 50,
                      sectionsSpace: 5,
                      startDegreeOffset: -90,
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Analyse :',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    lowStockCount == 0
                        ? 'Tous vos produits sont bien approvisionnés. Bravo ! 🎉'
                        : '⚠️ Attention : ${lowStockCount} produit(s) en stock faible. Pensez à les réapprovisionner.',
                    style: GoogleFonts.poppins(fontSize: 15),
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