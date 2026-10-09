
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_gao_delevery_partner/views/Orders/Orders.dart';
import 'package:food_gao_delevery_partner/views/PhoneAuth/Profile.dart';
import 'package:food_gao_delevery_partner/views/SumbitDocument/SumbitPage.dart';
import 'package:food_gao_delevery_partner/views/vehicle_screen/selectVehicle.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../NotificationPage/notifications/notifications.dart';
import 'DirectionAndDurationController/DirectionAndDurationController.dart';

class MapPage extends StatefulWidget {
  final double pickupLatitude;
  final double pickupLongitude;

  MapPage(
      {Key? key, required this.pickupLatitude, required this.pickupLongitude})
      : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController seconddesnationController =
  TextEditingController();
  final DirectionAndDurationController directionController =
  Get.put(DirectionAndDurationController());
  List<Prediction> _suggestions = [];
  Timer? _debounce;
  LatLng? _pickupLatLng;
  GoogleMapController? _mapController;
  Marker? _selectedLocationMarker;
  int _selectedIndex = 0;


  // Variables for user info
  String userName = '';
  String userImage = '';

  @override
  void initState(){
    super.initState();
    getAddress();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    try {
      // Get the current user ID
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        String userId = currentUser.uid;

        // Fetch user data from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('delivery')
            .doc(userId) // Use the current user ID to fetch data
            .get();

        if (userDoc.exists) {
          setState(() {
            userName = userDoc['name'] ?? 'Unknown';
            userImage = userDoc['imageUrl'] ?? '';
          });
        } else {
          // Handle case where user document does not exist
          print('User document does not exist.');
        }
      } else {
        // Handle case where there is no authenticated user
        print('No user is currently signed in.');
      }
    } catch (e) {
      print('Error fetching user info: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('FoodGaoMaps'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _pickupLatLng ??
                  LatLng(widget.pickupLatitude, widget.pickupLongitude),
              zoom: 14,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            markers: _selectedLocationMarker != null
                ? {_selectedLocationMarker!}
                : {},
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: buildSearchField(seconddesnationController,
                'Enter Pickup location', _onSearchTextChanged),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Expanded(child: _addressItemView(_suggestions, context)),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.delivery_dining), label: 'Delivery'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (context) => SelectVehiclePage(),));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => OrdersList(),));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(),));
        break;
    }
  }

  Widget buildSearchField(TextEditingController controller, String hintText,
      Function(String) onChanged) {
    return Container(
      height: 55,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Color(0xffF0F1F3),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.location_on, color: Colors.grey[700]),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () {
                      controller.clear();
                      setState(() {
                        _suggestions.clear();
                      });
                    },
                    icon: Icon(Icons.close),
                  ),
                  hintText: hintText,
                  hintStyle: TextStyle(color: Colors.grey[700], fontSize: 18),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addressItemView(List<Prediction> prediction, BuildContext context) {
    return prediction.isNotEmpty
        ? ListView.builder(
      shrinkWrap: true,
      itemCount: prediction.length,
      itemBuilder: (context, index) {
        var address = prediction[index].description ?? 'Unknown address';
        return InkWell(
          onTap: () async {
            var location = await getLatLngFromAddress(address);
            if (location.latitude != 0.0 && location.longitude != 0.0) {
              setState(() {
                _selectedLocationMarker = Marker(
                  markerId: MarkerId('selected-location'),
                  position: LatLng(location.latitude, location.longitude),
                  infoWindow: InfoWindow(title: address),
                );
                _mapController?.animateCamera(
                  CameraUpdate.newLatLng(
                      LatLng(location.latitude, location.longitude)),
                );
                seconddesnationController.text = address;
                _suggestions.clear();
              });
              directionController.pickup.value = address;
            }
          },
          child: ListTile(
            title: Text(address),
            trailing: Icon(Icons.favorite_border),
          ),
        );
      },
    )
        : Center(child: Text(''));
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children:[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.orange, // Set the header background color to orange
            ),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundImage: userImage.isNotEmpty
                      ? NetworkImage(userImage)
                      : AssetImage('assets/default_user_image.png') as ImageProvider,
                  radius: 50.0, // Adjust the radius as needed
                ),
                SizedBox(width: 16.0), // Add some space between the avatar and the text
                Text(
                  userName.isNotEmpty ? userName : 'User Name',
                  style: TextStyle(
                    color: Colors.white, // Text color
                    fontSize: 18.0, // Text size
                  ),
                ),
              ],
            ),
          ),

          ListTile(
            leading: Icon(Icons.verified),
            title: Text('Document'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SubmitDocumentPage(),));
            },
          ),
          ListTile(
            leading: Icon(Icons.notification_add),
            title: Text('Notifications'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Notification_Page(),));
              // Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationExample(),));
            },
          ),
        ],
      ),
    );
  }




  void _onSearchTextChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (text.isNotEmpty) {
        _fetchSuggestions(text);
      }
    });
  }

  void _fetchSuggestions(String input) async {
    final places =
    GoogleMapsPlaces(apiKey: 'AIzaSyCiJLymeCL0CTqTmcmPJ5T0lkLwA02OxWg');
    PlacesAutocompleteResponse response = await places.autocomplete(input);
    if (response.isOkay) {
      setState(() {
        _suggestions = response.predictions!;
      });
    } else {
      print('Error fetching suggestions: ${response.errorMessage}');
    }
  }

  Future<geocoding.Location> getLatLngFromAddress(String address) async {
    var location = await geocoding.locationFromAddress(address);
    return location.first;
  }


  Future<String> getAddressFromLatLong(
      {required double latitude, required double longitude}) async {
    List<geocoding.Placemark> placeMarks =
    await geocoding.placemarkFromCoordinates(latitude, longitude);
    geocoding.Placemark place = placeMarks[0];
    var address =
        '${place.locality}, ${place.administrativeArea}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.street}, ${place.name}, ${place.thoroughfare}, ${place.postalCode}';
    return address;
  }

  getAddress() async {
    var address = await getAddressFromLatLong(
        latitude: widget.pickupLatitude, longitude: widget.pickupLongitude);
    directionController.pickup.value = address;
  }
}