import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AadhaarVerification extends StatefulWidget {
  const AadhaarVerification({super.key, required String aadhaarNumber});

  @override
  State<AadhaarVerification> createState() => _AadhaarVerification();
}

class _AadhaarVerification extends State<AadhaarVerification> {
  bool _isSelected = false;
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  void _toggleSelection() {
    setState(() {
      _isSelected = !_isSelected;
    });
  }

  @override
  void dispose() {
    _aadharController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Aadhaar Verification'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            children: [
              Center(
                child: GestureDetector(
                  onTap: _toggleSelection,
                  child: CircleAvatar(
                    radius: screenWidth * 0.25,
                    backgroundColor: _isSelected ? Colors.blue : Colors.grey,
                    child: CircleAvatar(
                      radius: screenWidth * 0.25,
                      backgroundImage: NetworkImage(
                          "https://5.imimg.com/data5/SELLER/Default/2022/9/ZK/CB/SF/4910836/aadhar-card-software-500x500.png"),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Text(
                "Enter Aadhar details for verification",
                style: TextStyle(fontSize: screenWidth * 0.040),
              ),
              SizedBox(height: screenHeight * 0.0),
              Padding(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aadhar number',
                      style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.orange),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    TextField(
                      controller: _aadharController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter Your 12-digit Aadhar number',
                        suffixIcon: _aadharController.text.isEmpty
                            ? null
                            : IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            _aadharController.clear();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.0),
              Padding(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.00),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OTP',
                      style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.orange),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter OTP',
                        suffixIcon: _otpController.text.isEmpty
                            ? null
                            : IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            _otpController.clear();
                          },
                        ),
                      ),
                      inputFormatters: [AadharInputFormatter()],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      'OTP sent to Aadhar-linked mobile number.',
                      style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              SizedBox(
                height: screenHeight * 0.07,
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                    'Complete Aadhar OTP Verification',
                    style: TextStyle(color: Colors.orange, fontSize: screenWidth * 0.045),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.03),
                child: Text(
                  '''Zomato does not collect or store any Aadhaar information. We assure Real-time ID verification & 100% security with 256-bit encryption. By clicking on Send OTP, you consent to sharing your Aadhaar details with Surepass for offline verification purposes and agree to the''',
                  style: TextStyle(fontSize: screenWidth * 0.03),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Center(
                child: Text(
                  '"terms and conditions"',
                  style: TextStyle(color: Colors.orange, fontSize: screenWidth * 0.035),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AadharInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    final newText = text.replaceAll(' ', '');
    String formatted = '';

    for (int i = 0; i < newText.length; i++) {
      formatted += newText[i];
      if ((i + 1) % 4 == 0 && i + 1 != newText.length) {
        formatted += ' ';
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: newValue.selection.copyWith(
        baseOffset: formatted.length,
        extentOffset: formatted.length,
      ),
    );
  }
}



//map page

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:food_gao_delevery_partner/views/Home_page/submit_document.dart';
// import 'package:geocoding/geocoding.dart' as geocoding;
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_webservice/places.dart';
// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../Delivery/DeliveryPage.dart';
// import '../Profile.dart';
// import 'DirectionAndDurationController/DirectionAndDurationController.dart';
//
// class MapPage extends StatefulWidget {
//   final double pickupLatitude;
//   final double pickupLongitude;
//
//   MapPage({Key? key, required this.pickupLatitude, required this.pickupLongitude})
//       : super(key: key);
//
//   @override
//   State<MapPage> createState() => _MapPageState();
// }
//
// class _MapPageState extends State<MapPage> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   final TextEditingController seconddesnationController = TextEditingController();
//   final DirectionAndDurationController directionController = Get.put(DirectionAndDurationController());
//   List<Prediction> _suggestions = [];
//   Timer? _debounce;
//   LatLng? _pickupLatLng;
//   GoogleMapController? _mapController;
//   Marker? _selectedLocationMarker;
//   int _selectedIndex = 0;
//   final PageController _pageController = PageController();
//
//   String userName = '';
//   String userImage = '';
//
//   @override
//   void initState() {
//     super.initState();
//     getAddress();
//     fetchUserInfo();
//   }
//
//   Future<void> fetchUserInfo() async {
//     try {
//       User? currentUser = FirebaseAuth.instance.currentUser;
//       if (currentUser != null) {
//         String userId = currentUser.uid;
//         DocumentSnapshot userDoc = await FirebaseFirestore.instance
//             .collection('delivery')
//             .doc(userId)
//             .get();
//
//         if (userDoc.exists) {
//           setState(() {
//             userName = userDoc['name'] ?? 'Unknown';
//             userImage = userDoc['imageUrl'] ?? '';
//           });
//         } else {
//           print('User document does not exist.');
//         }
//       } else {
//         print('No user is currently signed in.');
//       }
//     } catch (e) {
//       print('Error fetching user info: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: AppBar(
//         // title: Text('FoodGaoMaps'),
//         backgroundColor: Colors.orange,
//         leading: _selectedIndex == 0
//             ? IconButton(
//           icon: Icon(Icons.menu),
//           onPressed: () {
//             _scaffoldKey.currentState?.openDrawer();
//           },
//         )
//             : null,
//       ),
//       drawer: _selectedIndex == 0 ? _buildDrawer() : null,
//       body: Stack(
//         children: [
//           PageView(
//             controller: _pageController,
//             onPageChanged: (index) {
//               setState(() {
//                 _selectedIndex = index;
//               });
//             },
//             children: [
//               GoogleMap(
//                 initialCameraPosition: CameraPosition(
//                   target: _pickupLatLng ?? LatLng(widget.pickupLatitude, widget.pickupLongitude),
//                   zoom: 14,
//                 ),
//                 onMapCreated: (controller) {
//                   _mapController = controller;
//                 },
//                 markers: _selectedLocationMarker != null ? {_selectedLocationMarker!} : {},
//               ),
//               Deliverypage(),
//               SubmitDocumentPage(),
//               ProfilePage(),
//             ],
//           ),
//           _selectedIndex == 0
//               ? Positioned(
//             top: 10,
//             left: 10,
//             right: 10,
//             child: buildSearchField(seconddesnationController, 'Enter Pickup location', _onSearchTextChanged),
//           )
//               : SizedBox.shrink(),
//           _selectedIndex == 0
//               ? Positioned(
//             bottom: 10,
//             left: 10,
//             right: 10,
//             child: _addressItemView(_suggestions, context),
//           )
//               : SizedBox.shrink(),
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: (index) {
//           _pageController.jumpToPage(index);
//         },
//         backgroundColor: Colors.orange,
//         selectedItemColor: Colors.white,
//         unselectedItemColor: Colors.black,
//         type: BottomNavigationBarType.fixed,
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.delivery_dining),
//             label: 'Delivery',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.document_scanner),
//             label: 'Document',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }
//
//
//   Widget buildSearchField(TextEditingController controller, String hintText, Function(String) onChanged) {
//     return Container(
//       height: 55,
//       width: double.infinity,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8.0),
//         color: Color(0xffF0F1F3),
//       ),
//       child: Row(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Icon(Icons.location_on, color: Colors.grey[700]),
//           ),
//           Expanded(
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 8.0),
//               child: TextField(
//                 controller: controller,
//                 onChanged: onChanged,
//                 decoration: InputDecoration(
//                   suffixIcon: IconButton(
//                     onPressed: () {
//                       controller.clear();
//                       setState(() {
//                         _suggestions.clear();
//                       });
//                     },
//                     icon: Icon(Icons.close),
//                   ),
//                   hintText: hintText,
//                   hintStyle: TextStyle(color: Colors.grey[700], fontSize: 18),
//                   border: InputBorder.none,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _addressItemView(List<Prediction> predictions, BuildContext context) {
//     return predictions.isNotEmpty
//         ? ListView.builder(
//       shrinkWrap: true,
//       itemCount: predictions.length,
//       itemBuilder: (context, index) {
//         var address = predictions[index].description ?? 'Unknown address';
//         return InkWell(
//           onTap: () async {
//             var location = await getLatLngFromAddress(address);
//             if (location.latitude != 0.0 && location.longitude != 0.0) {
//               setState(() {
//                 _selectedLocationMarker = Marker(
//                   markerId: MarkerId('selected-location'),
//                   position: LatLng(location.latitude, location.longitude),
//                   infoWindow: InfoWindow(title: address),
//                 );
//                 _mapController?.animateCamera(
//                   CameraUpdate.newLatLng(LatLng(location.latitude, location.longitude)),
//                 );
//                 seconddesnationController.text = address;
//                 _suggestions.clear();
//               });
//               directionController.pickup.value = address;
//             }
//           },
//           child: ListTile(
//             title: Text(address),
//             trailing: Icon(Icons.favorite_border),
//           ),
//         );
//       },
//     )
//         : Center(child: Text('No suggestions'));
//   }
//
//   Widget _buildDrawer() {
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           DrawerHeader(
//             decoration: BoxDecoration(
//               color: Colors.orange,
//             ),
//             child: Column(
//               children: [
//                 CircleAvatar(
//                   backgroundImage: userImage.isNotEmpty
//                       ? NetworkImage(userImage)
//                       : AssetImage('assets/default_user_image.png') as ImageProvider,
//                   radius: 50.0,
//                 ),
//                 SizedBox(width: 16.0),
//                 Text(
//                   userName.isNotEmpty ? userName : 'User Name',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18.0,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _onSearchTextChanged(String text) {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();
//     _debounce = Timer(const Duration(milliseconds: 500), () {
//       if (text.isNotEmpty) {
//         _fetchSuggestions(text);
//       }
//     });
//   }
//
//   void _fetchSuggestions(String input) async {
//     final places = GoogleMapsPlaces(apiKey: 'YOUR_API_KEY');
//     PlacesAutocompleteResponse response = await places.autocomplete(input);
//     if (response.isOkay) {
//       setState(() {
//         _suggestions = response.predictions!;
//       });
//     } else {
//       print('Error fetching suggestions: ${response.errorMessage}');
//     }
//   }
//
//   Future<geocoding.Location> getLatLngFromAddress(String address) async {
//     var location = await geocoding.locationFromAddress(address);
//     return location.first;
//   }
//
//   Future<String> getAddressFromLatLong({required double latitude, required double longitude}) async {
//     List<geocoding.Placemark> placeMarks = await geocoding.placemarkFromCoordinates(latitude, longitude);
//     geocoding.Placemark place = placeMarks[0];
//     var address = '${place.locality}, ${place.administrativeArea}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.street}, ${place.name}, ${place.thoroughfare}, ${place.postalCode}';
//     return address;
//   }
//
//   getAddress() async {
//     var address = await getAddressFromLatLong(latitude: widget.pickupLatitude, longitude: widget.pickupLongitude);
//     directionController.pickup.value = address;
//   }
// }