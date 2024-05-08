import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ims/configs/myconfig.dart';
import 'package:ims/models/supplier.dart';
import 'package:http/http.dart' as http;
import 'package:ims/screens/employer/supplier/addsupplierscreen.dart';
import 'package:ims/screens/employer/supplier/editsupplierscreen.dart';
import 'package:ims/screens/employer/supplier/supplierdetailscreen.dart';
import 'package:ims/screens/shared/customsearchdelegate.dart';

class SupplierScreen extends StatefulWidget {
  const SupplierScreen({super.key});

  @override
  State<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {
  final scrollController = ScrollController();
  late double sWidth, sHeight, textSize;

  // Pagination
  int _pageNum = 1;
  final int _paginationLimit = 6;

  final List<Supplier> _supplierList = [];
  bool _hasMoreData = true;
  bool _isDataAvailable = false;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(
      () {
        if (scrollController.position.maxScrollExtent ==
                scrollController.offset &&
            _hasMoreData) {
          loadSupplier(_pageNum);
        }
      },
    );
    loadSupplier(1);
  }

  @override
  Widget build(BuildContext context) {
    sWidth = MediaQuery.of(context).size.width;
    sHeight = MediaQuery.of(context).size.height;
    textSize = sWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Supplier",
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
                _supplierList.clear();

                _hasMoreData = false;
                _pageNum = 1;

                await searchSupplier(query);

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
                _supplierList.clear();

                loadSupplier(1);
              },
              child: ListView.builder(
                controller: scrollController,
                itemCount: _supplierList.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index < _supplierList.length) {
                    return InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SupplierDetailScreen(
                              currentSupplier: _supplierList[index],
                            ),
                          ),
                        );
                        _isDataAvailable = false;
                        _supplierList.clear();
                        _pageNum = 1;
                        loadSupplier(1);
                      },
                      onDoubleTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditSupplierScreen(
                              currentSupplier: _supplierList[index],
                            ),
                          ),
                        );
                        _isDataAvailable = false;
                        _supplierList.clear();
                        _pageNum = 1;
                        loadSupplier(1);
                      },
                      onLongPress: () {
                        showDeleteSupplierDialog(_supplierList[index]);
                      },
                      child: Container(
                        width: sWidth,
                        height: sHeight * 0.15,
                        margin: EdgeInsets.fromLTRB(textSize * 0.75,
                            textSize * 0.2, textSize * 0.75, textSize * 0.2),
                        padding: EdgeInsets.all(textSize * 0.25),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: Image.asset(
                                    "assets/images/profileIcon.png")),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: EdgeInsets.all(textSize * 0.5),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _supplierList[index]
                                          .supplierName
                                          .toString(),
                                      style: TextStyle(
                                        fontSize: textSize * 1.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.visible,
                                    ),
                                    Text(
                                      _supplierList[index]
                                          .supplierPhone
                                          .toString(),
                                      style: TextStyle(
                                        fontSize: textSize,
                                        color: Colors.grey,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.visible,
                                    ),
                                    Text(
                                      _supplierList[index]
                                          .supplierEmail
                                          .toString(),
                                      style: TextStyle(
                                        fontSize: textSize,
                                        color: Colors.grey,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: textSize),
                      child: Center(
                        child: _hasMoreData
                            ? const CircularProgressIndicator()
                            : const Divider(),
                      ),
                    );
                  }
                },
              ),
            )
          : SizedBox(
              height: sHeight,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    for (int i = 0; i < 5; ++i)
                      Container(
                        width: sWidth,
                        height: sHeight * 0.15,
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
            ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddSupplierScreen(),
              ),
            );
            _isDataAvailable = false;
            _supplierList.clear();
            loadSupplier(1);
          },
          backgroundColor: Colors.white,
          elevation: 0,
          child: Align(
            child: Text(
              "+",
              style: TextStyle(
                color: Colors.black,
                fontSize: textSize * 2.5,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void loadSupplier(int pageNum) async {
    int returnedSupplierCount = 0;

    http.post(
      Uri.parse("${MyConfig.server}/ims/php/supplier/load_supplier.php"),
      body: {
        "pageNumber": pageNum.toString(),
        "paginationLimit": _paginationLimit.toString()
      },
    ).then(
      (response) {
        if (response.statusCode == 200) {
          log(response.body);
          dynamic jsonData = jsonDecode(response.body);
          if (jsonData['status'] == "success") {
            var extractSuppliers = jsonData['data'];
            extractSuppliers['suppliers'].forEach(
              (supplier) {
                _supplierList.add(Supplier.fromJson(supplier));
              },
            );

            returnedSupplierCount =
                int.parse(jsonData['currentReturnedSupplierCount']);

            if (returnedSupplierCount < _paginationLimit) {
              _hasMoreData = false;
            } else {
              ++_pageNum;
              _hasMoreData = true;
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

  void showDeleteSupplierDialog(Supplier supplier) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Delete ${supplier.supplierName}?",
            style: const TextStyle(overflow: TextOverflow.ellipsis),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  deleteSupplier(supplier);
                  Navigator.pop(context);
                },
                child: const Text('Yes')),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('No')),
          ],
        );
      },
    );
  }

  void deleteSupplier(Supplier supplier) {
    log(supplier.toJson().toString());
    http.post(
        Uri.parse("${MyConfig.server}/ims/php/supplier/delete_supplier.php"),
        body: {
          "supplierID": supplier.supplierId.toString(),
        }).then((response) {
      if (response.statusCode == 200) {
        log(response.body);
        dynamic jsonData = jsonDecode(response.body);
        if (jsonData['status'] == "success") {
          showToastMessage("Delete Supplier Success");

          // Reload the screen
          _isDataAvailable = false;
          _supplierList.clear();
          _pageNum = 1;
          loadSupplier(1);
        } else {
          showToastMessage("Failed To Delete Supplier");
        }
      } else {}
    });
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

  Future<void> searchSupplier(String query) async {
    await http.post(
      Uri.parse("${MyConfig.server}/ims/php/supplier/search_supplier.php"),
      body: {
        "searchKeywords": query,
      },
    ).then(
      (response) {
        if (response.statusCode == 200) {
          log(response.body);
          dynamic jsonData = jsonDecode(response.body);
          if (jsonData['status'] == "success") {
            var extractSuppliers = jsonData['data'];
            extractSuppliers['suppliers'].forEach(
              (supplier) {
                _supplierList.add(Supplier.fromJson(supplier));
              },
            );
            setState(() {});
          } else if (jsonData['status'] == 'no-data') {
            showToastMessage("No record founded");
          } else {
            showToastMessage("HTTP ERROR CODE: ${response.statusCode}");
          }
        }
      },
    );
  }
}
