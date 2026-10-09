import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as path;

class SubmitAddressDocument extends StatefulWidget {
  const SubmitAddressDocument({super.key});

  @override
  State<SubmitAddressDocument> createState() => _SubmitAddressDocumentState();
}

class _SubmitAddressDocumentState extends State<SubmitAddressDocument> {
  File? _selectedImageFront;
  File? _selectedImageBack;
  bool _isFormValid = false;

  Future<void> _pickImage(String side) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      if (side == 'front') {
                        _selectedImageFront = File(image.path);
                      } else {
                        _selectedImageBack = File(image.path);
                      }
                      _validateForm();
                    });
                  }
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    setState(() {
                      if (side == 'front') {
                        _selectedImageFront = File(image.path);
                      } else {
                        _selectedImageBack = File(image.path);
                      }
                      _validateForm();
                    });
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _selectedImageFront != null && _selectedImageBack != null;
    });
  }

  Future<String> _uploadImageToStorage(File image) async {
    String fileName = path.basename(image.path);
    Reference storageRef = FirebaseStorage.instance.ref().child('licence/$fileName');
    UploadTask uploadTask = storageRef.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> _submitData() async {
    try {
      if (_selectedImageFront != null && _selectedImageBack != null) {
        // Upload images to Firebase Storage
        String frontImageUrl = await _uploadImageToStorage(_selectedImageFront!);
        String backImageUrl = await _uploadImageToStorage(_selectedImageBack!);

        // Add a new document to Firestore and capture the document reference
        DocumentReference docRef = await FirebaseFirestore.instance.collection('licence').add({
          'front_image_url': frontImageUrl,
          'back_image_url': backImageUrl,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Get the unique document ID
        String documentId = docRef.id;

        // Show a success message with the document ID
        Fluttertoast.showToast(
          msg: "Document ID $documentId submitted successfully.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      // Show an error message if submission fails
      Fluttertoast.showToast(
        msg: "Failed to submit data: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }



  void _showLogoutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'More options',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              const Divider(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.logout, color: Colors.orange),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                      const Text(
                        'Logout',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_forward),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Padding(
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.1),
                child: const Text(
                  'Your progress will be saved',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Submit Address Document'),
        actions: [
          PopupMenuButton<String>(
            color: Colors.white,
            onSelected: (value) {
              if (value == 'Logout') {
                _showLogoutBottomSheet(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Address proof',
                style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
              ),
              Text(
                'Photo of driving licence, voter ID or ration card',
                style: TextStyle(fontSize: screenWidth * 0.03),
              ),
              SizedBox(height: screenHeight * 0.02),
              Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Add Licence Photo',
                      style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold),
                    ),
                    Text('Front Photo',style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    DottedBorder(
                      color: Colors.orange,
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(5),
                      dashPattern: const [10, 6],
                      child: Container(
                        width: double.infinity,
                        height: screenHeight * 0.25,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (_selectedImageFront != null)
                              Positioned.fill(
                                child: AspectRatio(
                                  aspectRatio: 4 / 3,
                                  child: Image.file(_selectedImageFront!, fit: BoxFit.cover),
                                ),
                              )
                            else
                              GestureDetector(
                                onTap: () => _pickImage('front'),
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.orange),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Upload',
                                      style: TextStyle(color: Colors.orange, fontSize: screenWidth * 0.04),
                                    ),
                                  ),
                                ),
                              ),
                            if (_selectedImageFront != null)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  icon: Icon(Icons.close, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _selectedImageFront = null;
                                      _validateForm();
                                    });
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Text('Back Photo',style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    DottedBorder(
                      color: Colors.orange,
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(5),
                      dashPattern: const [10, 6],
                      child: Container(
                        width: double.infinity,
                        height: screenHeight * 0.25,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (_selectedImageBack != null)
                              Positioned.fill(
                                child: AspectRatio(
                                  aspectRatio: 4 / 3,
                                  child: Image.file(_selectedImageBack!, fit: BoxFit.cover),
                                ),
                              )
                            else
                              GestureDetector(
                                onTap: () => _pickImage('back'),
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.orange),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Upload',
                                      style: TextStyle(color: Colors.orange, fontSize: screenWidth * 0.04),
                                    ),
                                  ),
                                ),
                              ),
                            if (_selectedImageBack != null)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  icon: Icon(Icons.close, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _selectedImageBack = null;
                                      _validateForm();
                                    });
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.05),
              SizedBox(
                height: screenHeight * 0.06,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: _isFormValid ? _submitData : null,
                  child: Text(
                    'Next',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
