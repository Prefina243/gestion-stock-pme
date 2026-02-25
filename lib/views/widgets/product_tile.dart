import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // ✅ format monétaire
import '../../models/product_model.dart';
import '../home/product_form_screen.dart';
import '../../services/firestore_service.dart';
import '../../controllers/product_controller.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final String userId;

  const ProductTile({
    super.key,
    required this.product,
    required this.userId,
  });

  Future<int?> _askQuantity(
      BuildContext context,
      String type,
      int currentQty,
      ) async {
    final controller = TextEditingController();

    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            '$type de stock',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.indigo[800],
            ),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Quantité à $type',
              hintText: 'Exemple : 5',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Annuler',
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final value = int.tryParse(controller.text);
                if (value == null || value <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Entrez une quantité valide (> 0).'),
                    ),
                  );
                  return;
                }
                Navigator.pop(context, value);
              },
              child: Text(
                'Valider',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ProductController>(context, listen: false);
    final service = FirestoreService();


    final currencyFormat = NumberFormat.currency(
      locale: 'fr_CD',
      symbol: 'FC',
      decimalDigits: 0,
    );
    final formattedPrice = currencyFormat.format(product.unitPrice);

    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
          product.isLowStock ? Colors.redAccent : Colors.indigoAccent,
          radius: 22,
          child: const Icon(Icons.inventory_2_rounded,
              color: Colors.white, size: 22),
        ),
        title: Text(
          product.name,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: product.isLowStock ? Colors.redAccent : Colors.indigo[900],
          ),
        ),
        subtitle: Text(
          'Qté : ${product.quantity}   •   Prix : $formattedPrice\nCode : ${product.barcode}',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          icon: const Icon(Icons.more_vert, color: Colors.indigo),
          onSelected: (value) async {
            if (value == 'edit') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductFormScreen(product: product),
                ),
              );
            } else if (value == 'delete') {
              await service.deleteProduct(userId, product.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.redAccent,
                    content: Text('Produit "${product.name}" supprimé.'),
                  ),
                );
              }
            } else if (value == 'in' || value == 'out') {
              final isEntry = value == 'in';
              final type = isEntry ? 'Entrée' : 'Sortie';
              final qty = await _askQuantity(context, type, product.quantity);

              if (qty != null) {
                final change = isEntry ? qty : -qty;
                await controller.recordTransaction(
                  product: product,
                  quantityChange: change,
                  type: type,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor:
                      isEntry ? Colors.indigo : Colors.deepOrangeAccent,
                      content:
                      Text('$type de $qty unité(s) pour ${product.name}'),
                    ),
                  );
                }
              }
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit_outlined, color: Colors.indigo),
                  const SizedBox(width: 8),
                  Text('Modifier', style: GoogleFonts.poppins()),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete_outline, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Text('Supprimer', style: GoogleFonts.poppins()),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'in',
              child: Row(
                children: [
                  const Icon(Icons.arrow_upward, color: Colors.green),
                  const SizedBox(width: 8),
                  Text('Entrée (+)', style: GoogleFonts.poppins()),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'out',
              child: Row(
                children: [
                  const Icon(Icons.arrow_downward, color: Colors.deepOrange),
                  const SizedBox(width: 8),
                  Text('Sortie (-)', style: GoogleFonts.poppins()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//Modification

