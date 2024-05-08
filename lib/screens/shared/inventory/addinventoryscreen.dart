import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:ims/configs/myconfig.dart';

class AddInventoryScreen extends StatefulWidget {
  final String staffID;
  const AddInventoryScreen({super.key, required this.staffID});

  @override
  State<AddInventoryScreen> createState() => _AddInventoryScreenState();
}

class _AddInventoryScreenState extends State<AddInventoryScreen> {
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

  final _formKey = GlobalKey<FormState>();
  File? _image;
  String assetPath = 'assets/images/camera.png';

  @override
  void initState() {
    super.initState();
    fetchCategoryList();
  }

  @override
  Widget build(BuildContext context) {
    sWidth = MediaQuery.of(context).size.width;
    sHeight = MediaQuery.of(context).size.height;
    textSize = sWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Inventory Form",
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
              // addCategory();
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SizedBox(
          height: sHeight,
          child: Column(
            children: [
              Flexible(
                flex: 3,
                child: GestureDetector(
                  onTap: () {
                    _selectImageFromGallery();
                  },
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
                            image: _image == null
                                ? AssetImage(assetPath)
                                : FileImage(_image!) as ImageProvider,
                            fit: BoxFit.contain,
                          ),
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
                    padding:
                        EdgeInsets.all(textSize).copyWith(bottom: textSize / 4),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Flexible(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        textSize * 0.75, 0, textSize / 2, 0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
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
                                            child: Text(
                                              categoryElement,
                                              overflow: TextOverflow.visible,
                                            ),
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
                              controller: _inventoryNameTextEditingController,
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
                                    controller: _quantityTextEditingController,
                                    validator: (value) =>
                                        value!.isEmpty || int.parse(value) < 0
                                            ? 'Please enter a correct quantity'
                                            : null,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(
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
                                    validator: (value) =>
                                        value!.isEmpty || int.parse(value) < 0
                                            ? 'Please enter a correct quantity'
                                            : null,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(
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
                                    validator: (value) => value!.isEmpty ||
                                            double.parse(value) <= 0
                                        ? 'Please enter a correct buying price'
                                        : null,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(
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
                                    validator: (value) => value!.isEmpty ||
                                            double.parse(value) <= 0
                                        ? 'Please enter a correct selling price'
                                        : null,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        textSize * 0.75, 0, textSize / 2, 0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
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
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10.0,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    insertInventoryDialog();
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

  void _selectImageFromGallery() async {
    final ImagePicker imagePicker = ImagePicker();
    final selectedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (selectedImage != null) {
      setState(
        () {
          _image = File(selectedImage.path);
        },
      );
    }
  }

  void fetchCategoryList() async {
    _categoryList = [_firstElement];
    _selectedCategory = _firstElement;

    _supplierList = [_firstElement];
    _selectedSupplier = _firstElement;

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
              _selectedCategory = _categoryList[0];
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

  void fetchSupplierList() async {
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
              _selectedSupplier = _supplierList[0];
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

  void insertInventoryDialog() {
    if (!_formKey.currentState!.validate()) {
      showToastMessage("Check your input");
      return;
    }
    if (_selectedCategory == "Please Select        ") {
      showToastMessage("Category is not selected");
      return;
    }
    if (_selectedSupplier == "Please Select                    ") {
      showToastMessage("Supplier is not selected");
      return;
    }
    if (_image == null) {
      showToastMessage("Please insert the required pictures");
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Inventory?"),
          actions: [
            TextButton(
                onPressed: () {
                  insertNewInventory();
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

  void insertNewInventory() {
    String inventoryName = _inventoryNameTextEditingController.text;
    String selectedCategory = _selectedCategory.toString();
    String inventoryQuantity = _quantityTextEditingController.text;
    String inventoryMaximumQuantity =
        _maximumQuantityTextEditingController.text;
    String buyingPrice = _buyingPriceTextEditingController.text;
    String sellingPrice = _sellingPriceTextEditingController.text;
    String supplierName = _selectedSupplier.toString();
    String staffID = widget.staffID.toString();
    String base64Image = base64Encode(_image!.readAsBytesSync());

    http.post(
      Uri.parse("${MyConfig.server}/ims/php/inventory/insert_inventory.php"),
      body: {
        "inventoryName": inventoryName,
        "inventoryCategory": selectedCategory,
        "inventoryQuantity": inventoryQuantity,
        "inventoryMaximumQuantity": inventoryMaximumQuantity,
        "inventoryBuyingPrice": buyingPrice,
        "inventorySellingPrice": sellingPrice,
        "inventorySupplierName": supplierName,
        "inventoryStaffID": staffID,
        "image": base64Image,
      },
    ).then(
      (response) {
        if (response.statusCode == 200) {
          log(response.body);
          var jsondata = jsonDecode(response.body);
          if (jsondata['status'] == 'success') {
            showToastMessage("Inventory Inserted Successfully");
            Navigator.pop(context);
          } else if (jsondata['status'] == 'inventory-exists') {
            String inventoryID = jsondata['data'];
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Inventory Exists (ID: $inventoryID)"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          } else {
            showToastMessage('Inventory Inserted Failed - Json');
          }
        } else {
          showToastMessage('Inventory Inserted Failed - HTTP');
        }
      },
    );
  }
}
