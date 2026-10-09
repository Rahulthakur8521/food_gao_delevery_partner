import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../PhoneAuth/mapPage/mapPage.dart';
import '../AAdharVerify/AadharCardPage.dart';

class SubmitPanCard extends StatefulWidget {
  @override
  _SubmitPanCardState createState() => _SubmitPanCardState();
}

class _SubmitPanCardState extends State<SubmitPanCard> {
  final TextEditingController _panNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _adharNumberController = TextEditingController();
  String _errorMessage = '';
  String? _selectedGender;
  File? _imageFile;
  bool _isLoading = false;
  String? _panNumberError;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _panNumberController.dispose();
    _adharNumberController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _fatherNameController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _panNumberError = _validatePanNumber(_panNumberController.text);
    });
  }

  String? _validatePanNumber(String pan) {
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    if (!panRegex.hasMatch(pan)) {
      return 'Invalid PAN number';
    }
    return null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _dobController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
        _validateForm();
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _validateForm();
      });
    }
  }

  Future<void> _saveData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_panNumberError != null ||
          _panNumberController.text.isEmpty ||
          _adharNumberController.text.isEmpty ||
          _nameController.text.isEmpty ||
          _dobController.text.isEmpty ||
          _fatherNameController.text.isEmpty ||
          _selectedGender == null ||
          _imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please fill out all fields and upload an image."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      final User? user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("User is not logged in."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
      String userId = user.uid;

      DocumentReference documentRef = _firestore.collection('document').doc();
      String documentId = documentRef.id;

      await documentRef.set({
        'panId': documentId,
        'userId': userId,
        'pan_number': _panNumberController.text,
        'adhar_number':_adharNumberController.text,
        'name': _nameController.text,
        'dob': _dobController.text,
        'father_name': _fatherNameController.text,
        'gender': _selectedGender,
        'image_url': _imageFile != null ? _imageFile!.path : null,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Data saved successfully!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MapPage(pickupLatitude: 0.0, pickupLongitude: 0.0)),
      );
    } catch (e) {
      print('Error saving data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving data: $e"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: screenHeight * 1.1,
          color: Colors.white,
          child: Stack(
            children: [
              // Yellow container
              Container(
                width: double.infinity,
                height: screenHeight * 0.35,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(screenWidth * 0.08),
                    bottomRight: Radius.circular(screenWidth * 0.08),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _showImageSourceActionSheet(context);
                      },
                      child: _imageFile != null
                          ? CircleAvatar(
                        radius: screenWidth * 0.15,
                        backgroundImage: FileImage(_imageFile!),
                      )
                          : Icon(
                        Icons.add_a_photo,
                        size: screenWidth * 0.15,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      "Select pan card pic",
                      style: TextStyle(
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                  ],
                ),
              ),
              // White container overlapping the yellow container
              Positioned(
                top: screenHeight * 0.3,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(screenWidth * 0.08),
                      topRight: Radius.circular(screenWidth * 0.08),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _panNumberController,
                        decoration: InputDecoration(
                          labelText: 'PAN Number',
                          errorText: _panNumberError,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _panNumberError = _validatePanNumber(value);
                          });
                        },
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      TextField(
                        controller: _adharNumberController,
                        keyboardType: TextInputType.number,
                        maxLength: 14, // 12 digits + 2 spaces
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Enter Your Adhar number',
                          hintText: 'Enter Your 12-digit Aadhar number',
                          suffixIcon: _adharNumberController.text.isEmpty
                              ? null
                              : IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              _adharNumberController.clear();
                             // _updateMaskedAadhar('');
                            },
                          ),
                        ),
                        onChanged: (text) {
                         // _updateMaskedAadhar(text);
                          if (_errorMessage.isNotEmpty) {
                            setState(() {
                              _errorMessage = '';
                            });
                          }
                        },
                        inputFormatters: [AadharInputFormatter()],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'Name',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextField(
                            controller: _dobController,
                            decoration: InputDecoration(labelText: 'Date of Birth',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      TextField(
                        controller: _fatherNameController,
                        decoration: InputDecoration(labelText: 'Father\'s Name',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                            
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedGender = newValue;
                          });
                        },
                        items: ['Male', 'Female', 'Other']
                            .map((gender) => DropdownMenuItem(
                          child: Text(gender),
                          value: gender,
                        ))
                            .toList(),
                        decoration: InputDecoration(labelText: 'Gender',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                            
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      ElevatedButton(
                        onPressed: _saveData,
                        child: _isLoading
                            ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                            : Text('Submit',style: TextStyle(color: Colors.white),),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                          textStyle: TextStyle(fontSize: screenWidth * 0.045),
                          backgroundColor: Colors.orange
                        ),
                      ),
                      SizedBox(height: screenHeight * 4,)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('Pick from Gallery'),
            onTap: () {
              _pickImage(ImageSource.gallery);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Take a Picture'),
            onTap: () {
              _pickImage(ImageSource.camera);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
