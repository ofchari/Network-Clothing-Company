import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  MobileScannerController? controller;
  bool _hasDetectedBarcode = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Barcode"),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => controller?.toggleTorch(),
          ),
        ],
      ),
      body: MobileScanner(
        controller: controller!,
        onDetect: (capture) {
          if (!_hasDetectedBarcode) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              _hasDetectedBarcode = true;
              final String code = barcodes.first.rawValue ?? "";

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Barcode Detected"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Scanned DC Number: $code"),
                        const SizedBox(height: 10),
                        const Text("Do you want to use this code?"),
                      ],
                    ),
                    actions: [
                      TextButton(
                        child: const Text("Scan Again"),
                        onPressed: () {
                          _hasDetectedBarcode = false;
                          Navigator.pop(context); // Close dialog
                        },
                      ),
                      TextButton(
                        child: const Text("Confirm"),
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          Navigator.pop(context, code); // Return to main screen with code
                        },
                      ),
                    ],
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}