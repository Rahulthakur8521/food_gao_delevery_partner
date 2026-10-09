import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_gao_delevery_partner/views/PhoneAuth/mapPage/mapPage.dart';
import 'Login.dart';

class SpleshPage extends StatefulWidget {
  const SpleshPage({super.key});


  @override
  State<SpleshPage> createState() => _SpleshPageState();
}


class _SpleshPageState extends State<SpleshPage> {
  @override
  void initState() {
    super.initState();
    // Check the authentication state and navigate accordingly
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      // Delay the navigation slightly to give time for the splash screen to be shown
      Timer(Duration(seconds: 2), () {
        if (user == null) {
          // If user is not authenticated, navigate to Phone Auth Page
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => LoginPage()));
        } else {
          // If user is authenticated, navigate to Home Page
          Navigator.pushReplacement(context,
              MaterialPageRoute(
                builder: (context) => MapPage(pickupLatitude: double.infinity, pickupLongitude: double.infinity),
              ));
        }
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange[700]!,
              Colors.orange[400]!,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Delivery person image
            Image.asset(
              'assets/images/image-removebg-preview.png', // Ensure you have this image in your assets folder
              height: 150,
            ),
            SizedBox(height: 20),
            // Title text
            Text(
              "FoodGao Delivery Partner",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            // Optional: Animated loading indicator at the bottom
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}