import 'dart:convert';
import 'dart:developer';

import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ims/configs/myconfig.dart';
import 'package:ims/models/sales.dart';
import 'package:ims/screens/employer/sales/selectdatescreen.dart';
import 'package:ims/screens/shared/customsearchdelegate.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;

class SaleScreen extends StatefulWidget {
  const SaleScreen({super.key});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen>
    with SingleTickerProviderStateMixin {
  DateFormat dateFormat = DateFormat('dd MMM');

  final _fAButtonKey = GlobalKey<ExpandableFabState>();
  final ScrollController _scrollController = ScrollController();
  final ScrollController scrollController = ScrollController();

  late double sWidth, sHeight, textSize;

  // Data
  final int _paginationLimit = 5;
  int _pageNum = 1;
  final List<SalesDate> _graphDataList = [];
  final List<SalesSummaryData> _salesDataList = [];
  final List<Sales> _salesList = [];
  bool _hasMoreData = true, _isDataAvailable = false;
  int _totalSalesQuantity = 0;
  double _totalSalesAmount = 0.0;
  String _bestSalesCategory = "";

  @override
  void initState() {
    super.initState();
    scrollController.addListener(
      () {
        if (scrollController.position.maxScrollExtent ==
                scrollController.offset &&
            _hasMoreData) {
          loadSales(_pageNum);
        }
      },
    );

    loadSalesData();
    loadSales(1);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    sWidth = MediaQuery.of(context).size.width;
    sHeight = MediaQuery.of(context).size.height;
    textSize = sWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Sales",
          style: TextStyle(
              color: Colors.black,
              fontSize: textSize * 1.25,
              fontWeight: FontWeight.w900),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              String? query = await showSearch<String>(
                  context: context, delegate: CustomSearchDelegate());
              if (query != null && query.isNotEmpty) {
                _salesList.clear();

                _hasMoreData = false;
                _pageNum = 1;

                await searchSales(query);
                await searchSalesData(query);

                setState(() {});
              }
            },
            icon: Icon(
              Icons.search,
              color: Colors.black,
              size: textSize * 1.5,
            ),
          ),
        ],
      ),
      body: _isDataAvailable
          ? RefreshIndicator(
              onRefresh: () async {
                _isDataAvailable = false;
                _hasMoreData = true;
                _pageNum = 1;
                _salesList.clear();

                loadSalesData();
                loadSales(1);
              },
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: EdgeInsets.all(textSize),
                      child: Column(
                        children: [
                          Container(
                            width: sWidth,
                            height: sHeight * 0.4,
                            padding: EdgeInsets.all(textSize),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(20)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Sales Overview",
                                  style: TextStyle(
                                      fontSize: textSize * 1.25,
                                      fontWeight: FontWeight.w900),
                                ),
                                SizedBox(
                                  height: textSize / 4,
                                ),
                                Expanded(
                                  child: SfCartesianChart(
                                    margin: EdgeInsets.all(textSize / 2),
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
                                      StackedLineSeries<SalesDate, String>(
                                        color: Colors.red,
                                        dataSource: _graphDataList,
                                        xValueMapper: (SalesDate data, _) =>
                                            dateFormat.format(DateTime.parse(
                                                data.date.toString())),
                                        yValueMapper: (SalesDate data, _) =>
                                            int.parse(data.salesQuantity!),
                                        dataLabelSettings:
                                            const DataLabelSettings(
                                          isVisible: true,
                                        ),
                                        name: "Sales",
                                        markerSettings: const MarkerSettings(
                                          isVisible: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: textSize / 2,
                          ),
                          Container(
                            width: sWidth,
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Overview",
                                  style: TextStyle(
                                      fontSize: textSize * 1.75,
                                      fontWeight: FontWeight.w900),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      fit: FlexFit.tight,
                                      child: Container(
                                        // width: sWidth * 0.4,
                                        height: sHeight * 0.15,
                                        padding: EdgeInsets.all(textSize / 2),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              style: BorderStyle.solid),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                "Total Sales",
                                                style: TextStyle(
                                                    fontSize: textSize * 1.375,
                                                    fontWeight: FontWeight.w900,
                                                    overflow:
                                                        TextOverflow.visible),
                                              ),
                                            ),
                                            SizedBox(
                                              height: textSize * 0.625,
                                            ),
                                            Flexible(
                                              child: Text(
                                                _totalSalesQuantity.toString(),
                                                style: TextStyle(
                                                    fontSize: textSize * 1.875,
                                                    fontWeight: FontWeight.bold,
                                                    overflow:
                                                        TextOverflow.visible),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: textSize / 2,
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        // width: sWidth * 0.45,
                                        height: sHeight * 0.15,
                                        padding: EdgeInsets.all(textSize / 2)
                                            .copyWith(right: 0),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              style: BorderStyle.solid),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                "Total Item Sold",
                                                style: TextStyle(
                                                    fontSize:
                                                        textSize * 1.25, //1.75
                                                    fontWeight: FontWeight.w900,
                                                    overflow:
                                                        TextOverflow.visible),
                                              ),
                                            ),
                                            Flexible(
                                              child: Text(
                                                "RM ${double.parse(_totalSalesAmount.toString()).toStringAsFixed(2)}",
                                                style: TextStyle(
                                                    fontSize: textSize * 1.125,
                                                    fontWeight: FontWeight.w900,
                                                    overflow:
                                                        TextOverflow.visible),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: textSize / 2,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: sHeight * 0.135,
                                        padding: EdgeInsets.all(textSize / 2),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              style: BorderStyle.solid),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                "Best Sales Category",
                                                style: TextStyle(
                                                    fontSize: textSize * 1.375,
                                                    fontWeight: FontWeight.w900,
                                                    overflow:
                                                        TextOverflow.visible),
                                              ),
                                            ),
                                            SizedBox(
                                              height: textSize * 0.625,
                                            ),
                                            Flexible(
                                              child: Text(
                                                _bestSalesCategory,
                                                style: TextStyle(
                                                    fontSize: textSize * 1.25,
                                                    fontWeight: FontWeight.bold,
                                                    overflow:
                                                        TextOverflow.visible),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: textSize,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Sales",
                                style: TextStyle(
                                    fontSize: textSize * 1.75,
                                    fontWeight: FontWeight.w900,
                                    overflow: TextOverflow.visible),
                              ),
                              NotificationListener<ScrollNotification>(
                                onNotification: (notification) {
                                  if (notification is OverscrollNotification) {
                                    if (notification.overscroll < 0 &&
                                        _scrollController.position.pixels ==
                                            0) {
                                      _scrollController.jumpTo(0);
                                      return true;
                                    } else if (notification.overscroll > 0 &&
                                        _scrollController.position.pixels ==
                                            _scrollController
                                                .position.maxScrollExtent) {
                                      _scrollController.jumpTo(_scrollController
                                          .position.maxScrollExtent);
                                      return true;
                                    }
                                  }
                                  return false;
                                },
                                child: ListView.builder(
                                  controller: _scrollController,
                                  shrinkWrap: true,
                                  itemCount: _salesList.length + 1,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    if (index < _salesList.length) {
                                      Sales currentSale = _salesList[index];
                                      return Container(
                                        height: sHeight * 0.125,
                                        decoration: BoxDecoration(
                                            border: Border.all(width: 1),
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        margin: EdgeInsets.only(
                                          top: textSize / 2,
                                        ),
                                        padding: EdgeInsets.fromLTRB(
                                            textSize * 0.9375,
                                            textSize * 0.75,
                                            textSize * 0.9375,
                                            textSize * 0.75),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              flex: 9,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      currentSale
                                                          .saleInventoryName
                                                          .toString(),
                                                      style: TextStyle(
                                                        fontSize:
                                                            textSize * 1.5,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        overflow: TextOverflow
                                                            .visible,
                                                      ),
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                      currentSale
                                                          .salesRegistrationDate
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w300,
                                                          overflow: TextOverflow
                                                              .visible),
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Flexible(
                                              flex: 2,
                                              child: Text(
                                                currentSale.saleQuantity
                                                    .toString(),
                                                style: TextStyle(
                                                  fontSize: textSize * 2.5,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      return Center(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: textSize),
                                          child: _hasMoreData
                                              ? const CircularProgressIndicator()
                                              : _salesList.isEmpty
                                                  ? Text(
                                                      "No Data..",
                                                      style: TextStyle(
                                                          fontSize: textSize),
                                                    )
                                                  : Text(
                                                      "No More Data..",
                                                      style: TextStyle(
                                                          fontSize: textSize),
                                                    ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: <Widget>[
                  for (int i = 0; i < 3; ++i)
                    Container(
                      width: sWidth,
                      height: sHeight * 0.3,
                      margin: EdgeInsets.all(textSize / 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[250],
                        gradient: LinearGradient(colors: [
                          Colors.grey[350]!,
                          Colors.grey[200]!,
                        ]),
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),
                ],
              ),
            ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        openButtonBuilder: RotateFloatingActionButtonBuilder(
          child: const Icon(
            Icons.file_copy_outlined,
            color: Colors.black,
          ),
          fabSize: ExpandableFabSize.regular,
          backgroundColor: Colors.white,
          shape: const CircleBorder(),
          foregroundColor: Colors.transparent,
        ),
        closeButtonBuilder: FloatingActionButtonBuilder(
          size: 56,
          builder: (BuildContext context, void Function()? onPressed,
              Animation<double> progress) {
            return IconButton(
              onPressed: onPressed,
              icon: const Icon(
                Icons.close,
                size: 40,
              ),
            );
          },
        ),
        key: _fAButtonKey,
        overlayStyle: ExpandableFabOverlayStyle(blur: 2),
        children: [
          FloatingActionButton(
            heroTag: null,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const SelectDateScreen(reportMode: "Date"),
                ),
              );
            },
            backgroundColor: Colors.white,
            shape: const CircleBorder(
              side: BorderSide(color: Colors.black),
            ),
            child: const Text(
              "D",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w900),
            ),
          ),
          FloatingActionButton(
            heroTag: null,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const SelectDateScreen(reportMode: "Month"),
                ),
              );
            },
            backgroundColor: Colors.white,
            shape: const CircleBorder(
              side: BorderSide(color: Colors.black),
            ),
            child: const Text(
              "M",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w900),
            ),
          ),
          FloatingActionButton(
            heroTag: null,
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const SelectDateScreen(reportMode: "Range"),
                ),
              );
            },
            backgroundColor: Colors.white,
            shape: const CircleBorder(
              side: BorderSide(color: Colors.black),
            ),
            child: const Text(
              "D2D",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
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

  void loadSales(int pageNum) {
    int returnedSalesCount = 0;

    http.post(Uri.parse("${MyConfig.server}/ims/php/sales/load_sales.php"),
        body: {
          "paginationLimit": _paginationLimit.toString(),
          "pageNumber": pageNum.toString(),
        }).then(
      (response) {
        if (response.statusCode == 200) {
          log(response.body);
          dynamic jsonData = jsonDecode(response.body);
          if (jsonData['status'] == "success") {
            dynamic extractSales = jsonData['sales'];
            extractSales['sales'].forEach(
              (salesRecord) {
                _salesList.add(Sales.fromJson(salesRecord));
              },
            );

            returnedSalesCount =
                int.parse(jsonData['currentReturnedSalesCount']);

            if (returnedSalesCount < _paginationLimit) {
              _hasMoreData = false;
            } else {
              ++_pageNum;
            }
            _isDataAvailable = true;
          } else if (jsonData['status'] == 'no-data') {
            _hasMoreData = false;
            _isDataAvailable = true;
          } else {
            _isDataAvailable = false;
          }
        }
        setState(() {});
      },
    );
  }

  void loadSalesData() {
    _totalSalesQuantity = 0;
    _totalSalesAmount = 0.0;
    _bestSalesCategory = "";
    _salesDataList.clear();
    _graphDataList.clear();

    http.post(Uri.parse("${MyConfig.server}/ims/php/sales/load_sales_data.php"),
        body: {}).then(
      (response) {
        if (response.statusCode == 200) {
          log(response.body);
          dynamic jsonData = jsonDecode(response.body);
          if (jsonData['status'] == "success") {
            dynamic extractGraphData = jsonData['graphData'];
            extractGraphData['graphData'].forEach((graphData) {
              _graphDataList.add(SalesDate.fromJson(graphData));
            });

            dynamic extractSalesData = jsonData['salesData'];
            extractSalesData['salesData'].forEach((salesData) {
              _salesDataList.add(SalesSummaryData.fromJson(salesData));
            });
            _bestSalesCategory = _salesDataList[0].salesCategory!;

            for (SalesSummaryData salesData in _salesDataList) {
              _totalSalesQuantity += int.parse(salesData.totalSalesQuantity!);
              _totalSalesAmount += double.parse(salesData.totalSalesAmount!);
            }
          } else {}
        }
        setState(() {});
      },
    );
  }

  Future<void> searchSales(String query) async {
    await http.post(
        Uri.parse("${MyConfig.server}/ims/php/sales/search_sales.php"),
        body: {
          "searchKeywords": query,
        }).then(
      (response) {
        if (response.statusCode == 200) {
          log(response.body);
          dynamic jsonData = jsonDecode(response.body);
          if (jsonData['status'] == "success") {
            var extractSales = jsonData['sales'];
            extractSales['sales'].forEach(
              (sales) {
                _salesList.add(Sales.fromJson(sales));
              },
            );
          } else {
            showToastMessage("No record founded");
          }
        } else {
          showToastMessage("HTTP ERROR CODE: ${response.statusCode}");
        }
      },
    );
  }

  Future<void> searchSalesData(String query) async {
    _totalSalesQuantity = 0;
    _totalSalesAmount = 0.0;
    _bestSalesCategory = "";
    _salesDataList.clear();
    _graphDataList.clear();

    await http.post(
        Uri.parse("${MyConfig.server}/ims/php/sales/search_sales_data.php"),
        body: {
          "searchKeywords": query,
        }).then(
      (response) {
        if (response.statusCode == 200) {
          log(response.body);
          dynamic jsonData = jsonDecode(response.body);
          if (jsonData['status'] == "success") {
            dynamic extractGraphData = jsonData['graphData'];
            extractGraphData['graphData'].forEach((graphData) {
              _graphDataList.add(SalesDate.fromJson(graphData));
            });

            dynamic extractSalesData = jsonData['salesData'];
            extractSalesData['salesData'].forEach((salesData) {
              _salesDataList.add(SalesSummaryData.fromJson(salesData));
            });
            _bestSalesCategory = _salesDataList[0].salesCategory!;

            for (SalesSummaryData salesData in _salesDataList) {
              _totalSalesQuantity += int.parse(salesData.totalSalesQuantity!);
              _totalSalesAmount += double.parse(salesData.totalSalesAmount!);
            }
          } else {}
        }
        setState(() {});
      },
    );
  }
}

class SalesDate {
  String? salesQuantity;
  String? date;

  SalesDate.fromJson(Map<String, dynamic> json) {
    salesQuantity = json["salesTotalQuantity"];
    date = json['salesRegistrationDate'];
  }
}

class SalesSummaryData {
  String? salesCategory;
  String? totalSalesQuantity;
  String? totalSalesAmount;

  SalesSummaryData.fromJson(Map<String, dynamic> json) {
    salesCategory = json['salesCategory'];
    totalSalesQuantity = json["salesTotalQuantity"];
    totalSalesAmount = json['salesTotalSales'];
  }
}
