import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ims/configs/myconfig.dart';
import 'package:ims/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:ims/screens/authentication/loginscreen.dart';

class OTPScreen extends StatefulWidget {
  final User user;
  const OTPScreen({super.key, required this.user});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  late double sWidth, sHeight, textSize;
  final TextEditingController _otpEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<TextEditingController> controllers = List.generate(
    5,
    (index) => TextEditingController(),
  );
  List<FocusNode> focusNodes = List.generate(
    5,
    (index) => FocusNode(),
  );

  @override
  void initState() {
    super.initState();

    mailOTP();
  }

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
          Container(
            padding: EdgeInsets.all(textSize),
            width: sWidth * 0.75,
            height: sHeight * 0.5,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Flexible(
                  child: Text(
                    "OTP Verification",
                    style: TextStyle(
                        fontSize: textSize * 2, fontWeight: FontWeight.w800),
                    overflow: TextOverflow.visible,
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(
                      0, textSize * 0.75, 0, textSize * 1.5),
                  padding: EdgeInsets.fromLTRB(
                      textSize, textSize, textSize / 2, textSize),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 183, 255, 186),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text.rich(
                    TextSpan(
                      text: "We're sent a verification code to your email - ",
                      style: const TextStyle(
                          color: Color.fromARGB(255, 28, 112, 31),
                          fontWeight: FontWeight.w400,
                          overflow: TextOverflow.visible),
                      children: [
                        TextSpan(
                          text: "${widget.user.userEmail}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.visible),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, textSize),
                    child: Form(
                      key: _formKey,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          5,
                          (index) => SizedBox(
                            width: 40,
                            height: 50,
                            child: TextFormField(
                              focusNode: focusNodes[index],
                              controller: controllers[index],
                              maxLength: 1,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: textSize,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(
                                    textSize * 0.75, 0, textSize * 0.75, 0),
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: textSize * 1.25,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                if (value.length == 1 && index < 4) {
                                  FocusScope.of(context).nextFocus();
                                } else {
                                  FocusScope.of(context).unfocus();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          mailOTP();
                        },
                        child: Text(
                          "Resend OTP",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: textSize,
                              fontWeight: FontWeight.w900,
                              decoration: TextDecoration.underline,
                              overflow: TextOverflow.visible),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          verifyOTP();
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.black,
                          ),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
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
                              overflow: TextOverflow.visible),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controllers.forEach(
      (controller) {
        controller.dispose();
      },
    );
    focusNodes.forEach(
      (node) {
        node.dispose();
      },
    );
    // TODO: implement dispose
    super.dispose();
  }

  void verifyOTP() {
    if (!_formKey.currentState!.validate()) {
      showToastMessage("Check Your Inputs");
      return;
    }

    String userOTP = "";
    for (TextEditingController controller in controllers) {
      userOTP += controller.text;
    }
    http.post(
      Uri.parse("${MyConfig.server}/ims/php/user/verifyOTP.php"),
      body: {
        "staffID": widget.user.staffID,
        "userName": widget.user.userName,
        "userEmail": widget.user.userEmail,
        "userOTP": userOTP,
      },
    ).then(
      (response) {
        log(response.body);
        if (response.statusCode == 200) {
          var jsonData = jsonDecode(response.body);
          if (jsonData['status'] == "success") {
            showToastMessage("Verified! Please wait for admin approval.");

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            );
          } else {
            showToastMessage("OTP not correct, please try again");
          }
        } else {
          showToastMessage("HTTP Error");
        }
      },
    );
  }

  void mailOTP() {
    http.post(
      Uri.parse("${MyConfig.server}/ims/php/user/mailOTP.php"),
      body: {
        "staffID": widget.user.staffID,
        "userName": widget.user.userName,
        "userEmail": widget.user.userEmail,
      },
    ).then(
      (response) {
        if (response.statusCode == 200) {
          log(response.body);
          var jsonData = jsonDecode(response.body);
          if (jsonData['status'] == "success") {
            showToastMessage("OTP Sent");
          } else {
            showToastMessage("Something went wrong to mail OTP");
          }
        } else {
          showToastMessage("HTTP Error");
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
}
