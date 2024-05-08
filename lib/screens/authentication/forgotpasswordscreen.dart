import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ims/configs/myconfig.dart';
import 'package:ims/models/user.dart';
import 'package:ims/screens/authentication/loginscreen.dart';
import 'package:ims/screens/authentication/otpforgotpasswordscreen.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _staffIDEditingController = TextEditingController();
  final _userEmailEditingController = TextEditingController();

  late double sWidth, sHeight, textSize;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    sWidth = MediaQuery.of(context).size.width;
    sHeight = MediaQuery.of(context).size.height;
    textSize = sWidth * 0.04; //(16 / 392)

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/splashScreen.jpg"),
                  fit: BoxFit.cover),
            ),
          ),
          SizedBox(
            width: sWidth * 0.8,
            height: sHeight * 0.45,
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  20,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(
                  textSize * 1.25,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Text(
                        "Forgot Password",
                        style: TextStyle(
                          fontSize: textSize * 2,
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: TextFormField(
                                      controller: _staffIDEditingController,
                                      validator: (val) => val!.isEmpty ||
                                              (val.length < 5)
                                          ? "Staff ID is longer than 5 characters"
                                          : null,
                                      keyboardType: TextInputType.name,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.fromLTRB(
                                            textSize * 0.75,
                                            0,
                                            textSize * 0.75,
                                            0),
                                        labelText: "StaffID",
                                        icon: const Icon(
                                            Icons.people_alt_outlined),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: textSize / 2,
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: TextFormField(
                                      controller: _userEmailEditingController,
                                      validator: (val) => val!.isEmpty ||
                                              !val.contains("@") ||
                                              !val.contains(".")
                                          ? "Please insert a valid email"
                                          : null,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.fromLTRB(
                                            textSize * 0.75,
                                            0,
                                            textSize * 0.75,
                                            0),
                                        labelText: "Email",
                                        icon: const Icon(Icons.email_outlined),
                                        border: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(15),
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
                    Flexible(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Back",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: textSize * 0.875,
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              FocusScope.of(context).unfocus();

                              submitInputs();
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.black),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                            child: Text(
                              "SUBMIT",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: textSize,
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

  void submitInputs() {
    if (!_formKey.currentState!.validate()) {
      showToastMessage("Check Your Input");
      return;
    }

    String staffID = _staffIDEditingController.text;
    String userEmail = _userEmailEditingController.text;

    http.post(
      Uri.parse("${MyConfig.server}/ims/php/user/forgot_password.php"),
      body: {
        "staffID": staffID,
        "userEmail": userEmail,
      },
    ).then(
      (response) {
        if (response.statusCode == 200) {
          dynamic jsonData = jsonDecode(response.body);
          if (jsonData['status'] == "user_exists") {
            if (jsonData['data']['userStatus'] == 'Unverified') {
              showToastMessage(
                "Email Unverified. Please continue to verify your email",
              );
            } else if (jsonData['data']['userStatus'] == 'Pending') {
              showToastMessage(
                  "Account Pending. Please wait for admin approval");
            } else if (jsonData['data']['userStatus'] == 'Rejected') {
              showToastMessage(
                  "Your registration was rejected, please contact admin for assistance");
            } else if (jsonData['data']['userEmail'] != userEmail) {
              showToastMessage("Please enter correct email address");
            } else {
              User registeredUser = User(
                staffID: staffID,
                userName: jsonData['data']['userName'],
                userEmail: jsonData['data']['userEmail'],
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      OTPForgotPasswordScreen(user: registeredUser),
                ),
              );
            }
          } else {
            showToastMessage("User Not Exists");
          }
        }
      },
    );
  }
}
