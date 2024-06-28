import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recyclear/utils/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRCodeScannerView extends StatefulWidget {
  const QRCodeScannerView({super.key});

  @override
  State<StatefulWidget> createState() => _QRCodeScannerViewState();
}

class _QRCodeScannerViewState extends State<QRCodeScannerView> {
  bool _showDialog = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool isProcessing = false; // Flag to prevent multiple increments
  DateTime? lastScanTime; // To keep track of the last successful scan time

  @override
  void initState() {
    super.initState();
    _checkFirstTimeUser('QRCodeScannerView');
  }

  @override
  Widget build(BuildContext context) {
    if (_showDialog && WidgetsBinding.instance != null) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        _showIntroDialog(context);
        setState(() {
          _showDialog = false;
        });
      });
    }
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Scanner')),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text('Scanned Data: ${result!.code}')
                  : const Text('Scan a code'),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!isProcessing) {
        setState(() {
          result = scanData;
          isProcessing =
              true; // Set the flag to true to prevent multiple increments
        });
        // Process the scanned data
        _processScannedData(scanData.code);
      }
    });
  }

  void _processScannedData(String? scannedData) async {
    if (scannedData != null) {
      try {
        // Pause the camera to prevent multiple scans
        controller?.pauseCamera();

        int binId = int.parse(
            scannedData); // Assuming the scanned data is the bin ID as an integer
        await _retrieveBinHistoryAndUpdatePoints(binId);

        // Optionally resume the camera after a delay
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            isProcessing = false; // Reset the flag
          });
          controller?.resumeCamera();
        });
      } catch (e) {
        print('Error processing scanned data: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error processing scanned data')),
        );
        setState(() {
          isProcessing = false; // Reset the flag on error
        });
      }
    }
  }

  void _showIntroDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'QR Scan Guidelines',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Image.asset(
                    'assets/images/qr-scan.gif',
                    height: 30,
                    width: 30,
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Welcome to Recyclear App! To earn points, follow these steps:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              const Text(
                '1. After discarding your recyclables, scan the QR code on the bin within 2 minutes.',
              ),
              const SizedBox(height: 8.0),
              const Text(
                '2. Ensure the QR code is clearly visible and within the scan area.',
              ),
              const SizedBox(height: 8.0),
              const Text(
                '3. You will earn points for every successful scan.',
              ),
              const SizedBox(height: 16.0),
              Center(
                child: Image.asset(
                  'assets/images/qr.png',
                  height: 150,
                  width: 150,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: AppColors.white,
                backgroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.grey),
              ),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkFirstTimeUser(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String email = user.email!;
      String uniqueKey = '$email-$key';
      bool isFirstTime = prefs.getBool(uniqueKey) ?? true;

      if (isFirstTime) {
        await prefs.setBool(uniqueKey, false);
        setState(() {
          _showDialog = true;
        });
      }
    }
  }

  Future<void> _retrieveBinHistoryAndUpdatePoints(int binId) async {
    try {
      QuerySnapshot binHistorySnapshot = await FirebaseFirestore.instance
          .collection('binsHistory')
          .where('binId', isEqualTo: binId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (binHistorySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> binHistoryData =
            binHistorySnapshot.docs.first.data() as Map<String, dynamic>;
        Timestamp binTimestamp = binHistoryData['timestamp'];
        DateTime binTime = binTimestamp.toDate();
        DateTime currentTime = DateTime.now();

        // Check if the time difference is within the error margin (e.g., 2 minutes)
        if (currentTime.difference(binTime).inMinutes.abs() <= 2) {
          if (lastScanTime == null ||
              currentTime.difference(lastScanTime!).inMinutes.abs() > 2) {
            await _incrementUserPoints();
            lastScanTime = currentTime; // Update last scan time
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('You can only scan once within the error margin.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Time difference is more than 5 minutes.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No history found for this bin.')),
        );
      }
    } catch (e) {
      print('Error retrieving bin history: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error retrieving bin history.')),
      );
    }
  }

  Future<void> _incrementUserPoints() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'points': FieldValue.increment(10), // Example: increment points by 10
      });

      // Optionally, show a success message or update the UI
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Points added successfully!')),
      );
    } catch (e) {
      print('Error updating user points: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating user points.')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
