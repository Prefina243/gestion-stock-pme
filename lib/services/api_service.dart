import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {

  static Future<Map<String, dynamic>?> fetchProductData(String barcode) async {
    final Uri url = Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 1) {
        return data['product'];
      }
    }
    return null;
  }
}