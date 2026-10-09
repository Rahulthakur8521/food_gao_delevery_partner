
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'Profile.dart';

class EditProfile extends StatefulWidget {
  final String initialName;
  final String initialage;
  final String initialgender;
  final String initialaddress;
  final String initialImageUrl;

  const EditProfile({
    Key? key,
    required this.initialName,
    required this.initialage,
    required this.initialgender,
    required this.initialaddress,
    required this.initialImageUrl,
  }) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController genderController;
  late TextEditingController addressController;
  PickedFile? _image;
  String? _selectedGender;
  bool _isLoading = false; // Loading flag

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialName);
    ageController = TextEditingController(text: widget.initialage);
    genderController = TextEditingController(text: widget.initialgender);
    addressController = TextEditingController(text: widget.initialaddress);
  }

  @override
  Widget build(BuildContext context) {

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(screenHeight * 0.02),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(screenHeight * 0.05),
                  bottomRight: Radius.circular(screenHeight * 0.05),
                ),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  leading: Icon(Icons.photo_library, size: screenHeight * 0.03),
                                  title: Text('Choose from gallery', style: TextStyle(fontSize: screenHeight * 0.025)),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickImageFromGallery();
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.photo_camera, size: screenHeight * 0.03),
                                  title: Text('Take a picture', style: TextStyle(fontSize: screenHeight * 0.025)),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickImageFromCamera();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: screenHeight * 0.1,
                          backgroundImage: _image != null
                              ? FileImage(File(_image!.path)) as ImageProvider<Object>
                              : NetworkImage(widget.initialImageUrl),
                        ),
                        if (_image == null)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Icon(
                              Icons.add_a_photo,
                              size: screenHeight * 0.05,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: screenHeight * 0.03,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(fontSize: screenHeight * 0.025),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenHeight * 0.01),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: TextField(
                controller: ageController,
                decoration: InputDecoration(
                  labelText: 'Age',
                  labelStyle: TextStyle(fontSize: screenHeight * 0.025),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenHeight * 0.01),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: DropdownButtonFormField<String>(
                value: _selectedGender,
                items: ['Male', 'Female', 'Other']
                    .map((label) => DropdownMenuItem(
                  child: Text(label),
                  value: label,
                ))
                    .toList(),
                decoration: InputDecoration(
                  labelText: 'Gender',
                  labelStyle: TextStyle(fontSize: screenHeight * 0.025),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenHeight * 0.01),
                  ),
                ),
                onChanged: (String? value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  labelStyle: TextStyle(fontSize: screenHeight * 0.025),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenHeight * 0.01),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            ElevatedButton(
              onPressed:  _updateProfile,
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                'Update',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenHeight * 0.025,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(screenWidth * 0.8, screenHeight * 0.06),
                backgroundColor: Color(0xFFFFA500),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenHeight * 0.01),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true; // Start loading
    });
    if (nameController.text.isEmpty ||
        ageController.text.isEmpty ||
        _selectedGender == null ||
        addressController.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all the fields.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false; // Stop loading
      });
      return; // Stop further execution
    }

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        String imageUrl = widget.initialImageUrl;

        if (_image != null) {
          imageUrl = await _updateImageInFirebaseStorage(_image!.path);
        }

        await FirebaseFirestore.instance.collection('delivery').doc(user.uid).update({
          'name': nameController.text,
          'age': ageController.text,
          'gender': _selectedGender,
          'address': addressController.text,
          'imageUrl': imageUrl,
        });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
      } catch (error) {
        print('Error updating user data: $error');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = PickedFile(pickedFile.path);
      }
    });
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = PickedFile(pickedFile.path);
      }
    });
  }

  Future<String> _updateImageInFirebaseStorage(String newFilePath) async {
    try {
      final File newImageFile = File(newFilePath);
      final Reference storageRef = FirebaseStorage.instance.ref();

      await FirebaseStorage.instance.refFromURL(widget.initialImageUrl).delete();

      final Reference imageRef = storageRef.child('usersimages/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await imageRef.putFile(newImageFile);

      final String newImageUrl = await imageRef.getDownloadURL();
      print('Updated image URL: $newImageUrl');

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('delivery').doc(user.uid).update({'imageUrl': newImageUrl});
      }

      return newImageUrl;
    } catch (e) {
      print('Error updating image in Firebase Storage: $e');
      return '';
    }
  }
}

