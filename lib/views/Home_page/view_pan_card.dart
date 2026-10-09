import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ViewPanCard extends StatefulWidget {
  String panNumber;
  String name;
  String dob;
  String fatherName;
  String gender;
  String imageUrl;

  ViewPanCard({
    required this.panNumber,
    required this.name,
    required this.dob,
    required this.fatherName,
    required this.gender,
    required this.imageUrl,
  });

  @override
  _ViewPanCardState createState() => _ViewPanCardState();
}

class _ViewPanCardState extends State<ViewPanCard> {
  late TextEditingController _panNumberController;
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _fatherNameController;
  late String _selectedGender;
  late String _imageUrl;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _panNumberController = TextEditingController(text: widget.panNumber);
    _nameController = TextEditingController(text: widget.name);
    _dobController = TextEditingController(text: widget.dob);
    _fatherNameController = TextEditingController(text: widget.fatherName);
    _selectedGender = widget.gender;
    _imageUrl = widget.imageUrl;
  }

  @override
  void dispose() {
    _panNumberController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _fatherNameController.dispose();
    super.dispose();
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
      });
      Navigator.of(context).pop(); // Close the dialog
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageUrl = pickedFile.path;
      });
    }
  }

  // void _showEditDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(
  //         builder: (BuildContext context, StateSetter setState) {
  //           return AlertDialog(
  //             title: Text('Edit PAN Card Details'),
  //             content: SingleChildScrollView(
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   GestureDetector(
  //                     onTap: () async {
  //                       final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  //                       if (pickedFile != null) {
  //                         setState(() {
  //                           _imageUrl = pickedFile.path;
  //                         });
  //                       }
  //                     },
  //                     child: _imageUrl.isNotEmpty
  //                         ? Image.file(
  //                       File(_imageUrl),
  //                       width: 100,
  //                       height: 100,
  //                       fit: BoxFit.cover,
  //                     )
  //                         : Container(
  //                       width: 100,
  //                       height: 100,
  //                       color: Colors.grey[300],
  //                       child: Icon(
  //                         Icons.camera_alt,
  //                         color: Colors.grey[100],
  //                       ),
  //                     ),
  //                   ),
  //                   SizedBox(height: 20),
  //                   TextField(
  //                     controller: _panNumberController,
  //                     decoration: InputDecoration(
  //                       labelText: 'PAN Number',
  //                       labelStyle: TextStyle(color: Colors.orange),
  //                       border: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(5),
  //                       ),
  //                     ),
  //                   ),
  //                   SizedBox(height: 20),
  //                   TextField(
  //                     controller: _nameController,
  //                     decoration: InputDecoration(
  //                       labelText: 'Name on PAN card',
  //                       labelStyle: TextStyle(color: Colors.orange),
  //                       border: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(5),
  //                       ),
  //                     ),
  //                   ),
  //                   SizedBox(height: 20),
  //                   TextField(
  //                     controller: _dobController,
  //                     readOnly: true,
  //                     decoration: InputDecoration(
  //                       labelText: 'Date of Birth',
  //                       labelStyle: TextStyle(color: Colors.orange),
  //                       border: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(5),
  //                       ),
  //                       suffixIcon: IconButton(
  //                         icon: Icon(
  //                           Icons.calendar_today,
  //                           color: Colors.orange,
  //                         ),
  //                         onPressed: () => _selectDate(context),
  //                       ),
  //                     ),
  //                   ),
  //                   SizedBox(height: 20),
  //                   TextField(
  //                     controller: _fatherNameController,
  //                     decoration: InputDecoration(
  //                       labelText: 'Father\'s Name',
  //                       labelStyle: TextStyle(color: Colors.orange),
  //                       border: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(5),
  //                       ),
  //                     ),
  //                   ),
  //                   SizedBox(height: 20),
  //                   DropdownButtonFormField<String>(
  //                     value: _selectedGender,
  //                     items: ['Male', 'Female', 'Other']
  //                         .map((label) => DropdownMenuItem(
  //                       child: Text(label),
  //                       value: label,
  //                     ))
  //                         .toList(),
  //                     onChanged: (value) {
  //                       setState(() {
  //                         _selectedGender = value!;
  //                       });
  //                     },
  //                     decoration: InputDecoration(
  //                       labelText: 'Gender',
  //                       labelStyle: TextStyle(color: Colors.orange),
  //                       border: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(5),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             actions: [
  //               TextButton(
  //                 child: Text('Cancel'),
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //               ),
  //               ElevatedButton(
  //                 child: Text('Update'),
  //                 onPressed: () {
  //                   Navigator.of(context).pop({
  //                     'panNumber': _panNumberController.text,
  //                     'name': _nameController.text,
  //                     'dob': _dobController.text,
  //                     'fatherName': _fatherNameController.text,
  //                     'gender': _selectedGender,
  //                     'imageUrl': _imageUrl,
  //                   });
  //                 },
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   ).then((result) {
  //     if (result != null) {
  //       setState(() {
  //         widget.panNumber = result['panNumber'];
  //         widget.name = result['name'];
  //         widget.dob = result['dob'];
  //         widget.fatherName = result['fatherName'];
  //         widget.gender = result['gender'];
  //         widget.imageUrl = result['imageUrl'];
  //       });
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Pan Card'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _imageUrl.isNotEmpty
                  ? Image.file(
                File(_imageUrl),
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
              ),
              SizedBox(height: 20),
              TextField(
                controller: _dobController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  labelStyle: TextStyle(color: Colors.orange, fontSize: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.calendar_today,
                      color: Colors.orange,
                    ),
                    onPressed: () => _selectDate(context),
                  ),
                ),
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
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: ['Male', 'Female', 'Other']
                    .map((label) => DropdownMenuItem(
                  child: Text(label),
                  value: label,
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Gender',
                  labelStyle: TextStyle(color: Colors.orange, fontSize: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              SizedBox(height: 25),

              // SizedBox(
              //   height: 55,
              //   width: double.infinity,
              //   child: ElevatedButton(
              //     onPressed: _showEditDialog,
              //     style: ElevatedButton.styleFrom(
              //         shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(5)
              //         ),
              //         backgroundColor: Colors.orange
              //     ), child: Text('Edit',style: TextStyle(color: Colors.white,fontSize: 20),),
              //   ),
              // ),

              // ElevatedButton(
              //   onPressed: _showEditDialog,
              //   child: Text('Edit'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
