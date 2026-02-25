class TransactionModel {
  final String productId;
  final String productName;
  final int quantityChange;
  final String type;
  final DateTime date;

  TransactionModel({
    required this.productId,
    required this.productName,
    required this.quantityChange,
    required this.type,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'productName': productName,
    'quantityChange': quantityChange,
    'type': type,
    'date': date.toIso8601String(),
  };

  factory TransactionModel.fromMap(Map<String, dynamic> data) {
    return TransactionModel(
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      quantityChange: data['quantityChange'] ?? 0,
      type: data['type'] ?? '',
      date: DateTime.tryParse(data['date'] ?? '') ?? DateTime.now(),
    );
  }
}