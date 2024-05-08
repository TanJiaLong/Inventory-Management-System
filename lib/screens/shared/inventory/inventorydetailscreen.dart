import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ims/configs/myconfig.dart';
import 'package:ims/models/inventory.dart';
import 'package:ims/models/inventorymovement.dart';
import 'package:ims/screens/shared/inventory/addinventoryhistoryscreen.dart';
import 'package:ims/screens/shared/inventory/editinventoryhistoryscreen.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;

class InventoryDetailScreen extends StatefulWidget {
  final Inventory currentInventory;
  final String userRole;
  final String staffID;
  const InventoryDetailScreen(
      {super.key,
      required this.currentInventory,
      required this.userRole,
      required this.staffID});

  @override
  State<InventoryDetailScreen> createState() => _InventoryDetailScreenState();
}

class _InventoryDetailScreenState extends State<InventoryDetailScreen> {
  final scrollController = ScrollController();
  bool closeTopContainer = false;
  late Inventory currentInventory;

  late double sWidth, sHeight, textSize;

  // Pagination
  int _pageNum = 1;
  final int _paginationLimit = 6;

  final List<InventoryMovement> _imList = [];
  int _numOfIM = 0;
  bool _hasMoreData = true;
  bool _isDataAvailable = false;

  @override
  void initState() {
    super.initState();
    currentInventory = widget.currentInventory;

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
          loadIM(_pageNum);
        }
      },
    );

    loadIM(1);
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
    textSize = sWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.currentInventory.inventoryName.toString(),
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
              showQR();
            },
            icon: const Icon(
              Icons.qr_code_outlined,
            ),
          ),
        ],
      ),
      body: SizedBox(
        width: sWidth,
        height: sHeight,
        child: Column(
          children: [
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  alignment: Alignment.topCenter,
                  margin: closeTopContainer
                      ? const EdgeInsets.all(0)
                      : EdgeInsets.all(textSize / 2).copyWith(right: textSize),
                  height: closeTopContainer ? 0 : sHeight * 0.2,
                  width: sWidth * 0.7,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CachedNetworkImage(
                    imageUrl:
                        '${MyConfig.server}/ims/assets/inventory/${widget.currentInventory.inventoryID}.png',
                    fit: BoxFit.contain,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  height: closeTopContainer ? 0 : textSize * 2.5,
                  alignment: Alignment.topLeft,
                  margin: closeTopContainer
                      ? const EdgeInsets.all(0)
                      : EdgeInsets.fromLTRB(textSize * 0.75, textSize * 0.75, 0,
                          textSize * 0.375),
                  child: Text(
                    "Overview",
                    style: TextStyle(
                        fontSize: textSize * 1.375,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    height: closeTopContainer ? 0 : sHeight * 0.17,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          width: sWidth * 0.47,
                          height: sHeight * 0.17,
                          padding: EdgeInsets.all(textSize * 0.375)
                              .copyWith(right: textSize * 0.875),
                          margin: closeTopContainer
                              ? const EdgeInsets.all(0)
                              : EdgeInsets.symmetric(
                                  horizontal: textSize * 0.375),
                          decoration: BoxDecoration(
                            border: Border.all(style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  "Current Quantity",
                                  style: TextStyle(
                                    fontSize: textSize * 1.375,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                              Flexible(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text.rich(
                                    TextSpan(
                                      text: currentInventory.inventoryQuantity
                                          .toString(),
                                      style: TextStyle(
                                          fontSize: textSize * 3,
                                          fontWeight: FontWeight.bold,
                                          overflow: TextOverflow.visible),
                                      children: const <TextSpan>[],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          width: sWidth * 0.5,
                          height: sHeight * 0.17,
                          padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
                          margin: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                          decoration: BoxDecoration(
                            border: Border.all(style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  "Maximum Quantity",
                                  style: TextStyle(
                                      fontSize: textSize * 1.375,
                                      fontWeight: FontWeight.w900,
                                      overflow: TextOverflow.visible),
                                ),
                              ),
                              Flexible(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text.rich(
                                    TextSpan(
                                      text: currentInventory
                                          .inventoryMaximumQuantity
                                          .toString(),
                                      style: TextStyle(
                                          fontSize: textSize * 3,
                                          fontWeight: FontWeight.bold,
                                          overflow: TextOverflow.visible),
                                      children: const <TextSpan>[],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.userRole != "Employee")
                          Container(
                            alignment: Alignment.topLeft,
                            width: sWidth * 0.5,
                            height: sHeight * 0.17,
                            padding: EdgeInsets.all(textSize * 0.375),
                            margin: EdgeInsets.symmetric(
                                horizontal: textSize * 0.375),
                            decoration: BoxDecoration(
                              border: Border.all(style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Text(
                                    "Buying Price",
                                    style: TextStyle(
                                        fontSize: textSize * 1.375,
                                        fontWeight: FontWeight.w900,
                                        overflow: TextOverflow.visible),
                                  ),
                                ),
                                Flexible(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text.rich(
                                      TextSpan(
                                        text: " RM",
                                        style: TextStyle(
                                            fontSize: textSize * 1.5,
                                            fontWeight: FontWeight.bold,
                                            overflow: TextOverflow.visible),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text:
                                                " ${currentInventory.inventoryBuyingPrice}",
                                            style: TextStyle(
                                                fontSize: textSize * 1.3,
                                                fontWeight: FontWeight.bold,
                                                overflow: TextOverflow.visible),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (widget.userRole != "Employee")
                          Container(
                            alignment: Alignment.topLeft,
                            width: sWidth * 0.5,
                            height: sHeight * 0.17,
                            padding: EdgeInsets.all(textSize * 0.375),
                            margin: EdgeInsets.symmetric(
                                horizontal: textSize * 0.375),
                            decoration: BoxDecoration(
                              border: Border.all(style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Text(
                                    "Selling Price",
                                    style: TextStyle(
                                        fontSize: textSize * 1.375,
                                        fontWeight: FontWeight.w900,
                                        overflow: TextOverflow.visible),
                                  ),
                                ),
                                Flexible(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text.rich(
                                      TextSpan(
                                        text: " RM",
                                        style: TextStyle(
                                            fontSize: textSize * 1.5,
                                            fontWeight: FontWeight.bold,
                                            overflow: TextOverflow.visible),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text:
                                                " ${currentInventory.inventorySellingPrice}",
                                            style: TextStyle(
                                                fontSize: textSize * 1.3,
                                                fontWeight: FontWeight.bold,
                                                overflow: TextOverflow.visible),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Container(
                          alignment: Alignment.topLeft,
                          width: sWidth * 0.5,
                          height: sHeight * 0.17,
                          padding: EdgeInsets.all(textSize * 0.375),
                          margin: EdgeInsets.symmetric(
                              horizontal: textSize * 0.375),
                          decoration: BoxDecoration(
                            border: Border.all(style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  "Category",
                                  style: TextStyle(
                                      fontSize: textSize * 1.625,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.visible),
                                ),
                              ),
                              Flexible(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "  ${currentInventory.inventoryCategory}",
                                    style: TextStyle(
                                        fontSize: textSize * 1.3,
                                        fontWeight: FontWeight.bold,
                                        overflow: TextOverflow.visible),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          width: sWidth * 0.5,
                          height: sHeight * 0.17,
                          padding: EdgeInsets.all(textSize * 0.375),
                          margin: EdgeInsets.symmetric(
                              horizontal: textSize * 0.375),
                          decoration: BoxDecoration(
                            border: Border.all(style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  "Supplier",
                                  style: TextStyle(
                                    fontSize: textSize * 1.625,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "  ${currentInventory.inventorySupplierName}",
                                    style: TextStyle(
                                      fontSize: textSize * 1.3,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
            Container(
              margin: EdgeInsets.only(left: textSize * 0.75),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 8,
                    child: Text(
                      "Inventory Movement History",
                      style: TextStyle(
                          fontSize: textSize * 1.375,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: IconButton(
                      onPressed: () async {
                        String? updatedQuantity = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddInventoryMovementHistoryScreen(
                              currentInventory: widget.currentInventory,
                              staffID: widget.staffID,
                            ),
                          ),
                        );
                        if (updatedQuantity == null) {
                          return;
                        }
                        setState(
                          () {
                            currentInventory.inventoryQuantity =
                                updatedQuantity;
                          },
                        );

                        _scrollToTop();
                        _imList.clear();
                        _pageNum = 1;
                        loadIM(_pageNum);
                      },
                      icon: const Icon(
                        Icons.add,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _isDataAvailable
                ? Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: _imList.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index < _imList.length) {
                          final currentIM = _imList[index];
                          return InkWell(
                            onDoubleTap: () async {
                              if (currentIM.imInventoryFlowType ==
                                      "Staff Modify" ||
                                  widget.userRole == "Employee") {
                                return;
                              }
                              String? newQuantity = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditInventoryMovementScreen(
                                    currentInventory: widget.currentInventory,
                                    im: currentIM,
                                    staffID: widget.staffID,
                                  ),
                                ),
                              );
                              if (newQuantity == null) {
                                return;
                              }
                              if (newQuantity !=
                                  currentInventory.inventoryQuantity) {
                                currentInventory.inventoryQuantity =
                                    newQuantity;
                              }

                              _isDataAvailable = false;
                              _imList.clear();
                              _pageNum = 1;
                              loadIM(1);
                            },
                            onLongPress: () {
                              if (currentIM.imInventoryFlowType ==
                                      "Staff Modify" ||
                                  widget.userRole == "Employee") {
                                return;
                              }
                              showDeleteDialog(currentIM);
                            },
                            child: Container(
                              height: sHeight * 0.125,
                              margin: EdgeInsets.all(textSize * 0.75)
                                  .copyWith(top: 0),
                              padding: EdgeInsets.all(textSize * 0.75),
                              decoration: BoxDecoration(
                                border: Border.all(width: 1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 7,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            currentIM.imInventoryFlowType
                                                .toString(),
                                            style: TextStyle(
                                              fontSize: textSize * 1.125,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.visible,
                                          ),
                                        ),
                                        Flexible(
                                          child: Text(
                                            currentIM.imRegistrationDate
                                                .toString(),
                                            style: TextStyle(
                                              fontSize: textSize,
                                              fontWeight: FontWeight.w300,
                                            ),
                                            overflow: TextOverflow.visible,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        currentIM.imInventoryMovementQuantity
                                            .toString(),
                                        style: TextStyle(
                                          fontSize: textSize * 2.5,
                                          fontWeight: FontWeight.w900,
                                          color: currentIM.imInventoryFlow
                                                      .toString() ==
                                                  "Stock-In"
                                              ? const Color.fromARGB(
                                                  255, 0, 255, 0)
                                              : const Color.fromARGB(
                                                  255, 255, 0, 0),
                                        ),
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: textSize),
                              child: _hasMoreData
                                  ? const CircularProgressIndicator()
                                  : _imList.isEmpty
                                      ? Text(
                                          "No Data..",
                                          style: TextStyle(fontSize: textSize),
                                        )
                                      : Text(
                                          "No More Data..",
                                          style: TextStyle(fontSize: textSize),
                                        ),
                            ),
                          );
                        }
                      },
                    ),
                  )
                : Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: <Widget>[
                          for (int i = 0; i < 6; ++i)
                            GestureDetector(
                              onTap: () {
                                _imList.clear();
                                _pageNum = 1;
                                loadIM(1);
                                _isDataAvailable = true;
                              },
                              child: Container(
                                width: sWidth,
                                height: sHeight * 0.1,
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

  void loadIM(int pageNum) async {
    int returnedIMCount = 0;

    http.post(
      Uri.parse(
          "${MyConfig.server}/ims/php/inventorymovement/load_inventory_movement.php"),
      body: {
        "imInventoryID": widget.currentInventory.inventoryID,
        "pageNumber": pageNum.toString(),
        "paginationLimit": _paginationLimit.toString()
      },
    ).then(
      (response) {
        if (response.statusCode == 200) {
          // log(response.body);
          dynamic jsonData = jsonDecode(response.body);
          if (jsonData['status'] == "success") {
            var extractIM = jsonData['data'];
            extractIM['inventoryMovement'].forEach(
              (inventoryMovement) {
                _imList.add(InventoryMovement.fromJson(inventoryMovement));
              },
            );

            returnedIMCount = int.parse(jsonData['currentReturnedIMCount']);

            if (returnedIMCount < _paginationLimit) {
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

  void _scrollToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void showDeleteDialog(InventoryMovement currentIM) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Delete Inventory with ID ${currentIM.imInventoryID!}?",
              style: const TextStyle(overflow: TextOverflow.visible),
              maxLines: 2,
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    deleteIM(currentIM);
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

  void deleteIM(InventoryMovement im) {
    http.post(
        Uri.parse(
            "${MyConfig.server}/ims/php/inventorymovement/delete_inventory_movement.php"),
        body: {
          "imID": im.imId.toString(),
          "imInventoryID": im.imInventoryID.toString(),
          "imFlow": im.imInventoryFlow.toString(),
          "imMovementQuantity": im.imInventoryMovementQuantity.toString(),
        }).then((response) {
      if (response.statusCode == 200) {
        log(response.body);
        dynamic jsonData = jsonDecode(response.body);
        if (jsonData['status'] == "success") {
          showToastMessage("Delete IM Success");
          if (im.imInventoryFlow == "Stock-In") {
            currentInventory.inventoryQuantity =
                (int.parse(currentInventory.inventoryQuantity!) -
                        int.parse(im.imInventoryMovementQuantity!))
                    .toString();
          } else {
            currentInventory.inventoryQuantity =
                (int.parse(currentInventory.inventoryQuantity!) +
                        int.parse(im.imInventoryMovementQuantity!))
                    .toString();
          }
          // Reload the screen
          _isDataAvailable = false;
          _imList.clear();
          _pageNum = 1;
          loadIM(1);
        } else {
          showToastMessage("Failed To Delete IM");
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

  void showQR() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("QR of ${widget.currentInventory.inventoryName}"),
            content: buildQR(),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Capture QR",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Done",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        });
  }

  Widget buildQR() {
    return Container(
      width: sWidth * 0.3,
      height: sHeight * 0.3,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          width: 3,
        ),
        borderRadius: BorderRadius.circular(
          10,
        ),
      ),
      child: QrImageView(
        data: widget.currentInventory.inventoryID.toString(),
        version: QrVersions.auto,
        size: sHeight * 0.25,
      ),
    );
  }
}
