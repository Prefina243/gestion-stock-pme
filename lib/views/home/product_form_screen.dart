import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/product_model.dart';
import '../../services/firestore_service.dart';
import '../../services/barcode_service.dart';
import '../../services/api_service.dart';   // ✅ import de ton API externe

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _minCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameCtrl.text = widget.product!.name;
      _qtyCtrl.text = widget.product!.quantity.toString();
      _minCtrl.text = widget.product!.minStock.toString();
      _priceCtrl.text = widget.product!.unitPrice.toString();
      _barcodeCtrl.text = widget.product!.barcode;
    }
  }

  /// 🔹 Scan du code‑barres ET récupération via l’API externe
  Future<void> _scanBarcode() async {
    final scanned = await BarcodeService.scanBarcode(context);
    if (scanned != null) {
      _barcodeCtrl.text = scanned;

      // 🔹 Appel de l’API (ex : Open Food Facts)
      final apiProduct = await ApiService.fetchProductData(scanned);

      if (apiProduct != null) {
        setState(() {
          _nameCtrl.text = apiProduct['product_name'] ?? '';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produit trouvé : ${apiProduct['product_name']}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Aucun produit trouvé dans la base externe.')),
        );
      }
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    setState(() => _loading = true);

    final product = Product(
      id: widget.product?.id ?? '',
      name: _nameCtrl.text.trim(),
      quantity: int.parse(_qtyCtrl.text),
      minStock: int.parse(_minCtrl.text),
      unitPrice: double.parse(_priceCtrl.text),
      barcode: _barcodeCtrl.text.trim(),
    );

    final service = FirestoreService();

    if (widget.product == null) {
      await service.addProduct(userId, product);
    } else {
      await service.updateProduct(userId, product);
    }

    if (mounted) {
      setState(() => _loading = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
          Text(widget.product == null ? 'Nouveau produit' : 'Modifier produit')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nom du produit'),
                validator: (v) => v!.isEmpty ? 'Obligatoire' : null,
              ),
              TextFormField(
                controller: _qtyCtrl,
                decoration: const InputDecoration(labelText: 'Quantité'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Obligatoire' : null,
              ),
              TextFormField(
                controller: _minCtrl,
                decoration: const InputDecoration(labelText: 'Stock minimum'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Obligatoire' : null,
              ),
              TextFormField(
                controller: _priceCtrl,
                decoration:
                const InputDecoration(labelText: 'Prix unitaire (€)'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Obligatoire' : null,
              ),
              TextFormField(
                controller: _barcodeCtrl,
                decoration: InputDecoration(
                  labelText: 'Code‑barres',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: _scanBarcode,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _saveProduct,
                child: Text(
                    widget.product == null ? 'Enregistrer' : 'Modifier'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}