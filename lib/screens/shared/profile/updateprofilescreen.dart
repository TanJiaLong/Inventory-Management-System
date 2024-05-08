import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:ims/configs/myconfig.dart';
import 'package:ims/models/user.dart';

class UpdateProfileScreen extends StatefulWidget {
  final User currentUser;
  const UpdateProfileScreen({super.key, required this.currentUser});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  late double sWidth, sHeight, textSize;

  final _formKey = GlobalKey<FormState>();
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _itemFocusNode = FocusNode();
  final _nameTextEditingController = TextEditingController();
  final _emailTextEditingController = TextEditingController();
  final _phoneTextEditingController = TextEditingController();
  final TextEditingController _password1EditingController =
      TextEditingController();
  final TextEditingController _password2EditingController =
      TextEditingController();
  bool isPassVisible = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameTextEditingController.text = widget.currentUser.userName.toString();
    _emailTextEditingController.text = widget.currentUser.userEmail.toString();
    _phoneTextEditingController.text =
        widget.currentUser.userPhoneNumber.toString();
    _password1EditingController.text =
        widget.currentUser.userPassword.toString();
    _password2EditingController.text =
        widget.currentUser.userPassword.toString();
  }

  @override
  Widget build(BuildContext context) {
    sWidth = MediaQuery.of(context).size.width;
    sHeight = MediaQuery.of(context).size.height;
    textSize = sWidth * 0.04;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Update Profile",
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
                flex: 2,
                child: Image.asset(
                  "./assets/images/updateProfile.jpeg",
                  fit: BoxFit.contain,
                ),
              ),
              Expanded(
                flex: 6,
                child: SingleChildScrollView(
                  child: SizedBox(
                    height: sHeight * 0.6,
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
                                  ? 'The username must be at least 5 characters'
                                  : null,
                              keyboardType: TextInputType.name,
                              decoration: const InputDecoration(
                                  labelText: 'Username',
                                  icon: Icon(Icons.people_alt_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
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
                              focusNode: _emailFocusNode,
                              controller: _emailTextEditingController,
                              validator: (value) => value == null ||
                                      !value.contains('@') ||
                                      !value.contains('.')
                                  ? 'Email must contain the characters @ and .'
                                  : null,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                  labelText: 'Email',
                                  icon: Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
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
                              focusNode: _phoneFocusNode,
                              controller: _phoneTextEditingController,
                              validator: (value) => value == null ||
                                      value.length < 5
                                  ? 'The phone number must be at least 5 characters'
                                  : null,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                  labelText: 'Phone Number',
                                  icon: Icon(Icons.people_alt_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
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
                              controller: _password1EditingController,
                              validator: (val) =>
                                  val!.isEmpty || (val.length < 5)
                                      ? "Password is longer than 5 characters"
                                      : null,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: !isPassVisible,
                              decoration: InputDecoration(
                                labelText: "Password",
                                icon: const Icon(Icons.password_outlined),
                                border: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                suffixIcon: IconButton(
                                  icon: isPassVisible
                                      ? const Icon(Icons.visibility)
                                      : const Icon(Icons.visibility_off),
                                  onPressed: () {
                                    setState(() {
                                      isPassVisible = !isPassVisible;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: textSize,
                          ),
                          Flexible(
                            child: TextFormField(
                              controller: _password2EditingController,
                              validator: (val) =>
                                  val!.isEmpty || (val.length < 5)
                                      ? "Password is longer than 5 characters"
                                      : null,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: !isPassVisible,
                              decoration: InputDecoration(
                                labelText: "Re-enter Password",
                                icon: const Icon(Icons.password_outlined),
                                border: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                suffixIcon: IconButton(
                                  icon: isPassVisible
                                      ? const Icon(Icons.visibility)
                                      : const Icon(Icons.visibility_off),
                                  onPressed: () {
                                    setState(() {
                                      isPassVisible = !isPassVisible;
                                    });
                                  },
                                ),
                              ),
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
                    updateUserDialog();
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

  void updateUserDialog() {
    if (!_formKey.currentState!.validate()) {
      showToastMessage("Check your input");
      return;
    }
    if (_password1EditingController.text != _password2EditingController.text) {
      showToastMessage("Check Your Password");
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Update Profile?"),
          actions: [
            TextButton(
                onPressed: () {
                  updateUser();
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

  void updateUser() {
    log(widget.currentUser.toJson().toString());
    http.post(
      Uri.parse("${MyConfig.server}/ims/php/user/update_profile.php"),
      body: {
        "staffID": widget.currentUser.staffID.toString(),
        "userName": _nameTextEditingController.text,
        "userEmail": _emailTextEditingController.text,
        "userPhone": _phoneTextEditingController.text,
        "password": _password1EditingController.text,
      },
    ).then(
      (response) {
        log(response.body);
        if (response.statusCode == 200) {
          dynamic jsonData = jsonDecode(response.body);
          if (jsonData['status'] == "success") {
            showToastMessage("Profile updated successfully");
            User updatedUser = User(
              staffID: widget.currentUser.toString(),
              userName: _nameTextEditingController.text,
              userEmail: _emailTextEditingController.text,
              userPhoneNumber: _phoneTextEditingController.text,
              userPassword: _password1EditingController.text,
            );
            Navigator.pop(context, updatedUser);
          } else {
            showToastMessage("Profile updated Failed");
          }
        }
      },
    );
  }
}
