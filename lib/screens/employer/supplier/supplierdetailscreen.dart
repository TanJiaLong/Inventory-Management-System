import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:ims/configs/myconfig.dart';
import 'package:ims/models/supplier.dart';
import 'package:http/http.dart' as http;

class SupplierDetailScreen extends StatefulWidget {
  final Supplier currentSupplier;
  const SupplierDetailScreen({super.key, required this.currentSupplier});

  @override
  State<SupplierDetailScreen> createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends State<SupplierDetailScreen> {
  final scrollController = ScrollController();
  late double sWidth, sHeight, textSize;

  List<SuppliedItem> _suppliedItemList = [];

  bool _isDataAvailable = false;

  @override
  void initState() {
    super.initState();
    loadSuppliedInventory();
  }

  @override
  Widget build(BuildContext context) {
    sWidth = MediaQuery.of(context).size.width;
    sHeight = MediaQuery.of(context).size.height;
    textSize = sWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.currentSupplier.supplierName.toString(),
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
        padding: EdgeInsets.fromLTRB(textSize * 1.25, 0, textSize * 1.25, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                "Contact Information",
                style: TextStyle(
                  fontSize: textSize * 1.5,
                  fontWeight: FontWeight.w900,
                ),
                overflow: TextOverflow.visible,
              ),
            ),
            Flexible(
              flex: 4,
              child: Container(
                width: sWidth,
                height: sHeight * 0.25,
                padding: EdgeInsets.all(textSize / 2)
                    .copyWith(left: textSize * 0.875),
                margin: EdgeInsets.only(top: textSize / 4),
                decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Email:",
                      style: TextStyle(
                          fontSize: textSize * 1.75,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.currentSupplier.supplierEmail.toString(),
                      style: TextStyle(
                        fontSize: textSize * 1.25,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                    ),
                    SizedBox(
                      height: textSize,
                    ),
                    Text(
                      "Phone Number:",
                      style: TextStyle(
                          fontSize: textSize * 1.75,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.currentSupplier.supplierPhone.toString(),
                      style: TextStyle(
                        fontSize: textSize * 1.25,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              child: Container(
                margin: EdgeInsets.fromLTRB(0, textSize, 0, textSize),
                child: Text(
                  "Supplied Items",
                  style: TextStyle(
                      fontSize: textSize * 1.375, fontWeight: FontWeight.w800),
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
            _isDataAvailable
                ? Expanded(
                    flex: 7,
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: _suppliedItemList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final currentItemSupplied = _suppliedItemList[index];
                        return Container(
                          height: sHeight * 0.1,
                          width: sWidth,
                          margin: EdgeInsets.only(bottom: textSize * 0.75),
                          padding: EdgeInsets.all(textSize * 0.75),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Text(
                                          currentItemSupplied.itemName
                                              .toString(),
                                          style: TextStyle(
                                            fontSize: textSize * 1.125,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.visible),
                                    ),
                                    Flexible(
                                      child: Text(
                                          currentItemSupplied.itemCategory
                                              .toString(),
                                          style: TextStyle(
                                            fontSize: textSize,
                                            fontWeight: FontWeight.w300,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.visible),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                : Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          for (int i = 0; i < 4; ++i)
                            Container(
                              width: sWidth,
                              height: sHeight * 0.1,
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[250],
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey[350]!,
                                    Colors.grey[200]!,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(
                                  10,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void loadSuppliedInventory() {
    http.post(
      Uri.parse("${MyConfig.server}/ims/php/supplier/load_supplier.php"),
      body: {
        "supplierName": widget.currentSupplier.supplierName,
      },
    ).then(
      (response) {
        if (response.statusCode == 200) {
          log(response.body);
          dynamic jsonData = jsonDecode(response.body);
          if (jsonData['status'] == "success") {
            var extractSuppliers = jsonData['data'];
            extractSuppliers['suppliedItems'].forEach(
              (suppliedItem) {
                _suppliedItemList.add(SuppliedItem.fromJson(suppliedItem));
              },
            );
            _isDataAvailable = true;
            setState(() {});
          } else if (jsonData['status'] == 'failed') {
            _isDataAvailable = true;
          } else {
            _isDataAvailable = false;
          }
        }
        setState(() {});
      },
    );
  }
}

class SuppliedItem {
  String? itemName;
  String? itemCategory;

  SuppliedItem.fromJson(Map<String, dynamic> json) {
    itemName = json["itemName"];
    itemCategory = json['itemCategory'];
  }
}
