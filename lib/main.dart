import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:food_gao_delevery_partner/views/NotificationPage/localNotification/localNotification.dart';
import 'package:food_gao_delevery_partner/views/PhoneAuth/splesh.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controllers/longuage_change_controller.dart';
import 'firebase_options.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  print(message.data.toString());
  print(message.notification!.title);
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences sp = await SharedPreferences.getInstance();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

  LocalNotificationService.initLocalNotification();

  final String languageCode = sp.getString('language_code') ?? 'en';
  runApp(MyApp(locale: languageCode));


}

class MyApp extends StatefulWidget {
  final String locale;
  const MyApp({super.key, required this.locale});
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = Locale(widget.locale);
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LanguageChangeController(),
        ),
      ],
      child: Consumer<LanguageChangeController>(
        builder: (context, provider, child) {

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: provider.appLocale ?? _locale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate
            ],
            supportedLocales: [
              Locale('en'),
              Locale('hi'),
              Locale('te'),
              Locale('kn'),
              Locale('ta'),
              Locale('ml'),
              Locale('bn'),
            ],
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
            ),
            home: SpleshPage(),
          );
        },
      ),
    );
  }
}