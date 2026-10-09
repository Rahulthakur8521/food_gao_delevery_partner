import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageChangeController with ChangeNotifier {
  Locale? _appLocale;
  Locale? get appLocale => _appLocale;

  LanguageChangeController() {
    _loadLocale();
  }

  void changeLanguage(Locale type) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString('language_code', type.languageCode);
    _appLocale = type;
    notifyListeners();
  }


  Future<void> _loadLocale() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? languageCode = sp.getString('language_code');

    if (languageCode == null || languageCode.isEmpty) {
      _appLocale = Locale('en');
    } else {
      _appLocale = Locale(languageCode);
    }

    notifyListeners();
  }

  void changeLanguageByIndex(int index) {
    switch (index) {
      case 1:
        changeLanguage(Locale('en'));
        break;
      case 2:
        changeLanguage(Locale('hi'));
        break;
      case 3:
        changeLanguage(Locale('te'));
        break;
      case 4:
        changeLanguage(Locale('kn'));
        break;
      case 5:
        changeLanguage(Locale('ta'));
        break;
      case 6:
        changeLanguage(Locale('ml'));
        break;
      case 7:
        changeLanguage(Locale('bn'));
        break;
      default:
        changeLanguage(Locale('en'));
    }
  }
}
