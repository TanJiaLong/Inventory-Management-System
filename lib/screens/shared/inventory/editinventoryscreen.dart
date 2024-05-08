import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:ims/configs/myconfig.dart';
import 'package:ims/models/inventory.dart';

class EditInventoryScreen extends StatefulWidget {
  final Inventory currentInventory;
  final String staffID;
  const EditInventoryScreen(
      {super.key, required this.currentInventory, required this.staffID});

  @override
  State<EditInventoryScreen> createState() => _EditInventoryScreenState();
}

class _EditInventoryScreenState extends State<EditInventoryScreen> {
  final _inventoryNameTextEditingController = TextEditingController();
  final _quantityTextEditingController = TextEditingController();
  final _buyingPriceTextEditingController = TextEditingController();
  final _sellingPriceTextEditingController = TextEditingController();
  final _maximumQuantityTextEditingController = TextEditingController();
  late double sWidth, sHeight, textSize;

  late List<String> _categoryList;
  late String _selectedCategory;
  late List<String> _supplierList;
  late String _selectedSupplier;
  final String _firstElement =
      "Please Select                                     ";
  bool _isInit = true;
  bool _isDataAvailable = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _inventoryNameTextEditingController.text =
        widget.currentInventory.inventoryName.toString();
    _quantityTextEditingController.text =
        widget.currentInventory.inventoryQuantity.toString();
    _buyingPriceTextEditingController.text =
        widget.currentInventory.inventoryBuyingPrice.toString();
    _sellingPriceTextEditingController.text =
        widget.currentInventory.inventorySellingPrice.toString();
    _maximumQuantityTextEditingController.text =
        widget.currentInventory.inventoryMaximumQuantity.toString();

