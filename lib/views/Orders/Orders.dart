
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

import '../OrderDetails/OrderDetails.dart';

class OrdersList extends StatelessWidget {
  var uid = FirebaseAuth.instance.currentUser?.uid ?? "";

  // Function to send notification using FCM token
  Future<void> _sendNotificationToSeller(String fcmToken, String orderId) async {
    try {
      const String serverKey = 'AAAA3eLhBAM:APA91bE7UZqtlN32Xu13A58GaOZVc3CU984i5bCYoagstTWVn8xxHH3eVjFjr6eCGCC4k0qvAcoqP9K83uR3_wtpKIxA7O1S0Y35hGCuHsO21TNfxfeD-oZnAqbbv9g6d-F6Sc-0wjQi'; // Add your server key
      const String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

      final notification = {
        'to': fcmToken,
        'notification': {
          'title': 'Order Accepted',
          'body': 'Your order $orderId has been accepted!',
        },
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'order_id': orderId,
        },
      };

      await http.post(
        Uri.parse(fcmUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode(notification),
      );
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // Function to update order status and notify the seller
  Future<void> _updateOrderStatus(
      String orderId, String driverId, String status) async {
    try {
      var updateData = {'status': status, 'delivery_boys': [uid]};

      if (status == 'Delivered') {
        updateData['delivery_boy_request_status'] = "true";
      }

      // Update order status in Firestore
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update(updateData);

      // Fetch seller's FCM token from Firestore
      DocumentSnapshot sellerDoc = await FirebaseFirestore.instance
          .collection('delivery')
          .doc(driverId)
          .get();
      var sellerData = sellerDoc.data() as Map<String, dynamic>;
      String fcmToken = sellerData['fcmToken'] ?? '';

      // Send notification to the seller if the FCM token is available
      if (fcmToken.isNotEmpty) {
        _sendNotificationToSeller(fcmToken, orderId);
      }
    } catch (e) {
      print('Error updating order status or sending notification: $e');
    }
  }


  // Function to show confirmation dialog before accepting an order
  Future<void> _showConfirmationDialog(
      BuildContext context, String orderId, String driverId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Action'),
          content: Text('Are you sure you want to accept this order?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                _updateOrderStatus(orderId, driverId, 'Delivered');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Orders List', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where("delivery_boys", arrayContains: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No orders available.',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data?.docs.length ?? 0,
            itemBuilder: (context, index) {
              var orderData = snapshot.data!.docs[index];
              var data = orderData.data() as Map<String, dynamic>;
              String productName = data.containsKey('name') ? data['name'] : '';
              String userAddress =
              data.containsKey('address') ? data['address'] : '';
              String userPhone = data.containsKey('phone') ? data['phone'] : '';
              String userName = data.containsKey('userName') ? data['userName'] : '';
              String image = data.containsKey('image') ? data['image'] : '';
              String orderStatus =
              data.containsKey('status') ? data['status'] : 'Pending';
              double totalAmount = double.tryParse(
                  data.containsKey('totalPrice') ? data['totalPrice'] : '0.0') ?? 0.0;
              String paymentMode = data.containsKey('paymentMethod')
                  ? data['paymentMethod']
                  : 'COD';
              Timestamp orderTime =
              data.containsKey('orderTime') ? data['orderTime'] : Timestamp.now();
              DateTime orderDateTime = orderTime.toDate();
              String orderId = orderData.id;

              String restaurantId =
              data.containsKey('restaurantId') ? data['restaurantId'] : '';

              if (restaurantId.isNotEmpty) {
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('restaurants')
                      .doc(restaurantId)
                      .get(),
                  builder: (context, restaurantSnapshot) {
                    if (restaurantSnapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox();
                    }

                    if (!restaurantSnapshot.hasData ||
                        !restaurantSnapshot.data!.exists) {
                      return Center(child: Text('Restaurant details not available.'));
                    }

                    var restaurantData =
                    restaurantSnapshot.data!.data() as Map<String, dynamic>;

                    return GestureDetector(  // Make entire card clickable
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailsPage(
                              productName: productName,
                              userName: userName,
                              userPhone: userPhone,
                              userAddress: userAddress,
                              paymentMode: paymentMode,
                              totalAmount: totalAmount,
                              image: image,
                              restaurantId: restaurantId,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 10,
                        color: Colors.white,
                        shadowColor: Colors.black,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (image.isNotEmpty)
                                    ClipOval(
                                      child: Image.network(
                                        image,
                                        width: screenSize.width * 0.3,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  SizedBox(width: 10),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Product Name: $productName"),
                                        Text("Customer: $userName"),
                                        Text("Phone No: $userPhone"),
                                        Text("Address: $userAddress"),
                                        Text("Payment Mode: $paymentMode"),
                                        Text("Price: ₹$totalAmount"),
                                        Text("Order Status: $orderStatus")
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (orderStatus != 'Delivered')
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton(
                                    onPressed: () {
                                      _showConfirmationDialog(context, orderId, restaurantId);
                                    },
                                    child: Text('Accept Order'),
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }

              return const SizedBox();
            },
          );
        },
      ),
    );
  }
}