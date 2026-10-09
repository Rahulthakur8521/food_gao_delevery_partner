import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'OtpVerification.dart'; // Ensure this path is correct

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // New state variable

  @override
  Widget build(BuildContext context) {
    // Getting screen dimensions
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: screenHeight,
        color: Colors.white,
        child: Stack(
          children: [
            // Yellow container
            Container(
              width: double.infinity,
              height: screenHeight * 0.4, // Adjusted height using MediaQuery
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phonelink_lock_sharp, size: screenWidth * 0.12, color: Colors.white),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    "Mobile number",
                    style: TextStyle(
                      fontSize: screenWidth * 0.06, // Font size relative to screen width
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                    child: Text(
                      "We need to send an OTP to authenticate your mobile number.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.04, // Font size relative to screen width
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // White container overlapping the yellow container
            Positioned(
              top: screenHeight * 0.35, // Adjusted top using MediaQuery
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(screenWidth * 0.05),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      'Verify Number',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05, // Font size relative to screen width
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Enter phone',
                          hintText: 'Enter phone',
                          prefix: Text("+91 "),
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(screenWidth * 0.02),
                            child: Image.asset(
                              'assets/images/download (7).png', // Verify path
                              width: screenWidth * 0.06, // Image size relative to screen width
                              height: screenWidth * 0.06,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.02),
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Phone number is required";
                          }
                          if (value.length != 10) {
                            return "Invalid phone number";
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true; // Start loading
                            });
                            try {
                              await FirebaseAuth.instance.verifyPhoneNumber(
                                phoneNumber: '+91${phoneController.text}',
                                verificationCompleted: (PhoneAuthCredential credential) {
                                  setState(() {
                                    _isLoading = false; // Stop loading on completion
                                  });
                                  // Handle successful verification
                                },
                                verificationFailed: (FirebaseAuthException ex) {
                                  setState(() {
                                    _isLoading = false; // Stop loading on failure
                                  });
                                  if (ex.code == 'invalid-phone-number') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Invalid phone number.')),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(ex.message ?? 'Verification failed.')),
                                    );
                                  }
                                },
                                codeSent: (String verificationId, int? resendToken) {
                                  setState(() {
                                    _isLoading = false; // Stop loading once code is sent
                                  });
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OtpVerificationPage(verificationid: verificationId),
                                    ),
                                  );
                                },
                                codeAutoRetrievalTimeout: (String verificationId) {
                                  setState(() {
                                    _isLoading = false; // Stop loading on timeout
                                  });
                                  // Handle timeout if needed
                                },
                              );
                            } catch (e) {
                              setState(() {
                                _isLoading = false; // Stop loading on error
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to verify phone number: ${e.toString()}')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(screenHeight * 0.02), // Button padding relative to screen height
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.02),
                          ),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: screenWidth * 0.045, // Font size relative to screen width
                            color: Colors.white,
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
    );
  }
}