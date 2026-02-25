import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // ✅ pour le format monétaire
import '../../models/product_model.dart';
import '../../services/firestore_service.dart';
import '../../services/barcode_service.dart';
import '../../services/api_service.dart';

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


  final NumberFormat _fcFormat = NumberFormat.currency(
    locale: 'fr_CD',
    symbol: 'FC',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameCtrl.text = widget.product!.name;
      _qtyCtrl.text = widget.product!.quantity.toString();
      _minCtrl.text = widget.product!.minStock.toString();


      _priceCtrl.text =
          _fcFormat.format(widget.product!.unitPrice).replaceAll(' ', ' ');
      _barcodeCtrl.text = widget.product!.barcode;
    }
  }

  Future<void> _scanBarcode() async {
    final scanned = await BarcodeService.scanBarcode(context);
    if (scanned != null) {
      _barcodeCtrl.text = scanned;
      final apiProduct = await ApiService.fetchProductData(scanned);

      if (apiProduct != null) {
        setState(() {
          _nameCtrl.text = apiProduct['product_name'] ?? '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produit trouvé : ${apiProduct['product_name']}'),
            backgroundColor: Colors.indigo,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucun produit trouvé dans la base externe.'),
          ),
        );
      }
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    setState(() => _loading = true);


    final double parsedPrice = double.tryParse(
      _priceCtrl.text.replaceAll(RegExp(r'[^0-9.]'), ''),
    ) ??
        0;

    final product = Product(
      id: widget.product?.id ?? '',
      name: _nameCtrl.text.trim(),
      quantity: int.parse(_qtyCtrl.text),
      minStock: int.parse(_minCtrl.text),
      unitPrice: parsedPrice,
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        title: Text(
          widget.product == null ? 'Nouveau produit' : 'Modifier produit',
          style: GoogleFonts.poppins(
            color: Colors.indigo[800],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _nameCtrl,
                    label: 'Nom du produit',
                    icon: Icons.inventory_2_outlined,
                    validator: (v) =>
                    v!.isEmpty ? 'Ce champ est obligatoire' : null,
                  ),
                  _buildTextField(
                    controller: _qtyCtrl,
                    label: 'Quantité',
                    icon: Icons.storage_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                    v!.isEmpty ? 'Ce champ est obligatoire' : null,
                  ),
                  _buildTextField(
                    controller: _minCtrl,
                    label: 'Stock minimum',
                    icon: Icons.warning_amber_rounded,
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                    v!.isEmpty ? 'Ce champ est obligatoire' : null,
                  ),
                  _buildTextField(
                    controller: _priceCtrl,
                    label: 'Prix unitaire (FC)',
                    icon: Icons.payments_outlined,
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) =>
                    v!.isEmpty ? 'Ce champ est obligatoire' : null,
                  ),
                  TextFormField(
                    controller: _barcodeCtrl,
                    decoration: InputDecoration(
                      labelText: 'Code-barres',
                      prefixIcon:
                      const Icon(Icons.qr_code, color: Colors.indigo),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.qr_code_scanner,
                            color: Colors.indigo),
                        onPressed: _scanBarcode,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  _loading
                      ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.indigo,
                    ),
                  )
                      : ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _saveProduct,
                    icon: Icon(
                      widget.product == null
                          ? Icons.save_outlined
                          : Icons.check_circle_outline,
                      color: Colors.white,
                    ),
                    label: Text(
                      widget.product == null
                          ? 'Enregistrer'
                          : 'Modifier',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.indigo),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.indigo, width: 0.4),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.indigo, width: 1.2),
          ),
          labelStyle: GoogleFonts.poppins(),
        ),
        validator: validator,
        keyboardType: keyboardType,
      ),
    );
  }
}