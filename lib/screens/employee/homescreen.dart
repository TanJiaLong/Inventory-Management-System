import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:badges/badges.dart' as Badges;
import 'package:ims/configs/myconfig.dart';
import 'package:ims/models/inventory.dart';
import 'package:ims/models/inventorymovement.dart';
import 'package:ims/screens/shared/notificationscreen.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  late double sWidth, sHeight, textSize;
  final List<Inventory> _lowQuantityInventoryList = [];
  final List<RecentTransactionData> _recentTransactionList = [];
  final List<SalesSummaryData> _salesDataList = [];
  bool _isLQLoaded = false, _isRTLoaded = false, _isSDLoaded = false;

  bool _isDataAvailable = false;

  // double _totalSalesQuantity = 0;

  @override
  void initState() {
    super.initState();
    loadLowQuantityInventoryList();
    loadSalesData();
    loadRecentTransaction();
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
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: sHeight * 0.2,
                      margin:
                          EdgeInsets.fromLTRB(textSize / 2, 0, textSize / 2, 0),
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
                  ),
                  Expanded(
                    flex: 5,
                    child: Container(
                      padding: EdgeInsets.all(textSize / 2).copyWith(bottom: 0),
                      child: Column(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Recent Transactions",
                                style: TextStyle(
                                    fontSize: textSize * 1.25,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 6,
                            child: SizedBox(
                              width: sWidth,
                              height: sHeight * 0.5,
                              child: ListView.builder(
                                itemCount: _recentTransactionList.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: sWidth,
                                    height: sHeight * 0.1,
                                    margin:
                                        EdgeInsets.only(bottom: textSize / 4),
                                    padding: EdgeInsets.only(
                                        left: textSize, right: textSize),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(textSize / 2),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 8,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  _recentTransactionList[index]
                                                      .inventoryName
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: textSize * 1.25,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.visible,
                                                ),
                                              ),
                                              Flexible(
                                                child: Text(
                                                  _recentTransactionList[index]
                                                      .inventoryFlowType
                                                      .toString(),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.visible,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              _recentTransactionList[index]
                                                  .inventoryMovementQuantity
                                                  .toString(),
                                              style: TextStyle(
                                                fontSize: textSize * 2.5,
                                                fontWeight: FontWeight.w900,
                                                color: _recentTransactionList[
                                                                index]
                                                            .inventoryFlow ==
                                                        "Stock-In"
                                                    ? const Color.fromARGB(
                                                        255, 0, 255, 0)
                                                    : const Color.fromARGB(
                                                        255, 255, 0, 0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : SizedBox(
              width: sWidth,
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

  void loadLowQuantityInventoryList() async {
    await http.post(
        Uri.parse("${MyConfig.server}/ims/php/load_low_quantity_inventory.php"),
        body: {}).then((response) {
      // log(response.body);

      if (response.statusCode == 200) {
        dynamic jsonData = jsonDecode(response.body);
        if (jsonData['status'] == "success") {
          dynamic extractLowQuantityInventories = jsonData['data'];
          extractLowQuantityInventories['inventories']
              .forEach((currentInventory) {
            _lowQuantityInventoryList.add(Inventory.fromJson(currentInventory));
          });
          _isLQLoaded = true;
          if (_isLQLoaded && _isSDLoaded && _isRTLoaded) {
            _isDataAvailable = true;
          }
        } else {}
      } else {}
      setState(() {});
    });
  }

  void loadSalesData() async {
    await http.post(
        Uri.parse("${MyConfig.server}/ims/php/sales/load_sales_data.php"),
        body: {}).then(
      (response) {
        // log(response.body);
        if (response.statusCode == 200) {
          dynamic jsonData = jsonDecode(response.body);
          if (jsonData['status'] == "success") {
            dynamic extractSalesData = jsonData['salesData'];
            extractSalesData['salesData'].forEach((salesData) {
              _salesDataList.add(SalesSummaryData.fromJson(salesData));
            });

            while (_salesDataList.length < 3) {
              _salesDataList.add(SalesSummaryData("--", "0"));
            }
            _isSDLoaded = true;
            if (_isLQLoaded && _isSDLoaded && _isRTLoaded) {
              _isDataAvailable = true;
            }
          } else {}
        }
        setState(() {});
      },
    );
  }

  void loadRecentTransaction() async {
    await http.post(
        Uri.parse("${MyConfig.server}/ims/php/load_recent_transaction.php"),
        body: {}).then(
      (response) {
        // log(response.body);

        if (response.statusCode == 200) {
          dynamic jsonData = jsonDecode(response.body);
          if (jsonData['status'] == "success") {
            dynamic extractRTData = jsonData['data'];
            extractRTData['inventoryMovement'].forEach((recentTransaction) {
              _recentTransactionList
                  .add(RecentTransactionData.fromJson(recentTransaction));
            });

            _isRTLoaded = true;
            if (_isLQLoaded && _isSDLoaded && _isRTLoaded) {
              _isDataAvailable = true;
            }
            // _isDataAvailable = true;
          } else {}
        }
        setState(() {});
      },
    );
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

class RecentTransactionData {
  String? inventoryName;
  String? inventoryFlowType;
  String? inventoryFlow;
  String? inventoryMovementQuantity;

  RecentTransactionData.fromJson(Map<String, dynamic> json) {
    inventoryName = json['inventoryName'];
    inventoryFlowType = json['inventoryFlowType'];
    inventoryFlow = json['inventoryFlow'];
    inventoryMovementQuantity = json["inventoryMovementQuantity"];
  }
}
