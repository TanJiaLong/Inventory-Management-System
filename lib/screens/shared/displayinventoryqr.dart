import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:ims/configs/myconfig.dart';
import 'package:ims/models/inventory.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DisplayInventoryQRScreen extends StatefulWidget {
  const DisplayInventoryQRScreen({super.key});

  @override
  State<DisplayInventoryQRScreen> createState() =>
      _DisplayInventoryQRScreenState();
}

class _DisplayInventoryQRScreenState extends State<DisplayInventoryQRScreen> {
  late double sWidth, sHeight, textSize;
  final List<Inventory> _inventoryList = [];
  bool _isDataAvailable = false;

  @override
  void initState() {
    super.initState();
    fetchInventory();
  }

  @override
  Widget build(BuildContext context) {
    sWidth = MediaQuery.of(context).size.width;
    sHeight = MediaQuery.of(context).size.height;
    textSize = sWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Display Inventory QR",
          style: TextStyle(
              color: Colors.black,
              fontSize: textSize * 1.25,
              fontWeight: FontWeight.w900),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            onPressed: () {
              printPDFDialog();
            },
            icon: const Icon(
              Icons.print,
            ),
          ),
        ],
      ),
      body: _isDataAvailable
          ? SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(textSize / 2),
                child: Column(
                  children: [
                    GridView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Number of columns
                        crossAxisSpacing: 10.0, // Spacing between columns
                        mainAxisSpacing: 10.0, // Spacing between rows
                        childAspectRatio: 1.0, // Aspect ratio of each grid item
                      ),
                      children: _inventoryList.map((currentInventory) {
                        return Container(
                          alignment: Alignment.topCenter,
                          width: sWidth * 0.3,
                          height: sWidth * 0.3,
                          padding: EdgeInsets.all(textSize / 2)
                              .copyWith(left: textSize * 0.75),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                flex: 9,
                                child: QrImageView(
                                  data: currentInventory.inventoryID.toString(),
                                  version: QrVersions.auto,
                                  size: textSize * 9,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  "ID ${currentInventory.inventoryID}: ${currentInventory.inventoryName}",
                                  style: const TextStyle(),
                                  maxLines: 1,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(
                      height: textSize,
                    ),
                  ],
                ),
              ),
            )
          : Padding(
              padding: EdgeInsets.all(textSize / 2),
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of columns
                  crossAxisSpacing: 10.0, // Spacing between columns
                  mainAxisSpacing: 10.0, // Spacing between rows
                  childAspectRatio: 1.0, // Aspect ratio of each grid item
                ),
                children: _inventoryList.map((currentInventory) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      border: Border.all(
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }

  void fetchInventory() async {
    await http.post(
        Uri.parse("${MyConfig.server}/ims/php/inventory/loadQR.php"),
        body: {}).then(
      (response) {
        log(response.body);
        if (response.statusCode == 200) {
          dynamic jsonData = jsonDecode(response.body);
          if (jsonData['status'] == 'success') {
            dynamic extractInventories = jsonData['data'];
            extractInventories['inventories'].forEach(
              (currentInventory) {
                _inventoryList.add(Inventory.fromJson(currentInventory));
              },
            );

            _isDataAvailable = true;
            setState(() {});
          } else {
            showToastMessage("No data loaded");
            _isDataAvailable = false;
          }
        } else {
          showToastMessage("Something wenr wrong - HTTP");
        }
      },
    );
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

  void printPDFDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text("Print PDF?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  printPDF();
                },
                child: const Text("Yes"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("No"),
              ),
            ],
          );
        });
  }

  void printPDF() {}
}
