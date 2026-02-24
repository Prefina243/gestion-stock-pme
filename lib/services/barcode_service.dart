import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeService {
  static Future<String?> scanBarcode(BuildContext context) async {
    String? detectedCode;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) {
        return Scaffold(
          appBar: AppBar(title: const Text('Scanner le code-barres')),
          body: MobileScanner(
            onDetect: (capture) {
              final barcode = capture.barcodes.first;
              detectedCode = barcode.rawValue;
              Navigator.pop(context);
            },
          ),
        );
      }),
    );
    return detectedCode;
  }
}