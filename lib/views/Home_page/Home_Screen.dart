//
// import 'package:flutter/material.dart';
// import '../PhoneAuth/Profile.dart';
// import 'Select_Vehicle_Page.dart';
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   void _showSupportBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return Padding(
//           padding: const EdgeInsets.all(15.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Need help?',
//                     style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.close),
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               Divider(),
//               SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(Icons.call, color: Colors.green),
//                       SizedBox(width: 10),
//                       Text(
//                         'Call FoodGao Support',
//                         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                       ),
//                     ],
//                   ),
//                   Icon(Icons.arrow_forward),
//                 ],
//               ),
//               SizedBox(height: 10),
//               Padding(
//                 padding: const EdgeInsets.only(left: 40),
//                 child: Text(
//                   'Talk to our agent for help',
//                   style: TextStyle(fontSize: 13),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   void _showLogoutBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return Padding(
//           padding: const EdgeInsets.all(15.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'More options',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.close),
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               Divider(),
//               SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(Icons.logout, color: Colors.red),
//                       SizedBox(width: 10),
//                       Text(
//                         'Logout',
//                         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                       ),
//                     ],
//                   ),
//                   Icon(Icons.arrow_forward),
//                 ],
//               ),
//               SizedBox(height: 10),
//               Padding(
//                 padding: const EdgeInsets.only(left: 40),
//                 child: Text(
//                   'Your progress will be saved',
//                   style: TextStyle(fontSize: 13),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Image.network(
//             'https://s.cafebazaar.ir/images/upload/screenshot/com.application.zomato-50bbba73-9c0f-45f2-aeaf-3eb8a301e630.jpeg?x-img=v1/resize,h_600,lossless_false/optimize',
//             fit: BoxFit.cover,
//             width: double.infinity,
//             height: double.infinity,
//           ),
//           // Overlay content
//           Column(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(top: 50),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         _showSupportBottomSheet(context);
//                       },
//                       icon: Icon(Icons.call),
//                       label: Text('Help'),
//                     ),
//                     SizedBox(width: 10),
//                     PopupMenuButton<String>(
//                       color: Colors.white,
//                       onSelected: (value) {
//                         if (value == 'Logout') {
//                           _showLogoutBottomSheet(context);
//                         }
//                       },
//                       itemBuilder: (context) => [
//                         PopupMenuItem(
//                           value: 'Logout',
//                           child: Text('Logout'),
//                         ),
//                         PopupMenuItem(
//                           onTap: (){
//                             Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfilePage(),));
//                           },
//                           value: 'Profile',
//                           child: Text('Profile'),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: SizedBox(
//                     height: 50,
//                     width: double.infinity,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [Colors.black,Colors.orange, Colors.black,], // Multiple colors for gradient
//                           // begin: Alignment.topLeft,
//                           // end: Alignment.bottomRight,
//                         ),
//                         borderRadius: BorderRadius.circular(7),
//                       ),
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           elevation: 5, // Adds shadow for a raised effect
//                           backgroundColor: Colors.transparent, // Important to set the background to transparent
//                           shadowColor: Colors.transparent, // Removes the default shadow color to match the gradient
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(7),
//                           ),
//                         ),
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => SelectVehiclePage(),
//                             ),
//                           );
//                         },
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
//                           child: Text(
//                             'Next',
//                             style: TextStyle(
//                               fontSize: 22,
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     )
//
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }