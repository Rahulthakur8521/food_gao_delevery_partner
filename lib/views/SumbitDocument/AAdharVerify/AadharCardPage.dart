import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AadharVerification extends StatefulWidget {
  @override
  _AadharVerificationState createState() => _AadharVerificationState();
}

class _AadharVerificationState extends State<AadharVerification> {
  bool _isSelected = false;
  final TextEditingController _aadharController = TextEditingController();
  bool _isLogging = false; // New variable to track submission status
  String _errorMessage = '';

  void _toggleSelection() {
    setState(() {
      _isSelected = !_isSelected;
    });
  }

  void _updateMaskedAadhar(String text) {
    String cleanedText = text.replaceAll(' ', '');
    String maskedAadhar;

  }

  String _formatWithSpaces(String text) {
    text = text.replaceAll(' ', '');
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      int index = i + 1;
      if (index % 4 == 0 && index != text.length) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  @override
  void dispose() {
    _aadharController.dispose();
    super.dispose();
  }

  Future<String?> getLinkedMobileNumber(String aadhaarNumber) async {
    return "9876543210";
  }

  Future<void> sendOtpToMobile(String mobileNumber) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91$mobileNumber',
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        print("Failed to send OTP: ${e.message}");
        Fluttertoast.showToast(
          msg: "Failed to send OTP: ${e.message}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        print("OTP sent to $mobileNumber");
        Fluttertoast.showToast(
          msg: "OTP sent to $mobileNumber",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void _navigateToNextPage() async {
    setState(() {
      _isLogging = true; // Start the loading
    });

    try {
      String? linkedMobileNumber = await getLinkedMobileNumber(_aadharController.text);

      if (linkedMobileNumber != null) {
        DocumentReference documentRef = FirebaseFirestore.instance.collection('delivery').doc();

        await documentRef.set({
          'aadhar_number': _aadharController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });

        await sendOtpToMobile(linkedMobileNumber);
      } else {
        Fluttertoast.showToast(
          msg: "No mobile number linked with this Aadhaar!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      print('Error storing Aadhaar number: $e');
      Fluttertoast.showToast(
        msg: "Error processing request!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      setState(() {
        _isLogging = false; // Stop the loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aadhar Verification'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: GestureDetector(
                onTap: _toggleSelection,
                child: CircleAvatar(
                  radius: 100,
                  backgroundColor: _isSelected ? Colors.orange : Colors.grey,
                  child: CircleAvatar(
                    radius: 100,
                    backgroundImage: NetworkImage(
                        "https://5.imimg.com/data5/SELLER/Default/2022/9/ZK/CB/SF/4910836/aadhar-card-software-500x500.png"),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: SizedBox(height: 12),
            ),
            Text("Enter Aadhar details for verification"),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aadhar number',
                    style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _aadharController,
                    keyboardType: TextInputType.number,
                    maxLength: 14, // 12 digits + 2 spaces
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter Your 12-digit Aadhar number',
                      suffixIcon: _aadharController.text.isEmpty
                          ? null
                          : IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          _aadharController.clear();
                          _updateMaskedAadhar('');
                        },
                      ),
                    ),
                    onChanged: (text) {
                      _updateMaskedAadhar(text);
                      if (_errorMessage.isNotEmpty) {
                        setState(() {
                          _errorMessage = '';
                        });
                      }
                    },
                    inputFormatters: [AadharInputFormatter()],
                  ),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text('Aadhar ID should be linked to your mobile number'),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    backgroundColor: _isLogging ? Colors.white : Colors.grey, // Control button color
                  ),
                  onPressed: _navigateToNextPage, // Disable when logging
                  child: _isLogging
                      ? CircularProgressIndicator(color: Colors.white) // Show progress
                      : Text('Submit', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
            ),
            Text("or", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                '''FoodGao does not collect or store any Aadhaar information. We assure Real-time ID verification & 100% security with 256 bit encryption. By clicking on Proceed, you consent to sharing your Aadhaar details with Surepass for offline verification purposes and agree to the.''',
                style: TextStyle(fontSize: 11),
              ),
            ),
            SizedBox(height: 5),
            Text(
              '"Term and conditions"',
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
      ),
    );
  }
}

// Formatter for Aadhar number input
class AadharInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll(' ', '');

    if (newText.length > 12) {
      newText = newText.substring(0, 12);
    }

    String formattedText = '';
    for (int i = 0; i < newText.length; i++) {
      formattedText += newText[i];
      if ((i + 1) % 4 == 0 && i != newText.length - 1) {
        formattedText += ' ';
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
