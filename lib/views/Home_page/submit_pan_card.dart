import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_gao_delevery_partner/views/SumbitDocument/PanCardVerify/PanViewPage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart'; // Make sure to import the viewPanCardPage

class SubmitPanCard extends StatefulWidget {
  const SubmitPanCard({super.key});

  @override
  _SubmitPanCardState createState() => _SubmitPanCardState();
}

class _SubmitPanCardState extends State<SubmitPanCard> {
  final TextEditingController _panNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  String? _selectedGender;
  File? _imageFile;
  bool _isFormValid = false;
  String? _panNumberError;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _panNumberController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _fatherNameController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _panNumberError = _validatePanNumber(_panNumberController.text);
      _isFormValid = _panNumberError == null &&
          _nameController.text.isNotEmpty &&
          _dobController.text.isNotEmpty &&
          _fatherNameController.text.isNotEmpty &&
          _selectedGender != null &&
          _imageFile != null;
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

  Future<void> _launchCaller() async {
    const url = "tel:1234567890";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _saveData() async {
    try {
      // Generate a unique ID for the document
      DocumentReference documentRef = _firestore.collection('pan_cards').doc();
      String documentId = documentRef.id;

      await documentRef.set({
        'id': documentId,
        'pan_number': _panNumberController.text,
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

    } catch (e) {
      print('Error saving data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving data: $e"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: screenHeight,
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
                      Icons.person_add,
                      size: screenWidth * 0.15,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    "PanCard Details",
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
                        labelText: 'PAN number',
                        hintText: 'Enter pan no',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        ),
                        errorText: _panNumberError,
                      ),
                      inputFormatters: [LengthLimitingTextInputFormatter(10)],
                      onChanged: (value) => _validateForm(),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name on PAN card',
                        hintText: 'Enter pan card name',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        ),
                      ),
                      onChanged: (value) => _validateForm(),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    TextField(
                      controller: _dobController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Date of Birth',
                        hintText: 'Enter date of birth',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        ),
                        suffixIcon: Icon(Icons.calendar_today, color: Colors.orange),
                      ),
                      onTap: () => _selectDate(context),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: InputDecoration(
                        labelText: 'Select Gender',
                        hintText: 'Enter gender',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        ),
                      ),
                      items: <String>['Male', 'Female', 'Other']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGender = newValue;
                          _validateForm();
                        });
                      },
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    TextField(
                      controller: _fatherNameController,
                      decoration: InputDecoration(
                        labelText: "Father's name",
                        hintText: "Enter father's name",
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        ),
                      ),
                      onChanged: (value) => _validateForm(),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Padding(
                      padding: EdgeInsets.only(top: screenHeight * 0.02),
                      child: ElevatedButton(
                        onPressed: _isFormValid ? _saveData : null,
                        child: Text('Save'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                          textStyle: TextStyle(fontSize: screenWidth * 0.05),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a Photo'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.close),
                title: Text('Cancel'),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
