import 'package:flutter/material.dart';
import 'package:food_gao_delevery_partner/views/vehicle_screen/Motocycle.dart';
import 'Electric_vehicle.dart';

class SelectVehiclePage extends StatefulWidget {
  const SelectVehiclePage({super.key});

  @override
  State<SelectVehiclePage> createState() => _SelectVehiclePage();
}

class _SelectVehiclePage extends State<SelectVehiclePage> {
  String? _selectedVehicle;

  void _showSupportBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Need help?',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.call, color: Colors.green),
                      SizedBox(width: 10),
                      Text(
                        'Call Foodgao Support',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_forward),
                ],
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Text(
                  'Talk to our agent for help',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Close',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'More options',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 10),
                      Text(
                        'Logout',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_forward),
                ],
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Text(
                  'Your progress will be saved',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Close',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecting Vehicle'),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              _showSupportBottomSheet(context);
            },
            icon: Icon(Icons.call),
            label: Text('Help'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
          ),
          PopupMenuButton<String>(
            color: Colors.white,
            onSelected: (value) {
              if (value == 'Logout') {
                _showLogoutBottomSheet(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'Logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/images22.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Column(
            children: [
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(

                                '------- CHOOSE VEHICLE -------',
                                style: TextStyle(fontSize: 12,color: Colors.orange),
                              ),
                            ),
                            SizedBox(height: 10),
                            ListTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Motorcycle/Scooty(MS)'),
                                  Radio<String>(
                                    value: 'Motorcycle/Scooty',
                                    groupValue: _selectedVehicle,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedVehicle = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Divider(),
                            ListTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Electric Vehicle(EV)'),
                                  Radio<String>(
                                    value: 'Electric Vehicle(EV)',
                                    groupValue: _selectedVehicle,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedVehicle = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            backgroundColor: Colors.orange
                        ),
                        onPressed: _selectedVehicle == null
                            ? null
                            : () {
                          if (_selectedVehicle == 'Motorcycle/Scooty') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MotocycleScooty(),),
                            );
                          } else if (_selectedVehicle == 'Electric Vehicle(EV)') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VehicleScreen(),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Next',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}