    await fetchCategoryList();
    _selectedCategory =
        await widget.currentInventory.inventoryCategory.toString();
    fetchSupplierList();
    _isDataAvailable = true;
  }

  @override
  Widget build(BuildContext context) {
    sWidth = MediaQuery.of(context).size.width;
    sHeight = MediaQuery.of(context).size.height;
    textSize = sWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Inventory Form",
          style: TextStyle(
              color: Colors.black,
              fontSize: textSize * 1.25,
              fontWeight: FontWeight.w900),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isDataAvailable
          ? GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: SizedBox(
                height: sHeight,
                child: Column(
                  children: [
                    Flexible(
                      flex: 3,
                      child: Padding(
                        padding: EdgeInsets.all(textSize / 2),
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            margin: EdgeInsets.all(textSize / 2),
                            width: sWidth * 0.8,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                    "${MyConfig.server}/ims/assets/inventory/${widget.currentInventory.inventoryID}.png"),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Container(
                          height: sHeight * 0.49,
                          width: sWidth,
                          padding: EdgeInsets.all(textSize)
                              .copyWith(bottom: textSize / 4),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Flexible(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Flexible(
                                        flex: 1,
                                        child: Icon(
                                          Icons.category_outlined,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 7,
                                        child: Container(
                                          padding: EdgeInsets.fromLTRB(
                                              textSize * 1.25,
                                              0,
                                              textSize / 2,
                                              0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1, color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: DropdownButton(
                                            isExpanded: true,
                                            alignment: Alignment.centerLeft,
                                            focusColor: Colors.grey,
                                            value: _selectedCategory,
                                            items: _categoryList.map(
                                              (categoryElement) {
                                                return DropdownMenuItem(
                                                  value: categoryElement,
                                                  child: Text(categoryElement),
                                                );
                                              },
                                            ).toList(),
                                            onChanged: (selectedCategory) {
                                              setState(
                                                () {
                                                  _selectedCategory =
                                                      selectedCategory!;
                                                  if (_selectedCategory !=
                                                      _firstElement) {
                                                    fetchSupplierList();
                                                  }
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: textSize,
                                ),
                                Flexible(
                                  child: TextFormField(
                                    controller:
                                        _inventoryNameTextEditingController,
                                    validator: (value) => value == null ||
                                            value.length < 5
                                        ? 'The inventory name must be at least 5 characters'
                                        : null,
                                    keyboardType: TextInputType.name,
                                    decoration: const InputDecoration(
                                      labelText: 'Inventory Name',
                                      icon: Icon(Icons.people_alt_outlined),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8),
                                        ),
                                      ),
                                      focusColor: Colors.black,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: textSize,
                                ),
                                Flexible(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        flex: 5,
                                        child: TextFormField(
                                          controller:
                                              _quantityTextEditingController,
                                          validator: (value) => value!
                                                      .isEmpty ||
                                                  int.parse(value) < 0
                                              ? 'Please enter a correct quantity'
                                              : null,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(
                                                    r'[0-9]')), // Allow only numbers
                                          ],
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                              labelText: 'Current Quantity',
                                              icon: Icon(
                                                Icons.money,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(8),
                                                ),
                                              ),
                                              focusColor: Colors.black),
                                        ),
                                      ),
                                      SizedBox(
                                        width: textSize,
                                      ),
                                      Flexible(
                                        flex: 4,
                                        child: TextFormField(
                                          controller:
                                              _maximumQuantityTextEditingController,
                                          validator: (value) => value!
                                                      .isEmpty ||
                                                  int.parse(value) < 0
                                              ? 'Please enter a correct quantity'
                                              : null,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(
                                                    r'[0-9]')), // Allow only numbers
                                          ],
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                              labelText: 'Maximum Quantity',
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(8),
                                                ),
                                              ),
                                              focusColor: Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: textSize,
                                ),
                                Flexible(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        flex: 5,
                                        child: TextFormField(
                                          controller:
                                              _buyingPriceTextEditingController,
                                          validator: (value) => value!
                                                      .isEmpty ||
                                                  double.parse(value) <= 0
                                              ? 'Please enter a correct buying price'
                                              : null,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(
                                                    r'^\d+\.?\d{0,2}$')), // Allow integers or doubles with up to 2 decimal places
                                          ],
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                              labelText: 'Buying Price (MYR)',
                                              icon: Icon(
                                                Icons.monetization_on_outlined,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(8),
                                                ),
                                              ),
                                              focusColor: Colors.black),
                                        ),
                                      ),
                                      SizedBox(
                                        width: textSize,
                                      ),
                                      Flexible(
                                        flex: 4,
                                        child: TextFormField(
                                          controller:
                                              _sellingPriceTextEditingController,
                                          validator: (value) => value!
                                                      .isEmpty ||
                                                  double.parse(value) <= 0
                                              ? 'Please enter a correct selling price'
                                              : null,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(
                                                    r'^\d+\.?\d{0,2}$')), // Allow integers or doubles with up to 2 decimal places
                                          ],
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: 'Selling Price (MYR)',
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(8),
                                              ),
                                            ),
                                            focusColor: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: textSize,
                                ),
                                Flexible(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Flexible(
                                        flex: 1,
                                        child: Icon(
                                          Icons.people_alt_outlined,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 7,
                                        child: Container(
                                          padding: EdgeInsets.fromLTRB(
                                              textSize * 0.75,
                                              0,
                                              textSize / 2,
                                              0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1, color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: DropdownButton(
                                            isExpanded: true,
                                            alignment: Alignment.centerLeft,
                                            focusColor: Colors.grey,
                                            value: _selectedSupplier,
                                            items: _supplierList.map(
                                              (supplierElement) {
                                                return DropdownMenuItem(
                                                  value: supplierElement,
                                                  child: Text(supplierElement),
                                                );
                                              },
                                            ).toList(),
                                            onChanged: (selectedSupplier) {
                                              setState(
                                                () {
                                                  _selectedSupplier =
                                                      selectedSupplier!;
                                                },
                                              );
                                            },
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
                      ),
                    ),
                    SizedBox(
                      width: sWidth * 0.9,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: const MaterialStatePropertyAll(
                            Colors.black,
                          ),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                10.0,
                              ),
                            ),
                          ),
                        ),
                        onPressed: () {
                          updateInventoryDialog();
                        },
                        child: Text(
                          "Save",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: textSize * 1.25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                    for (int i = 0; i < 1; ++i)
                      Container(
                        width: sWidth,
                        height: sHeight * 0.90,
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

  Future<void> fetchCategoryList() async {
    _categoryList = [_firstElement];
    _selectedCategory = _firstElement;

    http.post(
      Uri.parse("${MyConfig.server}/ims/php/fetchCategory.php"),
      body: {},
    ).then(
      (response) {
        if (response.statusCode == 200) {
          log(response.body);
          var jsonData = jsonDecode(response.body);
          if (jsonData['status'] == 'success') {
            List<String> categoryList = List<String>.from(jsonData['data']);
            if (categoryList.isNotEmpty) {
              _categoryList.addAll(categoryList);
              if (_isInit) {
                _selectedCategory =
                    widget.currentInventory.inventoryCategory.toString();
              } else {
                _selectedCategory = _firstElement;
              }
            }

            setState(() {});
          } else if (jsonData['status'] == 'no-data') {
            showToastMessage("No data in database");
            return;
          }
        } else {
          showToastMessage("HTTP ERROR");
        }
      },
    );
  }

  void fetchSupplierList() {
    _supplierList = [_firstElement];
    _selectedSupplier = _firstElement;
    http.post(
      Uri.parse("${MyConfig.server}/ims/php/fetchSupplier.php"),
      body: {
        "selectedCategory": _selectedCategory,
      },
    ).then(
      (response) {
        if (response.statusCode == 200) {
          log(response.body);
          var jsonData = jsonDecode(response.body);
          if (jsonData['status'] == 'success') {
            List<String> supplierList = List<String>.from(jsonData['data']);

            if (supplierList.isNotEmpty) {
              _supplierList.addAll(supplierList);
              if (_isInit) {
                _selectedSupplier =
                    widget.currentInventory.inventorySupplierName.toString();
              } else {
                _selectedSupplier = _firstElement;
              }
            }

            setState(() {});
          } else if (jsonData['status'] == 'no-data') {
            showToastMessage("No data in database");
            return;
          }
          _isInit = false;
        } else {
          showToastMessage("HTTP ERROR");
        }
      },
    );
  }

  void updateInventoryDialog() {
    if (!_formKey.currentState!.validate()) {
      showToastMessage("Check your input");
      return;
    }
    if (_selectedCategory == _firstElement) {
      showToastMessage("Category is not selected");
      return;
    }
    if (_selectedSupplier == _firstElement) {
      showToastMessage("Supplier is not selected");
      return;
    }
    if (double.parse(_quantityTextEditingController.text) >
        double.parse(_maximumQuantityTextEditingController.text)) {
      showToastMessage("Please insert correct current quantity");
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Update Inventory?"),
          actions: [
            TextButton(
                onPressed: () {
                  updateInventory();
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

  void updateInventory() {
    String inventoryName = _inventoryNameTextEditingController.text;
    String selectedCategory = _selectedCategory.toString();
    String inventoryQuantity = _quantityTextEditingController.text;
    String inventoryMaximumQuantity =
        _maximumQuantityTextEditingController.text;
    String buyingPrice = _buyingPriceTextEditingController.text;
    String sellingPrice = _sellingPriceTextEditingController.text;
    String supplierName = _selectedSupplier.toString();
    String staffID = widget.staffID.toString();

    http.post(
      Uri.parse("${MyConfig.server}/ims/php/inventory/update_inventory.php"),
      body: {
        "inventoryID": widget.currentInventory.inventoryID,
        "inventoryName": inventoryName,
        "inventoryCategory": selectedCategory,
        "inventoryQuantityBefore": widget.currentInventory.inventoryQuantity,
        "inventoryQuantity": inventoryQuantity,
        "inventoryMaximumQuantity": inventoryMaximumQuantity,
        "inventoryBuyingPrice": buyingPrice,
        "inventorySellingPrice": sellingPrice,
        "inventorySupplierName": supplierName,
        "inventoryStaffID": staffID,
      },
    ).then(
      (response) {
        if (response.statusCode == 200) {
          log(response.body);
          var jsonData = jsonDecode(response.body);
          if (jsonData['status'] == 'success') {
            showToastMessage("Inventory Updated Successfully");
            Navigator.pop(context);
          } else {
            showToastMessage('Inventory Updated Failed - Json');
          }
        } else {
          showToastMessage('Inventory Updated Failed - HTTP');
        }
      },
    );
  }
}
