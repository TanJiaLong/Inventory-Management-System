import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:ims/configs/myconfig.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class SalesReportScreen extends StatefulWidget {
  final DateTime fromDate, toDate;
  const SalesReportScreen(
      {super.key, required this.fromDate, required this.toDate});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  late double sWidth, sHeight, textSize;
  DateFormat dateFormat = DateFormat('dd MMM yyyy');
  List<ReportData> reportDataList = [];
  double _grandTotal = 0;
  double _profit = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    sWidth = MediaQuery.of(context).size.width;
    sHeight = MediaQuery.of(context).size.height;
    textSize = sWidth * 0.04;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Sales Report",
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
        width: sWidth,
        height: sHeight,
        padding: EdgeInsets.all(textSize * 0.75),
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "IMS Sales Report",
                style: TextStyle(
                    fontSize: textSize * 1.75, fontWeight: FontWeight.w900),
              ),
              SizedBox(
                height: textSize / 4,
              ),
              Text(
                "${dateFormat.format(widget.fromDate)} - ${dateFormat.format(widget.toDate)}",
                style: TextStyle(fontSize: textSize, color: Colors.grey),
              ),
              SizedBox(
                height: textSize * 1.5,
              ),
              Table(
                border: TableBorder.all(color: Colors.black),
                columnWidths: const {
                  0: FlexColumnWidth(0.6),
                  1: FlexColumnWidth(1.1),
                  2: FlexColumnWidth(1.2),
                  3: FlexColumnWidth(1.1),
                  4: FlexColumnWidth(1.5),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                    ),
                    children: [
                      TableCell(
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(textSize / 2),
                          height: sHeight * 0.08,
                          child: Text(
                            "ID",
                            style: TextStyle(
                              fontSize: textSize * 0.75,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.visible,
                            maxLines: 2,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(textSize / 2),
                          height: sHeight * 0.08,
                          child: Text(
                            "Inventory Name",
                            style: TextStyle(
                              fontSize: textSize * 0.75,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.visible,
                            maxLines: 2,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(textSize / 2),
                          height: sHeight * 0.08,
                          child: Text(
                            "Price (RM)",
                            style: TextStyle(
                              fontSize: textSize * 0.75,
                              fontWeight: FontWeight.w900,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(textSize / 2),
                          height: sHeight * 0.08,
                          child: Text(
                            "Quantity",
                            style: TextStyle(
                              fontSize: textSize * 0.75,
                              fontWeight: FontWeight.w900,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(textSize / 2),
                          height: sHeight * 0.08,
                          child: Text(
                            "Amount (RM)",
                            style: TextStyle(
                              fontSize: textSize * 0.75,
                              fontWeight: FontWeight.w900,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (reportDataList.isEmpty)
                    TableRow(
                      children: [
                        TableCell(
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(textSize / 2),
                            height: sHeight * 0.06,
                            child: const Text(
                              "---",
                              style: TextStyle(),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(textSize / 2),
                            height: sHeight * 0.06,
                            child: const Text(
                              "---",
                              style: TextStyle(),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(textSize / 2),
                            height: sHeight * 0.06,
                            child: const Text(
                              "---",
                              style: TextStyle(),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(textSize / 2),
                            height: sHeight * 0.06,
                            child: const Text(
                              "---",
                              style: TextStyle(),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(textSize / 2),
                            height: sHeight * 0.06,
                            child: const Text(
                              "---",
                              style: TextStyle(),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    for (int i = 0; i < reportDataList.length; ++i)
                      TableRow(
                        children: [
                          TableCell(
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(textSize / 2),
                              height: sHeight * 0.06,
                              child: Text(
                                reportDataList[i].inventoryID.toString(),
                                style: TextStyle(
                                  fontSize: textSize * 0.75,
                                ),
                                overflow: TextOverflow.visible,
                                maxLines: 2,
                              ),
                            ),
                          ),
                          TableCell(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.all(textSize / 2),
                              height: sHeight * 0.06,
                              child: Text(
                                reportDataList[i].inventoryName.toString(),
                                style: TextStyle(
                                  fontSize: textSize * 0.75,
                                ),
                                overflow: TextOverflow.visible,
                                maxLines: 2,
                              ),
                            ),
                          ),
                          TableCell(
                            child: Container(
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.all(textSize / 2),
                              height: sHeight * 0.06,
                              child: Text(
                                  reportDataList[i].inventoryPrice.toString(),
                                  style: TextStyle(
                                    fontSize: textSize * 0.75,
                                  ),
                                  overflow: TextOverflow.visible,
                                  maxLines: 2),
                            ),
                          ),
                          TableCell(
                            child: Container(
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.all(textSize / 2),
                              height: sHeight * 0.06,
                              child: Text(
                                  reportDataList[i]
                                      .inventoryTotalQuantity
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: textSize * 0.75,
                                  ),
                                  overflow: TextOverflow.visible,
                                  maxLines: 1),
                            ),
                          ),
                          TableCell(
                            child: Container(
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.all(textSize / 2),
                              height: sHeight * 0.06,
                              child: Text(
                                  double.parse(reportDataList[i]
                                          .inventoryTotalAmount
                                          .toString())
                                      .toStringAsFixed(2),
                                  style: TextStyle(
                                    fontSize: textSize * 0.75,
                                  ),
                                  overflow: TextOverflow.visible,
                                  maxLines: 1),
                            ),
                          ),
                        ],
                      ),
                ],
              ),
              Table(
                border: TableBorder.all(color: Colors.black),
                columnWidths: const {
                  0: FlexColumnWidth(4),
                  1: FlexColumnWidth(1.5),
                },
                children: [
                  TableRow(
                    children: [
                      TableCell(
                        child: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.all(textSize / 2),
                          height: sHeight * 0.05,
                          child: const Text("Grand Total:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.visible,
                              maxLines: 1),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.all(textSize / 2),
                          height: sHeight * 0.05,
                          child: Text(_grandTotal.toStringAsFixed(2),
                              style: TextStyle(
                                  fontSize: textSize * 0.75,
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.clip),
                              overflow: TextOverflow.visible,
                              maxLines: 1),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      TableCell(
                        child: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.all(textSize / 2),
                          height: sHeight * 0.05,
                          child: const Text("Profit:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.visible,
                              maxLines: 1),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.all(textSize / 2),
                          height: sHeight * 0.05,
                          child: Text(_profit.toStringAsFixed(2),
                              style: TextStyle(
                                  fontSize: textSize * 0.75,
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.clip),
                              overflow: TextOverflow.visible,
                              maxLines: 1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void loadData() {
    http.post(Uri.parse("${MyConfig.server}/ims/php/sales/load_report.php"),
        body: {
          "fromDate": widget.fromDate.toString(),
          "toDate": widget.toDate.toString(),
        }).then((response) {
      if (response.statusCode == 200) {
        log(response.body);
        var jsonData = jsonDecode(response.body);
        if (jsonData['status'] == "success") {
          var extractData = jsonData['data'];
          extractData['reportData'].forEach((v) {
            reportDataList.add(ReportData.fromJson(v));
          });
          for (ReportData reportData in reportDataList) {
            _grandTotal +=
                double.parse(reportData.inventoryTotalAmount.toString());
            _profit += reportData.inventoryProfitRate! *
                double.parse(reportData.inventoryTotalAmount.toString());
          }

          setState(() {});
        }
      }
    });
  }
}

class ReportData {
  String? inventoryID;
  String? inventoryName;
  String? inventoryPrice;
  String? inventoryTotalQuantity;
  String? inventoryTotalAmount;
  double? inventoryProfitRate;

  ReportData.fromJson(Map<String, dynamic> json) {
    inventoryID = json['inventoryID'];
    inventoryName = json['inventoryName'];
    inventoryPrice = json['inventoryPrice'];
    inventoryTotalQuantity = json['inventoryTotalQuantity'];
    inventoryTotalAmount = json['inventoryTotalAmount'];
    inventoryProfitRate = json['inventoryProfitRate'];
  }
}
