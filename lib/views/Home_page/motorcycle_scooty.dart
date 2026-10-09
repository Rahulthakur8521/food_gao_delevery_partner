import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class MotocycleScooty extends StatefulWidget {
  const MotocycleScooty({super.key});

  @override
  State<MotocycleScooty> createState() => _MotocycleScootyState();
}

class _MotocycleScootyState extends State<MotocycleScooty> {
  String? _selectedVehicleType;
  String? _selectedOwnershipType;
  File? _selectedImage;
  bool _isFormValid = false;

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _validateForm();
      });
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
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
      _isFormValid = _selectedVehicleType != null &&
          _selectedOwnershipType != null &&
          _selectedImage != null;
    });
  }

  Future<String> _uploadImageToStorage(File image) async {
    String fileName = path.basename(image.path);
    Reference storageRef = FirebaseStorage.instance.ref().child('motorcycle/$fileName');
    UploadTask uploadTask = storageRef.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> _submitData() async {
    try {
      if (_selectedVehicleType != null &&
          _selectedOwnershipType != null &&
          _selectedImage != null) {
        String imageUrl = await _uploadImageToStorage(_selectedImage!);

        DocumentReference docRef = await FirebaseFirestore.instance.collection('motorcycle').add({
          'vehicle_type': _selectedVehicleType,
          'ownership_type': _selectedOwnershipType,
          'image_url': imageUrl,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Get the unique document ID
        String documentId = docRef.id;

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Document ID $documentId submitted successfully."),
            backgroundColor: Colors.green,
          ),
        );

        // Optionally, navigate to another page or reset the form
        // Navigator.pushNamed(context, '/nextPage', arguments: documentId);
        // or
        // setState(() {
        //   _selectedVehicleType = null;
        //   _selectedOwnershipType = null;
        //   _selectedImage = null;
        //   _isFormValid = false;
        // });
      }
    } catch (e) {
      // Show an error message if submission fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to submit data: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showLogoutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                title: const Text('More options', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: const Icon(Icons.logout, color: Colors.orange),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: SizedBox(height: 20),
                      ),
                      const Text(
                        'Logout',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 30),
                    child: Icon(Icons.arrow_forward),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 55),
                child: Text('Your progress will be saved', style: TextStyle(fontSize: 12)),
              ),
              SizedBox(height: 50),
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
        title: const Text('Motocycle Scooty'),
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
                'Share Vehicle Details',
                style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: screenHeight * 0.0),
              Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vehicle type',
                      style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'With number plate',
                          groupValue: _selectedVehicleType,
                          onChanged: (value) {
                            setState(() {
                              _selectedVehicleType = value;
                              _validateForm();
                            });
                          },
                        ),
                        const Text(
                          'With number plate',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'Without number plate',
                          groupValue: _selectedVehicleType,
                          onChanged: (value) {
                            setState(() {
                              _selectedVehicleType = value;
                              _validateForm();
                            });
                          },
                        ),
                        const Text(
                          'Without number plate',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Ownership type',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Radio<String>(
                              value: 'Owned',
                              groupValue: _selectedOwnershipType,
                              onChanged: (value) {
                                setState(() {
                                  _selectedOwnershipType = value;
                                  _validateForm();
                                });
                              },
                            ),
                            const Text(
                              'Owned',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 150),
                          child: Row(
                            children: [
                              Radio<String>(
                                value: 'Rented',
                                groupValue: _selectedOwnershipType,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedOwnershipType = value;
                                    _validateForm();
                                  });
                                },
                              ),
                              const Text(
                                'Rented',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 37),
                    const Text(
                      'Upload a valid motorcycle proof',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Invoice or receipt of vehicle purchase/rent',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    GestureDetector(
                      onTap: () => _showImageSourceActionSheet(context),
                      child: DottedBorder(
                        color: Colors.orange,
                        strokeWidth: 4,
                        dashPattern: [8, 8],
                        borderType: BorderType.RRect,
                        radius: Radius.circular(5),
                        padding: EdgeInsets.all(screenWidth * 0.01),
                        child: Center(
                          child: _selectedImage != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.file(
                              _selectedImage!,
                              width: screenWidth * 20,
                              height: screenHeight * 0.3,
                              fit: BoxFit.cover,
                            ),
                          )
                              : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined,
                                  color: Colors.black, size: screenWidth * 0.10),
                              SizedBox(height: screenHeight * 0.03),
                              const Text(
                                'Upload image of motorcycle proof',
                                style: TextStyle(color: Colors.orange),
                              ),
                            ],
                          ),
                        ),
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
                        child: const Text(
                          'Submit',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
