import 'package:flutter/material.dart';
import 'package:kompot/routes.dart';
import 'dart:io';

import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScanPage extends StatefulWidget {
  const QRScanPage({Key? key}) : super(key: key);

  static const routeName = '/qr_scan_page';

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) {
      print('Scanned QR code: ${scanData.code}');

      if (dataisValid(scanData.code)) {
        controller.pauseCamera();
        Navigator.pop(context, scanData.code);
      }
    });
  }

  bool dataisValid(String? data) {
    if (data == null) {
      return false;
    }

    return true;
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.red,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
            ),
            onQRViewCreated: _onQRViewCreated,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 32,
                  color: Colors.white,
                ),
                onPressed: () {
                  navigatePop();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
