import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class OrderDetailsPage extends StatelessWidget {
  final String productName;
  final String userName;
  final String userPhone;
  final String userAddress;
  final String paymentMode;
  final double totalAmount;
  final String image;
  final String restaurantId;   // Added field to fetch restaurant details

  OrderDetailsPage({
    required this.productName,
    required this.userName,
    required this.userPhone,
    required this.userAddress,
    required this.paymentMode,
    required this.totalAmount,
    required this.image,
    required this.restaurantId, // Initialize restaurantId
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details',style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.orange,
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('restaurants').doc(restaurantId).get(),
        builder: (context, restaurantSnapshot) {
          if (restaurantSnapshot.connectionState == ConnectionState.waiting){

            return Center(child: CircularProgressIndicator());
          }

          if (restaurantSnapshot.hasError) {
            return Center(child: Text('Error fetching restaurant details.'));
          }

          if (!restaurantSnapshot.hasData || !restaurantSnapshot.data!.exists) {
            return Center(child: Text('Restaurant details not available.'));
          }

          var restaurantData = restaurantSnapshot.data!.data() as Map<String, dynamic>?;
          String restaurantName = restaurantData?['name'] ?? 'Unknown';
          String ownerName = restaurantData?['ownerName'] ?? 'Unknown';
          String location = restaurantData?['location'] ?? 'Unknown';
          String phoneNo = restaurantData?['phoneNo'] ?? 'Unknown';
          String imageUrl = restaurantData?['imageUrl'] ?? 'Unknown';


          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 5,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),

              child: Padding(
                padding: const EdgeInsets.all(16.0),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Text("Restaurant Name: $restaurantName"),
                    Text("Owner Name: $ownerName"),
                    Text("Location: $location"),
                    Text("Phone: $phoneNo"),
                    SizedBox(height: 16),
                    Divider(color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "Order Details",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (image.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          image,
                          width: screenSize.width * 0.8,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),

                    SizedBox(height: 8),
                    Text("Product Name: $productName", style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    Text("Customer: $userName", style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    Text("Phone No: $userPhone", style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    Text("Address: $userAddress", style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    Text("Payment Mode: $paymentMode", style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    Text("Price: ₹$totalAmount", style: TextStyle(fontSize: 18)),

                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
