import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ims/configs/myconfig.dart';
import 'package:ims/screens/authentication/loginscreen.dart';
import 'package:http/http.dart' as http;

class ResetPasswordScreen extends StatefulWidget {
  final String staffID;
  const ResetPasswordScreen({super.key, required this.staffID});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late double sWidth, sHeight, textSize;
  final _formKey = GlobalKey<FormState>();
  bool isPassVisible = false;

  final TextEditingController _password1EditingController =
      TextEditingController();
  final TextEditingController _password2EditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    sWidth = MediaQuery.of(context).size.width;
    sHeight = MediaQuery.of(context).size.height;
    textSize = sWidth * 0.04;

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
            width: sWidth * 0.9,
            height: sHeight * 0.45,
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: EdgeInsets.all(textSize * 1.25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        "Reset Password",
                        style: TextStyle(
                            fontSize: textSize * 2,
                            fontWeight: FontWeight.w800),
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    Flexible(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            height: sHeight * 0.19,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _password1EditingController,
                                      validator: (val) => val!.isEmpty ||
                                              (val.length < 5)
                                          ? "Password is longer than 5 characters"
                                          : null,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      obscureText: !isPassVisible,
                                      decoration: InputDecoration(
                                        labelText: "Password",
                                        icon: const Icon(Icons.password_sharp),
                                        border: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: isPassVisible
                                              ? const Icon(Icons.visibility)
                                              : const Icon(
                                                  Icons.visibility_off),
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
                                  Expanded(
                                    child: TextFormField(
                                      controller: _password2EditingController,
                                      validator: (val) => val!.isEmpty ||
                                              (val.length < 5)
                                          ? "Password is longer than 5 characters"
                                          : null,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      obscureText: !isPassVisible,
                                      decoration: InputDecoration(
                                        labelText: "Re-enter Password",
                                        icon: const Icon(Icons.password_sharp),
                                        border: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: isPassVisible
                                              ? const Icon(Icons.visibility)
                                              : const Icon(
                                                  Icons.visibility_off),
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
                        ],
                      ),
                    ), //form end

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
                                fontSize: textSize,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              resetPasswordDialog();
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
                            child: Text("SUBMIT",
                                style: TextStyle(
                                    color: Colors.white, fontSize: textSize)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void resetPasswordDialog() {
    if (!_formKey.currentState!.validate()) {
      showToastMessage("Check Your Input");
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
          title: const Text("Reset Password?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                resetPassword();
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
  }

  void resetPassword() {
    String staffID = widget.staffID.toString();
    String pass1 = _password1EditingController.text;

    http.post(
      Uri.parse("${MyConfig.server}/ims/php/user/reset_password.php"),
      body: {
        "staffID": staffID,
        "password": pass1,
      },
    ).then((response) {
      if (response.statusCode == 200) {
        dynamic jsonData = jsonDecode(response.body);
        if (jsonData['status'] == "success") {
          showToastMessage("Password reseted successfully");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        } else {
          showToastMessage("Password reseted failed");
        }
      }
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
}
