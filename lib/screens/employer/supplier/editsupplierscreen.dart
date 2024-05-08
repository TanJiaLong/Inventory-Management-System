import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:ims/configs/myconfig.dart';
import 'package:ims/models/supplier.dart';

class EditSupplierScreen extends StatefulWidget {
  final Supplier currentSupplier;
  const EditSupplierScreen({super.key, required this.currentSupplier});

  @override
  State<EditSupplierScreen> createState() => _EditSupplierScreenState();
}

class _EditSupplierScreenState extends State<EditSupplierScreen> {
  late double sWidth, sHeight, textSize;

  final _formKey = GlobalKey<FormState>();
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _itemFocusNode = FocusNode();
  final _nameTextEditingController = TextEditingController();
  final _emailTextEditingController = TextEditingController();
  final _phoneTextEditingController = TextEditingController();

  late final List<String> _categoryList;

  @override
  void initState() {
    super.initState();
    _nameTextEditingController.text =
        widget.currentSupplier.supplierName.toString();
    _emailTextEditingController.text =
        widget.currentSupplier.supplierEmail.toString();
    _phoneTextEditingController.text =
        widget.currentSupplier.supplierPhone.toString();
    _categoryList = [
      widget.currentSupplier.supplierSuppliedCategory.toString()
    ];
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
          "Edit Supplier Form",
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
          padding: EdgeInsets.all(textSize * 1.25),
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
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
                                Flexible(
                                  flex: 7,
                                  child: Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(12, 0, 8, 0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: DropdownButton(
                                      isExpanded: true,
                                      alignment: Alignment.centerLeft,
                                      focusColor: Colors.grey,
                                      value: _categoryList[0],
                                      items: _categoryList.map(
                                        (categoryElement) {
                                          return DropdownMenuItem(
                                            value: _categoryList[0],
                                            child: Text(_categoryList[0]),
                                          );
                                        },
                                      ).toList(),
                                      onChanged: (selectedCategory) {},
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
                    updateSupplierDialog();
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

  void updateSupplierDialog() {
    if (!_formKey.currentState!.validate()) {
      showToastMessage("Check your input");
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Update Supplier?"),
          actions: [
            TextButton(
                onPressed: () {
                  updateSupplier();
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

  void updateSupplier() {
    String supplierID = widget.currentSupplier.supplierId.toString();
    String supplierName = _nameTextEditingController.text;
    String supplierEmail = _emailTextEditingController.text;
    String supplierPhone = _phoneTextEditingController.text;

    http.post(
      Uri.parse("${MyConfig.server}/ims/php/supplier/update_supplier.php"),
      body: {
        "supplierID": supplierID,
        "supplierName": supplierName,
        "supplierEmail": supplierEmail,
        "supplierPhone": supplierPhone,
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
