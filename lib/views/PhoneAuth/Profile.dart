
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_gao_delevery_partner/views/PhoneAuth/Login.dart';
import 'package:food_gao_delevery_partner/views/PhoneAuth/mapPage/mapPage.dart';
import 'package:food_gao_delevery_partner/views/SumbitDocument/PanCardVerify/PanViewPage.dart';
import 'EditProfile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});


  @override
  _ProfilePageState createState() => _ProfilePageState();


}


class _ProfilePageState extends State<ProfilePage> {
  String name = '';
  String age = '';
  String gender = '';
  String address = '';
  String imageUrl = '';
  bool isLoading = true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    fetchCurrentUserData();
  }

  Future<void> fetchCurrentUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in')),
        );
      });
      return;
    }

    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('delivery')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data();

        setState(() {
          name = data?['name'] ?? '';
          age = data?['age'] ?? '';
          gender = data?['gender'] ?? '';
          address = data?['address'] ?? '';
          imageUrl = data?['imageUrl'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('User document not found for UID: ${user.uid}')),
          );
        });
      }
    }catch (error) {
      print('Error fetching user data: $error');
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching user data')),
        );
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Profile', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // _scaffoldKey.currentState!.openDrawer();
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MapPage(pickupLatitude: double.infinity, pickupLongitude: double.infinity),
                ));
          },
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'Edit':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditProfile(
                            initialName: name,
                            initialage: age,
                            initialgender: gender,
                            initialaddress: address,
                            initialImageUrl: imageUrl)),
                  );
                  break;
                case 'Document':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewPanCard(documentId: FirebaseAuth.instance.currentUser!.uid),
                    ),
                  );
                  break;
                case 'Logout':
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Logout"),
                        content: Text("Are you sure you want to logout?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              FirebaseAuth.instance.signOut();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => LoginPage()),
                              );
                            },
                            child: Text("Logout"),
                          ),
                        ],
                      );
                    },
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'Edit',
                  child: Text('Edit'),
                ),
                PopupMenuItem(
                  value: 'Logout',
                  child: Text('Logout'),
                ),
                PopupMenuItem(
                  value: 'Document',
                  child: Text('Document'),
                ),
              ];
            },
          )
        ],

      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
        color: Colors.white,
        width: double.infinity,
        height: screenHeight,
        child: Stack(
          children: [
            // Yellow container
            Container(
              width: double.infinity,
              height:
              screenHeight * 0.4, // Adjusted height using MediaQuery
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: screenHeight * 0.1, // Responsive radius
                    backgroundImage: imageUrl.isNotEmpty
                        ? NetworkImage(imageUrl)
                        : null,
                    backgroundColor: Colors.grey[300],
                    child: imageUrl.isEmpty
                        ? Icon(Icons.person,
                        size: screenHeight * 0.1,
                        color: Colors.grey[700])
                        : null,
                  ),
                  SizedBox(
                      height: screenHeight * 0.01), // Responsive spacing
                  Text(
                    "Profile",
                    style: TextStyle(
                      fontSize:
                      screenHeight * 0.03, // Responsive font size
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                      height: screenHeight * 0.01), // Responsive spacing
                ],
              ),
            ),
            // White container overlapping the yellow container
            Positioned(
              top: screenHeight *
                  0.35, // Adjusted position using MediaQuery
              left: 0,
              right: 0,
              child: Container(
                height: screenHeight *
                    0.6, // Adjusted height using MediaQuery
                padding: EdgeInsets.all(
                    screenWidth * 0.05), // Responsive padding
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(
                        height:
                        screenHeight * 0.02), // Responsive spacing
                    Text(
                      'Profile Details',
                      style: TextStyle(
                        fontSize:
                        screenHeight * 0.03, // Responsive font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                        height:
                        screenHeight * 0.03), // Responsive spacing
                    TextField(
                      controller: TextEditingController(text: name),
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      style: TextStyle(color: Colors.black),
                      onChanged: (value) {
                        setState(() {
                          name = value;
                        });
                      },
                      enabled: false,
                    ),
                    SizedBox(
                        height:
                        screenHeight * 0.02), // Responsive spacing
                    TextField(
                      controller: TextEditingController(text: age),
                      decoration: InputDecoration(
                        labelText: 'Age',
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      style: TextStyle(color: Colors.black),
                      onChanged: (value) {
                        setState(() {
                          age = value;
                        });
                      },
                      enabled: false,
                    ),
                    SizedBox(
                        height:
                        screenHeight * 0.02), // Responsive spacing
                    TextField(
                      controller: TextEditingController(text: gender),
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      style: TextStyle(color: Colors.black),
                      onChanged: (value) {
                        setState(() {
                          gender = value;
                        });
                      },
                      enabled: false,
                    ),
                    SizedBox(
                        height:
                        screenHeight * 0.02), // Responsive spacing
                    TextField(
                      controller: TextEditingController(text: address),
                      decoration: InputDecoration(
                        labelText: 'Address',
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      style: TextStyle(color: Colors.black),
                      onChanged: (value) {
                        setState(() {
                          address = value;
                        });
                      },
                      enabled: false,
                    ),
                    SizedBox(
                        height:
                        screenHeight * 0.05), // Responsive spacing
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
