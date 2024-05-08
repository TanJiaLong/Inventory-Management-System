import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ims/configs/myconfig.dart';
import 'package:ims/models/inventory.dart';
import 'package:ims/models/user.dart';
import 'package:ims/screens/shared/notificationscreen.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'package:badges/badges.dart' as Badges;

class EmployerHomeScreen extends StatefulWidget {
  final User user;
  const EmployerHomeScreen({super.key, required this.user});

  @override
  State<EmployerHomeScreen> createState() => _EmployerHomeScreenState();
}

class _EmployerHomeScreenState extends State<EmployerHomeScreen> {
  var dateFormat = DateFormat('dd MMM');
  late double sWidth, sHeight, textSize;
  final List<Inventory> _lowQuantityInventoryList = [];
  final List<QuantityDate> _stockInquantityDateList = [];
  final List<QuantityDate> _stockOutquantityDateList = [];
  final List<QuantityCategory> _quantityCategoryList = [];
  bool _isDataAvailable = false;
  int _totalSalesQuantity = 0;
  final List<SalesSummaryData> _salesDataList = [];

  @override
  void initState() {
    super.initState();
    loadInventoryDataList();
    loadLowQuantityInventoryList();
    loadSalesData();
  }

  @override
  Widget build(BuildContext context) {
    sWidth = MediaQuery.of(context).size.width;
    sHeight = MediaQuery.of(context).size.height;
    textSize = sWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Dashboard",
          style: TextStyle(
            color: Colors.black,
            fontSize: textSize * 1.25,
            fontWeight: FontWeight.w900,
          ),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          _lowQuantityInventoryList.isNotEmpty
              ? Align(
                  alignment: Alignment.center,
                  child: Badges.Badge(
                    position: Badges.BadgePosition.topEnd(
                        top: textSize / 2, end: textSize / 3),
                    badgeContent: Text(
                      _lowQuantityInventoryList.length.toString(),
                      style: TextStyle(
                          color: Colors.white, fontSize: textSize / 2),
                    ),
                    badgeAnimation: const Badges.BadgeAnimation.slide(),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationScreen(
                                lowQuantityInventoryList:
                                    _lowQuantityInventoryList),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.notifications_active_outlined,
                        color: Colors.black,
                        size: textSize * 1.5,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  onPressed: () {
                    showToastMessage("No notifications");
                  },
                  icon: Icon(
                    Icons.notifications_active_outlined,
                    color: Colors.black,
                    size: textSize * 1.5,
                  ),
                )
        ],
      ),
      body: _isDataAvailable
          ? SizedBox(
              width: sWidth,
              height: sHeight,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: sHeight * 0.5,
                      margin: EdgeInsets.fromLTRB(
                          textSize / 2, 0, textSize / 2, textSize * 0.75),
                      padding: EdgeInsets.fromLTRB(textSize / 2, textSize / 2,
                          textSize / 2, textSize * 0.75),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: textSize / 8,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Inventory Flow (Week)",
                            style: TextStyle(
                              fontSize: textSize * 1.25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(
                                top: textSize / 2,
                              ),
                              padding: EdgeInsets.only(
                                top: textSize,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: textSize / 8,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: SfCartesianChart(
                                margin: const EdgeInsets.all(8),
                                legend: Legend(
                                  isVisible: true,
                                  position: LegendPosition.bottom,
                                ),
                                primaryXAxis: CategoryAxis(
                                  minimum: 0,
                                  interval: 1,
                                  borderColor: Colors.transparent,
                                  arrangeByIndex: true,
                                ),
                                primaryYAxis: NumericAxis(
                                  interval: 4,
                                  borderColor: Colors.transparent,
                                ),
                                series: <ChartSeries>[
                                  StackedLineSeries<QuantityDate, String>(
                                    color: Colors.green,
                                    dataSource: _stockInquantityDateList,
                                    xValueMapper: (QuantityDate data, _) =>
                                        dateFormat
                                            .format(DateTime.parse(data.date!)),
                                    yValueMapper: (QuantityDate data, _) =>
                                        int.parse(
                                      data.totalQuantity!,
                                    ),
                                    dataLabelSettings: const DataLabelSettings(
                                      isVisible: true,
                                    ),
                                    name: "Stock In",
                                    groupName: "StockIn",
                                    markerSettings: const MarkerSettings(
                                      isVisible: true,
                                    ),
                                  ),
                                  StackedLineSeries<QuantityDate, String>(
                                    color: Colors.red,
                                    dataSource: _stockOutquantityDateList,
                                    xValueMapper: (QuantityDate data, _) =>
                                        dateFormat
                                            .format(DateTime.parse(data.date!)),
                                    yValueMapper: (QuantityDate data, _) =>
                                        int.parse(
                                      data.totalQuantity!,
                                    ),
                                    dataLabelSettings: const DataLabelSettings(
                                      isVisible: true,
                                    ),
                                    name: "Stock Out",
                                    groupName: "StockOut",
                                    markerSettings: const MarkerSettings(
                                      isVisible: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: sHeight * 0.4,
                      margin: EdgeInsets.fromLTRB(
                          textSize / 2, 0, textSize / 2, textSize * 0.75),
                      padding: EdgeInsets.fromLTRB(textSize / 2, textSize / 2,
                          textSize / 2, textSize * 0.75),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: textSize / 8,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Inventory (Category)",
                            style: TextStyle(
                              fontSize: textSize * 1.25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(
                                top: textSize / 2,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: textSize / 8,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: SfCircularChart(
                                legend: Legend(
                                  isVisible: true,
                                  overflowMode: LegendItemOverflowMode.wrap,
                                ),
                                series: <CircularSeries>[
                                  DoughnutSeries<QuantityCategory, String>(
                                    dataSource: _quantityCategoryList,
                                    xValueMapper: (QuantityCategory data, _) =>
                                        data.category,
                                    yValueMapper: (QuantityCategory data, _) =>
                                        int.parse(data.totalQuantity!),
                                    dataLabelSettings: const DataLabelSettings(
                                      isVisible: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: sHeight * 0.2,
                      margin: EdgeInsets.fromLTRB(
                          textSize / 2, 0, textSize / 2, textSize * 0.75),
                      padding: EdgeInsets.all(textSize / 2).copyWith(bottom: 0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: textSize / 8,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              "Top Sales For This Month",
                              style: TextStyle(
                                fontSize: textSize * 1.25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Container(
                              margin: EdgeInsets.only(
                                top: textSize / 2,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  for (int i = 0; i < 3; i++)
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              width: sWidth * 0.17,
                                              height: sWidth * 0.17,
                                              padding:
                                                  EdgeInsets.all(textSize / 2),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  5,
                                                ),
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color.fromARGB(
                                                        255, 0, 230, 0),
                                                    Color.fromARGB(
                                                        255, 0, 255, 0),
                                                  ],
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      _salesDataList[i]
                                                          .totalSalesQuantity
                                                          .toString(),
                                                      style: TextStyle(
                                                        fontSize: textSize,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color: Colors.white,
                                                      ),
                                                      overflow:
                                                          TextOverflow.visible,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                      "items",
                                                      style: TextStyle(
                                                        fontSize: textSize,
                                                        color: Colors.white,
                                                      ),
                                                      overflow:
                                                          TextOverflow.visible,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              _salesDataList[i]
                                                  .salesCategory
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: textSize * 0.75,
                                                  fontWeight: FontWeight.bold),
                                              overflow: TextOverflow.visible,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SizedBox(
              height: sHeight,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    for (int i = 0; i < 2; ++i)
                      Container(
                        width: sWidth,
                        height: sHeight * 0.5,
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

  void loadInventoryDataList() {
    http.post(
      Uri.parse("${MyConfig.server}/ims/php/load_dashboard_data.php"),
      body: {},
    ).then(
      (response) {
        if (response.statusCode == 200) {
          // log(response.body);
          var jsonData = jsonDecode(response.body);
          if (jsonData['status'] == 'success') {
            dynamic extractQuantityDate = jsonData['imQuantityDate'];
            extractQuantityDate['quantityDate'].forEach(
              (element) {
                if (element['imInventoryFlow'] == 'Stock-In') {
                  _stockInquantityDateList.add(QuantityDate.fromJson(element));
                } else if (element['imInventoryFlow'] == 'Stock-Out') {
                  _stockOutquantityDateList.add(QuantityDate.fromJson(element));
                } else {
                  // Error
                }
              },
            );

            dynamic extractQuantityCategory =
                jsonData['inventoryQuantityCategory'];
            extractQuantityCategory['quantityCategory'].forEach(
              (element) {
                _quantityCategoryList.add(QuantityCategory.fromJson(element));
              },
            );
            setState(() {});
          }
        } else {
          _isDataAvailable = false;
        }
      },
    );
  }

  void loadLowQuantityInventoryList() async {
    await http.post(
        Uri.parse("${MyConfig.server}/ims/php/load_low_quantity_inventory.php"),
        body: {}).then((response) {
      if (response.statusCode == 200) {
        dynamic jsonData = jsonDecode(response.body);
        if (jsonData['status'] == "success") {
          dynamic extractLowQuantityInventories = jsonData['data'];
          extractLowQuantityInventories['inventories']
              .forEach((currentInventory) {
            _lowQuantityInventoryList.add(Inventory.fromJson(currentInventory));
          });
          setState(() {});
        } else {}
      } else {}
    });
  }

  void loadSalesData() async {
    await http.post(
        Uri.parse("${MyConfig.server}/ims/php/sales/load_sales_data.php"),
        body: {}).then(
      (response) {
        if (response.statusCode == 200) {
          dynamic jsonData = jsonDecode(response.body);
          if (jsonData['status'] == "success") {
            dynamic extractSalesData = jsonData['salesData'];
            extractSalesData['salesData'].forEach((salesData) {
              _salesDataList.add(SalesSummaryData.fromJson(salesData));
            });

            for (SalesSummaryData salesData in _salesDataList) {
              _totalSalesQuantity += int.parse(salesData.totalSalesQuantity!);
            }
            while (_salesDataList.length < 3) {
              _salesDataList.add(SalesSummaryData("--", "0"));
            }
            _isDataAvailable = true;
          } else {}
        }
        setState(() {});
      },
    );
  }
}

class QuantityDate {
  String? totalQuantity;
  String? date;

  QuantityDate(this.totalQuantity, this.date);

  QuantityDate.fromJson(Map<String, dynamic> json) {
    totalQuantity = json["imTotalQuantity"];
    date = json['imRegistrationDate'];
  }
}

class QuantityCategory {
  String? totalQuantity;
  String? category;

  QuantityCategory(this.totalQuantity, this.category);

  QuantityCategory.fromJson(Map<String, dynamic> json) {
    totalQuantity = json["inventoryTotalQuantity"];
    category = json['inventoryCategory'];
  }
}

class SalesSummaryData {
  String? salesCategory;
  String? totalSalesQuantity;

  SalesSummaryData(String this.salesCategory, String this.totalSalesQuantity);

  SalesSummaryData.fromJson(Map<String, dynamic> json) {
    salesCategory = json['salesCategory'];
    totalSalesQuantity = json["salesTotalQuantity"];
  }
}
