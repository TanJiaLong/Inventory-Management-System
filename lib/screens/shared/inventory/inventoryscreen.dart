import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:ims/configs/myconfig.dart';
import 'package:ims/models/inventory.dart';
import 'package:ims/models/user.dart';
import 'package:ims/screens/shared/customsearchdelegate.dart';
import 'package:ims/screens/shared/inventory/addinventoryscreen.dart';
import 'package:ims/screens/shared/inventory/editinventoryscreen.dart';
import 'package:ims/screens/shared/inventory/inventorydetailscreen.dart';
import 'package:ims/screens/shared/scanqrscreen.dart';

class InventoryScreen extends StatefulWidget {
  final User user;
  const InventoryScreen({super.key, required this.user});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final scrollController = ScrollController();
  final _addCategoryTEC = TextEditingController();
  final _updateCategoryTEC = TextEditingController();

  bool closeTopContainer = false;

  late double sWidth, sHeight, textSize;

  // Pagination
  int _pageNum = 1;
  final int _paginationLimit = 6;

  List<Inventory> inventoryList = [];
  List<String> categoryList = [];
  int _numOfInventory = 0;
  double _inventoryTotalAmount = 0;
  int _numOfLowQuantityItems = 0;
  bool _hasMoreData = true;
  bool _isDataAvailable = false;

