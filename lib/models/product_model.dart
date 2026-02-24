class Product {
  final String id;
  final String name;
  final int quantity;
  final int minStock;
  final double unitPrice;
  final String barcode;

  Product({
    required this.id,
    required this.name,
    required this.quantity,
    required this.minStock,
    required this.unitPrice,
    required this.barcode,
  });

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'],
      quantity: data['quantity'],
      minStock: data['minStock'],
      unitPrice: (data['unitPrice'] ?? 0).toDouble(),
      barcode: data['barcode'],
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'quantity': quantity,
    'minStock': minStock,
    'unitPrice': unitPrice,
    'barcode': barcode,
  };

  bool get isLowStock => quantity < minStock;
}