import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:food_gao_delevery_partner/views/SumbitDocument/SumbitPage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  String? _selectedVehicleType;
  String? _selectedOwnershipType;
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  bool _isLoading = false;

  void _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_selectedVehicleType != null &&
        _selectedOwnershipType != null &&
        _imageFile != null) {
      setState(() {
        _isLoading = true; // Start loading
      });
      try {
        // Upload the image to Firebase Storage
        String fileName = _imageFile!.name;
        Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('vehicle_images/$fileName');
        UploadTask uploadTask = firebaseStorageRef.putFile(File(_imageFile!.path));
        TaskSnapshot taskSnapshot = await uploadTask;
        String imageUrl = await taskSnapshot.ref.getDownloadURL();

        // Store the data in Firestore
        await FirebaseFirestore.instance.collection('vehicles').add({
          'vehicle_type': _selectedVehicleType,
          'ownership_type': _selectedOwnershipType,
          'image_url': imageUrl,
          'timestamp': FieldValue.serverTimestamp(),
        });

        Fluttertoast.showToast(
          msg: "Success",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
        );

        // Navigate to SubmitDocumentPage
        Navigator.push(context, MaterialPageRoute(builder: (context) => SubmitDocumentPage(),));
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Error: $e",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } finally {
        setState(() {
          _isLoading = false; // Stop loading
        });
      }
    } else {
      Fluttertoast.showToast(
        msg: "Please select vehicle type, ownership type, and upload an image",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "EV Documents",
          style: TextStyle(fontSize: 19, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                ),
                builder: (BuildContext context) {
                  return Container(
                    height: 200,
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Options',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Divider(),
                        Expanded(
                          child: ListView(
                            children: [
                              ListTile(
                                leading: Icon(Icons.logout, color: Colors.orange),
                                title: Text('Logout'),
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                              Divider(),
                              ListTile(
                                leading: Icon(Icons.cancel, color: Colors.grey),
                                title: Text('Cancel'),
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Card(
                elevation: 10,
                margin: const EdgeInsets.all(10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Share Vehicle Details",
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                      ),
                      Divider(),
                      SizedBox(height: 20),
                      Text("Vehicle Type", style: TextStyle(fontSize: 19)),
                      ListTile(
                        title: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Radio<String>(
                              value: 'With_number_plate',
                              groupValue: _selectedVehicleType,
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedVehicleType = value;
                                });
                              },
                            ),
                            Text(
                              'With number plate',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 0),
                      ),
                      ListTile(
                        title: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Radio<String>(
                              value: 'Without_number_plate',
                              groupValue: _selectedVehicleType,
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedVehicleType = value;
                                });
                              },
                            ),
                            Text(
                              'Without number plate',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 0),
                      ),
                      SizedBox(height: 20),
                      Text("Ownership Type", style: TextStyle(fontSize: 19)),
                      Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Radio<String>(
                                    value: 'Owned',
                                    groupValue: _selectedOwnershipType,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _selectedOwnershipType = value;
                                      });
                                    },
                                  ),
                                  SizedBox(width: 4),
                                  Text('Owned', style: TextStyle(fontSize: 14)),
                                ],
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 0),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              title: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Radio<String>(
                                    value: 'Rented',
                                    groupValue: _selectedOwnershipType,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _selectedOwnershipType = value;
                                      });
                                    },
                                  ),
                                  SizedBox(width: 4),
                                  Text('Rented', style: TextStyle(fontSize: 14)),
                                ],
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 0),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text("Upload a Valid EV Proof",
                          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                            "Invoice or receipt of vehicle purchase/rent",
                            style: TextStyle(fontSize: 16)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: DottedBorder(
                          borderType: BorderType.RRect,
                          radius: Radius.circular(12),
                          dashPattern: [8, 4],
                          color: Colors.orange,
                          strokeWidth: 2,
                          child: Stack(
                            children: [
                              Card(
                                elevation: 10,
                                color: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Center(
                                        child: Text(
                                          "Invoice/Rent Receipt",
                                          style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ),
                                      Center(
                                        child: Text(
                                          "Front Image Only",
                                          style: TextStyle(
                                              fontSize: 18, color: Colors.white70),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: double.infinity,
                                          height: 150,
                                          color: Colors.grey[200],
                                          child: _imageFile == null
                                              ? Center(
                                            child: Text(
                                              'No image selected',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          )
                                              : Image.file(
                                            File(_imageFile!.path),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: _pickImage,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          minimumSize: Size(double.infinity, 50),
                                        ),
                                        child: Text("Pick Image"),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(
                          color: Colors.white,
                        )
                            : Text("Submit"),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
