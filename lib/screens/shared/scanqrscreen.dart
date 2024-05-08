import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ims/configs/myconfig.dart';
import 'package:ims/models/inventory.dart';
import 'package:ims/models/user.dart';
import 'package:ims/screens/shared/inventory/addinventoryhistoryscreen.dart';
import 'package:ims/screens/shared/inventory/inventorydetailscreen.dart';

import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';
import 'package:http/http.dart' as http;

class ScanQRScreen extends StatefulWidget {
  final User user;
  const ScanQRScreen({super.key, required this.user});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  late double sWidth, sHeight, textSize;
  late double borderlength;
  bool isScanComplete = false;

  MobileScannerController mobileScannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
  );

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  @override
  void dispose() {
    mobileScannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    sWidth = MediaQuery.of(context).size.width;
    sHeight = MediaQuery.of(context).size.height;
    borderlength = sHeight * 0.35;
    textSize = sWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Scan Inventory",
          style: TextStyle(
              color: Colors.black,
              fontSize: textSize * 1.25,
              fontWeight: FontWeight.w900),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Colors.white,
        width: sWidth,
        height: sHeight,
        padding: EdgeInsets.all(sWidth * 0.15),
        child: Column(
          children: [
            Flexible(
              child: SizedBox(
                width: borderlength,
                height: borderlength,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: borderlength * 0.6,
                      width: borderlength * 0.6,
                      child: MobileScanner(
                        controller: mobileScannerController,
                        onDetect: (barcode) async {
                          final List<Barcode> barCodes = barcode.barcodes;

                          if (!isScanComplete) {
                            isScanComplete = true;
                            String inventoryID =
                                barCodes.first.rawValue ?? "N/A";
                            Inventory? resultInventory =
                                await loadInventory(inventoryID);
                            if (resultInventory != null) {
                              showPopUpDialog(resultInventory);
                            } else {
                              showToastMessage(inventoryID);
                              return;
                            }
                          }
                        },
                      ),
                    ),
                    QRScannerOverlay(
                      overlayColor: Colors.white,
                      borderColor: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: textSize * 1.75,
            ),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            "Place the QR code in the area",
                            style: TextStyle(
                              fontSize: textSize,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            "Scanning will be started automatically",
                            style: TextStyle(
                              color: const Color.fromARGB(255, 194, 194, 194),
                              fontSize: textSize * 0.75,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "No response? ",
                          style: TextStyle(
                            fontSize: textSize,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 165, 165, 165),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _refreshQRScanner();
                          },
                          child: const Text(
                            "Refresh",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _requestCameraPermission() async {
    PermissionStatus cameraStatus = PermissionStatus.denied;
    cameraStatus = await Permission.camera.request();
    if (cameraStatus.isDenied || cameraStatus.isPermanentlyDenied) {
      showToastMessage("Camera permission is denied");
    }
  }

  void _refreshQRScanner() {
    isScanComplete = false;

    _requestCameraPermission();
  }

  void showToastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 2,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void showPopUpDialog(Inventory resultInventory) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("ID: ${resultInventory.inventoryID}"),
          content: SizedBox(
            height: sHeight * 0.15,
            child: Column(
              children: [
                Flexible(
                  child: ElevatedButton(
                    style: ButtonStyle(
                        minimumSize: MaterialStatePropertyAll(
                          Size(
                            sWidth * 0.5,
                            textSize * 3.5,
                          ),
                        ),
                        backgroundColor:
                            const MaterialStatePropertyAll(Colors.blue)),
                    onPressed: () {
                      if (widget.user.userRole != "Employee") {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InventoryDetailScreen(
                              currentInventory: resultInventory,
                              userRole: widget.user.userRole.toString(),
                              staffID: widget.user.staffID.toString(),
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InventoryDetailScreen(
                              currentInventory: resultInventory,
                              userRole: widget.user.userRole.toString(),
                              staffID: widget.user.staffID.toString(),
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text("View"),
                  ),
                ),
                SizedBox(
                  height: textSize,
                ),
                Flexible(
                  child: ElevatedButton(
                    style: ButtonStyle(
                        minimumSize: MaterialStatePropertyAll(
                          Size(
                            sWidth * 0.5,
                            textSize * 3.5,
                          ),
                        ),
                        backgroundColor:
                            const MaterialStatePropertyAll(Colors.redAccent)),
                    onPressed: () {
                      if (widget.user.userRole != "Employee") {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddInventoryMovementHistoryScreen(
                              currentInventory: resultInventory,
                              staffID: widget.user.staffID.toString(),
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddInventoryMovementHistoryScreen(
                              currentInventory: resultInventory,
                              staffID: widget.user.staffID.toString(),
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text("Add"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Inventory?> loadInventory(String inventoryID) async {
    Inventory? resultInventory;
    await http.post(
        Uri.parse("${MyConfig.server}/ims/php/inventory/scanQR.php"),
        body: {
          "inventoryID": inventoryID,
        }).then(
      (response) {
        // log(response.body);
        if (response.statusCode == 200) {
          dynamic jsonData = jsonDecode(response.body);
          if (jsonData['status'] == "success") {
            resultInventory = Inventory.fromJson(jsonData['data']);
          } else {}
        } else {}
      },
    );

    return resultInventory;
  }
}
