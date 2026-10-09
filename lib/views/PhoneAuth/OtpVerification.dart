import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_gao_delevery_partner/views/PhoneAuth/Register.dart';
import 'package:food_gao_delevery_partner/views/PhoneAuth/mapPage/mapPage.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpVerificationPage extends StatefulWidget {
  final String verificationid;
  OtpVerificationPage({Key? key, required this.verificationid}) : super(key: key);

  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final int otpLength = 6;
  late Timer _timer;
  TextEditingController otpController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    checkRegistrationStatus();
    super.initState();
  }

  Future<void> checkRegistrationStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      bool isPhoneAuthUser = user.providerData.any((provider) => provider.providerId == 'phone');
      if (isPhoneAuthUser) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MapPage(pickupLatitude: double.infinity,pickupLongitude: double.infinity,)),
        );

      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RegisterPage()),
        );
      }
    }
  }

  Future<bool> registerUser(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('delivery').doc(userId).get();
      return snapshot.exists;
    } catch (error) {
      print('Error checking user registration: $error');
      return false;
    }
  }

  void verifyOtp(String otp) async {
    setState(() {
      isLoading = true;
    });
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationid,
        smsCode: otp,
      );

      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      bool isRegistered = await registerUser(userCredential.user!.uid);

      if (isRegistered) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MapPage(pickupLatitude: double.infinity, pickupLongitude: double.infinity)));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => RegisterPage()));
      }
    } catch (ex) {
      log(ex.toString());
    } finally {
      setState(() {
       isLoading = false;
      });
    }
  }

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
                  bottomLeft: Radius.circular(screenWidth * 0.08), // Rounded corners relative to screen width
                  bottomRight: Radius.circular(screenWidth * 0.08),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phonelink_lock,
                    size: screenWidth * 0.15, // Icon size relative to screen width
                    color: Colors.white,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    "OTP Verification",
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
                      "Enter the OTP sent to your mobile number",
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
                padding: EdgeInsets.all(screenWidth * 0.05), // Padding relative to screen width
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(screenWidth * 0.08), // Rounded corners relative to screen width
                    topRight: Radius.circular(screenWidth * 0.08),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      'Verify OTP',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05, // Font size relative to screen width
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    // Centering PinCodeTextField
                    Center(
                      child: PinCodeTextField(
                        appContext: context,
                        length: otpLength,
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        textStyle: TextStyle(
                          fontSize: screenWidth * 0.05, // Font size relative to screen width
                          fontWeight: FontWeight.bold,
                        ),
                        animationType: AnimationType.fade,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(screenWidth * 0.03), // Rounded corners relative to screen width
                          fieldHeight: screenHeight * 0.06, // Field height relative to screen height
                          fieldWidth: screenWidth * 0.12, // Field width relative to screen width
                          activeFillColor: Colors.white,
                          selectedFillColor: Colors.white,
                          inactiveFillColor: Colors.white,
                          activeColor: Colors.orange,
                          selectedColor: Colors.orange,
                          inactiveColor: Colors.grey,
                        ),
                        onChanged: (value) {
                          print(value);
                          if (value.length == otpLength) {
                            // Autofill OTP and submit
                            verifyOtp(value);
                          }
                        },
                        onCompleted: (value) async {
                          verifyOtp(value);
                        },
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Didn't receive an OTP? ",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          "Resend OTP",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:  () async {
                          verifyOtp(otpController.text.toString());
                        },
                        style: ElevatedButton.styleFrom (
                          padding: EdgeInsets.all(screenWidth * 0.04), // Button padding relative to screen width
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.03), // Rounded corners relative to screen width
                          ),
                        ),
                        child: isLoading
                            ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          backgroundColor: Colors.orange,
                        )
                            : Text(
                          "Submit",
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