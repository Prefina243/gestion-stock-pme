import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  /// 🔹 Demande à l'utilisateur une quantité à modifier
  Future<int?> _askQuantity(
      BuildContext context, String type, int currentQty) async {
    final controller = TextEditingController();
    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$type de stock'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Quantité à $type',
              hintText: 'Exemple : 5',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // fermer
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                final value = int.tryParse(controller.text);
                if (value == null || value <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Entrez une quantité valide (> 0).')),
                  );
                  return;
                }
                Navigator.pop(context, value);
              },
              child: const Text('Valider'),
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

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
          product.isLowStock ? Colors.redAccent : Colors.green,
          radius: 10,
        ),
        title: Text(
          product.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: product.isLowStock ? Colors.red : Colors.black,
          ),
        ),
        subtitle: Text(
          'Qté: ${product.quantity} • Prix: ${product.unitPrice}€\nCode: ${product.barcode}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              // ✏️ Modifier produit
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductFormScreen(product: product),
                ),
              );
            } else if (value == 'delete') {
              // 🗑️ Supprimer produit
              await service.deleteProduct(userId, product.id);
            } else if (value == 'in' || value == 'out') {
              // ➕ Entrée ou ➖ Sortie de stock avec saisie
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                      Text('$type de $qty unités pour ${product.name}')),
                );
              }
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Modifier')),
            const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
            const PopupMenuDivider(),
            const PopupMenuItem(value: 'in', child: Text('Entrée (+)')),
            const PopupMenuItem(value: 'out', child: Text('Sortie (-)')),
          ],
        ),
      ),
    );
  }
}