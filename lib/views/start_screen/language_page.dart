import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:food_gao_delevery_partner/views/start_screen/start_page.dart';
import '../../controllers/longuage_change_controller.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  int _selectedLanguage = 1;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.1, left: screenWidth * 0.25),
                child: Text(
                  AppLocalizations.of(context)?.selectlanguage ?? 'Select Language',
                  style: TextStyle(fontSize: screenHeight * 0.035, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.25),
                child: Text(
                  AppLocalizations.of(context)?.selectonefrombelow ?? 'Select one from below',
                  style: TextStyle(fontSize: screenHeight * 0.025, fontWeight: FontWeight.w500, color: Colors.grey),
                ),
              ),
            ],
          ),
          Positioned(
            top: screenHeight * 0.25,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.0),
                child: Container(
                  width: screenWidth * 0.8, // Set the desired width
                  // Height can be adjusted as needed
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(screenHeight * 0.01),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildLanguageOption(1, 'English', TextStyle(fontSize: screenHeight * 0.03, fontWeight: FontWeight.bold), screenHeight),
                              ),
                              SizedBox(width: screenWidth * 0.04),
                              Expanded(
                                child: _buildLanguageOption(2, 'हिंदी', TextStyle(fontSize: screenHeight * 0.03, fontWeight: FontWeight.bold), screenHeight),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.025),
                          Row(
                            children: [
                              Expanded(
                                child: _buildLanguageOption(3, 'తెలుగు', TextStyle(fontSize: screenHeight * 0.025), screenHeight),
                              ),
                              SizedBox(width: screenWidth * 0.04),
                              Expanded(
                                child: _buildLanguageOption(4, 'ಕನ್ನಡ', TextStyle(fontSize: screenHeight * 0.025), screenHeight),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.025),
                          Row(
                            children: [
                              Expanded(
                                child: _buildLanguageOption(5, 'தமிழ்', TextStyle(fontSize: screenHeight * 0.025), screenHeight),
                              ),
                              SizedBox(width: screenWidth * 0.04),
                              Expanded(
                                child: _buildLanguageOption(6, 'മലയാളം', TextStyle(fontSize: screenHeight * 0.025), screenHeight),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.025),
                          Row(
                            children: [
                              Expanded(
                                child: _buildLanguageOption(7, 'বাংলা', TextStyle(fontSize: screenHeight * 0.025), screenHeight),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(screenHeight * 0.02),
              child: SizedBox(
                height: screenHeight * 0.07,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _changeLanguage();
                    print('Selected language: $_selectedLanguage');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => StartPage()),
                    );
                  },
                  child: Text('Proceed', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(int value, String label, TextStyle style, double screenHeight) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = value;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectedLanguage == value ? Colors.green : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(screenHeight * 0.01),
        height: screenHeight * 0.1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: style),
            Container(
              width: screenHeight * 0.03,
              height: screenHeight * 0.03,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _selectedLanguage == value ? Colors.green : Colors.grey,
                ),
              ),
              child: _selectedLanguage == value
                  ? Center(
                child: Container(
                  width: screenHeight * 0.015,
                  height: screenHeight * 0.015,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                ),
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _changeLanguage() {
    final languageProvider = Provider.of<LanguageChangeController>(context, listen: false);
    languageProvider.changeLanguageByIndex(_selectedLanguage);
  }
}