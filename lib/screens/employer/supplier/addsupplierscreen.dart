import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:ims/configs/myconfig.dart';

class AddSupplierScreen extends StatefulWidget {
  const AddSupplierScreen({super.key});

  @override
  State<AddSupplierScreen> createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends State<AddSupplierScreen> {
  late double sWidth, sHeight, textSize;

  final _formKey = GlobalKey<FormState>();
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _itemFocusNode = FocusNode();
  final _nameTextEditingController = TextEditingController();
  final _emailTextEditingController = TextEditingController();
  final _phoneTextEditingController = TextEditingController();

  late List<String> _categoryList;
  late String _selectedCategory;
  final String _firstElement =
      "Please Select                                     ";

  @override
  void initState() {
    super.initState();
    fetchCategoryList();
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _itemFocusNode.dispose();
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
          "Add Supplier Form",
          style: TextStyle(
              color: Colors.black,
              fontSize: textSize * 1.25,
              fontWeight: FontWeight.w900),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: GestureDetector(
        onTap: () {
          _nameFocusNode.unfocus();
          _emailFocusNode.unfocus();
          _phoneFocusNode.unfocus();
          _itemFocusNode.unfocus();
        },
        child: Container(
          width: sWidth,
          height: sHeight,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Image.asset(
                  "./assets/images/supplierForm.jpg",
                  fit: BoxFit.contain,
                ),
              ),
              Expanded(
                flex: 7,
                child: SingleChildScrollView(
                  child: SizedBox(
                    height: sHeight * 0.5,
                    width: sWidth,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(
                            height: textSize / 2,
                          ),
                          Flexible(
                            child: TextFormField(
                              focusNode: _nameFocusNode,
                              controller: _nameTextEditingController,
                              validator: (value) => value == null ||
                                      value.length < 5
                                  ? 'The supplier name must be at least 5 characters'
                                  : null,
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(
                                      textSize * 0.75, 0, textSize * 0.75, 0),
                                  labelText: 'Name',
                                  icon: const Icon(Icons.people_alt_outlined),
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  focusColor: Colors.black),
                            ),
                          ),
                          SizedBox(
                            height: textSize / 2,
                          ),
                          Flexible(
                            child: TextFormField(
                              focusNode: _emailFocusNode,
                              controller: _emailTextEditingController,
                              validator: (value) => value == null ||
                                      !value.contains('@') ||
                                      !value.contains('.')
                                  ? 'Email must contain the characters @ and .'
                                  : null,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(
                                      textSize * 0.75, 0, textSize * 0.75, 0),
                                  labelText: 'Email',
                                  icon: const Icon(Icons.email_outlined),
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  focusColor: Colors.black),
                            ),
                          ),
                          SizedBox(
                            height: textSize / 2,
                          ),
                          Flexible(
                            child: TextFormField(
                              focusNode: _phoneFocusNode,
                              controller: _phoneTextEditingController,
                              validator: (value) => value == null ||
                                      value.length < 5
                                  ? 'The phone number must be at least 5 characters'
                                  : null,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(
                                      textSize * 0.75, 0, textSize * 0.75, 0),
                                  labelText: 'Phone Number',
                                  icon: const Icon(Icons.people_alt_outlined),
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  focusColor: Colors.black),
                            ),
                          ),
                          SizedBox(
                            height: textSize / 2,
                          ),
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
                                            child: Text(categoryElement),
                                          );
                                        },
                                      ).toList(),
                                      onChanged: (selectedCategory) {
                                        setState(
                                          () {
                                            _selectedCategory =
                                                selectedCategory!;
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
                width: sWidth * 0.8,
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
                    // Add data
                    addSupplierDialog();
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
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

  void fetchCategoryList() async {
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

  void addSupplierDialog() {
    if (!_formKey.currentState!.validate()) {
      showToastMessage("Check your input");
      return;
    }
    if (_selectedCategory == "Please Select        ") {
      showToastMessage("Category is not selected");
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Supplier?"),
          actions: [
            TextButton(
                onPressed: () {
                  addSupplier();
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

  void addSupplier() {
    String supplierName = _nameTextEditingController.text;
    String supplierEmail = _emailTextEditingController.text;
    String supplierPhone = _phoneTextEditingController.text;
    String suppliedCategory = _selectedCategory.toString();
    http.post(
      Uri.parse("${MyConfig.server}/ims/php/supplier/insert_supplier.php"),
      body: {
        "supplierName": supplierName,
        "supplierEmail": supplierEmail,
        "supplierPhone": supplierPhone,
        "suppliedCategory": suppliedCategory,
      },
    ).then(
      (response) {
        if (response.statusCode == 200) {
          log(response.body);
          var jsondata = jsonDecode(response.body);
          if (jsondata['status'] == 'success') {
            showToastMessage("Supplier Added Successfully");
            Navigator.pop(context);
          } else if (jsondata['status'] == 'record-exists') {
            String inventoryID = jsondata['data'];
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Record Exists (ID: $inventoryID)"),
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
