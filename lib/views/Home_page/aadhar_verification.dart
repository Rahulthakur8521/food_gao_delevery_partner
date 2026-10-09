import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'aadhaar_verification.dart'; // Import the Aadhaar verification page

class AadharVerification extends StatefulWidget {
  const AadharVerification({super.key});

  @override
  State<AadharVerification> createState() => _AadharVerificationState();
}

class _AadharVerificationState extends State<AadharVerification> {
  bool _isSelected = false;
  final TextEditingController _aadharController = TextEditingController();
  bool _isAadharValid = false;
  String _errorMessage = '';

  void _toggleSelection() {
    setState(() {
      _isSelected = !_isSelected;
    });
  }

  void _updateMaskedAadhar(String text) {
    String cleanedText = text.replaceAll(' ', '');
    String maskedAadhar;
    if (cleanedText.length > 4) {
      maskedAadhar = '*' * (cleanedText.length - 4) + cleanedText.substring(cleanedText.length - 4);
    } else {
      maskedAadhar = cleanedText;
    }
    maskedAadhar = _formatWithSpaces(maskedAadhar);
    final cursorPosition = _aadharController.selection;

    _aadharController.value = TextEditingValue(
      text: maskedAadhar,
      selection: cursorPosition,
    );
    setState(() {
      _isAadharValid = cleanedText.length == 12;
    });
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
        // Handle OTP sent scenario
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
    if (_isAadharValid) {
      try {
        String? linkedMobileNumber = await getLinkedMobileNumber(_aadharController.text);

        if (linkedMobileNumber != null) {
          DocumentReference documentRef = FirebaseFirestore.instance.collection('aadhar_numbers').doc();

          await documentRef.set({
            'id': documentRef.id,
            'aadhar_number': _aadharController.text,
            'timestamp': FieldValue.serverTimestamp(),
          });

          // Send OTP to the linked mobile number
          await sendOtpToMobile(linkedMobileNumber);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AadhaarVerification(aadhaarNumber: _aadharController.text),
            ),
          );
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Aadhar Verification'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            children: [
              Center(
                child: GestureDetector(
                  onTap: _toggleSelection,
                  child: CircleAvatar(
                    radius: screenWidth * 0.25,
                    backgroundColor: _isSelected ? Colors.blue : Colors.grey,
                    child: CircleAvatar(
                      radius: screenWidth * 0.25,
                      backgroundImage: NetworkImage(
                          "https://5.imimg.com/data5/SELLER/Default/2022/9/ZK/CB/SF/4910836/aadhar-card-software-500x500.png"),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Text(
                "Enter Aadhar details for verification",
                style: TextStyle(fontSize: screenWidth * 0.045),
              ),
              SizedBox(height: screenHeight * 0.04),
              Text(
                'Aadhar number',
                style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.orangeAccent),
              ),
              SizedBox(height: screenHeight * 0.01),
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
                  padding: EdgeInsets.only(top: screenHeight * 0.01),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: screenHeight * 0.02),
              Padding(
                padding: EdgeInsets.only(right: screenWidth * 0.2),
                child: Text(
                  'Aadhar ID should be linked to your mobile number',
                  style: TextStyle(color: Colors.orange, fontSize: screenWidth * 0.030),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              SizedBox(
                height: screenHeight * 0.06,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    backgroundColor: _isAadharValid ? Colors.orange : Colors.grey,
                  ),
                  onPressed: _isAadharValid ? _navigateToNextPage : null,
                  child: Text(
                    'Submit',
                    style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.045),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.1),
              Text(
                '''Zomato does not collect or store any Aadhaar information. We assure Real-time ID verification & 100% security with 256 bit encryption. By clicking on Proceed, you consent to sharing your Aadhaar details with Surepass for offline verification purposes and agree to the''',
                style: TextStyle(fontSize: screenWidth * 0.03),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                '"term and conditions"',
                style: TextStyle(color: Colors.orange, fontSize: screenWidth * 0.035),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AadharInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    final newText = text.replaceAll(' ', '');
    String formatted = '';

    for (int i = 0; i < newText.length; i++) {
      formatted += newText[i];
      if ((i + 1) % 4 == 0 && i + 1 != newText.length) {
        formatted += ' ';
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: newValue.selection.copyWith(
        baseOffset: formatted.length,
        extentOffset: formatted.length,
      ),
    );
  }
}
