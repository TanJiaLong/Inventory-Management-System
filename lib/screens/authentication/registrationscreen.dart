import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:ims/configs/myconfig.dart';
import 'package:ims/models/user.dart';
import 'package:ims/screens/authentication/loginscreen.dart';
import 'package:ims/screens/authentication/otpscreen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late double sWidth, sHeight;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _staffIDEditingController =
      TextEditingController();
  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _phoneNumberEditingController =
      TextEditingController();
  final TextEditingController _password1EditingController =
      TextEditingController();
  final TextEditingController _password2EditingController =
      TextEditingController();
  bool isPassVisible = false;
  bool _isUserExists = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    sWidth = MediaQuery.of(context).size.width;
    sHeight = MediaQuery.of(context).size.height;

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
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: sWidth * 0.9,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            "Sign Up",
                            style: TextStyle(
                                fontSize: 32, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
                              child: Column(
                                children: [
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          controller: _staffIDEditingController,
                                          validator: (val) => val!.isEmpty ||
                                                  (val.length != 5)
                                              ? "Staff ID is exactly 5 characters"
                                              : (val[0] != 'B') &&
                                                      (val[0] != 'M') &&
                                                      (val[0] != 'E')
                                                  ? "Staff ID is starts with either B, M or E"
                                                  : null,
                                          keyboardType: TextInputType.text,
                                          decoration: InputDecoration(
                                            labelText: "Staff ID",
                                            icon: const Icon(
                                                Icons.account_circle_outlined),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        TextFormField(
                                          controller: _nameEditingController,
                                          validator: (val) => val!.isEmpty ||
                                                  (val.length < 5)
                                              ? "Username is longer than 5 characters"
                                              : null,
                                          keyboardType: TextInputType.name,
                                          decoration: InputDecoration(
                                            labelText: "Username",
                                            icon: const Icon(
                                                Icons.people_alt_outlined),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        TextFormField(
                                          controller: _emailEditingController,
                                          validator: (val) => val!.isEmpty ||
                                                  !val.contains("@") ||
                                                  !val.contains(".")
                                              ? "Email must contain '@' and '.' characters"
                                              : null,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          decoration: InputDecoration(
                                            labelText: "Email",
                                            icon: const Icon(
                                                Icons.email_outlined),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        TextFormField(
                                          controller:
                                              _phoneNumberEditingController,
                                          validator: (val) => val!.isEmpty ||
                                                  (val.length > 12)
                                              ? "Phone number is less than 12 characters"
                                              : null,
                                          keyboardType: TextInputType.phone,
                                          decoration: InputDecoration(
                                            labelText: "Phone Number",
                                            icon: const Icon(
                                                Icons.phone_outlined),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        TextFormField(
                                          controller:
                                              _password1EditingController,
                                          validator: (val) => val!.isEmpty ||
                                                  (val.length < 5)
                                              ? "Password is longer than 5 characters"
                                              : null,
                                          keyboardType:
                                              TextInputType.visiblePassword,
                                          obscureText: !isPassVisible,
                                          decoration: InputDecoration(
                                            labelText: "Password",
                                            icon: const Icon(
                                                Icons.password_sharp),
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
                                                  isPassVisible =
                                                      !isPassVisible;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        TextFormField(
                                          controller:
                                              _password2EditingController,
                                          validator: (val) => val!.isEmpty ||
                                                  (val.length < 5)
                                              ? "Password is longer than 5 characters"
                                              : null,
                                          keyboardType:
                                              TextInputType.visiblePassword,
                                          obscureText: !isPassVisible,
                                          decoration: InputDecoration(
                                            labelText: "Re-enter Password",
                                            icon: const Icon(
                                                Icons.password_sharp),
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
                                                  isPassVisible =
                                                      !isPassVisible;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (content) =>
                                                  const LoginScreen(),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          "Login",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900,
                                              decoration:
                                                  TextDecoration.underline),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          FocusScope.of(context).unfocus();
                                          await checkUserExists();
                                          if (_isUserExists) {
                                            return;
                                          }

                                          showRegisterDialog();
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.black),
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                          ),
                                        ),
                                        child: const Text("REGISTER",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showRegisterDialog() {
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
            content: const Text("Register New Account?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  registerUser();
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

  void registerUser() {
    String staffID = _staffIDEditingController.text;
    String? userName = _nameEditingController.text;
    String? userEmail = _emailEditingController.text;
    String? userPhoneNumber = _phoneNumberEditingController.text;
    String? userPassword = _password1EditingController.text;

    http.post(
      Uri.parse("${MyConfig.server}/ims/php/user/register_user.php"),
      body: {
        "staffID": staffID,
        "userName": userName,
        "userEmail": userEmail,
        "userPhoneNumber": userPhoneNumber,
        "userPassword": userPassword,
      },
    ).then(
      (response) {
        log(response.body);
        if (response.statusCode == 200) {
          var jsonData = jsonDecode(response.body);
          showToastMessage("Verify your email");
          User registeredUser = User(
            staffID: staffID,
            userName: jsonData['data']['userName'],
            userEmail: jsonData['data']['userEmail'],
          );
          log("User: ${registeredUser.staffID} ${registeredUser.userName} ${registeredUser.userEmail}");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPScreen(user: registeredUser),
            ),
          );
          log(response.body);
        } else {
          log("HTTP Status Code ${response.statusCode}: ${response.body}");
        }
      },
    );
  }

  Future<void> checkUserExists() async {
    String staffID = _staffIDEditingController.text;
    await http.post(
      Uri.parse("${MyConfig.server}/ims/php/user/check_user_exists.php"),
      body: {
        "staffID": staffID,
      },
    ).then(
      (response) {
        log(response.body);
        if (response.statusCode == 200) {
          var jsonData = jsonDecode(response.body);
          if (jsonData['status'] == "user_exists") {
            _isUserExists = true;
            if (jsonData['data']['userStatus'] == 'Unverified') {
              User registeredUser = User(
                staffID: staffID,
                userName: jsonData['data']['userName'],
                userEmail: jsonData['data']['userEmail'],
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OTPScreen(user: registeredUser),
                ),
              );
              showToastMessage(
                "User Exists. Please continue to verify your email",
              );
            } else if (jsonData['data']['userStatus'] == 'Pending') {
              showToastMessage("Please wait for admin approval");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            } else if (jsonData['data']['userStatus'] == 'Rejected') {
              showToastMessage(
                  "Your registration was rejected, please contact admin for assistance");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            } else if (jsonData['data']['userStatus'] == 'Active' ||
                jsonData['data']['userStatus'] == 'Inactive') {
              showToastMessage("User exists");

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            }
          } else {
            _isUserExists = false;
            return;
          }
        } else {
          log("HTTP Status Code ${response.statusCode} To Load User Existance");
        }
      },
    );
  }
}