  @override
  void initState() {
    super.initState();

    scrollController.addListener(
      () {
        setState(
          () {
            closeTopContainer = scrollController.offset >= 50;
          },
        );

        if (scrollController.position.maxScrollExtent ==
                scrollController.offset &&
            _hasMoreData) {
          loadInventory(_pageNum);
        }
      },
    );
    loadInventory(1);
    loadInventoryData();
    loadCategory();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    sWidth = MediaQuery.of(context).size.width;
    sHeight = MediaQuery.of(context).size.height;
    final double topContainerHeight = sHeight * 0.300;
    textSize = sWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Inventory",
          style: TextStyle(
              color: Colors.black,
              fontSize: textSize * 1.25,
              fontWeight: FontWeight.w900),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          if (widget.user.userRole != "Employee")
            IconButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScanQRScreen(user: widget.user),
                  ),
                );

                // Reload the screen
                _isDataAvailable = false;
                inventoryList.clear();
                _pageNum = 1;
                loadInventory(1);
                loadInventoryData();
              },
              icon: Icon(
                Icons.qr_code_scanner_outlined,
                color: Colors.black,
                size: textSize * 1.5,
              ),
            ),
          IconButton(
            onPressed: () async {
              String? query = await showSearch<String>(
                  context: context, delegate: CustomSearchDelegate());
              if (query != null && query.isNotEmpty) {
                _scrollToTop();
                inventoryList.clear();
                _hasMoreData = false;
                _isDataAvailable = false;
                _pageNum = 1;

                await searchInventoryData(query);
                await searchInventory(query);

                _isDataAvailable = true;
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
                inventoryList.clear();
                loadInventoryData();
                loadInventory(1);
              },
              child: Container(
                width: sWidth,
                height: sHeight,
                padding: EdgeInsets.all(textSize * 0.75),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.user.userRole == "Employer" ||
                        widget.user.userRole == "Inventory Manager")
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: closeTopContainer ? 0 : topContainerHeight,
                        alignment: Alignment.topCenter,
                        color: Colors.white,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Column(
                            children: [
                              FittedBox(
                                fit: BoxFit.contain,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: sWidth * 0.45,
                                          height: sHeight * 0.145,
                                          padding: EdgeInsets.all(textSize / 2),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                style: BorderStyle.solid),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  "Item Quantity",
                                                  style: TextStyle(
                                                      fontSize:
                                                          textSize * 1.375,
                                                      fontWeight:
                                                          FontWeight.w900),
                                                  overflow:
                                                      TextOverflow.visible,
                                                ),
                                              ),
                                              SizedBox(
                                                height: textSize * 0.625,
                                              ),
                                              Flexible(
                                                child: Text(
                                                  _numOfInventory.toString(),
                                                  style: TextStyle(
                                                      fontSize:
                                                          textSize * 2.375,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  overflow:
                                                      TextOverflow.visible,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: textSize / 2,
                                        ),
                                        Container(
                                          width: sWidth * 0.45,
                                          height: sHeight * 0.145,
                                          padding: EdgeInsets.all(textSize / 2),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                style: BorderStyle.solid),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  "Item Value",
                                                  style: TextStyle(
                                                      fontSize:
                                                          textSize * 1.375,
                                                      fontWeight:
                                                          FontWeight.w900),
                                                  overflow:
                                                      TextOverflow.visible,
                                                ),
                                              ),
                                              SizedBox(
                                                height: textSize,
                                              ),
                                              Flexible(
                                                child: Text(
                                                  "RM ${double.parse(_inventoryTotalAmount.toString()).toStringAsFixed(2)}",
                                                  style: TextStyle(
                                                      fontSize:
                                                          textSize * 1.375,
                                                      fontWeight:
                                                          FontWeight.w900),
                                                  overflow:
                                                      TextOverflow.visible,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: textSize / 2,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: sWidth * 0.45,
                                          height: sHeight * 0.145,
                                          padding: EdgeInsets.all(textSize / 2),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                style: BorderStyle.solid),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  "Low-Stock Item",
                                                  style: TextStyle(
                                                      fontSize:
                                                          textSize * 1.375,
                                                      fontWeight:
                                                          FontWeight.w900),
                                                  overflow:
                                                      TextOverflow.visible,
                                                ),
                                              ),
                                              SizedBox(
                                                height: textSize * 0.625,
                                              ),
                                              Flexible(
                                                child: Text(
                                                  _numOfLowQuantityItems
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize:
                                                          textSize * 2.375,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  overflow:
                                                      TextOverflow.visible,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: textSize / 2,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            showCategoryDialog();
                                          },
                                          child: Container(
                                            width: sWidth * 0.45,
                                            height: sHeight * 0.145,
                                            padding:
                                                EdgeInsets.all(textSize / 2),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  style: BorderStyle.solid),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    "Total Category",
                                                    style: TextStyle(
                                                        fontSize:
                                                            textSize * 1.375,
                                                        fontWeight:
                                                            FontWeight.w900),
                                                    overflow:
                                                        TextOverflow.visible,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: textSize * 0.625,
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    categoryList.length
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize:
                                                            textSize * 2.375,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    overflow:
                                                        TextOverflow.visible,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: textSize / 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: inventoryList.length + 1,
                        itemBuilder: (BuildContext context, int index) {
                          if (index < inventoryList.length) {
                            final currentInventory = inventoryList[index];
                            return InkWell(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => InventoryDetailScreen(
                                      currentInventory: currentInventory,
                                      userRole: widget.user.userRole.toString(),
                                      staffID: widget.user.staffID.toString(),
                                    ),
                                  ),
                                );
                                // Reload the screen
                                _isDataAvailable = false;
                                inventoryList.clear();
                                _pageNum = 1;
                                loadInventory(1);
                                loadInventoryData();
                              },
                              onDoubleTap: () async {
                                if (widget.user.userRole != "Employee") {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditInventoryScreen(
                                        currentInventory: currentInventory,
                                        staffID: widget.user.staffID.toString(),
                                      ),
                                    ),
                                  );
                                  // Reload the screen
                                  _isDataAvailable = false;
                                  inventoryList.clear();
                                  _pageNum = 1;
                                  loadInventory(1);
                                  loadInventoryData();
                                }
                              },
                              onLongPress: () {
                                if (widget.user.userRole != "Employee") {
                                  showDeleteDialog(currentInventory);
                                }
                              },
                              child: Container(
                                height: sHeight * 0.15,
                                margin: EdgeInsets.all(textSize / 4),
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: Container(
                                        margin: EdgeInsets.all(textSize / 2)
                                            .copyWith(right: textSize),
                                        height: sHeight * 0.15,
                                        width: sHeight * 0.15,
                                        // decoration: BoxDecoration(
                                        //   border: Border.all(
                                        //       color: Colors.black, width: 1),
                                        //   borderRadius: BorderRadius.circular(10),
                                        // ),
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              '${MyConfig.server}/ims/assets/inventory/${currentInventory.inventoryID}.png',
                                          fit: BoxFit.contain,
                                          placeholder: (context, url) =>
                                              const CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: textSize,
                                          ),
                                          Text(
                                            currentInventory.inventoryName
                                                .toString(),
                                            style: TextStyle(
                                              fontSize: textSize * 1.125,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.visible,
                                          ),
                                          SizedBox(
                                            height: textSize * 0.375,
                                          ),
                                          Text(
                                            currentInventory.inventoryCategory
                                                .toString(),
                                            style: TextStyle(
                                                fontSize: textSize,
                                                fontWeight: FontWeight.w300),
                                            maxLines: 2,
                                            overflow: TextOverflow.visible,
                                          ),
                                        ],
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
                    ),
                  ],
                ),
              ),
            )
          : SizedBox(
              width: sWidth,
              height: sHeight,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    for (int i = 0; i < 5; ++i)
                      Container(
                        width: sWidth,
                        height: sHeight * 0.15,
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[250],
                          gradient: LinearGradient(colors: [
                            Colors.grey[350]!,
                            Colors.grey[200]!,
                          ]),
                          borderRadius: BorderRadius.circular(10),
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
                builder: (context) => AddInventoryScreen(
                  staffID: widget.user.staffID.toString(),
                ),
              ),
            );
            _scrollToTop();
            inventoryList.clear();
            _pageNum = 1;
            loadInventory(1);
            loadInventoryData();
          },
          backgroundColor: Colors.white,
          elevation: 0,
          child: Text(
            "+",
            style: TextStyle(
                color: Colors.black,
                fontSize: textSize * 2,
                fontWeight: FontWeight.w300),
          ),
        ),
      ),
    );
  }

  Future<void> searchInventory(String query) async {
    await http.post(
        Uri.parse("${MyConfig.server}/ims/php/inventory/search_inventory.php"),
        body: {
          "searchKeywords": query,
        }).then(
      (response) {
        if (response.statusCode == 200) {
          log(response.body);
          dynamic jsonData = jsonDecode(response.body);
          if (jsonData['status'] == "success") {
            var extractInventories = jsonData['data'];
            extractInventories['inventories'].forEach(
              (inventory) {
                inventoryList.add(Inventory.fromJson(inventory));
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

  Future<void> searchInventoryData(String query) async {
    await http.post(
      Uri.parse(
          "${MyConfig.server}/ims/php/inventory/search_inventory_data.php"),
      body: {
        "searchKeywords": query,
      },
    ).then(
      (response) {
        log(response.body);
        if (response.statusCode == 200) {
          dynamic jsonData = jsonDecode(response.body);
          if (jsonData['status'] == "success") {
            _numOfInventory = int.parse(jsonData['numOfInventory']);
            _inventoryTotalAmount =
                double.parse(jsonData['inventoryTotalAmount']);

            _numOfLowQuantityItems =
                int.parse(jsonData['numOfLowQuantityItems']);
          } else {
            showToastMessage("Error when loading inventory data");
          }
        } else {
          showToastMessage("HTTP Error when loading inventory data");
        }
        setState(() {});
      },
    );
  }

  void loadInventoryData() async {
    await http.post(
      Uri.parse("${MyConfig.server}/ims/php/inventory/load_inventory_data.php"),
      body: {},
    ).then(
      (response) {
        if (response.statusCode == 200) {
          dynamic jsonData = jsonDecode(response.body);
          if (jsonData['status'] == "success") {
            _numOfInventory = int.parse(jsonData['numOfInventory']);
            _inventoryTotalAmount =
                double.parse(jsonData['inventoryTotalAmount']);

            _numOfLowQuantityItems =
                int.parse(jsonData['numOfLowQuantityItems']);
          } else {
            showToastMessage("Error when loading inventory data");
          }
        } else {
          showToastMessage("HTTP Error when loading inventory data");
        }
        setState(() {});
      },
    );
  }

  void loadInventory(int pageNumber) async {
    int returnedInventoryCount = 0;

    http.post(
      Uri.parse("${MyConfig.server}/ims/php/inventory/load_inventory.php"),
      body: {
        "pageNumber": pageNumber.toString(),
        "paginationLimit": _paginationLimit.toString()
      },
    ).then(
      (response) {
        if (response.statusCode == 200) {
          log(response.body);
          dynamic jsonData = jsonDecode(response.body);
          if (jsonData['status'] == "success") {
            dynamic extractInventories = jsonData['data'];
            extractInventories['inventories'].forEach(
              (inventory) {
                inventoryList.add(Inventory.fromJson(inventory));
              },
            );

            returnedInventoryCount =
                int.parse(jsonData['currentReturnedInventoryCount']);
            if (returnedInventoryCount < _paginationLimit) {
              _hasMoreData = false;
            } else {
              ++_pageNum;
              _hasMoreData = true;
            }
            _isDataAvailable = true;
          } else if (jsonData['status'] == 'no-data') {
            _hasMoreData = false;
          } else {
            _isDataAvailable = false;
          }
        }
        setState(() {});
      },
    );
  }

  void _scrollToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void showDeleteDialog(Inventory currentInventory) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Delete ${currentInventory.inventoryName!}",
              style: const TextStyle(overflow: TextOverflow.ellipsis),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    deleteInventory(currentInventory);
                  },
                  child: const Text("Yes")),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("No"))
            ],
          );
        });
  }

  void deleteInventory(Inventory currentInventory) {
    http.post(
        Uri.parse("${MyConfig.server}/ims/php/inventory/delete_inventory.php"),
        body: {
          "inventoryID": currentInventory.inventoryID.toString(),
        }).then((response) {
      if (response.statusCode == 200) {
        dynamic jsonData = jsonDecode(response.body);
        if (jsonData['status'] == "success") {
          showToastMessage("Delete Inventory Success");
          // Reload the screen
          _isDataAvailable = false;
          inventoryList.clear();
          loadInventory(1);
          loadInventoryData();
        } else {
          showToastMessage("Failed To Delete Inventory");
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

  void showCategoryDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(
                textSize / 2, 0, textSize / 2, textSize / 2),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(flex: 8, child: Text("Category List")),
                Expanded(
                  child: IconButton(
                    onPressed: () {
                      showAddCategoryDialog();
                    },
                    icon: const Icon(
                      Icons.add,
                    ),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              height: sHeight * 0.4,
              width: sWidth * 0.9,
              // color: Colors.red,
              child: ListView.builder(
                itemCount: categoryList.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: sWidth * 0.9,
                    height: sHeight * 0.1,
                    padding: EdgeInsets.only(left: textSize),
                    margin: EdgeInsets.all(textSize / 4),
                    decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(textSize / 4)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 7,
                          child: Text(
                            categoryList[index],
                            style: TextStyle(fontSize: textSize / 1.5),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: IconButton(
                            onPressed: () {
                              showUpdateCategoryDialog(
                                  categoryList[index], index);
                            },
                            icon: const Icon(Icons.edit),
                            color: Colors.black,
                            iconSize: textSize * 1.25,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        });
  }

  Future<void> loadCategory() async {
    await http.post(
        Uri.parse(
          "${MyConfig.server}/ims/php/fetchCategory.php",
        ),
        body: {}).then((response) {
      if (response.statusCode == 200) {
        dynamic jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 'success') {
          categoryList.clear();
          dynamic extractCategories = jsonData['data'];
          extractCategories.forEach(
            (element) {
              categoryList.add(element);
            },
          );
          setState(() {});
        } else {
          showToastMessage("Category not found");
        }
      } else {
        showToastMessage("HTTP ERROR when loading category");
      }
    });
  }

  void showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("New Category"),
          content: TextField(
            controller: _addCategoryTEC,
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(
              label: Text("Category Name"),
              border: UnderlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  if (_addCategoryTEC.text.isNotEmpty) {
                    insertCategory();
                  } else {
                    showToastMessage("Text field is empty");
                  }
                },
                child: const Text("Submit"))
          ],
        );
      },
    );
  }

  void insertCategory() async {
    String categoryName = _addCategoryTEC.text;

    await http.post(
        Uri.parse(
          "${MyConfig.server}/ims/php/category/insert_category.php",
        ),
        body: {
          "categoryName": categoryName,
        }).then((response) {
      log(response.body);
      if (response.statusCode == 200) {
        dynamic jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 'success') {
          showToastMessage("Add Category Success");
          categoryList.add(categoryName);

          Navigator.pop(context);
          setState(() {});
        } else {
          showToastMessage("Add Category Failed");
        }
      }
    });
  }

  void showUpdateCategoryDialog(String category, int index) {
    showDialog(
      context: context,
      builder: (context) {
        _updateCategoryTEC.text = category;

        return AlertDialog(
          title: const Text("Update Category"),
          content: TextField(
            controller: _updateCategoryTEC,
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(
              label: Text("Category Name"),
              border: UnderlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  if (_updateCategoryTEC.text.isNotEmpty) {
                    updateCategory(category, index);
                  } else {
                    showToastMessage("Text field is empty");
                  }
                },
                child: const Text("Submit"))
          ],
        );
      },
    );
  }

  void updateCategory(String oriCategoryName, int index) async {
    String updatedCategoryName = _updateCategoryTEC.text;

    await http.post(
        Uri.parse(
          "${MyConfig.server}/ims/php/category/update_category.php",
        ),
        body: {
          "oriCategoryName": oriCategoryName,
          "updatefCategoryName": updatedCategoryName,
        }).then((response) {
      log(response.body);
      if (response.statusCode == 200) {
        dynamic jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 'success') {
          showToastMessage("Update Category Success");
          categoryList[index] = updatedCategoryName;

          Navigator.pop(context);
          setState(() {});
        } else {
          showToastMessage("Add Category Failed");
        }
      }
    });
  }
}
