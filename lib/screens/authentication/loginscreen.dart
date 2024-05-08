import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ims/configs/myconfig.dart';
import 'package:ims/models/user.dart';
import 'package:ims/screens/authentication/forgotpasswordscreen.dart';
import 'package:ims/screens/authentication/otpscreen.dart';
import 'package:ims/screens/authentication/registrationscreen.dart';
import 'package:ims/screens/shared/mainscreen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late double sWidth, sHeight, textSize;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _staffIDEditingController =
      TextEditingController();
  final TextEditingController _passwordEditingController =
      TextEditingController();
  bool isPassVisible = false;
  bool _isRemember = false;
  bool _isUserActive = true;

  @override
  void initState() {
    super.initState();
    loadPref();
  }

  @override
  Widget build(BuildContext context) {
    sWidth = MediaQuery.of(context).size.width; //320
    sHeight = MediaQuery.of(context).size.height; //533.34
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
            height: sHeight * 0.6,
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: EdgeInsets.all(textSize * 1.25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 2,
                      child: Column(
                        children: [
                          // Icon
                          Flexible(
                            flex: 1,
                            child: SizedBox(
                              // height: sHeight * 0.09,
                              child: Image.asset(
                                "assets/images/profileIcon.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Text(
                              "Login",
                              style: TextStyle(
                                  fontSize: textSize * 2,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 4,
                      child: Column(
                        children: [
                          Flexible(
                            flex: 4,
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
                                      controller: _passwordEditingController,
                                      validator: (val) => val!.isEmpty ||
                                              (val.length < 5)
                                          ? "Password is longer than 5 characters"
                                          : null,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      obscureText: !isPassVisible,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.fromLTRB(
                                            textSize * 0.75,
                                            0,
                                            textSize * 0.75,
                                            0),
                                        labelText: "Password",
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
                          Flexible(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: sWidth * 0.07,
                                      height: sWidth * 0.05,
                                      child: Checkbox(
                                        value: _isRemember,
                                        onChanged: (bool? val) {
                                          if (!_formKey.currentState!
                                              .validate()) {
                                            _isRemember = false;
                                            setState(() {});
                                            return;
                                          }
                                          savePrefs(val!);
                                          setState(() {
                                            _isRemember = val;
                                          });
                                        },
                                      ),
                                    ),
                                    Text(
                                      "Remember Me",
                                      style: TextStyle(
                                          fontSize: textSize * 0.875,
                                          fontWeight: FontWeight.w900),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await checkUserStatus();
                                    if (!_isUserActive) {
                                      return;
                                    }
                                    loginUser();
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
                                  child: Text("LOGIN",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: textSize)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPasswordScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: textSize,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  //Navigator

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (content) =>
                                          const RegistrationScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: textSize,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          )
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

  void loginUser() {
    if (!_formKey.currentState!.validate()) {
      showToastMessage("Check Your Input");
      return;
    }

    String staffID = _staffIDEditingController.text;
    String userPassword = _passwordEditingController.text;

    http.post(
      Uri.parse("${MyConfig.server}/ims/php/user/login_user.php"),
      body: {
        "staffID": staffID,
        "userPassword": userPassword,
      },
    ).then(
      (response) {
        if (response.statusCode == 200) {
          dynamic jsonData = jsonDecode(response.body);
          if (jsonData['status'] == "success") {
            showToastMessage("Login Success");

            User loginUser = User.fromJson(jsonData['data']);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainScreen(
                  user: loginUser,
                ),
              ),
            );
          } else {
            showToastMessage("Json Error");
          }
        }
      },
    );
  }

  Future<void> checkUserStatus() async {
    String staffID = _staffIDEditingController.text;
    await http.post(
        Uri.parse("${MyConfig.server}/ims/php/user/check_user_exists.php"),
        body: {
          "staffID": staffID,
        }).then(
      (response) {
        if (response.statusCode == 200) {
          log(response.body);
          var jsonData = jsonDecode(response.body);
          if (jsonData['status'] == "user_exists") {
            if (jsonData['data']['userStatus'] == 'Unverified') {
              _isUserActive = false;

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
                "Email Unverified. Please continue to verify your email",
              );
            } else if (jsonData['data']['userStatus'] == 'Pending') {
              _isUserActive = false;
              showToastMessage(
                  "Account Pending. Please wait for admin approval");
            } else if (jsonData['data']['userStatus'] == 'Rejected') {
              _isUserActive = false;
              showToastMessage(
                  "Your registration was rejected, please contact admin for assistance");
            }
          } else {
            _isUserActive = false;
            showToastMessage(
                "User not exists, please register an account to use our service");
          }
        } else {
          log("HTTP Status Code ${response.statusCode} To Load User Existance");
        }
      },
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

  void savePrefs(bool value) async {
    String staffID = _staffIDEditingController.text;
    String password = _passwordEditingController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (value) {
      if (!_formKey.currentState!.validate()) {
        _isRemember = false;
        return;
      }
      await prefs.setString('staffID', staffID);
      await prefs.setString('password', password);
      await prefs.setBool('checkBox', value);

      showToastMessage("Preferences Stored");
    } else {
      await prefs.setString('staffID', "");
      await prefs.setString('password', "");
      await prefs.setBool('checkBox', false);
      setState(() {
        _staffIDEditingController.text = "";
        _passwordEditingController.text = "";
        _isRemember = false;
      });
      showToastMessage("Preferences Removed");
    }
  }

  Future<void> loadPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String staffID = (prefs.getString('staffID')) ?? '';
    String password = (prefs.getString('password')) ?? '';
    _isRemember = (prefs.getBool('checkBox')) ?? false;

    if (_isRemember) {
      setState(() {
        _staffIDEditingController.text = staffID;
        _passwordEditingController.text = password;
      });
    }
  }
}
