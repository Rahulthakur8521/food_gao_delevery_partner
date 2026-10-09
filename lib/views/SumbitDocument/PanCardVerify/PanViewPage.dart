
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewPanCard extends StatefulWidget {
  final String documentId; // Document ID for the PAN card

  ViewPanCard({required this.documentId});

  @override
  _ViewPanCardState createState() => _ViewPanCardState();
}

class _ViewPanCardState extends State<ViewPanCard> {
  late TextEditingController _panNumberController;
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _fatherNameController;
  late TextEditingController _genderController;
  String? _imageUrl; // To store the image URL

  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _panNumberController = TextEditingController();
    _nameController = TextEditingController();
    _dobController = TextEditingController();
    _fatherNameController = TextEditingController();
    _genderController = TextEditingController();

    // Fetch the PAN card data from Firestore
    _fetchPanCardData();
  }

  Future<void> _fetchPanCardData() async {
    try {
      // Fetch the document from Firestore using the document ID
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('pan_cards')
          .doc(widget.documentId)
          .get();

      if (documentSnapshot.exists) {
        // Retrieve the data and update the controllers
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        _panNumberController.text = data['pan_number'];
        _nameController.text = data['name'];
        _dobController.text = data['dob'];
        _fatherNameController.text = data['father_name'];
        _genderController.text = data['gender'];
        _imageUrl = data['image_url'];

        setState(() {
          _isLoading = false;
        });
      } else {
        // Handle case when document does not exist
        print('Document does not exist');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching PAN card data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _panNumberController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _fatherNameController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Pan Card'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator while data is being fetched
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _imageUrl != null && _imageUrl!.isNotEmpty
                  ? Image.file(
                File(_imageUrl!), // Assuming the image is stored locally
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              )
                  : Container(),
              SizedBox(height: 20),
              TextField(
                controller: _panNumberController,
                decoration: InputDecoration(
                  labelText: 'PAN Number',
                  labelStyle: TextStyle(color: Colors.orange, fontSize: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                enabled: false,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name on PAN card',
                  labelStyle: TextStyle(color: Colors.orange, fontSize: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                enabled: false,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _dobController,
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  labelStyle: TextStyle(color: Colors.orange, fontSize: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                enabled: false,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _fatherNameController,
                decoration: InputDecoration(
                  labelText: 'Father\'s Name',
                  labelStyle: TextStyle(color: Colors.orange, fontSize: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                enabled: false,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _genderController,
                decoration: InputDecoration(
                  labelText: 'Gender',
                  labelStyle: TextStyle(color: Colors.orange, fontSize: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                enabled: false,
              ),
              SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}