import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ims/configs/myconfig.dart';
import 'package:ims/models/inventory.dart';
import 'package:http/http.dart' as http;

class AddInventoryMovementHistoryScreen extends StatefulWidget {
  final Inventory currentInventory;
  final String staffID;
  const AddInventoryMovementHistoryScreen(
      {super.key, required this.currentInventory, required this.staffID});

  @override
  State<AddInventoryMovementHistoryScreen> createState() =>
      _AddInventoryMovementHistoryStateScreen();
}

class _AddInventoryMovementHistoryStateScreen
    extends State<AddInventoryMovementHistoryScreen> {
  late double sWidth, sHeight, textSize;
  final _formKey = GlobalKey<FormState>();

  final List<String> _inventoryFlowTypes = [
    "Please Select",
    "Purchase",
    "Sale",
    "Customer Return"
  ];
  String _selectedInventoryFlowType = "Please Select";
  String _inventoryFlow = "";
  late int _currentInventoryQuantity;

  final _inventoryNameTextEditingController = TextEditingController();
  final _currentQuantityTextEditingController = TextEditingController();
  final _maximumQuantityTextEditingController = TextEditingController();
  final _movementQuantityTextEditingController = TextEditingController();
  final _supplierNameTextEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentInventoryQuantity =
        int.parse(widget.currentInventory.inventoryQuantity!);

    _inventoryNameTextEditingController.text =
        widget.currentInventory.inventoryName.toString();
    _currentQuantityTextEditingController.text =
        widget.currentInventory.inventoryQuantity.toString();
    _maximumQuantityTextEditingController.text =
        widget.currentInventory.inventoryMaximumQuantity.toString();
    _supplierNameTextEditingController.text =
        widget.currentInventory.inventorySupplierName.toString();
  }

  @override
  Widget build(BuildContext context) {
    sWidth = MediaQuery.of(context).size.width;
    sHeight = MediaQuery.of(context).size.height;
    textSize = sWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Inventory Movement Form",
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
                            child: TextFormField(
                              controller: _inventoryNameTextEditingController,
                              enabled: false,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(
                                    textSize * 0.75, 0, textSize * 0.75, 0),
                                labelText: 'Inventory Name',
                                icon: const Icon(Icons.inventory_2_outlined),
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
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
                                        _currentQuantityTextEditingController,
                                    enabled: false,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.fromLTRB(
                                          textSize * 0.75,
                                          0,
                                          textSize * 0.75,
                                          0),
                                      labelText: 'Current Quantity',
                                      icon: const Icon(
                                        Icons.monetization_on_outlined,
                                      ),
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      focusColor: Colors.black,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: textSize * 1.5,
                                ),
                                Flexible(
                                  flex: 4,
                                  child: TextFormField(
                                    controller:
                                        _maximumQuantityTextEditingController,
                                    enabled: false,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.fromLTRB(
                                          textSize * 0.75,
                                          0,
                                          textSize * 0.75,
                                          0),
                                      labelText: 'Maximum Quantity',
                                      border: const OutlineInputBorder(
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
                                      alignment: Alignment.centerLeft,
                                      focusColor: Colors.grey,
                                      value: _selectedInventoryFlowType,
                                      items: _inventoryFlowTypes.map(
                                        (flowType) {
                                          return DropdownMenuItem(
                                            value: flowType,
                                            child: Text(flowType),
                                          );
                                        },
                                      ).toList(),
                                      onChanged: (selectedInventoryFlowType) {
                                        setState(
                                          () {
                                            _selectedInventoryFlowType =
                                                selectedInventoryFlowType!;
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
                                  _movementQuantityTextEditingController,
                              validator: (value) =>
                                  value!.isEmpty || int.parse(value) < 0
                                      ? 'Please enter a correct quantity'
                                      : null,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]')), // Allow only numbers
                              ],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(
                                      textSize * 0.75, 0, textSize * 0.75, 0),
                                  labelText: 'Movement Quantity',
                                  icon: const Icon(
                                    Icons.numbers,
                                  ),
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                  focusColor: Colors.black),
                            ),
                          ),
                          SizedBox(
                            height: textSize,
                          ),
                          Flexible(
                            child: TextFormField(
                              controller: _supplierNameTextEditingController,
                              enabled: false,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(
                                      textSize * 0.75, 0, textSize * 0.75, 0),
                                  labelText: 'Supplier Name',
                                  icon: const Icon(
                                    Icons.people_alt_outlined,
                                  ),
                                  border: const OutlineInputBorder(
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
                    insertInventoryMovementDialog();
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

  bool checkInsertion() {
    int maximumInventoryQuantity =
        int.parse(widget.currentInventory.inventoryMaximumQuantity!);
    int inventoryMovementQuantity =
        int.parse(_movementQuantityTextEditingController.text);

    // If purchase and the maximum quantity is not exceeded,
    if (_selectedInventoryFlowType == "Purchase" &&
        maximumInventoryQuantity >=
            _currentInventoryQuantity + inventoryMovementQuantity) {
      _inventoryFlow = "Stock-In";

      _currentInventoryQuantity += inventoryMovementQuantity;
      return true;
    }
    // If customer return the item
    else if (_selectedInventoryFlowType == "Customer Return") {
      _inventoryFlow = "Stock-In";
      _currentInventoryQuantity += inventoryMovementQuantity;
      return true;
    }
    // If Sales and the amount is not exceed the current quantity
    else if (_selectedInventoryFlowType == "Sale" &&
        _currentInventoryQuantity - inventoryMovementQuantity >= 0) {
      _inventoryFlow = "Stock-Out";

      _currentInventoryQuantity -= inventoryMovementQuantity;
      return true;
    }
    return false;
  }

  void insertInventoryMovementDialog() {
    if (!_formKey.currentState!.validate()) {
      showToastMessage("Check your input");
      return;
    }
    if (_selectedInventoryFlowType == "Please Select") {
      showToastMessage("Please Select Inventory Flow Type");
      return;
    }

    if (checkInsertion()) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Add Inventory Movement?"),
            actions: [
              TextButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  insertInventoryMovement();

                  Navigator.pop(context);
                },
                child: const Text("Yes"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("No"),
              ),
            ],
          );
        },
      );
    } else {
      showToastMessage("Invalid Quantity!");
      return;
    }
  }

  void insertInventoryMovement() {
    String inventoryID = widget.currentInventory.inventoryID!;
    String inventoryMovementQuantity =
        _movementQuantityTextEditingController.text;
    String inventoryCurrentQuantity = _currentInventoryQuantity.toString();
    String inventoryFlowType = _selectedInventoryFlowType;
    String inventoryFlow = _inventoryFlow;
    String staffID = widget.staffID;

    http.post(
      Uri.parse(
          "${MyConfig.server}/ims/php/inventorymovement/insert_inventory_movement.php"),
      body: {
        "inventoryID": inventoryID,
        "inventoryMovementQuantity": inventoryMovementQuantity,
        "inventoryCurrentQuantity": inventoryCurrentQuantity,
        "inventoryFlowType": inventoryFlowType,
        "inventoryFlow": inventoryFlow,
        "staffID": staffID,
      },
    ).then(
      (response) {
        if (response.statusCode == 200) {
          log(response.body);
          var jsonData = jsonDecode(response.body);
          if (jsonData['status'] == "success") {
            if (jsonData['isInsertIMSuccess']) {
              if (jsonData['isUpdateIQSuccess']) {
                showToastMessage("Record was added successfully");
                Navigator.pop(
                  context,
                  _currentInventoryQuantity.toString(),
                );
              } else {
                showToastMessage("Something went wrong to update I.Quantity");
              }
            } else {
              showToastMessage("Something went wrong to update I.Movement");
            }
          } else {
            showToastMessage(
                "Something went wrong to add the inventory movement");
          }
        } else {
          showToastMessage("HTTP Error: ${response.statusCode}");
        }
      },
    );
  }
}
