import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:food_gao_delevery_partner/views/SumbitDocument/SumbitPage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'Motocycle_view_Page.dart';

class MotocycleScooty extends StatefulWidget {
  const MotocycleScooty({super.key});

  @override
  State<MotocycleScooty> createState() => _MotocycleScootyState();
}

class _MotocycleScootyState extends State<MotocycleScooty> {
  String? _selectedVehicleType;
  String? _selectedOwnershipType;
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
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

  Future<String> _uploadImageToStorage(File image) async {
    String fileName = path.basename(image.path);
    Reference storageRef = FirebaseStorage.instance.ref().child('motorcycle/$fileName');
    UploadTask uploadTask = storageRef.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> _submitData() async {
    if (_selectedVehicleType == null || _selectedOwnershipType == null || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please complete all fields before submitting."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      String imageUrl = await _uploadImageToStorage(_selectedImage!);

      DocumentReference docRef = await FirebaseFirestore.instance.collection('motorcycle').add({
        'vehicle_type': _selectedVehicleType,
        'ownership_type': _selectedOwnershipType,
        'image_url': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
      String documentId = docRef.id;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Document ID $documentId submitted successfully."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubmitDocumentPage()
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to submit data: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
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
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Icon(Icons.logout, color: Colors.orange),
                      ),
                      const SizedBox(width: 20),
                      const Text(
                        'Logout',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 30),
                    child: Icon(Icons.arrow_forward),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(left: 55),
                child: Text('Your progress will be saved', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(height: 50),
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
            itemBuilder: (context) => const [
              PopupMenuItem(
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
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vehicle type',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
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
                            });
                          },
                        ),
                        const Text(
                          'Without number plate',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Text(
                      'Ownership type',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'Owned',
                          groupValue: _selectedOwnershipType,
                          onChanged: (value) {
                            setState(() {
                              _selectedOwnershipType = value;
                            });
                          },
                        ),
                        const Text(
                          'Owned',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'Rented',
                          groupValue: _selectedOwnershipType,
                          onChanged: (value) {
                            setState(() {
                              _selectedOwnershipType = value;
                            });
                          },
                        ),
                        const Text(
                          'Rented',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    const Text(
                      'Upload a valid motorcycle proof',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    const Text(
                      'Invoice or receipt of vehicle purchase/rent',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    GestureDetector(
                      onTap: () {
                        _showImageSourceActionSheet(context);
                      },
                      child: Center(
                        child: DottedBorder(
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(10),
                          dashPattern: const [5, 5],
                          color: Colors.orange,
                          strokeWidth: 2,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(12)),
                            child: Container(
                              width: screenWidth * 0.7,
                              height: screenHeight * 0.3,
                              color: Colors.orange[50],
                              child: _selectedImage != null
                                  ? Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              )
                                  : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    color: Colors.orange,
                                    size: screenWidth * 0.1,
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                  Text(
                                    'Upload Image',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    Center(
                      child: SizedBox(
                        width: screenWidth * 0.7,
                        height: screenHeight * 0.06,
                        child: ElevatedButton(
                          onPressed: _submitData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            'Submit',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
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
